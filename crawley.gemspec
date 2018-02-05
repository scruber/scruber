# coding: utf-8
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "crawley/version"

Gem::Specification.new do |spec|
  spec.name          = "crawley"
  spec.version       = Crawley::VERSION
  spec.authors       = ["Ivan Goncharov"]
  spec.email         = ["revis0r.mob@gmail.com"]

  spec.summary       = %q{Crawling library}
  spec.description   = %q{Crawling library}
  spec.homepage      = "TODO: Put your gem's website or public repo URL here."
  spec.license       = "MIT"

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  if spec.respond_to?(:metadata)
    spec.metadata["allowed_push_host"] = "rubygems.org"
  else
    raise "RubyGems 2.0 or newer is required to protect against " \
      "public gem pushes."
  end

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "typhoeus", "~> 1.1.0"
  spec.add_dependency "pickup", "0.0.11"
  spec.add_dependency "nokogiri", "~> 1.8.0"
  spec.add_runtime_dependency "thor"
  spec.add_development_dependency "bundler", "~> 1.15"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency "webmock", ["~> 3.0.1"]
end
