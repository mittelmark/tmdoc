#!/usr/bin/env tclsh -encoding cp1252

proc get_encoding {filename} {
    set encodings {utf-8 iso8859-1 iso8859-15 iso8859-16 cp1252 cp850}
    set all [encoding names]
    foreach enc $all {
        if {$enc ni $encodings} {
            lappend encoding $enc
        }
    }
    foreach enc $encodings {
        catch {
            set f [open $filename "r"]
            fconfigure $f -encoding $enc
            set data [read $f]
            close $f
        } err
        if {$err eq ""} {
            return $enc
        }
    }
}


if {![llength $argv] == 1} {
    puts "Usage: [info script] FILENAME"
} elseif {![file exists [lindex $argv 0]]} {
    puts "Error: File '[lindex $argv 0]' does not exists!"
} else {
    puts [get_encoding [lindex $argv 0]]
}
