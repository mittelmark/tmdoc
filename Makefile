##-*- makefile -*-############################################################
#
#  System        : 
#  Module        : 
#  Object Name   : $RCSfile$
#  Revision      : $Revision$
#  Date          : $Date$
#  Author        : $Author$
#  Created By    : MicroEmacs User
#  Created       : 2025-01-04 18:30:01
#  Last Modified : <250118.1737>
#
#  Description	
#
#  Notes
#
#  History
#	
#  $Log$
#
##############################################################################
#
#  Copyright (c) 2025 MicroEmacs User.
# 
#  All Rights Reserved.
# 
#  This  document  may  not, in  whole  or in  part, be  copied,  photocopied,
#  reproduced,  translated,  or  reduced to any  electronic  medium or machine
#  readable form without prior written consent from MicroEmacs User.
#
##############################################################################

TCL9=~/.local/opt/bin/tclsh9.0
TCL=tclsh
default:
	echo "Usage: make app|docu|test"
app:
	test -d app-build && rm -rf app-build
	mkdir app-build
	cd app-build && mkdir -p tmdoc.vfs/lib/tmdoc
	cd app-build && mkdir -p tmdoc.vfs/lib/cmdline
	cd app-build && mkdir -p tmdoc.vfs/lib/textutil
	cd app-build && mkdir -p tmdoc.vfs/lib/fileutil	
	cd app-build && cp ../modules/tmdoc/*.tcl tmdoc.vfs/lib/tmdoc
	cd app-build && cp ~/workspace/tcllib/modules/cmdline/*.tcl tmdoc.vfs/lib/cmdline/
	cd app-build && cp ~/workspace/tcllib/modules/textutil/*.tcl tmdoc.vfs/lib/textutil/	
	cd app-build && cp ~/workspace/tcllib/modules/fileutil/*.tcl tmdoc.vfs/lib/fileutil/		
	cd app-build && echo "lappend auto_path [file join [file dirname [info script]] lib]" > tmdoc.vfs/main.tcl
	cp apps/tmdoc app-build/tmdoc.tcl
	cd app-build && tpack wrap tmdoc.tapp --lz4
	tclsh app-build/tmdoc.tapp --version
	tclsh app-build/tmdoc.tapp --help
	cp app-build/tmdoc.tapp bin/tmdoc-`tclsh app-build/tmdoc.tapp --version`.bin	
docu:
	dtplite -o modules/tmdoc/tmdoc.html html modules/tmdoc/tmdoc.man 
	dtplite -o apps/tmdoc.html html apps/tmdoc.man 
test:
	TCLLIBPATH=modules tclsh modules/tmdoc/tmdoc.test	

test9:
	TCLLIBPATH=modules $(TCL9) modules/tmdoc/tmdoc.test	
