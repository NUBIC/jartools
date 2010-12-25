require File.expand_path("../../spec_helper", __FILE__)

describe JarTools::Diff do
  it "reports no differences for the same JAR" do
    same = sample_jar('slf4j-api-1.6.0.jar')
    capture_stdout { JarTools::Diff.diff(same, same) }.should == ""
  end

  describe "with a text file difference" do
    before do
      tmpdir("sub")
      tmpfile("A.txt", "Description\nFirst Letter")
      tmpfile("sub/B.txt", "Description\nSecond letter")
      jar1 = tmpjar("one.jar", "A.txt", "sub/B.txt")
      tmpfile("sub/B.txt", "Description\n2nd letter")
      jar2 = tmpjar("two.jar", "A.txt", "sub/B.txt")

      @actual = capture_stdout { JarTools::Diff.diff(jar1, jar2) }
    end

    it "should note the difference in its text description" do
      @actual.should == <<-EXPECTED
sub/B.txt text differs:
@@ -1,3 +1,3 @@
 Description
-Second letter
+2nd letter

EXPECTED
    end
  end

  describe "with a classfile difference" do
    before do
      tmpfile("A.java", "public class A { }");
      cd(tmpdir) { system("javac A.java") }
      jar1 = tmpjar("one.jar", "A.class")

      tmpfile("A.java", %q(public class A { public static final String N = "A"; }))
      cd(tmpdir) { system("javac A.java") }
      jar2 = tmpjar("two.jar", "A.class")

      @actual = capture_stdout { JarTools::Diff.diff(jar1, jar2) }
    end

    it "should not include a detailed diff" do
      @actual.should == <<-EXPECTED
A.class differs
EXPECTED
    end
  end

  describe "with files present in one jar but not the other" do
    before do
      tmpdir("sub")
      tmpfile("A.txt", "Description\nFirst Letter")
      tmpfile("sub/B.txt", "Description\nSecond letter")
      tmpfile("sub/C.txt", "Description\Third letter")
      jar1 = tmpjar("one.jar", "sub/B.txt", "sub/C.txt")
      jar2 = tmpjar("two.jar", "sub/C.txt", "A.txt")

      cd(tmpdir) do
        @actual = capture_stdout { JarTools::Diff.diff("one.jar", "two.jar") }
      end
    end

    it "should have an appropriate text description" do
      @actual.should == <<-EXPECTED
A.txt is in two.jar but not in one.jar
sub/B.txt is in one.jar but not in two.jar
EXPECTED
    end
  end

  describe "with a nested JAR difference" do
    before do
      tmpfile("same.txt", "No changes in here")
      tmpfile("altered.txt", "V1")
      tmpjar("nested.jar", "altered.txt")
      jar1 = tmpjar("main1.jar", "nested.jar", "same.txt")

      tmpfile("altered.txt", "V2")
      tmpfile("extra.txt", "Not in that other one")
      tmpjar("nested.jar", "altered.txt", "extra.txt")
      jar2 = tmpjar("main2.jar", "nested.jar", "same.txt")

      cd(tmpdir) do
        @actual = capture_stdout { JarTools::Diff.diff("main1.jar", "main2.jar") }
      end
    end

    it "should output the details of the difference" do
      @actual.should == <<-EXPECTED
nested.jar | altered.txt text differs:
@@ -1,2 +1,2 @@
-V1
+V2

nested.jar | extra.txt is in main2.jar but not in main1.jar
EXPECTED
    end
  end

  module JarTools::Diff
    describe TextDiff do
      describe "#different?" do
        it "is true for different values" do
          TextDiff.new("A", "B").should be_different
        end

        it "is false for identical values" do
          TextDiff.new("C", "C").should_not be_different
        end
      end

      describe "#text_description" do
        it "is nil for no differences" do
          TextDiff.new("ABC", "ABC").text_description.should be_nil
        end

        it "gives diff-style output for differences" do
          TextDiff.new("A\nb\nC", "A\nB\nC").text_description.should == <<-EXPECTED
@@ -1,4 +1,4 @@
 A
-b
+B
 C
          EXPECTED
        end
      end
    end
  end
end
