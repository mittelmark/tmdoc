#!/usr/bin/env tclsh
##############################################################################
#
# Copyright (C) 2025 MicroEmacs User.
#
# All rights reserved.
#
# Synopsis:    
# Authors:     MicroEmacs User
#
##############################################################################


namespace eval ::fpipe {
    variable n 0
    variable pipecode ""
    variable pypipe ""
    variable rpipe ""
    variable opipe ""
    variable show true
    #set n 0
    #set pipecode ""
}
proc piperead {pipe args} {
    if {![eof $pipe]} {
        set got [gets $pipe]
        if {$got ne "flush(stdout)"} {
            # not sure why python does this
            if {[regexp {^>>>} $got]} {
                append ::fpipe::pipecode [regsub {^} {^.+>>> } "$got" ""]
            } else {
                # R and Octave
                if {[regexp "### SHOW OFF" $got]} {
                    set ::fpipe::show false
                } 
                if {$::fpipe::show && $got ni [list "" "> "]} {
                    append ::fpipe::pipecode "$got\n"
                }
                if {[regexp "### SHOW ON" $got]} {
                    set ::fpipe::show true
                }
            }
            
        }
    } else {
        close $pipe
    }
}


# TODO: 
# * namespace vars
# * cleanup pipes if blocking true
# * trace add execution exit enter YourCleanupProc

proc ::fpipe::filter-pipe-R-df2md {} {
    puts $::fpipe::rpipe {### SHOW OFF
        df2md <- function(df,caption='',rownames=TRUE) {
            cn <- colnames(df)
            if (is.null(cn[1])) {
                cn=as.character(1:ncol(df))
            }
            rn <- rownames(df)
            if (is.null(rn[1])) {
                rn=as.character(1:nrow(df))
            }
            if (rownames) {
                headr <- paste0(c("","", cn),  sep = "|", collapse='')
                sepr <- paste0(c('|', rep(paste0(c(rep('-',3), "|"), 
                                                 collapse=''),length(cn)+1)), collapse ='')
            } else {
                headr <- paste0(c("", cn),  sep = "|", collapse='')
                sepr <- paste0(c('|', rep(paste0(c(rep('-',3), "|"), 
                                                 collapse=''),length(cn))), collapse ='')
                
            }
            st <- "|"
            for (i in 1:nrow(df)){
                if (rownames) {
                    st <- paste0(st, "**",as.character(rn[i]), "**|", collapse='')
                }
                for(j in 1:ncol(df)){
                    if (j%%ncol(df) == 0) {
                        st <- paste0(st, as.character(df[i,j]), "|", 
                                     "\n", "" , "|", collapse = '')
                    } else {
                        st <- paste0(st, as.character(df[i,j]), "|", 
                                     collapse = '')
                    }
                }
            }
            fin <- paste0(c("\n \n ",headr, sepr, substr(st,1,nchar(st)-1)), collapse="\n")
            if (caption!='') {
                fin=paste0(fin,'\n',caption,'\n')
            }
            cat(fin)
        }
        ### SHOW ON}
    flush $::fpipe::rpipe
}
proc filter-pipe {cont dict} {
    incr ::fpipe::n
    set ::fpipe::pipecode ""
    set def [dict create results show eval false label null \
             include true pipe python3 terminal true wait 300]
    set dict [dict merge $def $dict]
    if {[dict get $dict eval]} {
        if {$::fpipe::pypipe eq "" && [string range [dict get $dict pipe] 0 1] eq "py"} {
            set ::fpipe::pypipe [open "|python3 -qui 2>@1" r+]
            fconfigure $::fpipe::pypipe -buffering line -blocking false
            fileevent $::fpipe::pypipe readable [list piperead $::fpipe::pypipe]
        }
        if {$::fpipe::opipe eq "" && [string range [dict get $dict pipe] 0 1] eq "oc"} {
            set ::fpipe::opipe [open "|octave --interactive --no-gui --norc --silent 2>@1" r+]
            fconfigure $::fpipe::opipe -buffering none -blocking false
            fileevent $::fpipe::opipe readable [list piperead $::fpipe::opipe]
            puts $::fpipe::opipe {PS1("")}
            puts $::fpipe::opipe "page_screen_output(1);"
            puts $::fpipe::opipe "page_output_immediately(1);"
            puts $::fpipe::opipe "fflush(stdout)"
            flush $::fpipe::opipe
            after [dict get $dict wait] [list append wait ""]
            vwait wait
            set ::fpipe::pipecode ""
        }
        #  
        if {$::fpipe::rpipe eq "" && [string range [dict get $dict pipe] 0 0] eq "R"} {
            if {[auto_execok Rterm] != ""} {
                # Windows, MSYS
                set ::fpipe::rpipe [open "|Rterm -q --vanilla 2>@1" r+]
            } else {
                set ::fpipe::rpipe [open "|R -q --vanilla --interactive 2>@1" r+]
            }
            fconfigure $::fpipe::rpipe -buffering line -blocking false
            fileevent $::fpipe::rpipe readable [list piperead $::fpipe::rpipe]
            ::fpipe::filter-pipe-R-df2md
            
        }
        set wait [list]
        set term ">>>"
        if {[string range [dict get $dict pipe] 0 1] eq "oc"} {
            set term "octave>"
        }
        if {[string range [dict get $dict pipe] 0 0] ne "X"} {
            foreach line [split $cont \n] {
                #  && [string range [dict get $dict pipe] 0 0] ne "R"
                if {[dict get $dict terminal] && [string range [dict get $dict pipe] 0 1] in [list "py" "oc"]}  {
                    append ::fpipe::pipecode "$term $line\n" 
                
                }
                if {[string range [dict get $dict pipe] 0 1] eq "py"} {
                    puts $::fpipe::pypipe "$line"
                }
                if {[string range [dict get $dict pipe] 0 1] eq "oc"} {
                    puts $::fpipe::opipe "$line"
                    flush $::fpipe::opipe
                }
                if {[string range [dict get $dict pipe] 0 0] eq "R"} {
                    puts $::fpipe::rpipe "$line"
                    flush $::fpipe::rpipe
                }
                if {[regexp {^[^\s]} $line]} {
                    # delay only if first letter is non-whitespace
                    # to allow to flush output
                    after [dict get $dict wait] [list append wait ""]
                    vwait wait
                }
            }
        }
        after [dict get $dict wait] [list append wait ""]
        vwait wait
        set res $::fpipe::pipecode
    } else {
        set res ""
    }
    # TODO: dict app using
    if {!([dict get $dict results] in [list show asis])} {
        set res ""
    } 
    if {[dict get $dict results] eq "asis" && [string range [dict get $dict pipe] 0 0] in [list "R" "python"]} {
        set nres ""
        set res [regsub -- {\|\|---:} $res "|\n|---:"]
        foreach line [split $res \n] {
            ## not sure where this K comes from ...
            if {![regexp {^[+>]} $line] && ![regexp {^.\[K>} $line]} {
                append nres "$line\n"
            }
        }
        set res $nres
     } else {
        set res [regsub {^.\[K> } $res ""]
    }
    if {[dict get $dict results] in [list show asis] && [string range [dict get $dict pipe] 0 1] eq "oc"} {
        set nres ""
        set i 0
        foreach line [split $res \n] {
            if {![regexp {^.*ans = 0\s*$} $line] && ![regexp {^>\s*$} $line]} {
                append nres "$line\n"
            } elseif {$i == 2  && [regexp {^\s*$} $line]} {
                continue
            } else {
                set i 1
            }
            incr i
        }
        set res $nres
    }
    #  dirty fix for R pipe sometimes without starting greater sign
    if {[dict get $dict pipe] eq "R" && ![regexp {^> } $res]} {
        set res "> $res"
    } 
    return [list $res ""]
}

