# -*- encoding: utf-8 -*-
#
=begin
Copyright (c) 2018 Aspose Pty Ltd. All Rights Reserved.

Licensed under the MIT (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

      https://github.com/aspose-omr-cloud/aspose-omr-cloud-ruby/blob/master/LICENSE

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.


#Aspose.OMR for Cloud API Reference

#Aspose.OMR for Cloud helps performing optical mark recognition in the cloud

OpenAPI spec version: 1.1

Generated by: https://github.com/swagger-api/swagger-codegen.git
Swagger Codegen version: 3.0.0-SNAPSHOT

=end

$:.push File.expand_path("../lib", __FILE__)
require "aspose_omr_cloud/version"

Gem::Specification.new do |s|
  s.name        = "aspose_omr_cloud"
  s.version     = AsposeOmrCloud::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Aspose OMR"]
  s.email       = ["aspose-omr-cloud@aspose.com"]
  s.homepage    = "https://products.aspose.cloud/omr/ruby"
  s.summary     = "Ruby library for communicating with the Aspose.OMR Cloud API"
  s.description = "Aspose.OMR for Cloud is a REST API that helps you to perform optical mark recognition in the cloud"
  s.license     = "MIT"
  s.required_ruby_version = ">= 2.3"

  s.add_runtime_dependency 'faraday', '~> 0.14.0'
  s.add_runtime_dependency 'mimemagic', '~> 0.3.2'
  s.add_runtime_dependency 'json', '~> 2.1', '>= 2.1.0'

  s.add_development_dependency 'rspec', '~> 3.6', '>= 3.6.0'
  s.add_development_dependency 'vcr', '~> 3.0', '>= 3.0.1'
  s.add_development_dependency 'webmock', '~> 1.24', '>= 1.24.3'
  s.add_development_dependency 'autotest', '~> 4.4', '>= 4.4.6'
  s.add_development_dependency 'autotest-rails-pure', '~> 4.1', '>= 4.1.2'
  s.add_development_dependency 'autotest-growl', '~> 0.2', '>= 0.2.16'
  s.add_development_dependency 'autotest-fsevent', '~> 0.2', '>= 0.2.12'

  s.files         = Dir['lib/**/*.rb', 'LICENSE', 'README.MD', 'docs/**']
  s.executables   = []
  s.require_paths = ["lib"]
end
