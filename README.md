jartools
========

`jartools` is a command-line utility for examining java archives (JARs
and WARs).  It is a complement to (not a replacement for) the standard
`jar` utility.

It is designed to use streams in the standard unix style so it can be
composed with other stream-processing tools (e.g., `grep`, `xargs`).

Installing `jartools`
---------------------

`jartools` is distributed as a rubygem.  Install it like so:

    $ gem install jartools

Depending on how your ruby is installed, you may need root privileges
to do this.

It's been tested on Ruby 1.8.7 only.

Using `jartools`
----------------

To see what tools are included in the version you have installed, you
can do this:

    $ jartools help

To get details on a particular tool, use, e.g.:

    $ jartools help packages

This online help tells you what arguments may be passed to each command.

Tools included
--------------

### packages

Lists all the packages present in a JAR.

Project links
-------------

* [Continuous integration](https://ctms-ci.nubic.northwestern.edu/hudson/job/jartools/)
* [Issue tracking](http://github.com/rsutphin/jartools/issues)

Non-issue questions can be sent to rhett@detailedbalance.net.

About
-----

`jartools` is copyright 2010 Rhett Sutphin.  It was built at [NUBIC][].

[NUBIC]: http://www.nucats.northwestern.edu/centers/nubic
