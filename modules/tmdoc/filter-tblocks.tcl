#!/usr/bin/env tclsh
##############################################################################
#
# Copyright (C) 2026 MicroEmacs User.
#
# All rights reserved.
#
# Synopsis:
#  filter-tblocks -- render tblocks diagrams from Markdown code chunks.
#
#  A ```{.tblocks} chunk is Markdown that describes a block diagram.  The
#  tblocks package turns it into an SVG/PNG/PDF figure.  This filter is invoked
#  by tmdoc.tcl via  tmdoc::tblocks::filter <markdown> <chunk-options-dict>
#  and must return a list [resultsText figurePath]; when -fig is false the
#  figure path is an empty string.
#
# Authors:     MicroEmacs User
#
##############################################################################

package require tblocks
namespace eval ::tmdoc::tblocks { }

# Drop external @import rules from a generated SVG.  tblocks writes the
# web font import as
#   @import url(https://fonts.bunny.net/css?family=...);
# with an unquoted url() token, which weasyPrint refuses to parse - it then
# drops the whole figure from the PDF (the missing tblocks examples in the
# tutorial).  Browsers block external references for SVGs used as images
# anyway, so the font never applied there either.  The class rules in the
# same <style> block are kept, the text just falls back to the default font.
proc ::tmdoc::tblocks::sanitize {path} {
    if {![file exists $path]} {
        return
    }
    set fh [open $path r]
    fconfigure $fh -encoding iso8859-1
    set svg [read $fh]
    close $fh
    ## @import ...; up to the first semicolon, both url() and quoted forms
    set svg [regsub -line {^[ \t]*@import[ \t]+[^;]*;[ \t]*$} $svg ""]
    set fh [open $path w]
    fconfigure $fh -encoding iso8859-1
    puts -nonewline $fh $svg
    close $fh
}

proc ::tmdoc::tblocks::filter {cont dict} {
    # Default chunk options; merge the ones given on the code fence.
    set def [dict create results show eval true include true label null \
             mode boxes ext svg fig false fig.path images fig.width 100]
    set dict [dict merge $def $dict]
    if {![dict get $dict eval]} {
        return [list "" ""]
    }

    set owd [pwd]
    set res ""
    set fname ""

    if {[dict get $dict fig]} {
        # Render the chunk Markdown to a figure file, then optionally convert
        # it to the requested extension (svg|png|pdf).
        if {![file isdirectory [dict get $dict fig.path]]} {
            file mkdir [dict get $dict fig.path]
        }
        set base [dict get $dict label]
        if {$base eq "" || $base eq "null"} {
            set base "tblocks"
        }
        set outext .[dict get $dict ext]

        # tblocks::main reads a Markdown file and writes an SVG (or PDF).  Run
        # it against a temporary input that contains the chunk body.
        set tmpmd [file join $owd .tmdoc-tblocks-$base.md]
        set tmpout [file join $owd [dict get $dict fig.path] ${base}${outext}]
        set infh [open $tmpmd w]
        puts $infh $cont
        close $infh
        if {[catch {
            ::tblocks::main [list $tmpmd $tmpout]
            ## make the SVG loadable by weasyPrint / browsers (see above)
            sanitize $tmpout
            if {$outext ne ".svg"} {
                tmdoc::cairosvg $tmpout [array get dict dict]
            }
        } e]} {
            set res "Error: $e"
            file delete -force $tmpmd
        } else {
            file delete -force $tmpmd
            set fname $tmpout
        }
    }

    # Results text handling, mirroring filter-tcrd.tcl.
    if {[dict get $dict results] eq "hide"} {
        set res ""
    }
    if {![dict get $dict fig]} {
        set fname ""
    } else {
        set res ""
    }
    return [list $res $fname]
}
