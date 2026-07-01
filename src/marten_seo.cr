require "marten"
require "json"
require "html"

# marten-seo — SEO head tags, multi-locale sitemap + robots, and an
# alternate-URL helper for Marten sites. Runtime dependency: marten only.
module Marten
  module SEO
    VERSION = "0.1.0"
  end
end

# --- component requires (appended task-by-task) ---
require "./marten_seo/config"
require "./marten_seo/page_meta"
require "./marten_seo/head_tags"
