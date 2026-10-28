#!/usr/bin/env tclsh
# dtlite.tcl — minimal doctools man-page → HTML generator.
#
# A lightweight stand-in for the doctools `dtlite` tool (which lives in the
# tcllib sibling that is not always checked out).  It converts a doctools
# man-page source file (.man) into a standalone HTML file using the vendored
# doctools package (tools/doctools) and the repo's vendored textutil module.
#
# Usage:
#   tclsh tools/dtplite.tcl -o out.html modules/tmdoc/tmdoc.man
#
# The HTML is written with an embedded CSS block so the page renders
# standalone (no external stylesheets required).

package require Tcl 8.6-

# ---------------------------------------------------------------------------
# Argument handling: -o <outfile> <infile>.man
# ---------------------------------------------------------------------------
set o  ""
set in ""
set i  0
set argc [llength $::argv]
while {$i < $argc} {
    set tok [lindex $::argv $i]
    if {$tok eq "-o"} {
        incr i
        if {$i >= $argc} {
            puts stderr "Error: -o needs a filename"
            exit 1
        }
        set o [lindex $::argv $i]
    } else {
        set in $tok
    }
    incr i
}
if {$in eq "" || $o eq ""} {
    puts stderr "Usage: tclsh dtlite.tcl -o out.html in.man"
    exit 1
}

# ---------------------------------------------------------------------------
# Load doctools (from tools/doctools) plus the textutil dependency.
# ---------------------------------------------------------------------------
set here [file normalize [file dirname [info script]]]
lappend auto_path $here/doctools
lappend auto_path $here/../modules/textutil
lappend auto_path $here/../modules/cmdline

package require doctools
package require textutil::expander

# Point doctools at the vendored mpformats directory that holds fmt.html.
::doctools::search $here/doctools/mpformats

# ---------------------------------------------------------------------------
# Read the man page, evaluate its doctools markup into a doc object, and
# render it to HTML.
# ---------------------------------------------------------------------------
if {![file exists $in]} {
    error "input man page '$in' does not exist"
}
set inf [open $in r]
set text [read $inf]
close $inf

# Build a unique object name.
set base [file tail [file rootname $in]]
set obj "dtlite_$base"
if {[llength [info commands ::$obj]]} {
    catch {::doctools::destroy $obj}
}

set doc [::doctools::new $obj -format html -file $in]
set html [$doc format $text]
# The doctools HTML formatter already emits a complete, self-contained page
# (its own <!DOCTYPE>, <html>, and an embedded <style> block), so write it
# directly rather than nesting it inside another wrapper.
catch {::doctools::destroy $obj}
set of [open $o w]
puts -nonewline $of $html
close $of
puts "wrote $o ([file size $o] bytes)"
