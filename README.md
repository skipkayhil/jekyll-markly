# Jekyll::Markly

Jekyll Markdown converter that uses [`cmark-gfm`], Github's fork of the
reference parser for CommonMark, through the [`markly`] gem.

[`cmark-gfm`]: https://github.com/github/cmark-gfm
[`markly`]: https://github.com/socketry/markly

## Installation

Add `jekyll-markly` to the `jekyll_plugins` group in your `Gemfile`

```ruby
group :jekyll_plugins do
  gem "jekyll-markly"
end
```

and update the `markdown` configuration in `_config.yml`

```yml
markdown: Markly
```

## Configuration

`cmark-cfm` extensions and options can be configured with the `commonmark`
configuration in `_config.yml`

```yml
commonmark:
  extensions: [table, strikethrough, autolink]
  options: [unsafe, footnotes]
```

The full list of supported extensions and options can be found in the `Markly`
[documentation][].

[documentation]: https://socketry.github.io/markly/guides/getting-started/index.html#options

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run
`rake ` to run the tests. You can also run `bin/console` for an interactive
prompt that will allow you to experiment.

## Contributing

Bug reports and pull requests are welcome on GitHub at
https://github.com/skipkayhil/jekyll-markly.

## License

The gem is available as open source under the terms of the [MIT
License](https://opensource.org/licenses/MIT).
