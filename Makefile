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
	-test -d tmdoc.vfs && rm -rf tmdoc.vfs
	-test -d bin || mkdir bin
	mkdir -p tmdoc.vfs/lib
	for d in tmdoc bibtex citer cmdline fileutil markdown textutil yaml tdot tcrd tsvg tblocks; do \
		mkdir -p tmdoc.vfs/lib/$$d; \
	done
	cp modules/tmdoc/*.tcl tmdoc.vfs/lib/tmdoc/
	cp modules/tmdoc/tmdoc.sty tmdoc.vfs/lib/tmdoc/
	cp modules/bibtex/*.tcl tmdoc.vfs/lib/bibtex/
	cp modules/citer/*.tcl tmdoc.vfs/lib/citer/
	cp modules/cmdline/*.tcl tmdoc.vfs/lib/cmdline/
	cp modules/fileutil/*.tcl tmdoc.vfs/lib/fileutil/
	cp modules/markdown/*.tcl tmdoc.vfs/lib/markdown/
	cp modules/textutil/*.tcl tmdoc.vfs/lib/textutil/
	cp modules/tdot/*.tcl tmdoc.vfs/lib/tdot/
	cp modules/yaml/*.tcl tmdoc.vfs/lib/yaml/
	cp modules/tcrd/*.tcl tmdoc.vfs/lib/tcrd/
	cp modules/tsvg/*.tcl tmdoc.vfs/lib/tsvg/
	cp modules/tblocks/*.tcl tmdoc.vfs/lib/tblocks/
	echo "lappend auto_path [file join [file dirname [info script]] lib]" > tmdoc.vfs/main.tcl
	cp apps/tmdoc tmdoc.tcl
	@if [ -x "${HOME}/.local/bin/tpack" ]; then tclsh "${HOME}/.local/bin/tpack" wrap tmdoc.tapp --lz4; else tclsh "${HOME}/workspace/tpack/tpack-b64.tcl" wrap tmdoc.tapp --lz4; fi
	tclsh tmdoc.tapp --version
	tclsh tmdoc.tapp --help
	cp tmdoc.tapp bin/tmdoc-`tclsh tmdoc.tapp --version`.bin
	-test -d app-build && rm -rf app-build
	-test -f tmdoc.tcl && rm -f tmdoc.tcl
	-test -f tmdoc.tapp && rm -f tmdoc.tapp
	-test -f tmdoc.tb64 && rm -f tmdoc.tb64
	-test -f tmdoc.tb64.lz4 && rm -f tmdoc.tb64.lz4
	-test -f tmdoc.ttcl && rm -f tmdoc.ttcl
	-test -d tmdoc.vfs && rm -rf tmdoc.vfs

# Regenerate the doctools man-page HTML files using the vendored doctools
# package (tools/doctools) via the lightweight dtlite generator.  This no
# longer depends on the tcllib sibling checkout.
docu:
	tclsh tools/dtplite.tcl -o modules/tmdoc/tmdoc.html modules/tmdoc/tmdoc.man
	tclsh tools/dtplite.tcl -o apps/tmdoc.html apps/tmdoc.man
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

