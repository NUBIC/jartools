require 'bundler'
Bundler.setup

require 'rspec'

$LOAD_PATH.unshift File.expand_path("../../lib", __FILE__)

require 'jartools'
require 'fileutils'

RSpec.configure do |config|
  config.include FileUtils

  config.after do
    if @tmpdir
      rm_r @tmpdir
    end
  end

  ##
  # Returns the path to a JAR from the samples directory
  def sample_jar(name)
    File.join(File.expand_path("../samples", __FILE__), name)
  end

  ##
  # Captures everything printed to stdout during the block
  # and returns it as a string.
  def capture_stdout
    old_stdout, $stdout = $stdout, StringIO.new
    begin
      yield
      $stdout.string
    ensure
      $stdout = old_stdout
    end
  end

  def tmpdir(sub=nil)
    @tmpdir ||= begin
                  dirname = File.expand_path("../tmp", __FILE__)
                  mkdir_p dirname
                  dirname
                end
    if sub
      full = File.join(@tmpdir, sub)
      mkdir_p full
      full
    else
      @tmpdir
    end
  end

  def tmpfile(basename, contents=nil)
    full_path = File.join(tmpdir, basename)
    File.open(full_path, 'w') do |f|
      f.write(contents) if contents
    end
    full_path
  end

  def tmpjar(basename, *files)
    full_path = File.join(tmpdir, basename)
    cd tmpdir do
      cmd = "jar Mcf '#{full_path}' '#{files.join("' '")}'"
      `#{cmd}`
    end
    full_path
  end
end
