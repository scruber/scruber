# Scruber

Scruber is an open source scraping framework for Ruby.

## Getting started

1. Install Scruber at the command prompt if you haven't yet:

    $ gem install scruber

2. Create a new workspace

    $ scruber new myworkspace

3. Create a new scraper

    $ scruber new scraper example


```ruby
Scruber.run do
  csv_file 'output.csv', col_sep: ','

  get 'http://example.com'

  parse :html do |page, html|
    csv_out html.at('title').text
  end
end
```

4. Run your scraper

    $ scruber start example


## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/scruber/scruber.

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
