#!/bin/sh
# A Tcl comment, whose contents don't matter \
exec tclsh "$0" "$@"
##############################################################################
#  Author        : Dr. Detlef Groth
#  Created       : Tue Feb 18 06:05:14 2020
#  Last Modified : <251005.0828>
#
# Copyright (c) 2020-2025  Detlef Groth, University of Potsdam, Germany
#                          E-mail: dgroth(at)uni(minus)potsdam(dot)de
#
#  Description	 : Command line utility and package to embed and evaluate Tcl code
#                  inside Markdown documents, a technique known as literate programming.
#
#  History       : 2020-02-19 version 0.1
#                  2020-02-21 version 0.2
#                  2020-02-23 version 0.3
#                  2020-11-09 version 0.4
#                  2021-12-19 version 0.5.0
#                  2025-01-04 version 0.6.0 (tcllib and Tcl 9 aware version)
#                  2025-01-18 version 0.7.0 results="asis" implemented, include and list2md
#                  2025-03-21 version 0.8.0 support for shell chunks
#                  2025-04-02 version 0.9.0 better support for Tcl man page format
#                                           support for kroki code chunks
#                  2025-06-07 version 0.10.0 support for textual tool output, for example
#                                            from programming code
#                  2025-09-14 version 0.11.0 support for %b basename of input file
#                  2025-09-30 version 0.12.0 support for LaTeX quations using https://math.vercel.app
#                                            suport for embedding Youtube videos
#                                            support %f as input filename
#                  2025-10-02 version 0.13.0 fixing tcl code chunk option eval=false
#                                            fixing resetting default of code chunks
#                                            adding bibliography entry in YAML header
#                                            extending tmdoc tutorial
#                                            adding alert messages in Markdown ouput
#                                            adding abbreviations
#                                            adding csv based  table creation  
#                  2025-10-XX version 0.13.0 adding support for Octave, Python and R code embedding
#
package require Tcl 8.6-
package require fileutil
package require yaml
package provide tmdoc::tmdoc 0.14.0
package provide tmdoc [package provide tmdoc::tmdoc]
source [file join [file dirname [info script]] filter-r.tcl]
source [file join [file dirname [info script]] filter-python.tcl]
source [file join [file dirname [info script]] filter-octave.tcl]
namespace eval ::tmdoc {}

# clear all variables and defintions

proc ::tmdoc::interpReset {} {
    if {[interp exists intp]} {
        interp delete intp
        interp delete try
    }
    interp create intp
    interp eval intp " set pres {} ;  set auto_path {$::auto_path}"
    interp eval intp "package require yaml"
    interp eval intp {rename puts puts.orig}
    interp eval intp {
        set nfig 0
        set ntab 0
        array set figs [list]
        array set tabs [list]
        proc puts {args} {
            # TODO: catch if channel stdout is given
            set l [llength $args]
            if {[lindex $args 0] eq "-nonewline"} {
                if {$l == 2} {
                    # no channel
                    append ::pres [lindex $args 1]
                } else {
                    if {[lindex $args 1] eq "stdout"} {
                        append ::pres [lindex $args 2]
                    } else {
                        return [puts.orig -nonewline [lindex $args 1] [lindex $args 2]]
                    }
                }
            } else {
                if {$l == 1} {
                    append ::pres "[lindex $args 0]\n"
                } else {
                    # channel given
                    if {[lindex $args 0] eq "stdout"} {
                        append ::pres "[lindex $args 1]\n"
                    } else {
                        puts.orig [lindex $args 0] [lindex $args 1]
                    }
                }
            }
            return ""
        }
        proc list2mdtab {header values} {
            set ncol [llength $header]
            set nval [llength $values]
            if {[llength [lindex $values 0]] > 1 && [llength [lindex $values 0]] != [llength $header]} {
                error "Error: list2table - number of values if first row is not a multiple of columns!"
            } elseif {[expr {int(fmod($nval, $ncol))}] != 0} {
                error "Error: list2table - number of values is not a multiple of columns!"
            }
            set res "\n|"
            foreach h $header {
                append res " $h |"
            }
            append res "\n|"
            foreach h $header {
                append res " ---- |"
            }
            append res "\n"
            set c 0
            foreach val $values {
                if {[llength $val] > 1} {
                    # nested list
                    append res "| "
                    foreach v $val {
                        append res " $v |"
                    }
                    append res "\n"
                } else {
                    if {[expr {int(fmod($c, $ncol))}] == 0} {
                        append res "| "
                    }
                    append res " $val |"
                    incr c
                    if {[expr {int(fmod($c, $ncol))}] == 0} {
                        append res "\n"
                    }
                }
            }
            return $res
        }
        proc include {filename} {
            if [catch {open $filename r} infh] {
                return "Cannot open $filename"
            } else {
                set res ""
                while {[gets $infh line] >= 0} {
                    append res "$line\n"
                }
                set res [regsub {\n$} $res ""]
                close $infh
                return $res
            }
        }
        proc youtube {video args} {
            set html {<div class="video">}
            append html "<iframe src=\"https://www.youtube.com/embed/$video?rel=0\""
            foreach arg $args {
                append html " $arg"
            }
            append html allowfullscreen></iframe>
            append html </div>
            return $html
        }

        proc nfig {{label ""}} {
            global nfig
            incr nfig 1
            if {$label ne ""} {
                set ::figs($label) $nfig
            }
            return $nfig
        }
        proc rfig {label} {
            if {[info exists ::figs($label)]} {
                return $::figs($label)
            } else {
                return NN
            }
        }
        proc ntab {{label ""}} {
            global ntab
            incr ntab 1
            if {$label ne ""} {
                set ::tabs($label) $ntab
            }
            return $nfig
        }
        proc rtab {label} {
            if {[info exists ::tabs($label)]} {
                return $::tabs($label)
            } else {
                return NN
            }
        }
    }
    interp eval intp {
        proc gputs {} {
            set res $::pres
            set ::pres ""
            return $res
        }
    }
    # todo handle puts options

    # this is the try interp for the catch statements
    # we first check statements and only if they are ok
    # the real interpreter intp will be used
    interp create try
    interp eval try { set yamltext "" }
    interp eval try {rename puts puts.orig}
    interp eval try " set pres {} ;  set auto_path {$::auto_path}"
    interp eval try "package require yaml"
    # todo handle puts options
    
    interp eval try {proc puts {args} {}}
    interp eval try {proc include {filename} {}}
    interp eval try {proc list2mdtab {header data} {}}
    interp eval try {proc nfig {{label ""}} {}}    
    interp eval try {proc rfig {label} {}}        
    interp eval try {proc ntab {{label ""}} {}}    
    interp eval try {proc rtab {label} {}}        
    interp eval try {proc youtube {video args} {}}            
    interp eval try {namespace eval citer { } }
    interp eval try {proc citer::bibliography {{filename ""}} {}}
    interp eval try {proc citer::cite {key} {}}        
}

proc ::tmdoc::dia2kroki {text {dia graphviz} {ext svg}} {
    set b64 [string map {+ - / _ = ""} [binary encode base64 [zlib compress [encoding convertto utf-8 $text]]]]
    set uri https://kroki.io//$dia/$ext/$b64
}

proc ::tmdoc::url2crc32file {url {folder .} {ext png}} {
    
    if {[auto_execok wget] eq ""} {
        ## no local saving
        return $url
        ##"Error: wget not installed!"
    }
    set filename [file join $folder [zlib crc32 $url].$ext]
    if {[file exists $filename]} {
        return $filename
    } else {
        if {![file isdirectory $folder]} {
            file mkdir $folder
        }
        catch { exec {*}[list wget -q $url -O $filename] }
        return $filename
    }
}

proc ::tmdoc::extractAbbreviations {str} {
    set result {}
    set start 0
    
    # Pattern to match content inside curly braces
    set pattern {\{(\w+)\}}
    # Use regexp with -inline and -all to directly get all matches of content inside braces
    set matches [regexp -all -inline {\{(\w+)\}} $str]
    
    # Extract only the inner part without braces
    foreach match $matches {
        if {[regexp $pattern $match]} {
            # match looks like "{A}", so strip the first and last character
            set element [string range $match 1 end-1]
            lappend result $element
        }
    }
    return $result
}
proc tmdoc::block {txt inmode {style ""}} {
    set res ""
    if {$style ne ""} {
        set style "{${style}}"
    }
    if {$inmode eq "md"} {
        append res "```${style}\n${txt}"
        append res "```\n"
    } elseif {$inmode eq "man"} {
        append res "\n"
        append res "\[example_begin\]\n\n$txt\n\n\[example_end\]\n"
        append res "\n"
    } else {
        append res "\\begin{lcverbatim}\n"
        append res "$txt"
        append res "\\end{lcverbatim}"
    }
    return $res
}

# public functions - the main function process the files

proc ::tmdoc::tmdoc {filename outfile args} {
    if {[string tolower [file extension $filename]] in [list .tnw .tex]} {
        set inmode latex
    } elseif {[string tolower [file extension $filename]] in [list .tan .man .tman]} {
        set inmode man
    } else {
        set inmode md
    }
    array set arg [list infile $filename outfile $outfile -mode weave]
    if {[llength $args] > 0} {
        array set arg {*}$args
    }
    if {$arg(outfile) ni [list stdout -]} {
        if {[file extension $arg(outfile)] eq ".tex"} {
            set inmode latex
        }
        if {[file extension $arg(outfile)] eq ".man"} {
            set inmode man
        }
        set out [open $arg(outfile) w 0600]
    } else {
        set out stdout
    }
    if {$arg(-mode) eq "tangle"} {
        if [catch {open $filename r} infh] {
            return -code error "Cannot open $filename: $infh"
        } else {
            set flag false
            while {[gets $infh line] >= 0} {
                if {[regexp {^[> ]{0,2}```\{\.?tcl[^a-zA-Z]} $line]} {
                    set flag true
                    continue
                } elseif {$flag && [regexp {^[> ]{0,2}```} $line]} {
                    set flag false
                    continue
                } elseif {$flag} {
                    puts $out $line
                }
            }
            close $infh
        }
        if {$arg(outfile) ne "stdout"} {
            close $out
        }
        return
    }
    set mode text
    set alt false
    set tclcode ""
    set bashinput ""
    set krokiinput ""
    set mtexinput ""
    set lastbashinput ""
    set ginput ""
    array set mopt [list eval true echo true results show fig false include true label chunk-nn\
                    ext png chunk.ext txt]
    array set dopt [list eval true echo true results show fig false include true \
        fig.width 12cm fig.height 12cm fig.cap {} label chunk-nn ext png chunk.ext txt]
    ## bash / shell
    array set bdopt [list cmd "" echo true eval true results show fig true include true \
        fig.width 12cm label chunk-nn ext png chunk.ext txt]
    ## kroki
    array set kdopt [list echo true eval true results show fig true include true \
                     fig.width 12cm label chunk-nn ext png dia ditaa \
                     imagepath .]
    ## mtex
    array set tdopt [list echo true eval true results show fig true include true \
        label chunk-nn imagepath mtexfig]
    interpReset
    if [catch {open $filename r} infh] {
        return -code error "Cannot open $filename: $infh"
    } else {
        set chunki 0
        set lnr 0
        set yamlflag false
        set yaml false
        set yamltext ""
        
        while {[gets $infh line] >= 0} {
            incr lnr
            if {$yamlflag && [regexp {^---} $line]} {
                set yamlflag false
                set abbrev [dict create {*}[yaml::yaml2dict $yamltext]]
                if {[dict exists $abbrev abbreviations]} {
                    if {[file exists [dict get $abbrev abbreviations]]} {
                        set afile [open [dict get $abbrev abbreviations] r]
                        append yamltext [read $afile]
                        close $afile
                        set abbrev [dict create {*}[yaml::yaml2dict $yamltext]]
                    }
                }
                set yamltext ""
                set yaml true
            } 
            if {$yamlflag} {
                append yamltext "$line\n"
            }
            if {!$yamlflag && $lnr < 3 && [regexp {^---} $line]} {
                set yamlflag true
            } 
            if {$mode eq "text" && $yaml && ![regexp {```} $line] && [regexp {\{\w+\}} $line]} {
                set abbrevs [tmdoc::extractAbbreviations $line]
                foreach key [dict keys $abbrev] {
                    set line [regsub -all "\{$key\}" $line [dict get $abbrev $key]]
                }
            }
            if {$mode eq "text" && [regexp {```\{\.?(r|oc|py).*\}} $line]} {
                set line [regsub -nocase {\{\.?r(.*)\}} $line "{.pipe pipe=R\\1}"]
                set line [regsub -nocase {\{\.?oc[a-z]*(.*)\}} $line "{.pipe pipe=octave\\1}"]                
                set line [regsub -nocase {\{\.?py[a-z]*(.*)\}} $line "{.pipe pipe=python\\1}"]                                
            }
            if {$mode eq "text" && [regexp {\[@[@,\w]+\]} $line]} {
                set line [regsub -all {\[@([@\w,]+)\]} $line "`tcl citer::cite \\1`"]
            }
            if {$mode eq "text" && $lnr < 20 && [regexp {^bibliography: } $line]} {
                interp eval intp {lappend auto_path ..; package require citer }
                set bibfile [regsub {bibliography:\s+([^\s]+).*} $line "\\1"]
                if {![file exists $bibfile]} {
                    error "Error: BibTeX file $bibfile does not exists!"
                }
                interp eval intp "citer::bibliography $bibfile"
            }
            if {$mode eq "text" && $alt && [regexp {^\s*$} $line]} {
                set line "</p></div>\n\n"
                set alt false
            } 
            if {$mode eq "text" && $alt && [regexp {^> (.+)} $line -> txt]} {
                set line $txt
            } 
            if {$mode eq "text" && [regexp {^> \[!([A-Z]+)\]} $line -> alert]} {
                set alt true
                set alert [string tolower $alert 1 end]
                set line "<div class=\"side-[string tolower $alert]\"><p><b>${alert}:</b> "
            }
            if {$mode eq "text" && (![regexp {   ```} $line] && [regexp {```\s?\{\.?tcl\s*\}} $line -> opts])} {
                set mode code
                incr chunki
                array set copt [array get dopt]
            } elseif {$mode eq "text" && (![regexp {   ```} $line] && [regexp {```\s?\{\.?tcl\s+(.*)\}} $line -> opts])} {
                set mode code
                incr chunki
                array set copt [array get dopt]
                # TODO: spaces in fig.cap etc
                ::tmdoc::GetOpts 
                continue
            } elseif {$mode eq "text" && (![regexp {   ```} $line] && [regexp {```\s?\{\.?(shell|cmd)\s+(.*)\}} $line -> tp opts])} {
                set mode shell
                incr chunki
                array set copt [array get bdopt]
                # TODO: spaces in fig.cap etc
                ::tmdoc::GetOpts 
                continue
            } elseif {$mode eq "text" && (![regexp {   ```} $line] && [regexp {```\s?\{\.?(kroki)\s+(.*)\}} $line -> tp opts])} {
                set mode kroki
                incr chunki
                array set copt [array get kdopt]
                # TODO: spaces in fig.cap etc
                ::tmdoc::GetOpts 
                continue
            } elseif {$mode eq "text" && (![regexp {   ```} $line] && [regexp {```\s?\{\.?(mtex)(\s*.*)\}} $line -> tp opts])} {
                set mode mtex
                incr chunki
                array set copt [array get tdopt]
                ::tmdoc::GetOpts 
                continue
            } elseif {$mode eq "text" && [regexp {^ {0,3}```\{\.([a-z0-9]+)(\s*.*)\}} $line -> nmode opts]} {
                incr chunki
                set mode $nmode
                array set copt [array get mopt]
                ::tmdoc::GetOpts 
                continue
            } elseif {$mode in [list csv pipe] && [regexp {```} $line]} {
                if {$copt(echo)} {
                    puts $out [tmdoc::block $ginput $inmode]
                }
                if {$mode eq "csv"} {
                    if {$copt(results) eq "asis"}  {
                        puts $out [tmdoc::csv $ginput]
                    }
                } elseif {$mode eq "pipe"} {
                    if {$copt(pipe) eq "python"} {
                        set res [tmdoc::python::filter $ginput [dict create {*}[array get copt]]]
                    } elseif {$copt(pipe) eq "octave"} {
                        set res [tmdoc::octave::filter $ginput [dict create {*}[array get copt]]]
                    } else {
                        ## R
                        set res [tmdoc::r::filter $ginput [dict create {*}[array get copt]]]
                    }
                    if {$copt(results) eq "show"} {
                        puts $out [tmdoc::block [lindex $res 0] $inmode]
                    } elseif {$copt(results) eq "asis"} {
                        puts $out [lindex $res 0]
                    } 
                    if {$copt(fig) && $copt(include)} {
                        puts $out "!\[ \]([lindex $res 1])"
                    }

                }
                set ginput ""
                set mode text
                array unset copt
                continue
            } elseif {$mode eq "shell" && [regexp {```} $line]} {
                if {$copt(echo)} {
                    if {$inmode eq "md"} {
                        puts -nonewline $out "```{code}\n${bashinput}"
                        puts $out "```"
                    } elseif {$inmode eq "man"} {
                        puts $out ""
                        puts -nonewline $out "\[example_begin\]\n\n$bashinput\n\n\[example_end\]\n"
                        puts $out ""
                    } else {
                        puts $out "\\begin{lcverbatim}"
                        puts -nonewline $out $bashinput
                        puts $out "\\end{lcverbatim}"
                    }
                }
                set cmd [regsub -all {%i} $copt(cmd) $copt(label).$copt(chunk.ext)]
                set cmd [regsub -all {%f} $cmd $copt(label).$copt(chunk.ext)]                
                set cmd [regsub -all {%b} $cmd $copt(label)]                
                set cmd [regsub -all {%o} $cmd $copt(label).$copt(ext)]
                if {$copt(results) eq "show"} {
                    if {[regexp {LASTFILE} $bashinput]} {
                        set bashinput $lastbashinput
                    }
                    set tout [open $copt(label).$copt(chunk.ext) w 0600]
                    puts -nonewline $tout $bashinput
                    close $tout
                    set lastbashinput $bashinput
                }
                if {$copt(eval)} {
                    set err ""
                    if {[regexp {&&} $cmd]} {
                        set cmds [split $cmd &]
                        foreach c $cmds {
                            if {$c ne ""} {
                                if {[catch { set cnt [exec -ignorestderr {*}$c] } errMsg]} {
                                    append err "$::errorInfo\n\n$errMsg"
                                }
                            }
                        }
                    } else {
                        if {[catch { set cnt [exec {*}$cmd] } errMsg]} {
                            set err "$::errorInfo\n\n$errMsg"
                        } 
                    }
                }
                if {$copt(include)} {
                    if {$copt(ext) in [list png svg gif jpeg jpg]} {
                        if {$inmode eq "md"} {
                            puts $out "!\[\]($copt(label).$copt(ext))"
                        } elseif {$inmode eq "man"} {
                            puts $out "\n\[image $copt(label)\]n"
                        } elseif {$inmode eq "latex"} {
                            puts $out "\n\\includegraphics\[width=$copt(fig.width)\]{$copt(label)}\n"
                        }
                        if {$err ne ""} {
                            if {$inmode eq "md"} {
                                puts -nonewline $out "\n\n```{error}\n$err\n\n"
                                puts $out "```"
                            } elseif {$inmode eq "man"} {
                                puts $out ""
                                puts -nonewline $out "\[example_begin\]\n\n$err\n\n\[example_end\]\n"
                                puts $out ""
                            } else {
                                puts $out "\\begin{lcverbatim}"
                                puts -nonewline $out $err
                                puts $out "\\end{lcverbatim}"
                            }
                        }
                            
                    } else {
                        if [catch {open $copt(label).$copt(ext) r} infh2] {
                            set cnt "Cannot open $copt(label).$copt(ext)"
                        } else {
                            set cnt [read $infh2]
                            close $infh2
                        }
                        if {$inmode eq "md"} {
                            puts -nonewline $out "```{out}\n$cnt"
                            puts $out "```"
                        } elseif {$inmode eq "man"} {
                            puts $out ""
                            puts -nonewline $out "\[example_begin\]\n\n$cnt\n\n\[example_end\]\n"
                            puts $out ""
                        } else {
                            puts $out "\\begin{lcverbatim}"
                            puts -nonewline $out $cnt
                            puts $out "\\end{lcverbatim}"
                        }
                    }
                }
                set bashinput ""
                set mode text
                array unset copt
            } elseif {$mode eq "kroki" && [regexp {```} $line]} {
                if {$copt(echo)} {
                    if {$inmode eq "md"} {
                        puts -nonewline $out "```\n${krokiinput}"
                        puts $out "```"
                    } elseif {$inmode eq "man"} {
                        puts $out ""
                        puts -nonewline $out "\[example_begin\]\n\n$krokiinput\n\n\[example_end\]\n"
                        puts $out ""
                    } else {
                        puts $out "\\begin{lcverbatim}"
                        puts -nonewline $out $krokiinput
                        puts $out "\\end{lcverbatim}"
                    }
                }
                set url [dia2kroki $krokiinput $copt(dia) $copt(ext)] 
                set filename [url2crc32file $url $copt(imagepath) $copt(ext)]
                if {$copt(include)} {
                    if {$inmode eq "md"} {
                        puts $out "!\[\]($filename)"
                    } elseif {$inmode eq "man"} {
                        puts $out "\n\[image [file rootname $filename]\]n"
                    } elseif {$inmode eq "latex"} {
                        puts $out "\n\\includegraphics\[width=$copt(fig.width)\]{[file rootname $filename]}\n"
                    }
                }
                set krokiinput ""
                set mode text
                array unset copt                
            } elseif {$mode eq "mtex" && [regexp {```} $line]} {
                if {$copt(echo)} {
                    set cont [tmdoc::block $mtexinput $inmode]
                    puts $out $cont
                }
                set url https://math.vercel.app?from=[ue ${mtexinput}].svg
                set filename [url2crc32file $url $copt(imagepath) svg]
                if {$copt(include)} {
                    if {$inmode eq "md"} {
                        puts $out "!\[\]($filename)"
                    } elseif {$inmode eq "man"} {
                        puts $out "\n\[image [file rootname $filename]\]n"
                    } elseif {$inmode eq "latex"} {
                        puts $out "\n\\includegraphics\[width=$copt(fig.width)\]{[file rootname $filename]}\n"
                    }
                }
                set mtexinput ""
                set mode text
                array unset copt
            } elseif {$mode eq "shell"} {
                append bashinput "$line\n"
            } elseif {$mode eq "kroki"} {
                append krokiinput "$line\n"
            } elseif {$mode eq "mtex"} {
                append mtexinput "$line\n"
            } elseif {$mode in [list csv pipe]} {
                append ginput "$line\n"
            } elseif {$mode eq "code" && [regexp {```} $line]} {
               if {$copt(echo)} {
                   if {$inmode eq "md"} {
                       puts $out "```{tclcode}"
                       puts -nonewline $out $tclcode
                       puts $out "```"
                   } elseif {$inmode eq "man"} {
                       puts $out ""
                       puts -nonewline $out "\n\[example_begin\]\n$tclcode\n\[example_end\]\n"
                       puts $out ""
                   } else {
                       puts $out "\\begin{lcverbatim}"
                       puts -nonewline $out $tclcode
                        puts $out "\\end{lcverbatim}"
                    }
                }
                if {$copt(eval)} {
                    if {[catch {interp eval try $tclcode} res]} {
                        if {$inmode eq "md"} {
                            puts $out "```{tclerr}\n$res\n```\n"
                        } elseif {$inmode eq "man"} {
                            puts $out "\n\[example_begin\]\nError:\n$res\n\[example_end\]\n"
                        } else {
                            puts $out "\n\\begin{lrverbatim}\n$res\n\\end{lrverbatim}\n"
                        }
                    } else {
                        set res [interp eval intp $tclcode]
                        set pres [interp eval intp gputs]
                        if {$copt(results) eq "asis"} {
                            puts -nonewline $out $pres
                        } elseif {$copt(results) eq "show"} {
                            if {$inmode eq "md"} {
                                if {$res ne "" || $pres ne ""} {
                                    puts $out "```{tclout}"
                                }
                                if {$pres ne ""} {
                                    puts -nonewline $out "$pres"
                                }
                                if {$res ne ""} {
                                    puts $out "==> $res"
                                }
                                if {$res ne "" || $pres ne ""} {
                                    puts $out "```"
                                }
                            } elseif {$inmode eq "man"} { 
                                if {$pres ne ""} {
                                    puts -nonewline $out "==> $pres"
                                }
                                if {$res ne ""} {
                                    puts $out "==> $res"
                                }
                            } else {
                                if {$res ne "" || $pres ne ""} {
                                    puts $out "\\begin{lbverbatim}"
                                }
                                if {$pres ne ""} {
                                    puts -nonewline $out "$pres"
                                }
                                if {$res ne ""} {
                                    puts $out "==> $res"
                                }
                                if {$res ne "" || $pres ne ""} {
                                    puts $out "\\end{lbverbatim}"
                                }
                            
                            }
                            if {$copt(fig)} {
                                set imgfile [file tail [file rootname $filename]]-$copt(label).$copt(ext)
                                if {[interp eval intp "info commands figure"] eq ""} {
                                    if {$inmode eq "md"} {
                                        puts $out "```{tclerr}\nYou need to define a figure procedure \nwhich gets a filename as argument"
                                        puts $out "proc figure {filename} { }\n\nwhere within you create the image file```\n"
                                    } elseif {$inmode eq "man"} {
                                        puts $out "\n\[example_begin\]"
                                        puts $out "\nYou need to define a figure procedure \nwhich gets a filename as argument"
                                        puts $out "proc figure {filename} { }\n\nwhere within you create the image file\n"
                                        puts $out "\n\[example_end\]"
                                    } else {
                                        puts $out "\n\\begin{lrverbatim}\n\nYou need to define a figure procedure \nwhich gets a filename as argument\n"
                                        puts $out "proc figure {filename} { }\n\nwhere within you create the image file\\end{lrverbatim}\n"
                                    }
                                } else {
                                    interp eval intp [list figure $imgfile]
                                    if {$copt(include)} {
                                        if {$inmode eq "md"} {
                                            puts $out "\n!\[\]($imgfile)\n"
                                        } elseif {$inmode eq "man"} {
                                            puts $out "\n\[image [file rootname $imgfile]\]\n"
                                        } else {
                                            puts $out "\n\\includegraphics\[width=$copt(fig.width)\]{$imgfile}\n"
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
                set tclcode ""
                set mode text
                array unset copt
                continue
            } elseif {$mode eq "text" && [regexp {[> ]{0,2}```} $line]} {
                set mode pretext
                puts $out $line
                continue
            } elseif {$mode eq "pretext" && [regexp {[> ]{0,2}```} $line]} {
                puts $out $line
                set mode text
            } elseif {$mode ne "text" && [regexp {^\s{0,3}```} $line]} { 
                if {$copt(echo)} {
                    set cont [tmdoc::block $ginput $inmode $mode]
                    puts $out $cont
                }
                set ginput ""
                set mode text
                array unset copt
                continue
            } elseif {$mode eq "text"} {
                # todo check for `tcl fragments`
                while {[regexp {(.*?)`tcl ([^`]+)`(.*)$} $line -> pre t post]} {
                    if {[catch {interp eval try $t} res]} {
                        if {$inmode in [list md man]} {
                            set line "$pre*??$res??*$post"
                        } else {
                            set line [regsub -all {_} "$pre*??$res??*$post" {\\_}]
                        }
                    } else {
                        set res [interp eval intp $t]
                        if {$inmode in [list md man]} {                                                
                            set line "$pre$res$post"
                        } else {
                            set line [regsub -all {_}  "$pre$res$post" {\\_}]
                        }
                    }

                }
                while {[regexp {(.*?)`r ([^`]+)`(.*)$} $line -> pre t post]} {
                    set res [r::filter $t [dict create pipe R eval true echo false]]
                    set res [string trim [lindex [split [lindex $res 0] " "] end]]
                    set line [regsub -all {_}  "$pre$res$post" {\\_}]
                }
                while {[regexp {(.*?)`py ([^`]+)`(.*)$} $line -> pre t post]} {
                    set res [python::filter $t [dict create pipe python eval true echo false terminal false]]
                    set res [lindex [split [lindex [lindex $res 0] 0] " "] end]
                    set line [regsub -all {_}  "$pre$res$post" {\\_}]
                }
                while {[regexp {(.*?)`oc ([^`]+)`(.*)$} $line -> pre t post]} {
                    set res [octave::filter $t [dict create pipe octave eval true echo false terminal false]]
                    set res [lindex [split [lindex [lindex $res 0] 0] " "] end]
                    set line [regsub -all {_}  "$pre$res$post" {\\_}]
                }

                puts $out $line
            } elseif {$mode eq "pretext"} {
                puts $out $line
            } elseif {$mode eq "code"} {
                if {[regexp {^\s*::tmdoc::interpReset} $line]} {
                    ::tmdoc::interpReset
                    append tclcode "# ::tmdoc::interpReset\n"
                } else {
                    append tclcode "$line\n"
                }
            } else {
                puts $out $line
                #error "error on '$line' should be not reachable"
            }
            
        }
        close $infh
        close $out
        if {[interp exists intp]} {
            interp eval intp { catch {destroy . } }
            interp delete intp
        }
        if {[interp exists try]} {
            interp eval try { catch { destroy . } }
            interp delete try
        }
    }
}
proc ::tmdoc::GetOpts {} {
    uplevel 1 {
        while {[regexp -indices {"(.+?)"} $opts m1 m2]} {
            set before [string range $opts 0 [expr {[lindex $m1 0]-1}]] 
            set match [regsub -all { } [string range $opts [lindex $m2 0] [lindex $m2 1]] "%20"]
            set match [regsub -all "=" $match "%3d"]
            set after [string range $opts [expr {[lindex $m1 1]+1}] end] 
            set opts ${before}${match}${after}
        }
        set opts [regsub -all {,+} [regsub -all { +} $opts ,] ,]
        
        foreach opt [split $opts ","] {
            set opt [string trim [regsub -nocase false [regsub -nocase true $opt true] false]]
            set o [split $opt =] 
            set key [lindex $o 0]
            set value [regsub {"(.+)"} [lindex $o 1] "\\1"]
            set value [regsub -all {%20} $value " "]
            set value [regsub -all {%3d} $value "="]
            set copt($key) $value
        }
        # setting default label if no label was given
        foreach key [array names copt] {
            if {$key eq "label" && $copt($key) eq "chunk-nn"} {
                set value [regsub {nn} $copt($key) $chunki]
                set copt($key) $value
            }
        }
    }
}
proc ::tmdoc::tmeval {text} {
    set filename [fileutil::tempfile]
    set out [open $filename.tmd w 0600]
    puts $out $text
    close $out
    tmdoc::tmdoc $filename.tmd $filename.md
    set infh [open $filename.md r]
    set ret [read $infh]
    close $infh
    file delete $filename.tmd
    file delete $filename.md
    return $ret
}

proc tmdoc::csv {txt} {
    set res ""
    set x 0
    foreach line [split $txt \n] {
        if {[regexp {^\s*$} $line]} {
            continue
        }
        incr x
        set nline [regsub -all {[,;\t]} $line " | "]
        append res "| $nline |\n"
        if {$x == 1} {
            append hrule [regsub -all {[^\s|]} $nline "-"]
            append res "| $hrule |\n"
        } 
    }
    return $res
}
proc tmdoc::ue_init {} {
   lappend d + { }
   for {set i 0} {$i < 256} {incr i} {
      set c [format %c $i]
      set x %[format %02x $i]
      if {![string match {[a-zA-Z0-9]} $c]} {
         lappend e $c $x
         lappend d $x $c
      }
   }
   set ::ue_map $e
   set ::ud_map $d
}
tmdoc::ue_init
proc tmdoc::ue {s} { string map $::ue_map $s }
proc tmdoc::ud {s} { string map $::ud_map $s }
proc ::tmdoc::main {argv} {
    global argv0
    set APP $argv0
    if {[regexp {tclmain} $APP]} {
        set APP "tclmain -m tmdoc"
    }
    set Usage [string map [list "\n    " "\n"] {
        Usage: __APP__ ?[--help|version]? INFILE OUTFILE ?--mode weave|tangle?   
               
        tmdoc - Literate programming with Tcl for Markdown and LaTeX processor, Version __VERSION__
                Converts Markdown or LaTeX documents with embedded Tcl code into Markdown 
                or LaTeX documents with evaluated Tcl code
                
        Positional arguments (required):
        
            INFILE  - input file usually Markdown or LaTeX with embedded Tcl code
                      either in code chunks starting with ```{.tcl} or in short
                      inline code  with `tcl set x` syntax.
                      
            OUTFILE - output file usually a Markdown or LaTeX file, if not given
                      or if outfile is the `-` output is send to stdout
           
                     
        Optional arguments:
            
           --help       - displays this help page, and exit
           --version    - display version number, and exit
           --license    - display license information, and exit
           --mode       - either `weave` for evaluating the code chunks
                          or `tangle` for extracting all Tcl code  
                          
        Examples:
        
           # convert the tutorial in the modules/tmdoc folder
           __APP__ modules/tmdoc/tmdoc-tutorial.Tmd modules/tmdoc/tmdoc-tutorial.md
           # convert it furthermore to HTML using mkdoc
           mkdoc modules/tmdoc/tmdoc-tutorial.md modules/tmdoc/tmdoc-tutorial.html \
                 --css tmdoc.css
           
           # extract inline examples from the package code
           mkdoc modules/tmdoc/tmdoc.tcl modules/tmdoc/tmdoc.tmd
           # evaluate the examples and add the code output
           __APP__ modules/tmdoc/tmdoc.tmd modules/tmdoc/tmdoc.md
           # convert it to HTML 
           mkdoc modules/tmdoc/tmdoc.md modules/tmdoc/tmdoc-tmdoc.html \
                 --css tmdoc.css
           
      License: BSD
    }]

    if {[lsearch -exact $argv {--version}] > -1} {
        puts "[package provide tmdoc::tmdoc]"
        return
    }
    if {[lsearch -exact $argv {--license}] > -1} {
        puts "BSD License - see manual page"
        return
    }

    if {[llength $argv] < 2 || [lsearch -exact $argv {--help}] > -1} {
        set usage [regsub -all {__VERSION__} [regsub -all {__APP__} $Usage $APP] [package provide tmdoc]]
        puts $usage
        exit 0
    } else {
        set idxm [lsearch -exact $argv {--mode}]
        set mode weave
        if {$idxm > -1} {
            if {[llength $argv] != 4} {
                puts "Usage: Error - argument --mode must have an argument either weave or tangle"
            } elseif {[lindex $argv [expr {$idxm + 1}]] ni [list weave tangle]} {
                puts "Usage: Error - --mode must have as values on of weave or tangle"
            } else {
                set mode [lindex $argv [expr {$idxm + 1}]]
            }
            set argv [lreplace $argv $idxm [expr {$idxm + 1}]]
        }
        tmdoc::tmdoc [lindex $argv 0] [lindex $argv 1] [list -mode $mode]
    }
}

namespace eval ::tmdoc {
    namespace export tmdoc tmeval
}

#'
#' ## <a name='changes'>CHANGES</a>
#'
#' - 2020-02-19 Release 0.1
#' - 2020-02-21 Release 0.2
#'     - docu updates
#'     - nonewline puts fix
#'     - *-outfile filename* option
#'     - *-mode tangle* option
#' - 2020-02-23 Release 0.3
#'     - fix for puts into channels
#' - 2020-11-09 Release 0.4
#'     - github release
#'     - LaTeX support
#'     - fig.width support LaTeX
#'     - documentation fixes
#'     - LaTeX sample document
#'     - fix for inline code special markup using underlines
#'     - other file type extensions for figure using ext option for code chunks
#' - 2021-12-19 Release 0.5.0
#'     - pandoc compatible syntax with .tcl and tcl as chunk indicator
#'     - chunk options with spaces possible instead of comma
#' - 2025-01-18 Release 0.7.0
#'     - making it ready for tcllib inclusion
#'     - splitting app into own file
#'     - writing man-pages
#'     - adding tmdoc::main argv method to make it tclmain aware
#'     - adapting tmdoc.css to be used by mkdoc
#'     - Tcl 9 aware
#'     - documentation fix for app
#' - 2025-03-21 Release 0.8.0
#'     - adding support for shell code chunks to create graphics for
#'       tools like GraphViz dot, PlantUML or sgf-render and many others
#' - 2025-04-02 Release 0.9.0
#'     - adding support for kroki code chunks to create graphics for
#'       tools like GraphViz dot, PlantUML using the [kroki.io](https://kroki.io) web service
#'     - better support for Tcl man pages (images, code examples)
#' - 2025-07-07 Release 0.10.0
#'     - support for text output for shell commands
#'     - more examples added, 
#' - 2025-09-16 Release 0.11.0
#'     - support for %b, the basename of the input file
#'     - C and C++ examples updated
#' - 2025-09-30 Release 0.12.0
#'     - support for %f (for the input filename, so same as %i)
#'     - support for embedding LaTeX equations using [math.vercel.app](https://math.vercel.app) 
#'       webservice
#'     - support for embedding Youtube videos inside iframes
#'     - adding abc music examples
#' - 2025-10-02 Release 0.13.0
#'     - adding abbreviations in yaml header or yaml file
#'     - adding alert boxes for Markdown output
#'     - adding bibliography file entry in YAML header
#'     - adding csv based table creation
#'     - extending tmdoc tutorial for citation use
#'     - fixing tcl code chunk option eval=false
#'     - fixing resetting default of code chunks
#' - 2025-10-XX Release 0.14.0
#'     - adding support for Python and R code embedding
#'
#' ## <a name='todo'>TODO</a>
#'
#' - LaTeX mode if file extension is tnw intead of tmd (done)
#' - fig.width, fig.height options by using args argument in figure (for LaTeX done)
#' - more test cases
#'
#' ## <a name='license'>LICENSE AND COPYRIGHT</a>
#'
#' Tcl Markdown processor tmdoc::tmdoc, version 0.12.1
#'
#' Copyright (c) 2020-2025  Detlef Groth, University of Potsdam, Germany E-mail: <dgroth(at)uni(minus)potsdam(dot)de>
#'
#' License: BSD
#'
#' ## See Also
#'
#' - [mkdoc](https://github.com/mittelmark/mkdoc) - converting Markdown to HTML or extrac ting Markdown documentation from source code files
#' - [pandoc](https://pandoc.org)                 - the most flexible document converter
#' - [pantcl](https://github.com/mittelmark/pantcl) - combines the functionality of mkdoc, tmdoc and adds more languages like R, Python, GraphViz, PlantUML  and many more
#'
