    # tmdoc

[![license](https://img.shields.io/badge/license-BSD-lightgray.svg)](https://opensource.org/license/bsd)
[![Release](https://img.shields.io/github/v/release/mittelmark/tmdoc.svg?label=current+release)](https://github.com/mittelmark/tmdoc/releases)
![Downloads](https://img.shields.io/github/downloads/mittelmark/tmdoc/total)
![Commits](https://img.shields.io/github/commits-since/mittelmark/tmdoc/latest)

[![Docu Package](https://img.shields.io/badge/Docu-Package-blue)](http://htmlpreview.github.io/?https://github.com/mittelmark/tmdoc/blob/master/modules/tmdoc/tmdoc.html)
[![Docu App](https://img.shields.io/badge/Docu-App-blue)](http://htmlpreview.github.io/?https://github.com/mittelmark/tmdoc/blob/master/apps/tmdoc.html)
[![Tutorial](https://img.shields.io/badge/Docu-Tutorial-blue)](http://htmlpreview.github.io/?https://github.com/mittelmark/tmdoc/blob/master/modules/tmdoc/tmdoc-tutorial.html)
[![Wiki](https://img.shields.io/badge/Docu-Wiki-blue)](https://wiki.tcl-lang.org/page/tmdoc%3A%3Atmdoc)

Literate  programming with Tcl. Embed Diagram code and the output, LaTeX equation, literature
references,  shell  script  output,  Youtube  videos  and Tcl  code  with  the
evaluation  results into  your Markdown, AsciiDoc, Typst or LaTeX
documents.

## Description

The package _tmdoc_ and the standalone application of it provide facilities to
evaluate  embedded Diagram code, LaTeX equations, YAML defined  abbreviations,
or R, Python, Octave, Shell or Tcl code within  documents of Markup  languages
like Markdown, AsciiDoc, Typst or LaTeX and
add the  resulting  output to the document for creating  dynamic  documents, a
technique  as well known as  literate  programming. 

## Main Features

- __single file approach:__ the required small (approx. 230kb) single file (_tmdoc-0.14.2.bin_) just requires an existing Tcl/Tk installation
- __Abbreviations:__ expand YAML defined abbreviations - [Abbreviation Filter](http://htmlpreview.github.io/?https://github.com/mittelmark/tmdoc/blob/master/modules/tmdoc/filter-abbrev.html)
- __Alerts:__ [Markdown alerts](https://github.com/orgs/community/discussions/16925) - [Alert Section in the Tutorial](https://htmlpreview.github.io/?https://github.com/mittelmark/tmdoc/blob/master/modules/tmdoc/tmdoc-tutorial.html#alerts)
- __Citations:__ reference management using BibTeX files - [Citation Section in the Tutorial](https://htmlpreview.github.io/?https://github.com/mittelmark/tmdoc/blob/master/modules/tmdoc/tmdoc-tutorial.html#references)
- __CSV Tables:__ create tables using CSV data - [CSV Tables Section in the Tutorial](https://htmlpreview.github.io/?https://github.com/mittelmark/tmdoc/blob/master/modules/tmdoc/tmdoc-tutorial.html#csv)
- __Diagrams:__ evaluate diagram code and embed create graphics using the [Kroki webservice](https:://kroki.io) - [Kroki Section in the Tutorial](https://htmlpreview.github.io/?https://github.com/mittelmark/tmdoc/blob/master/modules/tmdoc/tmdoc-tutorial.html#kroki)
- __Graphic generation:__ create graphics using the [tsvg package](https://github.com/mittelmark/tsv) - [tsvg section in the tutorial](https://htmlpreview.github.io/?https://github.com/mittelmark/tmdoc/blob/master/modules/tmdoc/tmdoc-tutorial.html#images)
- __Includes:__ Markdown file includes - [include section in the tutorial](https://htmlpreview.github.io/?https://github.com/mittelmark/tmdoc/blob/master/modules/tmdoc/tmdoc-tutorial.html#include)
- __LaTeX equations:__ can be embedded using the [latex.codecs.com](https://latex.codecogs.com/) web servcie
    [![LaTeX Filter](https://img.shields.io/badge/Docu-LaTeX-Filter-blue)](http://htmlpreview.github.io/?https://github.com/mittelmark/tmdoc/blob/master/modules/tmdoc/filter-mtex.html)
- __Octave reports:__ writing statistical reports using the Octave programming
  language [![Octave Filter](https://img.shields.io/badge/Docu-Octave-Filter-blue)](http://htmlpreview.github.io/?https://github.com/mittelmark/tmdoc/blob/master/modules/tmdoc/filter-octave.html)
- __Python reports:__ writing statistical reports using the Python programming 
   language [![Python Filter](https://img.shields.io/badge/Docu-Python-Filter-blue)](http://htmlpreview.github.io/?https://github.com/mittelmark/tmdoc/blob/master/modules/tmdoc/filter-python.html)
- __R reports:__ writing statistical reports using the R programming language
   [![R Filter](https://img.shields.io/badge/Docu-R-Filter-blue)](http://htmlpreview.github.io/?https://github.com/mittelmark/tmdoc/blob/master/modules/tmdoc/filter-r.html)
- __Shell code:__ evaluate embedded shell code to create graphics or text to be used within the output - [shell section in the tutorial](https://htmlpreview.github.io/?https://github.com/mittelmark/tmdoc/blob/master/modules/tmdoc/tmdoc-tutorial.html#clp)
- __Tcl programming:__ evaluate Tcl and other programming language code
  [![Tcl Filter](https://img.shields.io/badge/Docu-Tcl-Filter-blue)](http://htmlpreview.github.io/?https://github.com/mittelmark/tmdoc/blob/master/modules/tmdoc/filter-tcl.html)


## Examples

| Code              | HTML-Output |
|:-----------------:|:-----------:|
| [abcmusic.tmd](examples/abcmusic.tmd) | [abcmusic.html](http://htmlpreview.github.io/?https://github.com/mittelmark/tmdoc/blob/master/examples/abcmusic.html) |
| [asciidoc.tdoc](examples/asciidoc.tdoc) | [asciidoc.html](http://htmlpreview.github.io/?https://github.com/mittelmark/tmdoc/blob/master/examples/asciidoc.html) |
| [c.tmd](examples/c.tmd) | [c.html](http://htmlpreview.github.io/?https://github.com/mittelmark/tmdoc/blob/master/examples/c.html) |
| [cpp.tmd](examples/cpp.tmd) | [cpp.html](http://htmlpreview.github.io/?https://github.com/mittelmark/tmdoc/blob/master/examples/cpp.html) |
| [dot.tmd](examples/dot.tmd) | [dot.html](http://htmlpreview.github.io/?https://github.com/mittelmark/tmdoc/blob/master/examples/dot.html) |
| [emf.tmd](examples/emf.tmd) | [emf.html](http://htmlpreview.github.io/?https://github.com/mittelmark/tmdoc/blob/master/examples/emf.html) |
| [literature.tmd](examples/literature.tmd) | [literature.html](http://htmlpreview.github.io/?https://github.com/mittelmark/tmdoc/blob/master/examples/literature.html) |
| [mtex.tmd](examples/mtex.tmd) | [mtex.html](http://htmlpreview.github.io/?https://github.com/mittelmark/tmdoc/blob/master/examples/mtex.html) |
| [pipe.tmd](examples/pipe.tmd) | [pipe.html](http://htmlpreview.github.io/?https://github.com/mittelmark/tmdoc/blob/master/examples/pipe.html) |
| [py.tmd](examples/py.tmd) | [py.html](http://htmlpreview.github.io/?https://github.com/mittelmark/tmdoc/blob/master/examples/py.html) |

## Installation

On Linux, MacOS and on Windows with installed [Msys2](https://www.msys2.org/) or [Cygwin](https://www.cygwin.com/) download the latest
[tmdoc-VERSION.bin](https://github.com/mittelmark/tmdoc/releases) binary (150-200kb in size), rename
the bin file to _tmdoc_ and copy the file to a folder belonging to your PATH variable. 
Thereafter make the file executable and check that it is correctly installed. Since version 0.14.0 there is an install script which installs both tmdoc and mndoc into ~/.local/bin. You can execute it like this:

```bash
/bin/bash -c "$(curl -fsSL https://github.com/mittelmark/tmdoc/releases/latest/download/install-tmdoc.sh)"
```

You can as well just install tmdoc alone like this:

```bash
### download to your local bin folder
wget https://github.com/mittelmark/tmdoc/releases/download/v0.15.0/tmdoc-0.15.0.bin \
  -O ~/.local/bin/tmdoc
### make the Tcl script executable
chmod 755 ~/.local/bin/tmdoc
### check the installation
tmdoc --version
## 0.15.0
```

If the folder `~/.local/bin` does not exists you should create it and add this to your `PATH` variable.

That approach  should as well work on  Windows-Cygwin  or  Windows-Msys2  with
installed Tcl interpreter.

To check the document processing create a simple file, let's say `test.tmd` with the following content:

```
---
title: Test file for tmdoc
author: Max Musterman
date: 2025-10-23 09:48
---

## Testing Tmdoc Installation

Remove the single qotes for the code block below:

'```{.tcl}
puts "Hello Tcl World!"
'```
```

Thereafter you can process the file  like this:

```
tmdoc test.tmd test.md
```

which should create the file test.md with the following content:

```
---
title: Test file for tmdoc
author: Max Musterman
date: 2025-10-06 10:02
---

## Testing Tmdoc Installation

Remove the single qotes for the code block below:

'```{tclcode}
puts "Hello Tcl World!"
'```
'```{tclout}
Hello Tcl World!
'```
```

This file can be then converted to HTML or PDF using standard tools like pandoc as well using the [mndoc](https://github.com/mittelmark/mndoc) command line application.

If you like to use as well a Tcl based converter of Markdown documents to HTML
documents, you can install the mndoc application in a similar way like this:


```bash
### download to your local bin folder
wget https://github.com/mittelmark/mndoc/releases/download/v0.15.0/mndoc-0.15.0.bin \
  -O ~/.local/bin/mndoc
### make the file executable  
chmod 755 ~/.local/bin/mndoc
### check the installation
mndoc --version
## 0.15.0
```  

To install the  _tmdoc_ package just  download  the latest Zip or Tar-Gz  archive from the release page and
unpack these files, then  you just copy the  _modules/tmdoc_  folder to a folder
belonging to your _TCLLIBPATH_ variable. Therafter you can as well execute the
command  line  application  using  the   [tclmain](https://github.com/mittelmark/tclmain)
utility like this:

```
tclmain -m tmdoc --help
```



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
how to process Tmd documents to html using tmdoc and mndoc.

```
'```{.kroki dia=graphviz imagepath=kroki ext=png}
digraph g {
  node[height=1.2,width=1.5,style=filled,shape=box,fillcolor=beige]
  TMD -> MD[label="tmdoc"]
  MD -> HTML[label="mndoc"]
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
using the  [https://math.vercel.app](https://math.vercel.app)  webservice. In version 0.14.0 we switched to [latex.codecs.com](https://latex.codecogs.com/)  as math.vercel.app svg
files can't be converted to png due to missing size information. The procedure to add LaTeX equations still stays the same. You
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

## Abbreviations

Since version 0.13.0 there is as well support for YAML based abbreviations. You can either provide an YAML abbreviation file in the YAML header or you simply declare a few abbreviatons within the Markdown file itself.

Here an example:

```
---
title: hello title
author: Some Author
DG: Detlef Groth, University of Potsdam, Germany
abbreviations: abbrev.yml
...
```

__Here the text:__

```
This is an abbrev {DG} and this is another for the 
Author: {author}. The document was created at {date}. 
This an empty abbreviation {empty}.

Now an abbreviation which is in the `abbrev.yml` file 
- tmdoc is: '{tmdoc}'!
```

## CSV Tables

Since version 0.13.0 there is as well support for embedding simple comma separated tables which are then displayed as Markdown tables.

Here an example:

```
'``{.csv results=asis echo=false}
col1,col2,col3,col4
11,12,13,14
15,16,17,18
19,20,21,22
'``
```

## Statistical Reports

Since version 0.14.0 there is as well support for writing  statistical reports
using  either  Octave, R or Python. In  contrast  to the shell based  approach
introduced in version 0.10.0 the state of the interpreter is saved between the
different  code chunks  allowing to write  statistical  reports with  stepwise
analysis steps.

To include code you can do something like the following:

```
'``{r fig=true}
data(iris)
plot(iris$Sepal.Length ~ iris$Species,col=2:4)
x=1
'``

In our data set we have `r nrow(species)` plants.

In the next code  chunk we use a variable defined before.

'```{r}
print(x)
'```
```


The same can be done using the Octave or the Python programming languages. For more details look at the filter documentation pages:

* [filter-octave](http://htmlpreview.github.io/?https://github.com/mittelmark/tmdoc/blob/master/modules/tmdoc/filter-octave.html)
* [filter-python](http://htmlpreview.github.io/?https://github.com/mittelmark/tmdoc/blob/master/modules/tmdoc/filter-python.html)
* [filter-r](http://htmlpreview.github.io/?https://github.com/mittelmark/tmdoc/blob/master/modules/tmdoc/filter-r.html)

## Document Processing

Documents  generated  with  tmdoc  can be then  processed  from the  generated
Markdown to HTML or PDF using tools like [mndoc](https://github.com/mittelmark/mndoc/),
[pandoc](https:///www.pandoc.org), [WeasyPrint](https://pypi.org/project/weasyprint/) or
[LibreOffice](https://libreoffice.org/). Here a pipeline to create an HTML, PDF or ODT 
document using Libreoffice.

![](https://kroki.io/graphviz/svg/eNp1zLEKwjAQgOE9T3FkroI4SpyKOLRUpFtxSHNpe_SalLSgIr67ptLR6bj7fg6pDXrsoIWXAOfRVlOnR6tq_0im-clWNcRsMYnDePZBGR_cRNwnd8K5U7vt_nYQELTrkYKS2VV-13JA2Bwhx4p1bVnJeUBvZCxzhEjnMs9WHNwPQSznyJf0tGpGdbC-acjY5cGaFGn5J3kL8QHVZ0VG)

If your input document is a [Typst](https://typst.app/)  document, for instance with a `.ttyp`
extension you might convert this file with embedded  Tmdoc code chunks into an
real Typst  document and then use standard  typst  compiler  tools to create a
PDF file. See the example for such a typst  document with embedded  tmdoc code
here:   [typst.ttyp](examples/typst.ttyp)  and  there  the  resulting  output:
[typst.pdf](examples/typst.pdf). So the pipeline in this case was:

```bash
tmdoc typst.ttyp typst.typ
typst compile typst.typ
```

If your input document is an [AsciiDoc](https://asciidoc.org/)  document, for instance with a `.tdoc`
extension you might convert this file with embedded  Tmdoc code chunks into an
AsciiDoc  document and then use standard AsciiDoc tools like  [asciidoctor](https://asciidoctor.org/)
for the conversion of that document. Here a typical pipeline.

![](https://kroki.io/graphviz/svg/eNp1zM0KwjAQBOB7niLk3AriUSIIRTxUFOmt9JDmxy6N3ZIEVMR3NykUQfQ0zM7HKrg4MXb0Qp-EDqh07Tsxat7iPfPhYTU3YK1WWQqJFh2X6AYPts9uoELHl4tVsybUiaFX4DgrzyzWSqGk-YZuY9ZWtNpyFq6xsITTlaZ5Xx3KeRZeAsQhoPugaE7F7gfJR2VYQ8n04ouV0DqNxoDU06eZHIvqD3kR8gZ5gVYU)

If you like to better retain the formatting of your HTML documents in your PDF
output, you should use the Python package
[WeasyPrint](https://pypi.org/project/weasyprint/).
 
To give an example the tmdoc tutorial ([source](modules/tmdoc/tmdoc-tutorial.tmd), 
[HTML](http://htmlpreview.github.io/?https://github.com/mittelmark/tmdoc/blob/master/modules/tmdoc/tmdoc-tutorial.html)
is processed with the following commands.

```
tmdoc --mode weave tmdoc-tutorial.tmd - | mndoc - tmdoc-tutorial.html --css tmdoc.css
```

Further  you might  embed your Tmd text within Tcl source code files after the
_#'_ commented lines for documentation  purposes of your Tcl projects. You can
then  extract the Markdown  text first with _mndoc_, then process the Tcl code
within  using _tmdoc_ and again do then a document  conversion  to HTML and or
PDF or OST as described above. Here such a workflow:

![](https://kroki.io/graphviz/svg/eNp1zLEKwjAQBuA9T3FkroI4SpyKOLRUJFtxSHNpG3pNSlpQEd_dplAHwem4__vv0DZBDS008GLgPJpybNVgROUfyTg9yYjaEhlM4tCefBDaBzda6pK7xakVu-3-dmAQlOvQBsGzK59XqQk2R5A9lqQqQ4L3Dr3msTqH0fIvTf1KOUKks8yz3ztgSxz5kp5WzWwVjK9rq83yYK0UqfxTeTP2AQwBTeg=)

See the  [tdot](https://github.com/mittelmark/tdot/blob/main/tdot/tdot.tcl)  source code
as example for such embedded documentation.

## Documentation

* [tmdoc package](http://htmlpreview.github.io/?https://github.com/mittelmark/tmdoc/blob/master/modules/tmdoc/tmdoc.html)
* [tmdoc application](http://htmlpreview.github.io/?https://github.com/mittelmark/tmdoc/blob/master/apps/tmdoc.html)
* [tmdoc tutorial](http://htmlpreview.github.io/?https://github.com/mittelmark/tmdoc/blob/master/modules/tmdoc/tmdoc-tutorial.html)

## Download 

* [Latest Release](https://github.com/mittelmark/tmdoc/releases)
* [Latest development code](https://github.com/mittelmark/tmdoc/warchive/refs/heads/main.zip)


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
- 2025-10-02 0.13.0 
    - support for abbreviations declared in the YAML header or in YAML files
    - support for [Markdown alerts](https://github.com/orgs/community/discussions/16925)
    - support for embedding CSV data for creating Markdown tables
- 2025-10-06 0.14.0
    - support for statistical reports in R,  Python or Octave
    - switching  to   https://latex.codecogs.com/   for  LaTeX  equations  as
      math.vercel.app  svgs can't be converted  to PNG needed for inclusion into
      pdf documents
    - documentation updates, docu for each filter started
- 2025-10-13 0.14.1
    - fixes for fig=true for R pipes and setting the proper image size for png images
    - fix for new Linux distros having no `python` alias for `python3` anymore, `python3` is
      now the default for the Python pipe
- 2025-10-15 0.14.2
    - kroki filter now uses local installs of GraphViz (dot), PlantUML (plantuml) and Ditaa (ditaa)
      command line applications avoding fetching kroki URL's if applications are available locally
- 2025-10-23 0.15.0
    - support for  AsciiDoc - Tcl code chunks,  Shell code chunks, CSV tables,
    ...
    - support for Typst - Tcl code chunks, Shell code chunks, CSV tables, ...
    - support for Yaml file based abbreviations as well for non Markdown files

## TODO

- [x] kroki code chunk support  (done)
- [x] bibtex citation support (citer package) using `[@ref]` syntax (done)
- [x] test cases with examples for Markdown, LaTeX, and Tcl Man page format (done).
- [x] R code chunk with default opening a png file and adding dev.off so automatic 
  generation  of, as well  use of  save.image  and load for  keeping  sessions
  between chunks (done)
- [x] documentation for filter abbreviation, csv, kroki, alerts, shell code (done)
- [ ] adding Julia language support using pipe
- [ ] adding tcrd filter for sheet music display and adding string instrument chords  
  
## See Also

- [mndoc](https://github.com/mittelmark/mndoc) - converting Markdown output of
  tmdoc to HTML or extracting Markdown documentation from source code files
- [Tcl man page format](https://core.tcl-lang.org/tcllib/doc/trunk/embedded/md/tcllib/files/modules/doctools/doctools_lang_cmdref.md)
- [WeasyPrint](https://pypi.org/project/weasyprint/) - converting HTML into PDF with styleseet support

## Author

@ 2020-2025 - Detlef  Groth,  University  of  Potsdam,  Germany  -
  dgroth(at)uni(minus)potsdam(dot)de

## License


```
BSD 3-Clause License

Copyright (c) 2020-2025, Detlef Groth, University of Potsdam, Germany

All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met:

1. Redistributions of source code must retain the above copyright notice, this
   list of conditions and the following disclaimer.

2. Redistributions in binary form must reproduce the above copyright notice,
   this list of conditions and the following disclaimer in the documentation
   and/or other materials provided with the distribution.

3. Neither the name of the copyright holder nor the names of its
   contributors may be used to endorse or promote products derived from
   this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
```


