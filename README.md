## tmdoc

[![license](https://img.shields.io/badge/license-BSD-lightgray.svg)](https://opensource.org/license/bsd)
[![Release](https://img.shields.io/github/v/release/mittelmark/tmdoc.svg?label=current+release)](https://github.com/mittelmark/tmdoc/releases)
![Downloads](https://img.shields.io/github/downloads/mittelmark/tmdoc/total)
![Commits](https://img.shields.io/github/commits-since/mittelmark/tmdoc/latest)

[![Docu Package](https://img.shields.io/badge/Docu-Package-blue)](http://htmlpreview.github.io/?https://github.com/mittelmark/tmdoc/blob/master/modules/tmdoc/tmdoc.html)
[![Docu App](https://img.shields.io/badge/Docu-App-blue)](http://htmlpreview.github.io/?https://github.com/mittelmark/tmdoc/blob/master/apps/tmdoc.html)
[![Tutorial](https://img.shields.io/badge/Docu-Tutorial-blue)](http://htmlpreview.github.io/?https://github.com/mittelmark/tmdoc/blob/master/modules/tmdoc/tmdoc-tutorial.html)
[![Wiki](https://img.shields.io/badge/Docu-Wiki-blue)](https://wiki.tcl-lang.org/page/tmdoc%3A%3Atmdoc)

Literate  programming with Tcl. Embed Diagram code and the output, LaTeX equation, literature
references, shell script output, Youtube videos  and Tcl code with the  evaluation  results into  Markdown or LaTeX
documents.

## Description

The package _tmdoc_ and the standalone application of it provide facilities to
evaluate  embedded Diagram code, LaTeX equations, YAML defined  abbreviations,
or Tcl code within  documents of Markup languages like Markdown and LaTeX and
add the  resulting  output to the document for creating  dynamic  documents, a
technique  as well known as  literate  programming. 

## Main Features

- __Abbreviations:__ expand YAML defined abbreviations
- __Alerts:__ [Markdown alerts](https://github.com/orgs/community/discussions/16925)
- __Citations:__ reference management using BibTeX files
- __CSV Tables:__ create tables using CSV data
- __Diagrams:__ evaluate diagram code and embed create graphics using the [Kroki webservice](https:://kroki.io)
- __Graphic generation:__ create graphics using the [tsvg package](https://github.com/mittelmark/tsv)
- __Includes:__ Markdown file includes
- __LaTeX equations:__ can be embedded using the [math.vercel.app](https://math.vercel.app) web servcie
- __Shell code:__ evaluate embedded shell code to create graphics or text to be used within the output
- __Tcl programming:__ evaluate Tcl and other programming language code

### Installation

On a Unix system with installed Tcl interpreter just download the file  tmdoc-0.12.0.bin, save it to your
hard disk and then make it executable like this:

```bash
### download to your local bin folder
wget https://github.com/mittelmark/tmdoc/releases/download/v0.12.0/tmdoc-0.12.0.bin \
  -O ~/.local/bin/tmdoc
### make the Tcl script executable
chmod 755 ~/.local/bin/tmdoc
### check the installation
tmdoc --version
## 0.12.0
```

If the folder `~/.local/bin` does not exists you should create it and add this to your `PATH` variable.

That approach  should as well work on  Windows-Cygwin  or  Windows-Msys2  with
installed Tcl interpreter.

### Tcl Code

Embedded  Tcl code  starts with three backticks  and a
language marker like this (remove the single ticks before the three backticks):

```
'```{.tcl}
    puts "Hello World"
'```
```
   
Shorter  Tcl code  fragments  can be embedded  directly  within the text using
single backticks like this (replace single ticks with backticks):

```
This document was generated at 'tcl clock format [clock seconds] -format "%Y-%m-%d %H:%m"' MET.
```

### Diagram Code

Furthermore  since  version  0.8.0 you can embed code chunks for command  line
tools          like           [GraphViz](https://www.graphviz.org)          or
[PlantUML](https://www.plantuml.com)  to embed  graphics  into your  documents
like this:

```
'```{.shell cmd="dot -Tpng %i -o%o" echo=false}
digraph g {
   A -> B 
}
'```
```

Since    version   0.9.0   as   well   creation   of   diagrams    using   the
[kroki.io](https://kroki.io) webservice is as well possible here an example on
how to process Tmd documents to html using tmdoc and mkdoc.

```
'```{.kroki dia=graphviz imagepath=kroki ext=png}
digraph g {
  node[height=1.2,width=1.5,style=filled,shape=box,fillcolor=beige]
  TMD -> MD[label="tmdoc"]
  MD -> HTML[label="mkdoc"]
}
'```
```

### Shell Code

Since  version  0.10.0 the  support for  embedding  tools which  provide  text
output. This can be used as well to embed and execute the code for programming
languages. Here an example for a C program which is compiled and executed.

```
'``{.shell cmd="gcc %i -o hello&&./hello > %o" chunk.ext=c ext=txt}
#include <stdio.h>
int main() {
    printf("Hello C World!\n");
    return(0);
}
'``
```

### LaTeX Equations

Since version  0.12.0 there is as well support for embedding  LaTeX  equations
using the  [https://math.vercel.app](https://math.vercel.app)  webservice. You
simply add the equation in a `mtex` source code block:

```
'``{.mtex}
E = mc^2  \tag{1}
'``
```

There is as well support for matrix displays:

```
'``{.mtex}
\begin{bmatrix}
1 & 2 & 3 \\      \tag{2}
4 & 5 & 6 
\end{bmatrix}
'``
```

### Youtube Videos

Since  version  0.12.0 you can as well embed  Youtube  videos like this (again
replace the single ticks with backticks):

```
'tcl youtube EhXpJo3YbKg width=640 height=480'
```

### Bibliography Entries

Since version 0.12.0 it as well possible to embed literature  references which
are based on BibTeX files.

Here an example:

```
'``
### load the bibliography file
citer::bibliography literature.bib
'``
```

Now in the text you can cite with the [@key] syntax light this: 

`Clustal  Omega is a multiple  sequence
aligner   which   offers  a  good   trade-off   between   speed  and   accuracy
[@Sievers2011].`

Then, to display the references:

```
`tcl citer::bibliography`
```

## Document Processing

Documents  generated  with  tmdoc  can be then  processed  from the  generated
Markdown to HTML or PDF using tools like [mkdoc](https://github.com/mittelmark/mkdoc/),
[pandoc](https:///www.pandoc.org), [WeasyPrint](https://pypi.org/project/weasyprint/) or
[LibreOffice](https://libreoffice.org/). Here a pipeline to create an HTML, PDF or ODT 
document using Libreoffice.

![](https://kroki.io/graphviz/svg/eNp1zLEKwkAMgOH9niLcXAVxlHMq4tCiSLficL1cbWjalGtBRXx3vUpHp5B8P0G6BTs0cIOXgl7Ql2NjB28qeSTj9GRvamL2mMThhCUYJ6EfidvkTjg1ZrPeXncKgu1bpGB0dtHftegQVnvIsWRbeTZ66lCcjmWOEOlY5NmCXftDUPM58jk9LJpRFbzUNTk_P1iSU1r8Sd5KfQDUcUVD)

If you like to better retain the formatting of your HTML documents in your PDF
output, you should use the Python package
[WeasyPrint](https://pypi.org/project/weasyprint/).
 
To give an example the tmdoc tutorial ([source](modules/tmdoc/tmdoc-tutorial.tmd), 
[HTML](http://htmlpreview.github.io/?https://github.com/mittelmark/tmdoc/blob/master/modules/tmdoc/tmdoc-tutorial.html)
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
[tmdoc-VERSION.bin](https://github.com/mittelmark/tmdoc/releases) binary (150-200kb in size), rename
thh bin file to _tmdoc_ and copy the file to a folder belonging to your PATH variable. 
Thereafter make the file executable and check that it is correctly installed like
this:

```
wget https://github.com/mittelmark/tmdoc/releases/download/v0.10.0/tmdoc-0.10.0.bin -O ~/.local/bin/tmdoc
chmod 755 ~/.local/bin/tmdoc
tmdoc --version
## 0.10.0
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
- 2025-03-21 0.8.0
    - support for shell code embedding to generate graphics
- 2025-04-02 0.9.0
    - better support for Tcl man pages (images, code examples)
    - support for kroki code chunks
- 2025-06-09 0.10.0    
    - support for embedded code of different programming languages like 
      C, C++, Python etc and displaying text output from the code
- 2025-09-14 0.11.0    
- 2025-09-30 0.12.0 
    - support for LaTeX quations using [https://math.vercel.app](https://math.vercel.app)
    - support for embedding Youtube videos creating an iframe
    - support for embedding citations based on BibteX files
- 2025-10-XX 0.13.0 
    - support for abbreviations declared in the YAML header or in YAML files
    - support for [Markdown alerts](https://github.com/orgs/community/discussions/16925)
    - support for embedding CSV data for creating Markdown tables
      
## TODO

- kroki code chunk support  (done)
- bibtex citation support (citer package) using `[@ref]` syntax (done)
- test cases with examples for Markdown, LaTeX, and Tcl Man page format (done).
- R code chunk with default opening a png file and adding dev.off so automatic 
  generation  of, as well  use of  save.image  and load for  keeping  sessions
  between chunks
  
## See Also

- [mkdoc](https://github.com/mittelmark/mkdoc) - converting Markdown output of
  tmdoc to HTML or extracting Markdown documentation from source code files
- [pantcl](https://github.com/mittelmark/pantcl)  - combines functionality of
  pandoc, mkdoc, tmdoc and brings many filter for code blocks like for GraphViz,
  PlantUML, Shell, R and Python
- [Tcl man page format](https://core.tcl-lang.org/tcllib/doc/trunk/embedded/md/tcllib/files/modules/doctools/doctools_lang_cmdref.md)
- [WeasyPrint](https://pypi.org/project/weasyprint/)

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


