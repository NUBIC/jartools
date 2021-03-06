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

It's been tested on Ruby 1.8.7, JRuby 1.6.7, and Ruby 1.9.3.

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

### manifest

Prints the JAR's manifest (if any) to standard out.

### diff

Does a diff of two JARs or WARs, including file content diffs and
recursive diffs of contained JARs.

Project links
-------------

* [Continuous integration](https://public-ci.nubic.northwestern.edu/job/jartools/)
* [Issue tracking](http://github.com/NUBIC/jartools/issues)

Non-issue questions can be sent to rhett@detailedbalance.net.

About
-----

`jartools` is copyright 2010 Rhett Sutphin.  It was built at [NUBIC][].

[NUBIC]: http://www.nucats.northwestern.edu/centers/nubic
