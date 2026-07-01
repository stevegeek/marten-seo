require "./spec_helper"

describe Marten::SEO::Escaping do
  describe ".escape_json" do
    it "escapes < > & to \\uXXXX sequences" do
      Marten::SEO::Escaping.escape_json(%(<script>&</script>))
        .should eq("\\u003cscript\\u003e\\u0026\\u003c/script\\u003e")
    end

    it "escapes U+2028 LINE SEPARATOR to \\u2028" do
      Marten::SEO::Escaping.escape_json("before\u{2028}after")
        .should eq("before\\u2028after")
    end

    it "escapes U+2029 PARAGRAPH SEPARATOR to \\u2029" do
      Marten::SEO::Escaping.escape_json("before\u{2029}after")
        .should eq("before\\u2029after")
    end

    it "leaves ordinary JSON characters untouched" do
      input = %({"key":"value","n":42})
      Marten::SEO::Escaping.escape_json(input).should eq(input)
    end
  end

  describe ".escape_html" do
    it "escapes HTML special characters" do
      Marten::SEO::Escaping.escape_html("Tea & <biscuits>")
        .should eq("Tea &amp; &lt;biscuits&gt;")
    end

    it "leaves safe characters untouched" do
      Marten::SEO::Escaping.escape_html("hello world").should eq("hello world")
    end
  end
end
