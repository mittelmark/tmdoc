#!/bin/sh
# A Tcl comment, whose contents don't matter \
exec tclsh "$0" "$@"
##############################################################################
#  Author        : Dr. Detlef Groth
#  Created       : Tue Feb 18 06:05:14 2020
#  Last Modified : <251121.0349>
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
#                  2025-10-06 version 0.14.0 adding support for Octave, Python and R code embedding
#                  2025-10-13 version 0.14.1 python bin missing fix, as wel as png file size fix
#                  2025-10-15 version 0.14.2 kroki chunks first check for local installs of dot, plantuml and ditaa
#                  2025-10-23 version 0.15.0 support for asciidoc and typst files (tdoc-adoc, ttyp-typ)
#                                            support for external declaration of abbreviations within Yaml files 
#                  2025-10-26 version 0.15.1 fix for different user run tmdoc on the same machine
#                  2025-10-29 version 0.15.2 fix for try as name of slave interp, naming it to itry to avoid clash with try command
#                  2025-11-01 version 0.15.3 fix for triple quotes within code chunks
#                  2025-11-03 version 0.16.0 fig.path for R code chunk option 
#                                            support for TOC inclusion for Markdown files
#                                            renamed imagepath to fig.path option for kroki as well
#                                            initial Julia support
#                  2025-11-05 version 0.16.1 removed curly braces for fenced code blocks to give pandoc compatibility
#                                            fix for single quotes for code chunk arguments
#                                            fix for width=0 as default for R plot 
#                  2025-11-06 version 0.16.2 fixes code chunk options with spaces around = signs, fixing toc generation if header code is within code chunks or the YAML section 
#                  2025-11-12 version 0.16.3 fix for `r code` chunks, not returning just last word
#                  2025-11-15 version 0.16.4 fix for Windows were errors break the pipe
#                                            better error handling for Python by redirecting stderr to stdout
#                  2025-11-21 version 0.16.5 embedding tmdoc.sty for inclusion into LaTeX output
#                                            fixing empty code chunk displays
#                                            fixing empty lines at the end of code chunks
#                                            fixing encoding language trouble in testing
#
package require Tcl 8.6-
package require fileutil
package require yaml
package provide tmdoc::tmdoc 0.16.5
package provide tmdoc [package provide tmdoc::tmdoc]
source [file join [file dirname [info script]] filter-r.tcl]
source [file join [file dirname [info script]] filter-python.tcl]
source [file join [file dirname [info script]] filter-octave.tcl]
source [file join [file dirname [info script]] filter-julia.tcl]
namespace eval ::tmdoc {
    variable script [info script]
}

# clear all variables and defintions

proc ::tmdoc::interpReset {} {
    if {[interp exists intp]} {
        interp delete intp
        interp delete itry
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
        proc list2tab {header values} {
            set inmode $::inmode
            return [list2mdtab $header $values $inmode]
        }
        proc list2mdtab {header values {inmode md}} {
            set ncol [llength $header]
            set nval [llength $values]
            if {[llength [lindex $values 0]] > 1 && [llength [lindex $values 0]] != [llength $header]} {
                error "Error: list2table - number of values if first row is not a multiple of columns!"
            } 
            if {$inmode eq "md"} {
                set res "|"
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
                        append res "|"
                        foreach v $val {
                            append res " $v |"
                        }
                        append res "\n"
                    } else {
                        if {[expr {int(fmod($c, $ncol))}] == 0} {
                            append res "|"
                        }
                        append res " $val |"
                        incr c
                        if {[expr {int(fmod($c, $ncol))}] == 0} {
                            append res "\n"
                        }
                    }
                }
            } elseif {$inmode eq "adoc"} {
                set c ""
                for {set i 1} {$i < $ncol} {incr i 1} {
                    append c 1,
                }
                append c 1
                append res "\[cols=\"$c\"\]\n|===\n"
                foreach h $header {
                    append res "| $h"
                }
                append res "\n\n"
                foreach val $values {
                    foreach v $val {
                        append res "|$v"
                    }
                    append res "\n"
                }
                append res "|===\n"
            } elseif {$inmode eq "typst"} {
                append res "#set table.hline(stroke: 1.4pt)\n"
                append res "#table(\n"
                append res "  stroke:none,\n"
                append res "  columns: [llength $header],\n"
                append res "  table.hline(),\n"
                foreach h $header {
                    append res " \[*$h*\],"
                }
                append res "\n  table.hline(),\n"
                foreach val $values {
                    foreach v $val {
                        append res " \[$v\],"
                    }
                    append res "\n"

                }
                append res "  table.hline(),\n)\n"
                                    
            } else {
                return "Error: Currently only Markdown and AsciiDoc tables are supported!"
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
    set funcDef [interp eval intp {info body list2mdtab}]
    set argList [interp eval intp {info args list2mdtab}]
    set procCmd "proc ::tmdoc::list2mdtab {$argList} {$funcDef}"
    eval $procCmd
    set funcDef [interp eval intp {info body list2tab}]
    set argList [interp eval intp {info args list2tab}]
    set procCmd "proc ::tmdoc::list2tab {$argList} {$funcDef}"
    eval $procCmd
    
    # todo handle puts options

    # this is the itry interp for the catch statements
    # we first check statements and only if they are ok
    # the real interpreter intp will be used
    interp create itry
    interp eval itry { set yamltext "" }
    interp eval itry {rename puts puts.orig}
    interp eval itry " set pres {} ;  set auto_path {$::auto_path}"
    interp eval itry "package require yaml"
    # todo handle puts options
    
    interp eval itry {proc puts {args} {}}
    interp eval itry {proc include {filename} {}}
    interp eval itry {proc list2tab {header data} {}}    
    interp eval itry {proc list2mdtab {header data} {}}
    interp eval itry {proc nfig {{label ""}} {}}    
    interp eval itry {proc rfig {label} {}}        
    interp eval itry {proc ntab {{label ""}} {}}    
    interp eval itry {proc rtab {label} {}}        
    interp eval itry {proc youtube {video args} {}}            
    interp eval itry {namespace eval citer { } }
    interp eval itry {proc citer::bibliography {{filename ""}} {}}
    interp eval itry {proc citer::cite {key} {}}        
}

proc ::tmdoc::dia2kroki {text {dia graphviz} {ext svg}} {
    set b64 [string map {+ - / _ = ""} [binary encode base64 [zlib compress [encoding convertto utf-8 $text]]]]
    set uri https://kroki.io//$dia/$ext/$b64
}

proc ::tmdoc::diacheck {text {folder .} {dia graphviz} {ext svg}} {
    array set dtype [list graphviz dot pikchr pik plantuml pml ditaa ditaa]
    if {![file isdirectory $folder]} {
        file mkdir $folder
    }
    set diafile [file join $folder [zlib crc32 $text].$dtype($dia)]
    set filename [file join $folder [zlib crc32 $text].$ext]
    if {[file exists $filename]} {
        return $filename
    }
    set out [open $diafile w 0600]
    puts $out $text
    close $out
    if {$dia eq "graphviz"} {
        if {[auto_execok "dot"] eq ""} {
            return ""
        } else {
            if {[catch {exec {*}[list dot -T$ext $diafile -o$filename]}]} {
                return ""
            } 
            return $filename
        }
    }
    if {$dia eq "plantuml"} {
        if {[auto_execok "plantuml"] eq ""} {
            return ""
        } else {
            if {[catch {exec {*}[list plantuml -t$ext $diafile]}]} {
                return ""
            } 
            return $filename
        }
    }
    if {$dia eq "ditaa"} {
        if {[auto_execok "ditaa"] eq ""} {
            return ""
        } else {
            if {[catch {exec {*}[list ditaa $diafile -o $filename]}]} {
                return ""
            } 
            return $filename
        }
    }
    return ""
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
    set mstyle $style
    if {$txt eq ""} {
        return ""
    } else {
        if {$style ne ""} {
            set mstyle "${style}"
        }
        if {$inmode eq "md"} {
            set txt [string trim $txt]
            set mstyle [regsub 3 $mstyle ""]
            append res "```${mstyle}\n${txt}"
            if {![regexp {\n$} $txt]} {
                append res "\n"
            }
            append res "```\n"
        } elseif {$inmode eq "typst"} {
            set style [regsub python3 $style python]
            set style [regsub tclcode $style tcl]
            append res "```${style}\n${txt}"
            if {![regexp {\n$} $txt]} {
                append res "\n"
            }
            append res "```\n"
        } elseif {$inmode eq "man"} {
            append res "\n"
            append res "\[example_begin\]\n\n$txt\n\n\[example_end\]\n"
            append res "\n"
        } elseif {$inmode eq "adoc"} {
            append res "\n"
            if {![regexp {\n$} $txt]} {
                set txt "$txt\n"
            }
            append res "\[,${style}]\n----\n$txt----\n"
            append res "\n"
        } else {
            append res "\\begin{lcverbatim}\n"
            append res "$txt"
            append res "\\end{lcverbatim}"
        }
        return $res
    }
}

proc tmdoc::iimage {} {
    uplevel 1 {
        if {$inmode eq "md"} {
            if {$copt(fig.width) > 0} {
                puts $out "!\[ \]($imgsrc){width=\"$copt(fig.width)\"}"
            } else {
                puts $out "!\[ \]($imgsrc)"
            }
        } elseif {$inmode eq "man"} {
            puts $out "\n\[image [file rootname $imgsrc]\]\n"
        } elseif {$inmode eq "adoc"} {
            puts $out "\nimage::$imgsrc\[\]\n"
        } elseif {$inmode eq "typst"} {
          puts $out "\n#image(\"$imgsrc\")\n"
      } elseif {$inmode eq "latex"} {
          if {$copt(fig.width) > 0} {
              puts $out "\n\\includegraphics\[width=$copt(fig.width)\]{[file rootname $imgsrc]}\n"
          } else {
              puts $out "\n\\includegraphics{[file rootname $imgsrc]}\n"
          }
        }
        
    }
}
proc tmdoc::cairosvg {filename dict} {
    array set opt $dict
    set fname [file rootname $filename]
    if {$opt(ext) in [list "pdf" "png"]} {
        if {[auto_execok cairosvg] eq ""} {
            return [list "Error: pdf and png conversion needs cairosvg, please install cairosvg https://www.cairosvg.org !" ""]
        }
    }
    if {[dict get $dict ext] eq "pdf"} {
        exec cairosvg $fname.svg -o $fname.pdf ;# -W $opt(width) -H $opt(height)
        return ${fname}.pdf
    } elseif {[dict get $dict ext] eq "png"} {
        exec cairosvg $fname.svg -o $fname.png ;#-W $opt(width) -H $opt(height)
        return ${fname}.png
    } elseif {[dict get $dict ext] ne "svg"} {
        return "Error unkown extension name valid values are svg, pdf, png"
    } else {
        return $filename
    }
}

# public functions - the main function process the files

proc ::tmdoc::tmdoc {filename outfile args} {
    variable script
    if {[string tolower [file extension $filename]] in [list .tnw .tex .snw]} {
        set inmode latex
        if {![file exists [file join [file dirname $filename] tmdoc.sty]]} {
            ## copy out tmdoc.sty
            file copy [file join [file dirname $script] tmdoc.sty] [file dirname $filename]
        }
    } elseif {[string tolower [file extension $filename]] in [list .tan .man .tman]} {
        set inmode man
    } elseif {[regexp {doc$} [string tolower [file extension $filename]]]} {
        set inmode adoc
    } elseif {[regexp {(typ|typst)$} [string tolower [file extension $filename]]]} {
        set inmode typst
    } else {
        ## default is Markdown
        set inmode md
    }
    set ::inmode $inmode
    set yaml false
    array set arg [list infile $filename outfile $outfile -mode weave -abbrev "" -toc false]
    if {[llength $args] > 0} {
        array set arg {*}$args
    }
    set abbrev [dict create default ""]
    if {$arg(-abbrev) ne "" && [file exists $arg(-abbrev)]} {
        if [catch {open $arg(-abbrev) r} infha] {
            return code -error "Cannot open $arg(-abbrev)"
        } else {
            set yamltext [read $infha]
            close $infha
            set abbrev [dict create {*}[yaml::yaml2dict $yamltext]]
            set yaml true
        }

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
                    ext png chunk.ext txt fig.width 0]
    ## r, python, octave, julia
    array set dopt [list eval true echo true results show fig false include true pipe python3 \
        fig.width 0 fig.height 0 fig.cap {} label chunk-nn ext png chunk.ext txt]
    ## bash / shell
    array set bdopt [list cmd "" echo true eval true results show fig true include true \
        fig.width 0 label chunk-nn ext png chunk.ext txt]
    ## kroki
    array set kdopt [list echo true eval true results show fig true include true \
                     fig.width 0 label chunk-nn ext png dia ditaa \
                     fig.path .]
    ## mtex
    array set tdopt [list echo true eval true results show fig true include true \
        label chunk-nn fig.path . fig.width 0 ext png]
    interpReset
    interp eval intp "set ::inmode $inmode"
    if [catch {open $filename r} infh] {
        return -code error "Cannot open $filename: $infh"
    } else {
        set chunki 0
        set lnr 0
        set yamlflag false
        set yamltext ""
        set toc ""
        if {$arg(-toc)} {
            set tocfile [file rootname $filename].toc
            if {![file exists $tocfile]} {
                set tout [open $tocfile w 0600]
                puts $tout "Hint: Run tmdoc twice on this document to get a correct TOC!"
                close $tout
            }
        }
        while {[gets $infh line] >= 0} {
            if {$arg(-toc)} {
                if {$mode eq "text" && !$yamlflag && [regexp {^## +(.+)} $line -> title]} {
                    set anchor [string trim [string tolower [regsub -all {[^A-za-z]} $title ""]]]
                    puts $out "<a name=\"$anchor\"> </a>"
                    append toc "* \[$title\](#$anchor)\n"
                } elseif {$mode eq "text" && !$yamlflag && [regexp {^### +(.+)} $line -> title]} {
                    set anchor [string trim [string tolower [regsub -all {[^A-za-z]} $title ""]]]
                    puts $out "<a name=\"$anchor\"> </a>"
                    append toc "    * \[$title\](#$anchor)\n"
                }

            }
            if {$mode eq "text" && !$yamlflag} {
                set line [regsub {^\s*\[@references\]\s*$} $line "`tcl citer::bibliography`"]
            }
            incr lnr
            if {$yamlflag && [regexp {^---} $line]} {
                set yamlflag false
                set yabbrev [dict create {*}[yaml::yaml2dict $yamltext]]
                if {[dict exists $yabbrev abbreviations]} {
                    if {[file exists [dict get $yabbrev abbreviations]]} {
                        set afile [open [dict get $yabbrev abbreviations] r]
                        append yamltext [read $afile]
                        close $afile
                        set yabbrev [dict create {*}[yaml::yaml2dict $yamltext]]
                    }
                }
                set abbrev [dict merge $abbrev $yabbrev]
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
            if {$mode eq "text" && [regexp {^ {0,2}```\{\.?(r|oc|py|ju?l).*\}} $line]} {
                set line [regsub -nocase {\{\.?r(.*)\}} $line "{.pipe pipe=R\\1}"]
                set line [regsub -nocase {\{\.?oc[a-z]*(.*)\}} $line "{.pipe pipe=octave\\1}"]
                set line [regsub -nocase {\{\.?py[a-z]*(.*)\}} $line "{.pipe pipe=python3\\1}"]
                set line [regsub -nocase {\{\.?ju?l[a-z]*(.*)\}} $line "{.pipe pipe=julia\\1}"]
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
            if {$mode eq "text" && (![regexp {   ```} $line] && [regexp {^\s{0,2}```\s?\{\.?tcl\s*\}} $line -> opts])} {
                set mode code
                incr chunki
                array set copt [array get dopt]
            } elseif {$mode eq "text" && (![regexp {   ```} $line] && [regexp {^\s{0,2}```\s?\{\.?tcl\s+(.*)\}} $line -> opts])} {
                set mode code
                incr chunki
                array set copt [array get dopt]

                # TODO: spaces in fig.cap etc
                ::tmdoc::GetOpts 
                continue
            } elseif {$mode eq "text" && (![regexp {   ```} $line] && [regexp {^\s{0,2}```\s?\{\.?(shell|cmd)\s+(.*)\}} $line -> tp opts])} {
                set mode shell
                incr chunki
                array set copt [array get bdopt]
                # TODO: spaces in fig.cap etc
                ::tmdoc::GetOpts 
                continue
            } elseif {$mode eq "text" && (![regexp {   ```} $line] && [regexp {^\s{0,2}```\s?\{\.?(kroki)\s*(.*)\}} $line -> tp opts])} {
                set mode kroki
                incr chunki
                array set copt [array get kdopt]
                # TODO: spaces in fig.cap etc
                ::tmdoc::GetOpts 
                continue
            } elseif {$mode eq "text" && (![regexp {   ```} $line] && [regexp {^\s{0,2}```\s?\{\.?(mtex)(\s*.*)\}} $line -> tp opts])} {
                set mode mtex
                incr chunki
                array set copt [array get tdopt]
                ::tmdoc::GetOpts 
                continue
            } elseif {$mode eq "text" && (![regexp {   ```} $line] && [regexp {^\s{0,2}```\s?\{\.?(pipe)(\s*.*)\}} $line -> tp opts])} {
                set mode pipe
                incr chunki
                array set copt [array get dopt]
                ::tmdoc::GetOpts 
                continue
            } elseif {$mode eq "text" && [regexp {^ {0,3}```\{\.([a-z0-9]+)(\s*.*)\}} $line -> nmode opts]} {
                incr chunki
                set mode $nmode
                array set copt [array get mopt]
                ### default is asis for csv
                if {$mode eq "csv"} {
                    set copt(results) "asis"
                }
                ::tmdoc::GetOpts 
                continue
            } elseif {$mode in [list csv pipe] && [regexp {^ {0,2}```} $line]} {
                if {$copt(echo)} {
                    if {$mode eq "pipe"} {
                        puts $out [tmdoc::block [string trim $ginput] $inmode $copt(pipe)]
                    } else {
                        puts $out [tmdoc::block $ginput $inmode]
                    }
                }
                if {$mode eq "csv"} {
                    if {$copt(results) eq "asis"}  {
                        puts $out [tmdoc::csv $ginput]
                    } elseif {$copt(results) eq "show"} {
                        puts $out [tmdoc::block $ginput $inmode]
                    }
                } elseif {$mode eq "pipe"} {
                    
                    if {$copt(pipe) eq "python" || $copt(pipe) eq "python3"} {
                        set res [tmdoc::python::filter $ginput [dict create {*}[array get copt]]]
                    } elseif {$copt(pipe) eq "octave"} {
                        set res [tmdoc::octave::filter $ginput [dict create {*}[array get copt]]]
                    } elseif {$copt(pipe) eq "julia"} {
                        set res [tmdoc::julia::filter $ginput [dict create {*}[array get copt]]]
                    } else {
                        ## R
                        set res [tmdoc::r::filter $ginput [dict create {*}[array get copt]]]
                    }
                    if {$copt(results) eq "show"} {
                        puts $out [tmdoc::block [lindex $res 0] $inmode $copt(pipe)]
                    } elseif {$copt(results) eq "asis"} {
                        puts $out [lindex $res 0]
                    } 
                    if {$copt(fig) && $copt(include)} {
                        set imgsrc [lindex $res 1]
                        iimage
                        #puts $out "!\[ \]([lindex $res 1])"
                    }

                }
                set ginput ""
                set mode text
                array unset copt
                continue
            } elseif {$mode eq "shell" && [regexp {^ {0,2}```} $line]} {
                if {$copt(echo)} {
                    set cont [tmdoc::block $bashinput $inmode code]
                    puts $out $cont
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
                        set imgsrc "$copt(label).$copt(ext)"
                        iimage
                        if {$err ne ""} {
                            set cont [tmdoc::block $err $inmode error]
                            puts $out $cont
                        }
                            
                    } else {
                        if [catch {open $copt(label).$copt(ext) r} infh2] {
                            set cnt "Cannot open $copt(label).$copt(ext)"
                        } else {
                            set cnt [read $infh2]
                            close $infh2
                        }
                        set cont [tmdoc::block $cnt $inmode out]
                        puts $out $cont
                    }
                }
                set bashinput ""
                set mode text
                array unset copt
            } elseif {$mode eq "kroki" && [regexp {^ {0,2}```} $line]} {
                if {$copt(echo)} {
                    set cont [tmdoc::block $krokiinput $inmode kroki]
                    puts $out $cont
                }
                ## check local installs of kroki, ditaa or plantuml first
                set filename [diacheck $krokiinput $copt(fig.path) $copt(dia) $copt(ext)]
                if {$filename eq ""} {
                    set url [dia2kroki $krokiinput $copt(dia) $copt(ext)] 
                    set filename [url2crc32file $url $copt(fig.path) $copt(ext)]
                }
                if {$copt(include)} {
                    set imgsrc $filename
                    iimage
                }
                set krokiinput ""
                set mode text
                array unset copt                
            } elseif {$mode eq "mtex" && [regexp {^ {0,2}```} $line]} {
                if {$copt(echo)} {
                    set cont [tmdoc::block $mtexinput $inmode mtex]
                    puts $out $cont
                }
                #set url https://math.vercel.app?from=[ue ${mtexinput}].svg
                set url https://latex.codecogs.com/png.image?[ue ${mtexinput}]
                set filename [url2crc32file $url $copt(fig.path) $copt(ext)]
                #if {$copt(ext) eq "svg"} {
                #    set filename [tmdoc::cairosvg $filename [array get copt]]
                #}
                if {$copt(include)} {
                    set imgsrc $filename
                    iimage
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
            } elseif {$mode eq "code" && [regexp {^ {0,2}```} $line]} {
                if {$copt(echo)} {
                    set cont [tmdoc::block [string trim $tclcode] $inmode tclcode]
                    puts $out $cont
                }
                if {$copt(eval)} {
                    if {[catch {interp eval itry $tclcode} res]} {
                        puts $out [tmdoc::block [regsub " +invoked from within.+" "$::errorInfo" ""] $inmode tclerr]
                    } else {
                        set res [interp eval intp $tclcode]
                        set pres [interp eval intp gputs]
                        if {$copt(results) eq "asis"} {
                            puts -nonewline $out $pres
                        } elseif {$copt(results) eq "show"} {
                            if {$inmode eq "md"} {
                                if {$res ne "" || $pres ne ""} {
                                    puts $out "```tclout"
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
                            } elseif {$inmode eq "typst"} {
                                if {$res ne "" || $pres ne ""} {
                                    puts $out "```tclout"
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
                            } elseif {$inmode eq "adoc"} {
                                if {$res ne "" || $pres ne ""} {
                                    puts $out "\[,tclout\]\n----"
                                }
                                if {$pres ne ""} {
                                    puts -nonewline $out "$pres"
                                }
                                if {$res ne ""} {
                                    puts $out "==> $res"
                                }
                                if {$res ne "" || $pres ne ""} {
                                    puts $out "----"
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
                                        set imgsrc $imgfile
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
                    if {[catch {interp eval itry $t} res]} {
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
                    set res [r::filter $t [dict create pipe R eval true echo false terminal false]]
                    set res [string trim [lindex $res 0] end]
                    set line [regsub -all {_}  "$pre$res$post" {\\_}]
                }
                while {[regexp {(.*?)`py ([^`]+)`(.*)$} $line -> pre t post]} {
                    set res [python::filter $t [dict create pipe python3 eval true echo false terminal false]]
                    #qset res [lindex [split [lindex [lindex $res 0] 0] " "] end]
                    set res [regsub {.+> } [lindex $res 0] ""]
                    set line [regsub -all {_}  "$pre$res$post" {\\_}]
                }
                while {[regexp {(.*?)`oc ([^`]+)`(.*)$} $line -> pre t post]} {
                    set res [octave::filter $t [dict create pipe octave eval true echo false terminal false wait 800]]
                    set res [lindex [split [lindex [lindex $res 0] 0] " "] end]
                    set line [regsub -all {_}  "$pre$res$post" {\\_}]
                }
                while {[regexp {(.*?)`jl ([^`]+)`(.*)$} $line -> pre t post]} {
                    set res [julia::filter $t [dict create pipe julia eval true echo false terminal false wait 300]]
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
        if {$arg(-toc)} {
            set tout [open $tocfile w 0600]
            puts $tout "<div class='toc'>\n\n### Table of Contents\n\n"
            puts $tout $toc
            puts $tout "</div>"            
            close $tout
        }
        if {[interp exists intp]} {
            interp eval intp { catch {destroy . } }
            interp delete intp
        }
        if {[interp exists itry]} {
            interp eval itry { catch { destroy . } }
            interp delete itry
        }
    }
}
proc ::tmdoc::GetOpts {} {
    uplevel 1 {
        while {[regexp -indices {["'](.+?)['"]} $opts m1 m2]} {
            set before [string range $opts 0 [expr {[lindex $m1 0]-1}]] 
            set match [regsub -all { } [string range $opts [lindex $m2 0] [lindex $m2 1]] "%20"]
            set match [regsub -all "=" $match "%3d"]
            set after [string range $opts [expr {[lindex $m1 1]+1}] end] 
            set opts ${before}${match}${after}
        }
        set opts [regsub -all { *= *} $opts =]
        set opts [regsub -all {,+} [regsub -all { +} $opts ,] ,]
        set opts [regsub {^,} $opts ""]
        foreach opt [split $opts ","] {
            set opt [string trim [regsub -nocase false [regsub -nocase true $opt true] false]]
            set o [split $opt =] 
            set key [lindex $o 0]
            set value [regsub {["'](.+)['"]} [lindex $o 1] "\\1"]
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
proc ::tmdoc::tmeval {text {ext tmd}} {
    set filename [fileutil::tempfile]
    set out [open $filename.$ext w 0600]
    puts $out $text
    close $out
    tmdoc::tmdoc $filename.$ext $filename.md
    set infh [open $filename.md r]
    set ret [read $infh]
    close $infh
    file delete $filename.$ext
    file delete $filename.md
    return $ret
}



proc tmdoc::csv {txt} {
    set res ""
    set x 0
    set header [list]
    set values [list]
    foreach line [split $txt \n] {
        if {[regexp {^\s*$} $line]} {
            continue
        }
        incr x
        set nline [regsub -all {[,;]} $line "\t"]
        if {$x == 1} {
            set header [split $nline "\t"]
        } else {
            lappend values [split $nline "\t"]
        }
        #set nline [regsub -all {[,;\t]} $line " | "]
        #append res "| $nline |\n"
        #if {$x == 1} {
        #    append hrule [regsub -all {[^\s|]} $nline "-"]
        #    append res "| $hrule |\n"
        #} 
    }
    set res [list2tab $header $values]
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
               
        tmdoc - Literate programming with Tcl for Markdown, AsciiDoc, Typst, 
                Quarkdown  and LaTeX documents, Version __VERSION__
                Converts Markdown, AsciiDoc, Typst, Quarkdown or LaTeX documents
                with embedded R, Python, Octave, Tcl Diagram code and other
                extensions with evaluated code chunks and embedded images
                
        Positional arguments (required):
        
            INFILE  - input file usually Markdown or LaTeX with embedded Tcl code
                      either in code chunks starting with ```{.tcl} or in short
                      inline code  with `tcl set x` syntax.
                      
            OUTFILE - output file usually a Markdown or LaTeX file, if not given
                      or if outfile is the `-` output is send to stdout
           
                     
        Optional arguments:
            
           --help               - displays this help page, and exit
           --version            - display version number, and exit
           --license            - display license information, and exit
           --mode  weave|tangle - either `weave` for evaluating the code chunks
                                  or `tangle` for extracting all Tcl code  
           --abbrev  FILENAM E  - an Yaml abbreviation file used to expand abbreviations
                                  within curly braces
           --toc   false|true   - should a table of contents file (toc.md) 
                                  ready for inclusion being generated
                                  
                          
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
        set idxa [lsearch -exact $argv {--abbrev}]
        set idxt [lsearch -exact $argv {--toc}]        
        set mode weave
        set abbrevfile ""
        set toc false
        if {$idxt > -1} {
            set toc [lindex $argv [expr {$idxt + 1}]]
            if {![string is boolean $toc]} {
                puts "Error: The argument for --toc must be either true or false!"
                puts $usage
                exit 0
            }
            set argv [lreplace $argv $idxt [expr {$idxt + 1}]]
        }
        
        if {$idxa > -1} {
            set abbrevfile [lindex $argv [expr {$idxa + 1}]]
            if {![file exists $abbrevfile]} {
                puts "Error: Abbreviation file '$abbrevfile' does not exists!"
                puts $usage
                exit 0
            }
            set argv [lreplace $argv $idxa [expr {$idxa + 1}]]
        }
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
        tmdoc::tmdoc [lindex $argv 0] [lindex $argv 1] [list -mode $mode -abbrev $abbrevfile -toc $toc]
    }
}

namespace eval ::tmdoc {
    namespace export tmdoc tmeval
}

