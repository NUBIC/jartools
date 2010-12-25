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

    desc "manifest JARFILE", "Print the manifest found in the JAR to standard out"
    long_desc <<-DESC
      Prints the META-INF/MANIFEST.MF if one is found in the JAR.  To ease examination,
      lines are unwrapped.  Use --raw to get the original manifest with wrapped lines.
    DESC
    method_option :raw, :type => :boolean,
      :desc => "Print the manifest exactly as it appears in the JAR."
    def manifest(jarfile)
      content = Zip::ZipFile.open(jarfile) { |zip|
        zip.file.read("META-INF/MANIFEST.MF") if zip.file.exists?("META-INF/MANIFEST.MF")
      }
      return unless content
      if options.raw
        say content
      else
        say content.gsub("\r\n", "\n").gsub("\r", "\n").split("\n").inject([]) { |result, raw_line|
          if raw_line =~ /^\s/
            result[-1] += raw_line.slice(1, raw_line.size)
          else
            result << raw_line
          end
          result
        }.join("\n")
      end
    end

    desc "diff JARFILE1 JARFILE2", "Recursively find differences in two JARs or WARs"
    def diff(jar1, jar2)
      Diff.diff(jar1, jar2)
    end
  end
end
