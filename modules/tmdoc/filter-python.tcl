#!/usr/bin/env tclsh
# Open the Python code file and read lines
#if {[llength $argv] < 1} {
#    puts "Usage: [info script] pyfile.py"
#    exit 0
#}

namespace eval tmdoc { }
namespace eval tmdoc::python { 
    variable pipe 
    variable res
    set pipe ""
    set res ""
    variable dict
    # Open a pipe to Python interpreter for reading and writing
    proc getCode {filename} {
        set fileId [open $filename r]
        set codeLines [list]
        while {[gets $fileId line] >= 0} {
            lappend codeLines $line
        }
        close $fileId
        return $codeLines
    }
    proc piperead {pipe} {
        variable res
        if {![eof $pipe]} {
            set outline [gets $pipe]
            if {$outline ne ""} {
                #puts "$outline"
                append res "$outline\n"
            }
        } else {
            close $pipe
            set ::filter-python::pipe ""
        }
    }
    proc pipestart {codeLines} {
        variable pipe
        variable res
        variable dict
        set res ""
        if {$pipe eq ""} {
            set pipe [open "|python3 -qui 2>@1" r+]
            fconfigure $pipe -buffering line -blocking 0
            fileevent $pipe readable [list ::tmdoc::python::piperead $pipe]
            set res ""
        }
        foreach line $codeLines {
            if {[dict get $dict terminal]} {
                if {[regexp {^  } $line] || [regexp  {^ *$} $line]} {
                    append res "... $line\n"
                } else {
                    append res ">>> $line\n"
                }
            }
            puts $pipe "$line"
            flush $pipe
            after 100 [list append wait ""]
            vwait wait
        }
        ## skip last empty line ... \n
        if {[dict get $dict terminal]} {
            set res "[string range $res 0 end-5]\n"
        }
        return $res
    }
    proc start {filename} {
        set codeLines [getCode $filename]
        pipestart $codeLines
        # Write the code lines to Python's stdin through the pipe
    }
    proc filter {cnt cdict} {
        variable dict
        set res ""
        set def [dict create results show eval false label null \
                 include true terminal true wait 100]
        set dict [dict merge $def $cdict]
        
        set codeLines [list]
        foreach line [split $cnt \n] {
            lappend codeLines $line
        }
        if {[dict get $dict eval]} {
            set res [pipestart $codeLines]
        } 
        set res [regsub -all {(>>> >>>|>>> >>> >>>)} $res {>>>}]
        return [list $res ""]
    }

}

#set file [open [lindex $argv 0] r]
#set cnt [read $file]
#close $file
#set res [filter-py $cnt [list eval true]]
#puts [lindex $res 0]
# pypipe::start [lindex $argv 0]
#close $pipe

