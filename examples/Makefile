##-*- makefile -*-############################################################
#
#  Author        : $Author$
#  Created By    : Detlef Groth
#  Created       : Tue Jun 10 05:31:45 2025
#  Last Modified : <250914.1619>
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
	TCLLIBPATH=~/workspace/mkdoc tclsh ../../mkdoc/apps/mkdoc - $(lang).html --css tmdoc.css
	

c:      ## process C examples
	TCLLIBPATH=~/workspace/tmdoc/modules ../apps/tmdoc --mode weave c.tmd c.md
	TCLLIBPATH="~/workspace/mkdoc ../modules" tclsh ../../mkdoc/apps/mkdoc c.md c.html --css tmdoc.css
cpp:    ## process C++ examples 
	TCLLIBPATH=../modules tclsh ../apps/tmdoc --mode weave cpp.tmd cpp.md
	TCLLIBPATH="~/workspace/mkdoc ../modules" tclsh ../../mkdoc/apps/mkdoc - cpp.html --css tmdoc.css
py:    ## process Python examples 
	TCLLIBPATH=../modules tclsh ../apps/tmdoc --mode weave $@.tmd  $@.md
	TCLLIBPATH="~/workspace/mkdoc ../modules" tclsh ../../mkdoc/apps/mkdoc $@.md $@.html --css tmdoc.css
emf:
	TCLLIBPATH=../modules tclsh ../apps/tmdoc --mode weave $@.tmd  $@.md
	TCLLIBPATH="~/workspace/mkdoc ../modules" tclsh ../../mkdoc/apps/mkdoc $@.md $@.html --css tmdoc.css

%.html: %.tmd mini.css ## that does not work
	TCLLIBPATH=../modules tclsh ../apps/tmdoc --mode weave $< - | \
	TCLLIBPATH=~/workspace/mkdoc tclsh ../../mkdoc/apps/mkdoc - `basename $< .tmd`.html --css tmdoc.css
	
