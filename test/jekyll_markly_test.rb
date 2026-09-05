# frozen_string_literal: true

class JekyllMarklyTest < JekyllMarklyTestCase
  test "syntax highlighting" do
    html = md_to_html(<<~MD)
      ```ruby
      3.times {}
      ```
    MD

    assert_snapshot(<<~SNAP, html)
      <div class="language-ruby highlighter-rouge"><pre class="highlight"><code data-lang="ruby"><span class="mi">3</span><span class="p">.</span><span class="nf">times</span> <span class="p">{}</span>
      </code></pre></div>
    SNAP
  end

  test "lang attributes include lexer options" do
    html = md_to_html(<<~MD)
      ```console?comments=true
      # frank
      ```
    MD

    assert_snapshot(<<~SNAP, html)
      <div class="language-console highlighter-rouge"><pre class="highlight"><code data-lang="console"><span class="c"># frank
      </span></code></pre></div>
    SNAP
  end

  private

  def assert_snapshot(expected, actual)
    if expected.empty?
      flunk <<~OUT
        Empty snapshot at line #{caller_locations(1, 1).first.lineno}. Replace with

        assert_snapshot(<<~SNAP, html)
          #{actual.strip}
        SNAP
      OUT
    end

    assert_equal expected.strip, actual.strip
  end

  def md_to_html(md)
    converter.convert(md)
  end

  def converter(config = {})
    @converter ||= Jekyll::Converters::Markdown::Markly.new(config)
  end
end
