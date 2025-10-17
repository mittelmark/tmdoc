##-*- makefile -*-############################################################
#
#  Author        : $Author$
#  Created By    : Detlef Groth
#  Created       : Tue Jun 10 05:31:45 2025
#  Last Modified : <251017.1949>
#
#  Description	 :
#
#  Notes         :
#
##############################################################################
#
#  Copyright (c) 2025 Detlef Groth.
# 
#  All Rights Reserved.
# 
#  This  document  may  not, in  whole  or in  part, be  copied,  photocopied,
#  reproduced,  translated,  or  reduced to any  electronic  medium or machine
#  readable form without prior written consent from Detlef Groth.
#
##############################################################################

CURRENT_MAKEFILE := $(lastword $(MAKEFILE_LIST))
lang=c
## argument delegation
ARGS=

## default: list existing tasks 
.PHONY: tasks
tasks:  ## list all tasks
	@grep -Eo '^[a-z0-9]+:.+' $(CURRENT_MAKEFILE) | sed -E 's/:\s+##/\t- /g'

default: ## ause lang=c|cpp|py for processing
	TCLLIBPATH=../modules tclsh ../apps/tmdoc --mode weave $(lang).tmd - | \
	TCLLIBPATH=~/workspace/mndoc tclsh ../../mndoc/apps/mndoc - $(lang).html --css tmdoc.css

c cpp dot emf mtex py pipe literature abcmusic:      ## process C examples
	TCLLIBPATH=~/workspace/tmdoc/modules ../apps/tmdoc --mode weave $@.tmd $@.md
	TCLLIBPATH="~/workspace/mkdoc ../modules" tclsh ../../mkdoc/apps/mkdoc $@.md $@.html --css tmdoc.css
adoc:
	perl -pe 's/\[(.+?)\]\((.+?)\)/link:$$2\[$$1\]/g;s/<center>/[.text-center]/;s/<\/center>//g' header.md > header.adoc
	TCLLIBPATH=../modules tclsh ../apps/tmdoc --mode weave asciidoc.tdoc asciidoc.adoc
	asciidoctor asciidoc.adoc

## run with make c.html, make cpp.html, make emf, make py
%.html: %.tmd mini.css ## that does not work
	TCLLIBPATH=../modules tclsh ../apps/tmdoc --mode weave $<.tmd $<.md
	TCLLIBPATH="~/workspace/mkdoc ../modules" tclsh ../../mkdoc/apps/mkdoc $<.md $<.html --css tmdoc.css
	
