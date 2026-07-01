ENV["MARTEN_ENV"] = "test"

require "spec"
require "sqlite3"
require "../src/marten_seo"
require "marten/spec"

require "./test_project/app"
require "./test_project/handlers"
require "./test_project/routes"

# Fixed test secret — reproducible failure modes beat per-run randomness.
SPEC_SECRET_KEY = "__insecure_spec_secret_marten_seo_DO_NOT_USE__"

Marten.configure :test do |config|
  config.secret_key = SPEC_SECRET_KEY
  config.log_level = ::Log::Severity::None

  config.installed_apps = [Marten::SEO::Spec::App]
  config.allowed_hosts = ["127.0.0.1"]
  config.templates.dirs = [File.expand_path("test_project/templates", __DIR__)]

  config.i18n.default_locale = :en
  config.i18n.available_locales = [:en, :it]

  config.database do |db|
    db.backend = :sqlite
    db.name = ":memory:"
  end
end
