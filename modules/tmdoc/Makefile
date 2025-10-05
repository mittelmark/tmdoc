##-*- makefile -*-############################################################

default:
	TCLLIBPATH=.. tclsh ../../apps/tmdoc --mode weave tmdoc-tutorial.tmd - | \
	TCLLIBPATH="~/workspace/mkdoc .." tclsh ../../../mkdoc/apps/mkdoc - tmdoc-tutorial.html --css tmdoc.css
	weasyprint -s small.css tmdoc-tutorial.html tmdoc-tutorial.pdf
	dtplite -o tmdoc.html html tmdoc.man
	weasyprint -s small.css tmdoc.html tmdoc.pdf
	dtplite -o ../../apps/tmdoc.html html ../../apps/tmdoc.man
test:
	TCLLIBPATH=.. tclsh tmdoc.test
	TCLLIBPATH=.. tclsh ../../apps/tmdoc test-man.tman test-man.man

tmdoc:
	TCLLIBPATH=.. tclsh ../../apps/tmdoc --mode weave tmdoc-tutorial.tmd out.md

filter-r:
	test -d images || mkdir images
	TCLLIBPATH=.. tclsh ../../apps/tmdoc --mode weave $@.tmd - | \
	TCLLIBPATH="~/workspace/mkdoc .." tclsh ../../../mkdoc/apps/mkdoc - $@.html --css tmdoc.css
	

