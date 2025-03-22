default:
	TCLLIBPATH=.. tclsh ../../apps/tmdoc --mode weave tmdoc-tutorial.tmd - | \
	TCLLIBPATH=~/workspace/mkdoc tclsh ../../../mkdoc/apps/mkdoc - tmdoc-tutorial.html --css tmdoc.css
	~/venv/bin/weasyprint -s small.css tmdoc-tutorial.html tmdoc-tutorial.pdf
	dtplite -o tmdoc.html html tmdoc.man
	~/venv/bin/weasyprint -s small.css tmdoc.html tmdoc.pdf
	dtplite -o ../../apps/tmdoc.html html ../../apps/tmdoc.man
test:
	tclsh tmdoc.test
	tclsh ../../apps/tmdoc test-man.tman test-man.man
