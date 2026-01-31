#!/usr/bin/env tclsh
# Open the Python code file and read lines
#if {[llength $argv] < 1} {
#    puts "Usage: [info script] pyfile.py"
#    exit 0
#}

namespace eval tmdoc { }
namespace eval tmdoc::julia { 
    variable pipe 
    variable res
    set pipe ""
    set res ""
    variable dict
    variable done
    set done [list]
    # Open a pipe to Julia interpreter for reading and writing
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
        if {![eof $pipe]} {
            set outline [gets $pipe]
            if {$outline eq "### DONE"} {
                lappend done ""
            } elseif {$outline ne ""} {
                #puts "$outline"
                append res "$outline\n"
            }
        } else {
            close $pipe
            set ::filter-julia::pipe ""
        }
    }
    proc pipestart {codeLines} {
        variable pipe
        variable res
        variable dict
        variable done
        set res ""
        if {$pipe eq ""} {
            set pipe [open "|julia -q 2>&1" r+]
            fconfigure $pipe -buffering line -blocking 0
            fileevent $pipe readable [list ::tmdoc::julia::piperead $pipe]
            set res ""
        }
        #puts $pipe "flush(stdin)"
        #puts $pipe "flush(stdout)"
        puts $pipe "[join $codeLines \n]\n"
        puts $pipe "println(\"### DONE\");"
        flush $pipe
        #puts $pipe "flush(stdin)"
        #puts $pipe "flush(stdout)"
        #after [dict get $dict wait] [list append wait ""]
        vwait tmdoc::julia::done
        return $res
    }
    proc start {filename} {
        set codeLines [getCode $filename]
        pipestart $codeLines
        # Write the code lines to Julia stdin through the pipe
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
        # to avoid hanging in case of print("Hello") at the end
        lappend codeLines "\nprintln(\"\");"
        if {[dict get $dict eval]} {
            set res [pipestart $codeLines]
        } 
        return [list $res ""]
    }

}


