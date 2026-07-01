Marten.routes.draw do
  path "/seo-page", Marten::SEO::Spec::SeoPageHandler, name: "seo_page"
  path "/sitemap.xml", Marten::SEO::SitemapHandler, name: "sitemap"
  path "/robots.txt", Marten::SEO::RobotsHandler, name: "robots"

  localized(prefix_default_locale: false) do
    path "/", Marten::SEO::Spec::PlainHandler, name: "home"
    path "/about", Marten::SEO::Spec::PlainHandler, name: "about"
  end
end
