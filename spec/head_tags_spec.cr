require "./spec_helper"

describe Marten::SEO::HeadTags do
  it "renders title, description, robots, and canonical with escaping" do
    meta = Marten::SEO::PageMeta.new
    meta.title = "Home <Acme>"
    meta.description = "Tea & biscuits"
    meta.canonical = "https://acme.test/"
    html = Marten::SEO::HeadTags.new(meta).render_to_s

    html.should contain("<title>Home &lt;Acme&gt;</title>")
    html.should contain(%(<meta name="description" content="Tea &amp; biscuits"/>))
    html.should contain(%(<meta name="robots" content="index,follow"/>))
    html.should contain(%(<link rel="canonical" href="https://acme.test/"/>))
  end

  it "honors a per-page robots override" do
    meta = Marten::SEO::PageMeta.new
    meta.robots = "noindex,nofollow"
    Marten::SEO::HeadTags.new(meta).render_to_s
      .should contain(%(<meta name="robots" content="noindex,nofollow"/>))
  end

  it "renders OpenGraph and Twitter tags, falling back to base fields" do
    meta = Marten::SEO::PageMeta.new
    meta.title = "T"
    meta.description = "D"
    meta.canonical = "https://x.test/p"
    html = Marten::SEO::HeadTags.new(meta).render_to_s

    html.should contain(%(<meta property="og:title" content="T"/>))
    html.should contain(%(<meta property="og:description" content="D"/>))
    html.should contain(%(<meta property="og:type" content="website"/>))
    html.should contain(%(<meta property="og:url" content="https://x.test/p"/>))
    html.should contain(%(<meta name="twitter:card" content="summary_large_image"/>))
    html.should contain(%(<meta name="twitter:title" content="T"/>))
  end

  it "emits json_ld and neutralizes </ so the script element can't be closed early" do
    meta = Marten::SEO::PageMeta.new
    meta.json_ld << %({"@type":"Org","x":"</script>"})
    html = Marten::SEO::HeadTags.new(meta).render_to_s

    html.should contain(%(<script type="application/ld+json">))
    html.should contain(%("x":"<\\/script>"))        # injected </ neutralized
    html.should contain("</script>\n")                # our own closing tag intact
  end
end
