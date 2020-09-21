css-theme-builder

Contents
================================================================================

* Description
* Requirements
* Installation
* Usage
* Versioning
* Copyright and License
  * The MIT License


Description
================================================================================

Perl script to generate a pair of color schemes (dark and light) for CSS usage


Requirements
================================================================================

*  Requires Perl (ver. 5.26 or higher) with the following modules installed:
   -  POSIX (should be in the core)
   -  List::Util (should be in the core)
   -  Math::Round
   -  Color::Rgb

*  A copy of `rgb.txt` somewhere in the system
   -  A copy of the `rgb.txt` file from the Vim project is included in the
      `assets` directory.


Installation
================================================================================

Place the script file, or a symlink to it, in your $PATH somewhere.


Usage
================================================================================

Run the file as `perl css-scheme-builder.pl` or `./css-scheme-builder.pl`


Versioning
================================================================================

The css-scheme-builder project uses Semantic Versioning v2.0.0.

Semantic Versioning <https://semver.org/spec/v2.0.0.html> was created by Tom
Preston-Werner <http://tom.preston-werner.com/>, inventor of Gravatars and
cofounder of GitHub.

Version numbers take the form X.Y.Z where X is the major version, Y is
the minor version and Z is the patch version. The meaning of the
different levels are:

* Major version increases indicates that there is some kind of change in
  the API (how this program works as seen by the user) or the program
  features which is incompatible with previous version

* Minor version increases indicates that there is some kind of change in
  the API (how this program works as seen by the user) or the program
  features which might be new, while still being compatible with all other
  versions of the same major version

* Patch version increases indicate that there is some internal change,
  bug fixes, changes in logic, or other internal changes which do not
  create any incompatible changes within the same major version, and which
  do not add any features to the program operations or functionality


Copyright and License
================================================================================

The MIT license applies to all the code within this repository.

Copyright © 2020  Chindraba (Ronald Lamoreaux)
            <projects@chindraba.work>
- All Rights Reserved

The MIT License

Permission is hereby granted, free of charge, to any person obtaining a
copy of this software and associated documentation files (the "Software"),
to deal in the Software without restriction, including without limitation
the rights to use, copy, modify, merge, publish, distribute, sublicense,
and/or sell copies of the Software, and to permit persons to whom the
Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included
in all copies or substantial portions of the Software

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGE MENT. IN NO EVENT SHALL
THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
DEALINGS IN THE SOFTWARE.
