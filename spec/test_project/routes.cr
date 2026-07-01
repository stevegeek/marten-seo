Marten.routes.draw do
  localized(prefix_default_locale: false) do
    path "/", Marten::SEO::Spec::PlainHandler, name: "home"
    path "/about", Marten::SEO::Spec::PlainHandler, name: "about"
  end
end
