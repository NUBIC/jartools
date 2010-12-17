# -*- coding: utf-8 -*-
require 'jartools'
require 'thor'

require 'zip/zipfilesystem'

module JarTools
  class CLI < Thor
    desc "packages JARFILE", "Print the java packages found in the JAR to standard out"
    long_desc <<-DESC
      Prints all the java packages found in the specified JAR to standard out, one per line.
      "Packages" are defined as unique paths in the JAR which contain at least one class.
    DESC
    def packages(jarfile)
      entry_names = []
      Zip::ZipFile.foreach(jarfile) { |entry|
        entry_names << entry.name
      }

      entry_names.select { |e| e =~ /\.class$/ }.
        collect { |e| e.sub(/\/[^\/]+$/, '').gsub('/', '.') }.
        uniq.sort.each { |pkg| say pkg }
    end
  end
end
