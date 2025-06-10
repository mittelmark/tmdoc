##-*- makefile -*-############################################################
#
#  Author        : $Author$
#  Created By    : Detlef Groth
#  Created       : Tue Jun 10 05:31:45 2025
#  Last Modified : <250610.0639>
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

## argument delegation
ARGS=

## default: list existing tasks 
.PHONY: tasks
tasks:  ## list all tasks
	@grep -Eo '^[a-z0-9]+:.+' $(CURRENT_MAKEFILE) | sed -E 's/:\s+##/\t- /g'

c:      ## process C examples
	TCLLIBPATH=../modules tclsh ../apps/tmdoc --mode weave c.tmd - | \
	TCLLIBPATH=~/workspace/mkdoc tclsh ../../mkdoc/apps/mkdoc - c.html --css tmdoc.css
cpp:    ## process C++ examples 
	TCLLIBPATH=../modules tclsh ../apps/tmdoc --mode weave cpp.tmd - | \
	TCLLIBPATH=~/workspace/mkdoc tclsh ../../mkdoc/apps/mkdoc - cpp.html --css tmdoc.css
