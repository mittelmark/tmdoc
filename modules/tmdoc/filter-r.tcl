#!/usr/bin/env tclsh

namespace eval tmdoc { }
namespace eval tmdoc::r { 
    variable pipe 
    variable res
    variable show
    set pipe ""
    set res ""
    set show true
    variable dict
    proc df2md {} {
        variable pipe
        puts $pipe {### SHOW OFF
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
                headr <- paste0(c("","", paste("**",cn,"**",sep="")),  sep = "|", collapse='')
                sepr <- paste0(c('|', rep(paste0(c(rep('-',3), "|"), 
                                                 collapse=''),length(cn)+1)), collapse ='')
            } else {
                headr <- paste0(c("", paste("**",cn,"**",sep="")),  sep = "|", collapse='')
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
        flush $pipe
    }
    
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
        variable show
        variable dict
        if {![eof $pipe]} {
            set got [gets $pipe]
            if {[regexp "### SHOW OFF" $got]} {
                set show false
            } 
            if {$show && $got ni [list "" "> "]} {
                #puts stderr $dict
                if {!([dict get $dict results] eq "asis" && ([regexp {^>} $got] | [regexp {^.{1,3}K>} $got]))} {
                    append res "$got\n"
                } 
            }
            if {[regexp "### SHOW ON" $got]} {
                set show true
            }
        } else {
            close $pipe
            set ::tmdoc::r::pipe ""
        }
    }
    proc pipestart {codeLines} {
        variable pipe
        variable res
        variable dict
        set res ""
        if {$pipe eq ""} {
            if {[auto_execok Rterm] != ""} {
                # Windows, MSYS
                set pipe [open "|Rterm -q --vanilla 2>@1" r+]
                puts $pipe "### SHOW OFF"
                puts $pipe "options(error=print)"
                puts $pipe "### SHOW ON"
            } else {
                set pipe [open "|R -q --vanilla --interactive 2>@1" r+]
            }
            fconfigure $pipe -buffering line -blocking false
            fileevent $::tmdoc::r::pipe readable [list tmdoc::r::piperead $pipe]
            df2md
            
            flush $pipe
            after [dict get $dict wait] [list append wait ""]
            vwait wait
        }
        if  {[dict get $dict fig]} {
            puts $pipe "### SHOW OFF"
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
            set fname [file join [dict get $dict fig.path] [dict get $dict label].[dict get $dict ext]]
            puts $pipe "[dict get $dict ext](file=\"$fname\",width=[dict get $dict fig.width],height=[dict get $dict fig.height]);"
            puts $pipe "### SHOW ON"            
            flush $pipe
            after [dict get $dict wait] [list append wait ""]
            vwait wait
        } 
        foreach line $codeLines {
            puts $pipe "$line"
            flush $pipe
            after [dict get $dict wait] [list append wait ""]
            vwait wait
        }
        if {[dict get $dict fig]} {
            puts $pipe "### SHOW OFF"            
            puts $pipe "dev.off();"
            puts $pipe "### SHOW ON"
            flush $pipe
            after [dict get $dict wait] [list append wait ""]
            vwait wait
        }
        return [regsub {.{1,3}K>} $res ">"]
    }
    proc start {filename} {
        set codeLines [getCode $filename]
        pipestart $codeLines
    }
    proc filter {cnt cdict} {
        variable dict
        set res ""
        if {$::tcl_platform(os) eq "windows"} {
            set r Rterm
        } else {
            set r R
        }
        set def [dict create pipe $r results show eval false label null fig false \
                 fig.width 600 fig.height 600 fig.path . \
                 include true terminal true wait 100]
        set dict [dict merge $def $cdict]
        if {![file isdirectory [dict get $dict fig.path]]} {
            file mkdir [dict get $dict fig.path]
        }
        set codeLines [list]
        foreach line [split $cnt \n] {
            lappend codeLines $line
        }
        if {[dict get $dict eval]} {
            set res [pipestart $codeLines]
        } 
        set img ""
        if {[dict get $dict fig] && [dict get $dict include]} {
            set img "[dict get $dict label].[dict get $dict ext]"
        }
        if {![dict get $dict terminal]} {
            set res [string trim [string trim [regsub {^> .+\[1\] } $res ""]] {"}] ;#"
            set res [regsub -all {\\n} $res "\n"]
        }
        set res [string trim $res]
        return [list "$res" "$img"]
    }

}



