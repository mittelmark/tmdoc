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
        if {![eof $pipe]} {
            set got [gets $pipe]
            if {[regexp "### SHOW OF" $got]} {
                set show false
            } 
            if {$show && $got ni [list "" "> "]} {
                append res "$got\n"
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
            } else {
                set pipe [open "|R -q --vanilla --interactive 2>@1" r+]
            }
            fconfigure $pipe -buffering line -blocking false
            fileevent $::tmdoc::r::pipe readable [list tmdoc::r::piperead $pipe]
            df2md
            flush $pipe
            after [dict get $dict wait] [list append wait ""]
            vwait wait
            #set ::pipecode ""
        }
        foreach line $codeLines {
            #if {[dict get $dict terminal]} {
            #    if {[regexp {^  } $line] || [regexp  {^ *$} $line]} {
            #        append res "+ $line\n"
            #    } else {
            #        append res "> $line\n"
            #    }
            #}
            puts $pipe "$line"
            flush $pipe
            after 100 [list append wait ""]
            vwait wait
        }
        ## skip last empty line > \n
        #if {[dict get $dict terminal]} {
        #    set res "[string range $res 0 end-4]\n"
        #}
        return [regsub {.{1,3}K>} $res ">"]
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
                 include true terminal true wait 500]
        set dict [dict merge $def $cdict]
        
        set codeLines [list]
        foreach line [split $cnt \n] {
            lappend codeLines $line
        }
        if {[dict get $dict eval]} {
            set res [pipestart $codeLines]
        } 
        return [list $res ""]
    }

}



