## tmdoc

[![license](https://img.shields.io/badge/license-BSD-lightgray.svg)](https://opensource.org/license/bsd)
[![Release](https://img.shields.io/github/v/release/mittelmark/tmdoc.svg?label=current+release)](https://github.com/mittelmark/tmdoc/releases)
![Downloads](https://img.shields.io/github/downloads/mittelmark/tmdoc/total)
![Commits](https://img.shields.io/github/commits-since/mittelmark/tmmdoc/latest)

[![Docu](https://img.shields.io/badge/Docu-blue)](http://htmlpreview.github.io/?https://github.com/mittelmark/tmdoc/blob/master/modules/tmdoc/tmdoc.html)
[![Tutorial](https://img.shields.io/badge/Tutorial-blue)](http://htmlpreview.github.io/?https://github.com/mittelmark/tmdoc/blob/master/modules/tmdoc/tmdoc-tutorial.html)
[![Wiki](https://img.shields.io/badge/Wiki-blue)](https://wiki.tcl-lang.org/page/tmdoc%3A%3Atmdoc)

Literate programming with Tcl. Embed Tcl code into Markdown or LaTeX
documents with code evaluation.

## Description

The package _tmdoc_  provides a command to evaluate  embedded Tcl code in code
chunks within  documents of Markup  languages  like Markdown and LaTeX and add
the  resulting  output to the  document  for  creating  dynamic  documents,  a
technique  as well known as  literate  programming.  The latter uses  Tcllib's
Markdown  package.  The  embedded  Tcl code  starts with tri  backticks  and a
language marker like this ((replace single ticks with backticks):

```
    '''{.tcl}
    puts "Hello World"
    '''
```
   
Shorter  Tcl code  fragments  can be embedded  directly  within the text using
single backticks like this (replace single ticks with backticks):

```
    This document was generated at 'tcl clock format [clock seconds] -format "%Y-%m-%d %H:%m"' MET.
```

Documents   can   be   processed   to   HTML   or   PDF   using   tools   like
[mkdoc](https://github.com/mittelmark/mkdoc/),
[pandoc](https:///www.pandoc.org)  or [LibreOffice](https://libreoffice.org/). Here a pipeline to create an
HTML or PDF or Libreoffice ODT documents

![](https://kroki.io/graphviz/svg/eNp1zLEKwkAMgOH9niLcXAVxlHMq4tCiSLficL1cbWjalGtBRXx3vUpHp5B8P0G6BTs0cIOXgl7Ql2NjB28qeSTj9GRvamL2mMThhCUYJ6EfidvkTjg1ZrPeXncKgu1bpGB0dtHftegQVnvIsWRbeTZ66lCcjmWOEOlY5NmCXftDUPM58jk9LJpRFbzUNTk_P1iSU1r8Sd5KfQDUcUVD)

To        give       an        example        the        tmdoc        tutorial
([source](modules/tmdoc/tmdoc-tutorial.tmd), [HTML](http://htmlpreview.github.io/?https://github.com/mittelmark/tmdoc/blob/master/modules/tmdoc/tmdoc-tutorial.html)
is processed with the following commands.

```
tmdoc --mode weave tmdoc-tutorial.tmd - | mkdoc - tmdoc-tutorial.html --css tmdoc.css
```

Further  you might  embed your Tmd text within Tcl source code files after the
_#'_ commented lines for documentation  purposes of your Tcl projects. You can
then  extract the Markdown  text first with _mkdoc_, then process the Tcl code
within  using _tmdoc_ and again do then a document  conversion  to HTML and or
PDF or OST as described above. Here such a workflow:

![](https://kroki.io/graphviz/svg/eNp1zLEKwjAQBuA9T3FkroI4SpyKOLQokq04pLnUHr02JS2oiO9uU6iD4HTc__13SLdg-hpu8BLQeXTFUJveqdI_kmF8slMVMTtM4rCefVDWh24gbpI74VirzXp73QkIpmuQgpLZRU6rtgyrPegWCzalYyXbBr2VsTqF0fIvje1COUKko86z3zsQcxz5nB4WzagMzlcVWTc_WCqnVP-pvIX4AAltTeI=)

See the  [tdot](https://github.com/mittelmark/tdot/blob/main/tdot/tdot.tcl)  source code
as example for such embedded documentation.

## Documentation

* [tmdoc package](http://htmlpreview.github.io/?https://github.com/mittelmark/tmdoc/blob/master/modules/tmdoc/tmdoc.html)
* [tmdoc application](http://htmlpreview.github.io/?https://github.com/mittelmark/tmdoc/blob/master/apps/tmdoc.html)
* [tmdoc tutorial](http://htmlpreview.github.io/?https://github.com/mittelmark/tmdoc/blob/master/modules/tmdoc/tmdoc-tutorial.html)

## Download 

* [Latest Release](https://github.com/mittelmark/tmdoc/releases)
* [Latest development code](https://github.com/mittelmark/tmdoc/warchive/refs/heads/main.zip)

## Installation

On Linux, MacOS and on Windows with installed Msys2 or Cyvwin download the latest
[tmdoc-VERSION.bin](https://github.com/mittelmark/tmdoc/releases) binary (190kb in size), rename
it to _tmdoc_ and copy the file to a folder belonging to your PATH variable. 
Thereafter make the file executable and check that it is correctly installed like
this:

```
$ tmdoc --version
0.7.0
```

To install the  package just  download  the latest Zip or Tar-Gz  archive from the release page and
unpack these files, then  you just copy the  _modules/tmdoc_  folder to a folder
belonging to your _TCLLIBPATH_ variable. Therafter you can as well execute the
command  line  application  using  the   [tclmain](https://github.com/mittelmark/tclmain)
utility like this:

```
tclmain -m tmdoc --help
```

## Changes

- 2020-02-19: 0.1 first release
- 2020-02-21: 0.2 release
    - puts -nonewline fix in the output
    - outfile and tangle options
    - manual page ready
- 2020-02-23: 0.3 release - fix for puts into channels
- 2020-11-08: 0.4 release
    - LaTeX support
    - project moved to github 
- 2021-12-19 0.5 release - making code structure like in tcllib
- 2025-01-04 0.6 tcllib and Tcl 9 aware version
- 2025-01-18 0.7.0
    - support for  _results="asis"_ for instance to create Markdown or SVG code
    - function  _include_ to  include other Markdown files 
    - function  _list2mdtab_ to  add tables within code chunks

## See Also

- [mkdoc](https://github.com/mittelmark/mkdoc) - converting Markdown output of
  tmdoc to HTML
- [pantcl](https://github.com/mittelmark/pantcl)  - combines functionality of
  pandoc, mkdoc, tmdoc and brings many filter for code blocks like for GraphViz,
  PlantUML, Shell, R and Python


## Author

@ 2020-2025 - Detlef  Groth,  University  of  Potsdam,  Germany  -
  dgroth(at)uni(minus)potsdam(dot)de

## License


```
The following  terms apply to all files associated  with the software  unless
explicitly disclaimed in individual files.

The authors  hereby grant  permission  to use, copy, modify,  distribute,  and
license this  software and its  documentation  for any purpose,  provided that
existing  copyright notices are retained in all copies and that this notice is
included  verbatim in any  distributions.  No written  agreement,  license, or
royalty fee is required for any of the authorized uses.  Modifications to this
software may be copyrighted by their authors and need not follow the licensing
terms described here, provided that the new terms are clearly indicated on the
first page of each file where they apply.

In no event  shall  the  authors  or  distributors  be liable to any party for
direct, indirect, special, incidental, or consequential damages arising out of
the use of this software, its documentation, or any derivatives  thereof, even
if the authors have been advised of the possibility of such damage.

The authors and distributors  specifically disclaim any warranties, including,
but not limited to, the implied warranties of  merchantability,  fitness for a
particular purpose, and non-infringement.  This software is provided on an "as
is" basis, and the  authors and  distributors  have no  obligation  to provide
maintenance, support, updates, enhancements, or modifications.

RESTRICTED RIGHTS: Use, duplication or disclosure by the government is subject
to the restrictions as set forth in subparagraph (c) (1) (ii) of the Rights in
Technical  Data and Computer  Software  Clause as DFARS  252.227-7013  and FAR
52.227-19.
```


