require 'bundler'
Bundler.setup

require 'rspec'

$LOAD_PATH.unshift File.expand_path("../../lib", __FILE__)

require 'jartools'

RSpec.configure do |config|
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
end
