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
        lappend codeLines "print('#### DONE ####')"
        close $fileId
        return $codeLines
    }
    proc piperead {pipe} {
        variable res
        variable dict
        if {![eof $pipe]} {
            set outline [gets $pipe]
            if {$outline ne ""} {
                if {[regexp "^\[> \]*#### DONE" $outline]} {
                    incr ::tmdoc::chunkd
                    after [dict get $dict wait] [list  append ::tmdoc::pipedone "."]
                } else {
                    set outline [regsub {^.*>>> ?} $outline ""]
                    append res "$outline\n"
                }
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
            #if {[dict get $dict terminal]} {
            #    if {[regexp {^  } $line] || [regexp  {^ *$} $line]} {
            #        append res "... $line\n"
            #    } elseif {![regexp {#### DONE} $line]} {
            #        append res ">>> $line\n"
            #    }
            #}
            puts $pipe "$line"
        }
        #puts $pipe "#### DONE ####"
        flush $pipe
        vwait ::tmdoc::pipedone
        ## skip last empty line ... \n
        #if {[dict get $dict terminal]} {
        #    set res "[string range $res 0 end-5]\n"
        #}
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
                 include true terminal true wait 50]
        set dict [dict merge $def $cdict]
        
        set codeLines [list]
        foreach line [split $cnt \n] {
            lappend codeLines $line
        }
        lappend codeLines "print('#### DONE ####')"
        if {[dict get $dict eval]} {
            set res [pipestart $codeLines]
        } 
        set nres ""
        foreach line [split $res "\n"] {
            set line [regsub { +$} $line ""]
            if {![regexp "#### DONE" $line]} {
                append nres "$line\n"
            }
        }
        set res $nres
        #set res [string trim [regsub {>>> >>> } [regsub {>>> >>> >>> } $res ""] ""]]
        #set res [string trim [regsub {>?>?>? ?\.\.\. \.\.\. >>> } $res ""]]
        #set res [regsub {\n\.\.\.$} $res ""]
        return [list [string trim $res] ""]
    }

}


