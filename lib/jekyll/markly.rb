# frozen_string_literal: true

require_relative "markly/version"
require "jekyll"
require "markly"
require "rouge"

# Markly made a bunch of changes to how footnotes are rendered. This module
# restores them to CommonMarker's behavior.
#
# TBD on whether I keep this, but I'm trying to minize the diff for now
module Jekyll::Markly::FootnoteCompat
  def footnote_reference(node)
    label = node.string_content

    out("<sup class=\"footnote-ref\"><a href=\"#fn#{label}\" id=\"fnref#{label}\">#{node.string_content}</a></sup>")
  end

  def footnote_definition(node)
    unless @footnote_ix
      out("<section class=\"footnotes\">\n<ol>\n")
      @footnote_ix = 0
    end

    @footnote_ix += 1
    label = node.string_content
    @footnotes[@footnote_ix] = label

    out("<li id=\"fn#{@footnote_ix}\">\n", :children)
    out("\n") if out_footnote_backref
    out("</li>\n")
  end

  private

  def out_footnote_backref
    return false if @written_footnote_ix == @footnote_ix

    @written_footnote_ix = @footnote_ix

    out("<a href=\"#fnref#{@footnote_ix}\" class=\"footnote-backref\">↩</a>")
    true
  end
end

class Jekyll::Markly::HtmlRenderer < Markly::Renderer::HTML
  include Jekyll::Markly::FootnoteCompat

  def code_block(node)
    block do
      lang, lang_with_options = extract_code_lang(node.fence_info)

      out('<div class="')
      out("language-", lang, " ") if lang
      out('highlighter-rouge">')
      out("<pre", source_position(node), ' class="highlight"')

      if flag_enabled?(Markly::GITHUB_PRE_LANG)
        out_data_attr(lang)
        out("><code>")
      else
        out("><code")
        out_data_attr(lang)
        out(">")
      end
      out(render_with_rouge(node.string_content, lang_with_options))
      out("</code></pre></div>")
    end
  end

  private

  def extract_code_lang(info)
    return unless info.is_a?(String)
    return if info.empty?

    lang_with_options = info.split(%r{\s+})[0]
    lang = lang_with_options.split("?")[0]

    [lang, lang_with_options]
  end

  def out_data_attr(lang)
    return unless lang

    out(' data-lang="', lang, '"')
  end

  def render_with_rouge(code, lang)
    formatter = Rouge::Formatters::HTMLLegacy.new(
      line_numbers: false,
      wrap: false,
      css_class: "highlight",
      gutter_class: "gutter",
      code_class: "code"
    )
    lexer = Rouge::Lexer.find_fancy(lang, code) || Rouge::Lexers::PlainText
    formatter.format(lexer.lex(code))
  end
end

class Jekyll::Converters::Markdown::Markly
  def initialize(config)
    @extensions = config.dig("commonmark", "extensions")&.map!(&:to_sym) || [].freeze

    if (symbol_options = config.dig("commonmark", "options")&.map!(&:to_sym))
      @parse_flags = symbol_options.filter_map { |k| Markly::PARSE_FLAGS[k] }.reduce(&:|)
      @render_flags = symbol_options.filter_map { |k| Markly::RENDER_FLAGS[k] }.reduce(&:|)
    else
      @parse_flags = @render_flags = 0
    end
  end

  def convert(content)
    node = Markly.parse(content, extensions: @extensions, flags: @parse_flags)

    Jekyll::Markly::HtmlRenderer.new(extensions: @extensions, flags: @render_flags).render(node)
  end
end
