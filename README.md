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

The package tmdoc provides a command to evaluate embedded Tcl code in code chunks within documents of Markup languages like Markdown and LaTeX and add the resulting output to the document for creating dynamic documents, a technique as well known as literate programming. The latter uses Tcllib's Markdown package. The embedded Tcl code starts with tri backticks and a language marker like this:

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

## Documentation

* [tmdoc code and manuals download](https://github.com/mittelmark/tmdoc/archive/refs/heads/main.zip)
* [tmdoc application manual](http://htmlpreview.github.io/?https://github.com/mittelmark/tmdoc/blob/master/apps/tmdoc.html)
* [tmdoc package manual](http://htmlpreview.github.io/?https://github.com/mittelmark/tmdoc/blob/master/modules/tmdoc/tmdoc.html)
* [tmdoc writing tutorial](http://htmlpreview.github.io/?https://github.com/mittelmark/tmdoc/blob/master/modules/tmdoc/tmdoc-tutorial.html)

## Installation

On Linux, MacOS and on Windows with installed Msys2 or Cyvwin download the latest
[tmdoc-VERSION.bin](https://github.com/mittelmark/tmdoc/releases) binary (90kb in size), rename
it to _tmdoc_ and copy the file to a folder belonging to your PATH variable. 
Thereafter make the file executable and check that it is correctly installed like
this:

```
$ tmdoc --version
0.7.0
```

To install the  package,  you just copy the  _modules/tmdoc_  folder to a folder
belonging to your _TCLLIBPATH_ variable. Therafter you can as well execute the
command  line  application  using  the   [tclmain](https://mittelmark/tclmain)
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
- 2025-01-04 0.6  tcllib and Tcl 9 aware version
- 2025-01-18  0.7 support for  _results="asis"_  and  functions  _include_ and
_list2mdtab_


## Author

@copyright Detlef  Groth,  University  of  Potsdam,  Germany  -
dgroth(at)uni(minus)potsdam(dot)de

## License


```
The following  terms apply to all files a ssociated  with the software  unless
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


