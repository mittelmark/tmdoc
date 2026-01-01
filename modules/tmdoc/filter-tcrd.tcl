#!/usr/bin/env tclsh
##############################################################################
#
# Copyright (C) 2026 MicroEmacs User.
#
# All rights reserved.
#
# Synopsis:    
# Authors:     MicroEmacs User
#
##############################################################################

package require tcrd
package require tsvg
namespace eval tmdoc { } 
namespace eval tmdoc::tcrd {
    proc filter {cont dict} {
        set def [dict create results show eval true include true label null transpose 0 inline true \
                 chord false chordname "" imagepath images fig false ext svg \
                 circlecolor black fig.width 100]
        set dict [dict merge $def $dict]
        if {![dict get $dict eval]} {
            return [list "" ""]
        }
        if {[dict get $dict chord]} {
            dict set dict fig true
        }
        
        set owd [pwd] 
        set fname [file join $owd [dict get $dict imagepath] [dict get $dict label]].svg

        if {[catch {
             set width [dict get $dict fig.width]
             if {[dict get $dict chord]} {
                 set ext .[dict get $dict ext]
                 set svgall ""
                 set x 0
                 foreach line [split $cont "\n"] {
                     set line [string trim $line]
                     set line [regsub -all { +}  $line " "]
                                      
                     foreach {key frets} [split $line " "] {
                         append svgall "<g transform=\"translate([expr {$x*($width+20)}], 0)\">\n"
                         append svgall [tcrd::svgchords $key $frets -circlecolor [dict get $dict circlecolor] -width $width]
                         append svgall "\n</g>\n"
                     }
                     incr x
                     
                 }
                 set out [open $fname w 0600]
                 puts $out "<?xml version=\"1.0\" encoding=\"utf-8\" standalone=\"yes\"?>"
                 puts $out "   <svg version=\"1.1\" xmlns=\"http://www.w3.org/2000/svg\" height=\"255\" width=\"[expr {($width+20)*$x}]\">"
                 puts $out $svgall
                 puts $out "</svg>"
                 close $out
                 if {$ext in [list .pdf .png]} {
                     if {[auto_execok cairosvg] eq ""} {
                         error "Conversion to $ext needs the cairosvg tool!"
                     }
                 } elseif {$ext ne ".svg"}  {
                     error "Unkown file extension, know file extensions are: .svg, .pdf, .png"
                 }
                 set outfile [regsub {.svg$} $fname $ext]
                 if {$ext in [list .pdf .png]} {
                     exec cairosvg $fname -o $outfile -W [expr {($width+20)*$x}] -H 255
                     set fname $outfile
                 } 
                 set res $cont
             } elseif {[dict get $dict inline]} {
                 set res [tcrd::chords $cont [dict get $dict transpose]] 
             } elseif {[dict get $dict transpose] == 0}  {
                 set res $cont
             } else {
                 set res [tcrd::songtranspose $cont [dict get $dict transpose]] 
             }
         }]} {
            set res "Error: [regsub {\n +invoked.+} $::errorInfo {}]"
        }

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
}




