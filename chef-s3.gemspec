# coding: utf-8
require_relative './lib/chef/s3/version'

Gem::Specification.new do |spec|
  spec.name          = 'chef-s3'
  spec.version       = Chef::S3::VERSION
  spec.authors       = ['John Manero']
  spec.email         = ['jmanero@rapid7.com']
  spec.summary       = 'Patch Chef to support loading of core-resources from S3'
  spec.description   = 'This gem allows databags and environments to be loaded directly from S3 by the chef-client runtime.'
  spec.homepage      = 'https://github.com/rapid7/chef-s3'
  spec.license       = 'MIT'

  spec.files         = Dir['**/*']
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.add_dependency 'aws-sdk', '~> 2'
end
