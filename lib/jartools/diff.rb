require 'jartools'

require 'diff/lcs'
require 'diff/lcs/hunk'
require 'sha1'

require 'tempfile'
require 'zip/zip'

module JarTools
  module Diff
    def self.diff(jar1, jar2)
      self.compare(ActualFile.new(jar1), ActualFile.new(jar2), [])
    end

    private

    ##
    # @param [ActualFile,ExtractedFile] jar1
    # @param [ActualFile,ExtractedFile] jar2
    # @param [Array<String>] container_files
    def self.compare(jar1, jar2, container_files = [], roots = [])
      # skip check if the files are identical
      return if jar1.sha1 == jar2.sha1
      roots = [jar1, jar2] if roots.empty?

      entries1 = EntryIterator.new(jar1, container_files)
      entries2 = EntryIterator.new(jar2, container_files)

      until entries1.exhausted? && entries2.exhausted?
        if entries2.exhausted? || (!entries1.exhausted? && entries1.current < entries2.current)
          puts missing_file_message(entries1.current.display_name, roots.first, roots.last)
          entries1.advance
        elsif entries1.exhausted? || entries1.current > entries2.current
          puts missing_file_message(entries2.current.display_name, roots.last, roots.first)
          entries2.advance
        else
          # at this point, the entry names are identical so we can
          # examine just one
          if entries1.current.archive?
            self.compare(entries1.current.extract, entries2.current.extract,
              container_files + [entries1.current.path], roots)
          elsif entries1.current.extract.sha1 != entries2.current.extract.sha1
            if entries1.current.binary? || entries2.current.binary?
              puts mismatched_binary_file_message(entries1.current.display_name)
            else
              puts mismatched_text_file_message(entries1.current.display_name,
                entries1.current.extract, entries2.current.extract)
            end
          else
            # identical in both
          end

          entries1.advance
          entries2.advance
        end
      end
    end

    def self.missing_file_message(display_name, is_in, is_not_in)
      "#{display_name} is in #{is_in.readable_filename} but not in #{is_not_in.readable_filename}"
    end

    def self.mismatched_binary_file_message(display_name)
      "#{display_name} differs"
    end

    def self.mismatched_text_file_message(display_name, one, two)
      diff = TextDiff.new(one.contents, two.contents)
      "#{display_name} text differs:\n#{diff.text_description}\n"
    end

    class EntryIterator
      attr_accessor :index

      def initialize(jarfile, container_files)
        @jarfile = jarfile
        @entries = read_directory
        @container_files = container_files
        @index = 0
        @current_entry_cache = nil
      end

      def current
        unless exhausted?
          @current_entry_cache ||=
            AnalyzableEntry.new(@jarfile, @entries[index], @container_files)
        end
      end

      def exhausted?
        index >= @entries.size
      end

      def advance
        @index += 1
        @current_entry_cache = nil
      end

      private

      def read_directory
        entries = []
        Zip::ZipFile.foreach(@jarfile.readable_filename) do |ze|
          entries << ze.name
        end
        entries.sort
      end

      class AnalyzableEntry
        include Comparable

        attr_reader :path

        def initialize(jarfile, path, container_files)
          @jarfile = jarfile
          @path = path
          @container_files = container_files
        end

        def display_name
          (@container_files + [path]).join(" | ")
        end

        def extract
          @extract ||= Zip::ZipFile.open(@jarfile.readable_filename) do |z|
            ExtractedFile.new(z.get_entry(path))
          end
        end

        def archive?
          path =~ /(zip|jar|war)$/
        end

        # This logic is odd, but it's what grep does, apparently
        def binary?
          extract.contents.match("\000")
        end

        def <=>(other)
          path <=> other.path
        end
      end
    end

    class UniformFile
      def contents
        @contents ||= File.read(readable_filename)
      end

      def sha1
        @sha1 ||= SHA1.sha1(contents).hexdigest
      end
    end

    class ExtractedFile < UniformFile
      attr_reader :entry_path

      def initialize(zip_entry)
        @entry_path = zip_entry.name
        @temp_file = Tempfile.new(File.basename(@entry_path))
        File.open(@temp_file.path, 'w') do |f|
          zip_entry.get_input_stream do |ze|
            f.write ze.read
          end
        end
      end

      def readable_filename
        @temp_file.path
      end
    end

    class ActualFile < UniformFile
      attr_reader :entry_path, :readable_filename

      def initialize(filename)
        @entry_path = @readable_filename = filename
      end
    end

    class TextDiff
      def initialize(a, b)
        @s1 = a
        @s2 = b
      end

      def different?
        @s1 != @s2
      end

      def text_description
        printable_diff if different?
      end

      private

      # Adapted from Diff::LCS::Ldiff by way of Rspec::Expectations::Differ
      def printable_diff
        data_old = @s1.split(/\n/).map! { |e| e.chomp }
        data_new = @s2.split(/\n/).map! { |e| e.chomp }
        output = ""
        diffs = ::Diff::LCS.diff(data_old, data_new)
        return output if diffs.empty?
        oldhunk = hunk = nil
        file_length_difference = 0
        diffs.each do |piece|
          begin
            hunk = ::Diff::LCS::Hunk.new(
              data_old, data_new, piece, 3, file_length_difference
            )
            file_length_difference = hunk.file_length_difference
            next unless oldhunk
            # Hunks may overlap, which is why we need to be careful when our
            # diff includes lines of context. Otherwise, we might print
            # redundant lines.
            if hunk.overlaps?(oldhunk)
              hunk.unshift(oldhunk)
            else
              output << oldhunk.diff(:unified)
            end
          ensure
            oldhunk = hunk
            output << "\n"
          end
        end
        #Handle the last remaining hunk
        output << oldhunk.diff(:unified) << "\n"
        output.lstrip
      end
    end
  end
end
