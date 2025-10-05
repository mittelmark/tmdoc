#!/usr/bin/env tclsh
# Open the Python code file and read lines
#if {[llength $argv] < 1} {
#    puts "Usage: [info script] pyfile.py"
#    exit 0
#}

namespace eval tmdoc { }
namespace eval tmdoc::octave { 
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
            if {$outline ne "" && ![regexp {Gtk-WARNING} $outline] && ![regexp octave:1 $outline] && ![regexp {ans = 0} $outline]}  {
                append res "$outline\n"
                puts $pipe "fflush(stdout)"
            }
        } else {
            close $pipe
            set ::tmdoc::octave::pipe ""
        }
    }
    proc pipestart {codeLines} {
        variable pipe
        variable res
        variable dict
        set res ""
        if {$pipe eq ""} {
            set res ""
            set pipe [open "|octave --interactive --no-gui --norc --silent 2>@1" r+]
            fconfigure $::tmdoc::octave::pipe -buffering none -blocking false
            fileevent $::tmdoc::octave::pipe readable [list ::tmdoc::octave::piperead $pipe]
            puts $pipe {PS1("")}
            puts $pipe "page_screen_output(1);"
            puts $pipe "page_output_immediately(1);"
            puts $pipe "fflush(stdout)"
            flush $pipe
            after [dict get $dict wait] [list append wait ""]
            vwait wait
            #set ::fpipe::pipecode ""
        }
        if  {[dict get $dict fig]} {
            puts $pipe "aux = figure('visible','off');"
            flush $pipe
            after [dict get $dict wait] [list append wait ""]
            vwait wait
        }
        foreach line $codeLines {
            if {[dict get $dict terminal]} {
                if {[regexp {^  } $line] || [regexp  {^ *$} $line]} {
                    append res "> $line\n"
                } else {
                    append res "octave> $line\n"
                }
            }
            puts $pipe "$line"
            flush $pipe
            after 100 [list append wait ""]
            vwait wait
        }
        ## skip last empty line > \n
        if {[dict get $dict terminal]} {
            set res "[string range $res 0 end-4]\n"
        }
        if {[dict get $dict fig]} {
            puts $pipe "print(aux,'[dict get $dict label].[dict get $dict ext]','-d[dict get $dict ext]','-S[dict get $dict fig.width],[dict get $dict fig.height]');"
            flush $pipe
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
        set def [dict create results show eval true label null ext png \
                 include true terminal true wait 300 fig false \
                 fig.width 600 fig.height 600]
        set dict [dict merge $def $cdict]
        
        set codeLines [list]
        foreach line [split $cnt \n] {
            lappend codeLines $line
        }
        if {[dict get $dict eval]} {
            set res [pipestart $codeLines]
        } 
        set img ""
        if {[dict get $dict fig]} {
            set img "[dict get $dict label].[dict get $dict ext]"
        }

        return [list $res $img]
    }

}

#set file [open [lindex $argv 0] r]
#set cnt [read $file]
#close $file
#set res [filter-py $cnt [list eval true]]
#puts [lindex $res 0]
# pypipe::start [lindex $argv 0]
#close $pipe

