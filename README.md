# marten-seo

SEO `<head>` metadata, a multi-locale route-integrated `sitemap.xml` with
`hreflang` alternates, a `robots.txt`, and an alternate-URL helper for
[Marten](https://martenframework.com) sites. Runtime dependency: **marten only**.

## Install

```yaml
dependencies:
  marten_seo:
    github: stevegeek/marten-seo
```

```crystal
require "marten_seo"
```

## Configure (once, in an initializer)

```crystal
Marten::SEO.configure do |c|
  c.site_name        = "Acme"
  c.default_og_image = "https://acme.test/assets/og-default.png"
  c.default_robots   = "index,follow"
  c.base_url         = "https://acme.test"   # absolute origin for sitemap/hreflang
  c.robots_disallow  = ["/admin"]
end
```

## Per-page metadata in handlers

```crystal
class HomeHandler < Marten::Handler
  include Marten::SEO::Page

  def get
    seo.title       = "Home"
    seo.description = "Welcome"
    seo.canonical   = "https://acme.test/"
    seo.og.image    = "https://acme.test/assets/home-og.png"
    seo.json_ld << %({"@context":"https://schema.org","@type":"Organization","name":"Acme"})
    render("home.html")
  end
end
```

The concern injects `seo` into the template context before rendering.

## Render head tags

ECR template (base layout `<head>`):

```html
<head>
  {% seo_tags %}
</head>
```

Blueprint layout:

```crystal
head do
  raw safe(Marten::SEO::HeadTags.new(@seo).render_to_s)
end
```

## Sitemap + robots

Register indexable routes in an initializer, then mount the handlers:

```crystal
# initializer
Marten::SEO::PageRegistry.register("home",  priority: 1.0, changefreq: "weekly")
Marten::SEO::PageRegistry.register("about", priority: 0.5, changefreq: "yearly")

# dynamic (DB/catalog) content — re-evaluated on every request:
Marten::SEO::PageRegistry.register_dynamic do
  Article.all.map do |article|
    Marten::SEO::SitemapEntry.new(
      "blog_post",
      params: {"slug" => article.slug},
      changefreq: "monthly",
      priority: 0.6,
      lastmod: article.updated_at.to_s("%Y-%m-%d"),
    )
  end
end
```

```crystal
# config/routes.cr (outside the `localized` block)
path "/sitemap.xml", Marten::SEO::SitemapHandler, name: "sitemap"
path "/robots.txt",  Marten::SEO::RobotsHandler,  name: "robots"
```

## hreflang / language switchers

```crystal
Marten::SEO.alternate_urls("about")
# => {"en" => "https://acme.test/en/about", "it" => "https://acme.test/it/about"}
```

> **hreflang requires fully-translated localized paths.** Every route you put in
> the registry (or pass to `alternate_urls`) must resolve under *each* available
> locale. If you use translated path segments (`path t("routes.about"), ...`),
> ensure the `routes.about` key exists in every locale file — `reverse` will
> raise for a locale that lacks the translation.

## Security

JSON-LD blobs emitted inside `<script type="application/ld+json">` are passed
through `Marten::SEO::Escaping.escape_json` before output. This replaces `<`,
`>`, `&`, U+2028, and U+2029 with their `\uXXXX` JSON string escapes, which
prevents `</script>` / `<!--<script>` breakout and mXSS via Unicode line/paragraph
separators while keeping the JSON valid. The implementation mirrors
`ERB::Util.json_escape` from Rails. Escaping is provided by the shared
[`web-escape`](https://github.com/stevegeek/web-escape) shard (`WebEscape`),
matching ERB::Util.json_escape semantics, with identical byte-level guarantees.

HTML attribute values and text content (canonical URLs, title, description, etc.)
are escaped with `WebEscape.escape_html` via `Marten::SEO::Escaping.escape_html`.

## Development

```bash
script/cr spec   # wrapper exports CRYSTAL_LIBRARY_PATH for the asdf-0.18 issue
```
