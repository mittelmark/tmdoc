##-*- makefile -*-############################################################

default:
	TCLLIBPATH=.. tclsh ../../apps/tmdoc --mode weave tmdoc-tutorial.tmd - --toc true | \
	TCLLIBPATH=.. tclsh ../../../mndoc/apps/mndoc - tmdoc-tutorial.html --css tmdoc.css
	weasyprint -q -s small.css tmdoc-tutorial.html tmdoc-tutorial.pdf
	TCLLIBPATH="~/workspace/tcllib/modules" \
		~/workspace/tcllib/apps/dtplite -o tmdoc.html html tmdoc.man
	weasyprint -q -s small.css tmdoc.html tmdoc.pdf
	TCLLIBPATH="~/workspace/tcllib/modules" \
		~/workspace/tcllib/apps/dtplite -o ../../apps/tmdoc.html html ../../apps/tmdoc.man
test:
	TCLLIBPATH=.. LANG=en_US.UTF-8 tclsh tmdoc.test
	TCLLIBPATH=.. tclsh ../../apps/tmdoc test-man.tman test-man.man

tmdoc:
	TCLLIBPATH=.. tclsh ../../apps/tmdoc --mode weave tmdoc-tutorial.tmd out.md

filter-julia filter-r filter-python filter-octave filter-mtex filter-tcl filter-abbrev:
	test -d images || mkdir images
	TCLLIBPATH=.. tclsh ../../apps/tmdoc --mode weave $@.tmd - | \
	TCLLIBPATH=.. tclsh ../../../mndoc/apps/mndoc - $@.html --css tmdoc.css
	

