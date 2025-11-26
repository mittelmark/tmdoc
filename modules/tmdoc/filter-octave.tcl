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
    variable done
    variable show
    set show true
    set done [list]
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
        variable done
        variable dict
        variable show
        if {![eof $pipe]} {
            set outline [gets $pipe]
            if {[regexp "^\[> \]*#### DONE" $outline]} {
                puts $pipe "fflush(stdout)"
                after [dict get $dict wait] [list  append ::tmdoc::pipedone "."]
            } elseif {[regexp ".*#### SHOW OFF" $outline]} {
                puts stderr "show off"
                set show false
            } elseif {[regexp ".*#### SHOW ON" $outline]} {
                set show true
            } elseif {$outline ne "" && $show && ![regexp {Gtk-WARNING} $outline] && ![regexp octave:1 $outline] && ![regexp {ans = 0} $outline]}  {
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
        set mshow true
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
            puts $pipe "disp(\"#### DONE ####\");"
            flush $pipe
            vwait ::tmdoc::pipedone
        }
        foreach line $codeLines {
            if {[dict get $dict terminal]} {
                if {[regexp {^ *[^\s]} $line] || [regexp  {^ *$} $line]} {
                    append res "> $line\n"
                } else {
                    if {[regexp {#### SHOW OFF} $line]} {
                        puts stderr $line
                        set mshow false
                    } elseif {[regexp {#### SHOW ON} $line]} {
                        set mshow true
                    } elseif {$mshow && ![regexp {.+#### SHOW.+} $line]} {
                        append res "octave> $line\n"
                    }
                }
            }
            puts $pipe "$line"
            flush $pipe
            if {![regexp {^[\s]*$} $line]} {
                puts $pipe "disp(\"#### DONE ####\");"
                flush $pipe
                vwait ::tmdoc::pipedone
            }
        }
        puts $pipe "disp(\"#### DONE ####\");"
        flush $pipe
        vwait ::tmdoc::pipedone

        ## skip last empty line > \n
        if {[dict get $dict terminal]} {
            set res "[string range $res 0 end-4]\n"
        }
        return $res
    }
    proc start {filename} {
        set codeLines [getCode $filename]
        pipestart $codeLines
    }
    proc filter {cnt cdict} {
        variable dict
        set res ""
        set def [dict create results show eval true label null ext png \
                 include true terminal true wait 300 fig false \
                 fig.width 600 fig.height 600]
        set dict [dict merge $def $cdict]
        if {[dict get $dict fig.width] == 0} {
            if {[dict get $dict ext] in [list png svg]} {
                dict set dict fig.width 600
            } else {
                dict set dict fig.width 600
            }
        }
        if {[dict get $dict fig.height] == 0} {
            dict set dict fig.height [dict get $dict fig.width]
        }
        if  {[dict get $dict fig]} {
            set codeLines [list "disp(\"#### SHOW OFF ####\");" "aux = figure('visible','off');" "disp(\"#### SHOW ON ####\");"]
        } else {
            set codeLines [list]
        }
        foreach line [split $cnt \n] {
            lappend codeLines $line
        }
        if  {[dict get $dict fig]} {
            lappend codeLines "disp(\"#### SHOW OFF ####\");"
            lappend codeLines "print(aux,'[dict get $dict label].[dict get $dict ext]','-d[dict get $dict ext]','-S[dict get $dict fig.width],[dict get $dict fig.height]');"
            lappend codeLines "disp(\"#### SHOW ON ####\");"
        }
        if {[dict get $dict eval]} {
            set res [pipestart $codeLines]
        } 
        set img ""
        if {[dict get $dict fig]} {
            set img "[dict get $dict label].[dict get $dict ext]"
        }
        set res [string trim $res]
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

