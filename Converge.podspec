#
# Be sure to run `pod spec lint --local' to ensure this is a valid spec.
#
# See: https://github.com/CocoaPods/CocoaPods/wiki/The-podspec-format
#
Pod::Spec.new do |s|
  s.name         = "Converge"
  s.version      = "1.0.0"
  s.summary      = 'Library for integrating between Core Data and a web API'
  s.homepage     = 'https://github.com/tripcraft/Converge'
  s.license      = 'MIT'

  s.authors      = { "David Deller" => "david.deller@tripcraft.com" }

  s.source       = { :git => "https://github.com/tripcraft/Converge.git", :tag => 'v1.0.0' }

  s.platform     = :ios, '7.0'
  s.source_files = 'Converge', 'Converge/**/*.{h,m}'

  s.frameworks = 'SystemConfiguration', 'CoreData'

  s.requires_arc = true
  
  s.dependency 'AFNetworking', '~> 2.5.0'
  s.dependency 'TransformerKit', '~> 0.5.0'
  s.dependency 'InflectorKit', '~> 0.0.1'
  s.dependency 'ISO8601DateFormatter', '~> 0.6'
  s.dependency 'TCKUtilities', '~> 1.0.0'
end
