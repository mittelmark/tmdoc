##-*- makefile -*-############################################################
#
#  Created By    : Detlef Groth, University of Potsdam
#  Created       : 2025-01-04 18:30:01
#
#  Description	 : Makefile for tmdoc project
#
#
##############################################################################

TCL9=~/.local/opt/bin/tclsh9.0
TCL=tclsh
TCLLIB=https://raw.githubusercontent.com/tcltk/tcllib/refs/heads/master/modules
CITER=https://raw.githubusercontent.com/mittelmark/citer/refs/heads/main
TDOT=https://raw.githubusercontent.com/mittelmark/tdot/refs/heads/main
default:
	echo "Usage: make app|docu|test"
app:
	-test -d app-build && rm -rf app-build
	-test -d bin || mkdir bin
	mkdir app-build
	cd app-build && mkdir -p tmdoc.vfs/lib/tmdoc
	cd app-build && mkdir -p tmdoc.vfs/lib/bibtex
	cd app-build && mkdir -p tmdoc.vfs/lib/citer
	cd app-build && mkdir -p tmdoc.vfs/lib/cmdline
	cd app-build && mkdir -p tmdoc.vfs/lib/fileutil
	cd app-build && mkdir -p tmdoc.vfs/lib/markdown		
	cd app-build && mkdir -p tmdoc.vfs/lib/textutil
	cd app-build && mkdir -p tmdoc.vfs/lib/yaml	
	cd app-build && mkdir -p tmdoc.vfs/lib/tdot
	cd app-build && cp ../modules/tmdoc/*.tcl tmdoc.vfs/lib/tmdoc/
	cd app-build && cp ../modules/tmdoc/tmdoc.sty tmdoc.vfs/lib/tmdoc/
	cd app-build && cp ../modules/bibtex/*.tcl tmdoc.vfs/lib/bibtex/
	cd app-build && cp ../modules/citer/*.tcl tmdoc.vfs/lib/citer/	
	cd app-build && cp ../modules/cmdline/*.tcl tmdoc.vfs/lib/cmdline/
	cd app-build && cp ../modules/fileutil/*.tcl tmdoc.vfs/lib/fileutil/	
	cd app-build && cp ../modules/markdown/*.tcl tmdoc.vfs/lib/markdown/			
	cd app-build && cp ../modules/textutil/*.tcl tmdoc.vfs/lib/textutil/		
	cd app-build && cp ../modules/tdot/*.tcl tmdoc.vfs/lib/tdot/			
	cd app-build && cp ../modules/yaml/*.tcl tmdoc.vfs/lib/yaml/				
	cd app-build && cp ~/workspace/tcllib/modules/cmdline/*.tcl tmdoc.vfs/lib/cmdline/
	cd app-build && cp ~/workspace/tcllib/modules/textutil/*.tcl tmdoc.vfs/lib/textutil/	
	cd app-build && cp ~/workspace/tcllib/modules/fileutil/*.tcl tmdoc.vfs/lib/fileutil/		
	cd app-build && echo "lappend auto_path [file join [file dirname [info script]] lib]" > tmdoc.vfs/main.tcl
	cp apps/tmdoc app-build/tmdoc.tcl
	cd app-build && tpack wrap tmdoc.tapp --lz4
	tclsh app-build/tmdoc.tapp --version
	tclsh app-build/tmdoc.tapp --help
	cp app-build/tmdoc.tapp bin/tmdoc-`tclsh app-build/tmdoc.tapp --version`.bin	
docu:
	TCLLIBPATH=`pwd`/../tcllib/modules ../tcllib/apps/dtplite -o modules/tmdoc/tmdoc.html html modules/tmdoc/tmdoc.man 
	TCLLIBPATH=`pwd`/../tcllib/modules ../tcllib/apps/dtplite -o apps/tmdoc.html html apps/tmdoc.man 
test:
	TCLLIBPATH=modules tclsh modules/tmdoc/tmdoc.test	

test9:
	TCLLIBPATH=modules $(TCL9) modules/tmdoc/tmdoc.test	

fileutil: lib
	if [ ! -d modules/$@ ] ; then mkdir -p modules/$@ ;fi
	for file in $@.tcl pkgIndex.tcl traverse.tcl multi.tcl multiop.tcl decode.tcl paths.tcl ; do \
		if [ ! -f modules/$@/$$file ]; then \
			wget -q $(TCLLIB)/$@/$$file -O modules/$@/$$file; \
		fi \
	done
## just package index file and module.tcl file	
cmdline bibtex markdown:
	if [ ! -d modules/$@ ] ; then mkdir -p modules/$@ ;fi
	for file in $@.tcl pkgIndex.tcl ; do \
		if [ ! -f modules/$@/$$file ]; then \
			wget -q $(TCLLIB)/$@/$$file -O modules/$@/$$file; \
		fi \
	done
yaml:
	if [ ! -d modules/$@ ] ; then mkdir -p modules/$@ ;fi
	for file in $@.tcl huddle.tcl huddle_types.tcl json2huddle.tcl pkgIndex.tcl ; do \
		if [ ! -f modules/$@/$$file ]; then \
			wget -q $(TCLLIB)/$@/$$file -O modules/$@/$$file; \
		fi \
	done
			
textutil:
	if [ ! -d modules/$@ ] ; then mkdir -p modules/$@ ;fi
	for file in $@.tcl pkgIndex.tcl adjust.tcl expander.tcl patch.tcl repeat.tcl split.tcl string.tcl tabify.tcl trim.tcl wcswidth.tcl; do \
		if [ ! -f modules/$@/$$file ]; then \
			wget -q $(TCLLIB)/$@/$$file -O modules/$@/$$file; \
		fi \
	done

citer:
	if [ ! -d modules/$@ ] ; then mkdir -p modules/$@ ;fi
	for file in $@.tcl pkgIndex.tcl citer_main.tcl citer_api.tcl; do \
		if [ ! -f modules/$@/$$file ]; then \
			wget -q $(CITER)/$@/$$file -O modules/$@/$$file; \
		fi \
	done
tdot tsvg:
	if [ ! -d modules/$@ ] ; then mkdir -p modules/$@ ;fi
	for file in $@.tcl pkgIndex.tcl; do \
		if [ ! -f modules/$@/$$file ]; then \
			wget -q https://raw.githubusercontent.com/mittelmark/$@/refs/heads/main/$@/$$file -O modules/$@/$$file; \
		fi \
	done
			
lib:
	@[[ -d lib ]] || mkdir -p lib

