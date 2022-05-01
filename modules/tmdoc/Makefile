default:
	tclsh ../../apps/tmdoc --mode weave tmdoc-tutorial.tmd - | pandoc -o tmdoc-tutorial.html \
	   -s --css tmdoc.css
	htmlark tmdoc-tutorial.html -o tmdoc-tutorial-out.html
	mv tmdoc-tutorial-out.html tmdoc-tutorial.html
	dtplite -o tmdoc.html html tmdoc.man
test:
	tclsh tmdoc.test
	tclsh ../../apps/tmdoc test-man.tman test-man.man
