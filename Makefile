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
## Pinned dependency commits so the build is reproducible.  Bump these only
## when a new dependency version is required; refresh any local vendor patches
## at the same time.
TCLLIB_REF=29bce268ae8d21a688d1a1efb256acc0e030a6a6
CITER_REF=10d043ca4c08d87d3c1693c7b171933edec846bf
TDOT_REF=18103b4cc927bff15c4c3b7b58c3c1780dfbe715
TBLOCKS_REF=0cbbe297578620c5d00fe69467bc889c8c8141ed
TSVG_REF=6188f012f3a59610bf02504bf367167ed4dfa59b
TCRD_REF=1aa1e1694dd8fe25dd61b6eb04229a875950ef64
TCLLIB=https://raw.githubusercontent.com/tcltk/tcllib/$(TCLLIB_REF)/modules
CITER=https://raw.githubusercontent.com/mittelmark/citer/$(CITER_REF)
TDOT=https://raw.githubusercontent.com/mittelmark/tdot/$(TDOT_REF)
TBLOCKS=https://raw.githubusercontent.com/mittelmark/tblocks/$(TBLOCKS_REF)
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
	cd app-build && mkdir -p tmdoc.vfs/lib/tcrd
	cd app-build && mkdir -p tmdoc.vfs/lib/tsvg
	cd app-build && mkdir -p tmdoc.vfs/lib/tblocks	
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
	cd app-build && cp ../../tcrd/tcrd/*.tcl tmdoc.vfs/lib/tcrd/
	cd app-build && cp ../../tsvg/tsvg/*.tcl tmdoc.vfs/lib/tsvg/
	cd app-build && cp ../../tblocks/tblocks/*.tcl tmdoc.vfs/lib/tblocks/	
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
	cd modules/tmdoc && LANG=en_US.UTF8 TCLLIBPATH=../ tclsh -encoding cp1252 tmdoc.test

test9:
	cd modules/tmdoc && LANG=en_US.UTF8 TCLLIBPATH=../ $(TCL9) -encoding cp1252 tmdoc.test	

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
tdot:
	@[ ! -d modules/tdot ] && mkdir -p modules/tdot
	@[ ! -f modules/tdot/tdot.tcl ] && wget -q https://raw.githubusercontent.com/mittelmark/tdot/$(TDOT_REF)/tdot/tdot.tcl -O modules/tdot/tdot.tcl
	@[ ! -f modules/tdot/pkgIndex.tcl ] && wget -q https://raw.githubusercontent.com/mittelmark/tdot/$(TDOT_REF)/tdot/pkgIndex.tcl -O modules/tdot/pkgIndex.tcl
tsvg:
	@[ ! -d modules/tsvg ] && mkdir -p modules/tsvg
	@[ ! -f modules/tsvg/tsvg.tcl ] && wget -q https://raw.githubusercontent.com/mittelmark/tsvg/$(TSVG_REF)/tsvg/tsvg.tcl -O modules/tsvg/tsvg.tcl
	@[ ! -f modules/tsvg/pkgIndex.tcl ] && wget -q https://raw.githubusercontent.com/mittelmark/tsvg/$(TSVG_REF)/tsvg/pkgIndex.tcl -O modules/tsvg/pkgIndex.tcl
tblocks:
	@[ ! -d modules/tblocks ] && mkdir -p modules/tblocks
	@[ ! -f modules/tblocks/tblocks.tcl ] && wget -q https://raw.githubusercontent.com/mittelmark/tblocks/$(TBLOCKS_REF)/tblocks/tblocks.tcl -O modules/tblocks/tblocks.tcl
	@[ ! -f modules/tblocks/pkgIndex.tcl ] && wget -q https://raw.githubusercontent.com/mittelmark/tblocks/$(TBLOCKS_REF)/tblocks/pkgIndex.tcl -O modules/tblocks/pkgIndex.tcl
tcrd:
	@[ ! -d modules/tcrd ] && mkdir -p modules/tcrd
	@[ ! -f modules/tcrd/tcrd.tcl ] && wget -q https://raw.githubusercontent.com/mittelmark/tcrd/$(TCRD_REF)/tcrd/tcrd.tcl -O modules/tcrd/tcrd.tcl
	@[ ! -f modules/tcrd/pkgIndex.tcl ] && wget -q https://raw.githubusercontent.com/mittelmark/tcrd/$(TCRD_REF)/tcrd/pkgIndex.tcl -O modules/tcrd/pkgIndex.tcl
			
lib:
	@[[ -d lib ]] || mkdir -p lib

