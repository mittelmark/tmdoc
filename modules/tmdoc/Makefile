default:
	TCLLIBPATH=.. tclsh ../../apps/tmdoc --mode weave tmdoc-tutorial.tmd - | \
	TCLLIBPATH=~/workspace/mkdoc tclsh ../../../mkdoc/apps/mkdoc - tmdoc-tutorial.html --css tmdoc.css
	dtplite -o tmdoc.html html tmdoc.man
test:
	tclsh tmdoc.test
	tclsh ../../apps/tmdoc test-man.tman test-man.man
