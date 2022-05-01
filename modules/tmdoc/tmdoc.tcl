#!/bin/sh
# A Tcl comment, whose contents don't matter \
exec tclsh "$0" "$@"
##############################################################################
#  Author        : Dr. Detlef Groth
#  Created       : Tue Feb 18 06:05:14 2020
#  Last Modified : <220501.1440>
#
# Copyright (c) 2020-2022  Dr. Detlef Groth, E-mail: detlef(at)dgroth(dot)de
# 
#  Description	 : Command line utility and package to embed and evaluate Tcl code
#                  inside Markdown documents, a technique known as literate programming. 
#
#  History       : 2020-02-19 version 0.1
#                  2020-02-21 version 0.2 
#                  2020-02-23 version 0.3
#                  2020-11-09 version 0.4
#                  2021-12-19 version 0.5.0
#                  2022-05-XX version 0.6.0 (tcllib) 
package require Tcl 8.6
package require fileutil
package provide tmdoc::tmdoc 0.6.0
package provide tmdoc [package provide tmdoc::tmdoc]
namespace eval ::tmdoc {} 


proc ::tmdoc::interpReset {} {
    if {[interp exists intp]} {
        interp delete intp
        interp delete try
    }
    interp create intp
    interp eval intp " set pres {} ;  set auto_path {$::auto_path}"
    interp eval intp { rename puts puts.orig }
    interp eval intp { 
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
    interp eval try { rename puts puts.orig }
    # todo handle puts options
    interp eval try { proc puts {args} {  } }
}

# public functions

proc ::tmdoc::tmdoc {filename outfile args} {
    if {[string tolower [file extension $filename]] in [list .tnw .tex]} {
        set inmode latex
    } else {
        set inmode md
    }
    array set arg [list infile $filename  outfile $outfile -mode weave] 
    if {[llength $args] > 0} {
        array set arg {*}$args
    }
    if {$arg(outfile) ni [list stdout -]} {
        if {[file extension $arg(outfile)] eq ".tex"} {
            set inmode latex
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
    set tclcode ""
    array set dopt [list echo true results show fig false include true \
                    fig.width 12cm fig.height 12cm fig.cap {} label chunk-nn ext png]
    interpReset
    if [catch {open $filename r} infh] {
        return -code error "Cannot open $filename: $infh"
    } else {
        set chunki 0
        while {[gets $infh line] >= 0} {
            if {$mode eq "text" && (![regexp {   ```} $line] && [regexp {```\s?\{\.?tcl\s*\}} $line -> opts])} {
                set mode code
                incr chunki
                array set copt [array get dopt]
            } elseif {$mode eq "text" && (![regexp {   ```} $line] && [regexp {```\s?\{\.?tcl\s+(.*)\}} $line -> opts])} {
                set mode code
                incr chunki
                array set copt [array get dopt]
                # TODO: spaces in fig.cap etc
                set opts [regsub -all {,+} [regsub -all { +} $opts ,] ,]
                foreach opt [split $opts ","] {
                    set opt [string trim [string tolower $opt]]
                    set o [split $opt =] 
                    set key [lindex $o 0]
                    set value [regsub {"(.+)"} [lindex $o 1] "\\1"]
                    
                    set copt($key) $value
                }
                # setting default label if no label was given
                foreach key [array names copt] {
                    if {$key eq "label" && $copt($key) eq "chunk-nn"} {
                        set value [regsub {nn} $copt($key) $chunki]
                        set copt($key) $value
                    }
                }
                continue
            } elseif {$mode eq "code" && [regexp {```} $line]} {
                if {$copt(echo)} {
                    if {$inmode eq "md"} {
                        puts $out "```{.tclcode}"
                        puts -nonewline $out $tclcode
                        puts $out "```"
                    } else {
                        puts $out "\\begin{lcverbatim}"
                        puts -nonewline $out $tclcode
                        puts $out "\\end{lcverbatim}"
                    }
                }
                if {[catch {interp eval try $tclcode} res]} {
                    if {$inmode eq "md"} {
                        puts $out "```{.tclerr}\n$res\n```\n"
                    } else {
                        puts $out "\n\\begin{lrverbatim}\n$res\n\\end{lrverbatim}\n"
                    }
                } else {
                    set res [interp eval intp $tclcode]
                    set pres [interp eval intp gputs]
                    if {$copt(results) eq "show"} {
                        if {$inmode eq "md"} {
                            if {$res ne "" || $pres ne ""} {
                                puts $out "```{.tclout}"
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
                    }
                    if {$copt(fig)} {
                        set imgfile [file tail [file rootname $filename]]-$copt(label).$copt(ext)
                        if {[interp eval intp "info commands figure"] eq ""} {
                            if {$inmode eq "md"} {
                                puts $out "```{.tclerr}\nYou need to define a figure procedure \nwhich gets a filename as argument"
                                puts $out "proc figure {filename} { }\n\nwhere within you create the image file```\n"
                            } else {
                                puts $out "\n\\begin{lrverbatim}\n\nYou need to define a figure procedure \nwhich gets a filename as argument\n"
                                puts $out "proc figure {filename} { }\n\nwhere within you create the image file\\end{lrverbatim}\n"
                            }
                        } else {
                            interp eval intp [list figure $imgfile]
                            if {$copt(include)} {
                                if {$inmode eq "md"} {
                                    puts $out "\n!\[\]($imgfile)\n"
                                } else {
                                    puts $out "\n\\includegraphics\[width=$copt(fig.width)\]{$imgfile}\n"
                                }
                            }
                        }
                    }
                }
                set tclcode ""
                set mode text
                continue
            } elseif {$mode eq "text" && [regexp {[> ]{0,2}```} $line]} {
                set mode pretext
                puts $out $line
                continue
            } elseif {$mode eq "pretext" && [regexp {[> ]{0,2}```} $line]} {
                puts $out $line
                set mode text
            } elseif {$mode eq "text"} {
                # todo check for `tcl fragments`
                while {[regexp {(.*?)`tcl ([^`]+)`(.*)$} $line -> pre t post]} {
                    if {[catch {interp eval try $t} res]} {
                        if {$inmode eq "md"} {
                            set line "$pre*??$res??*$post"
                        } else {
                            set line [regsub -all {_} "$pre*??$res??*$post" {\\_}]
                        }
                    } else {
                        set res [interp eval intp $t]
                        if {$inmode eq "md"} {                                                
                            set line "$pre$res$post"
                        } else {
                            set line [regsub -all {_}  "$pre$res$post" {\\_}]
                        }
                    }

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
                error "error on '$line' should be not reachable"
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
#' - 2022-05-XX Release 0.6.0
#'     - making it ready for tcllib inclusion
#'     - splitting app into own file
#'     - writing man-pages
#'
#' ## <a name='todo'>TODO</a>
#'
#' - LaTeX mode if file extension is tnw intead of tmd (done)
#' - fig.width, fig.height options by using args argument in figure (for LaTeX done)
#' - your suggestions ...
#'
#'
#' ## <a name='license'>LICENSE AND COPYRIGHT</a>
#'
#' Tcl Markdown processor tmdoc::tmdoc, version 0.6.0
#'
#' Copyright (c) 2020-2022  Dr. Detlef Groth, E-mail: <detlef(at)dgroth(dot)de>
#' 
#' License: BSD
