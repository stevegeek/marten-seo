Marten.routes.draw do
  path "/seo-page", Marten::SEO::Spec::SeoPageHandler, name: "seo_page"

  localized(prefix_default_locale: false) do
    path "/", Marten::SEO::Spec::PlainHandler, name: "home"
    path "/about", Marten::SEO::Spec::PlainHandler, name: "about"
  end
end
