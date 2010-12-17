require File.expand_path("../../spec_helper", __FILE__)

describe JarTools::CLI do
  describe "#packages" do
    before do
      @result = capture_stdout do
        JarTools::CLI.new.packages(sample_jar("slf4j-api-1.6.0.jar"))
      end.split(/\n/)
    end

    %w(org.slf4j org.slf4j.spi org.slf4j.helpers).each do |expected_pkg|
      it "lists all the packages, including #{expected_pkg}" do
        @result.should include(expected_pkg)
      end
    end

    it "does not list things which are not packages" do
      @result.should_not include "META-INF"
    end
  end
end
