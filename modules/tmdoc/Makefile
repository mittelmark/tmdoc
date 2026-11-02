##-*- makefile -*-############################################################

default: mndoc
	TCLLIBPATH=.. tclsh ../../apps/tmdoc --mode weave tmdoc-tutorial.tmd - --toc true | \
	TCLLIBPATH=.. tclsh ../../modules/mndoc/mndoc-app.tcl - tmdoc-tutorial.html --css tmdoc.css
	weasyprint -q -s small.css tmdoc-tutorial.html tmdoc-tutorial.pdf
	TCLLIBPATH="~/workspace/tcllib/modules" \
		~/workspace/tcllib/apps/dtplite -o tmdoc.html html tmdoc.man
	weasyprint -q -s small.css tmdoc.html tmdoc.pdf
	TCLLIBPATH="~/workspace/tcllib/modules" \
		~/workspace/tcllib/apps/dtplite -o ../../apps/tmdoc.html html ../../apps/tmdoc.man
test:
	TCLLIBPATH=.. LANG=en_US.UTF8 tclsh -encoding cp1252 tmdoc.test
	TCLLIBPATH=.. tclsh ../../apps/tmdoc test-man.tman test-man.man

tmdoc:
	TCLLIBPATH=.. tclsh ../../apps/tmdoc --mode weave tmdoc-tutorial.tmd out.md

filter-julia filter-r filter-python filter-octave filter-mtex filter-tcl filter-abbrev filter-tcrd: mndoc
	test -d images || mkdir images
	TCLLIBPATH=.. tclsh ../../apps/tmdoc --mode weave $@.tmd - | \
	TCLLIBPATH=.. tclsh ../../modules/mndoc/mndoc-app.tcl - $@.html --css tmdoc.css
	

test-eq: mndoc
	TCLLIBPATH=.. tclsh ../../apps/tmdoc --mode weave test.Rmd - --toc true | \
	TCLLIBPATH=.. tclsh ../../modules/mndoc/mndoc-app.tcl - test.htm --css tmdoc.css

## fetch the pinned mndoc source (top-level target) used for the HTML steps
.PHONY: mndoc
mndoc:
	$(MAKE) -C ../.. mndoc
