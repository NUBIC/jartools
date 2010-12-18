require File.expand_path("../../spec_helper", __FILE__)

describe JarTools::CLI do
  def cli_lines(*args)
    capture_stdout do
      JarTools::CLI.start(args)
    end.gsub("\r\n", "\n").split(/\n/)
  end

  describe "#packages" do
    before do
      @result = cli_lines("packages", sample_jar("slf4j-api-1.6.0.jar"))
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

  describe "#manifest" do
    describe "by default" do
      before do
        @result = cli_lines("manifest", sample_jar("slf4j-api-1.6.0.jar"))
      end

      it "prints the whole manifest" do
        @result.should have(16).lines
      end

      it "unwraps hard-wrapped lines" do
        @result.find { |l| l =~ /^Export-Package/ }.should ==
          "Export-Package: org.slf4j;version=1.6.0, org.slf4j.spi;version=1.6.0, org.slf4j.helpers;version=1.6.0"
      end
    end

    describe "--raw" do
      before do
        @result = cli_lines("manifest", sample_jar("slf4j-api-1.6.0.jar"), "--raw")
      end

      it "prints the raw manifest" do
        @result.should have(17).lines
      end

      it "leaves wrapped lines alone" do
        @result.find { |l| l =~ /^Export-Package/ }.should ==
          "Export-Package: org.slf4j;version=1.6.0, org.slf4j.spi;version=1.6.0, "
      end
    end

    describe "on a JAR without a manifest" do
      it "prints nothing" do
        cli_lines("manifest", sample_jar("empty.jar")).should == []
      end
    end
  end
end
