#
# Be sure to run `pod lib lint TBZipArchiver.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'TBZipArchiver'
  s.version          = '1.1.1'
  s.summary          = 'TBZipArchiver selective archive/unarchive content using directory URL'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
    TBZipArchiver provide native way to create/unarchive zip archives.
    You could select only some files provided you file predicate.
    It works well with passphrase encoded archives.
    Uses ZipArchive, TBFileManager, CDBKit inside.
                       DESC

  s.homepage         = 'https://github.com/truebucha/TBZipArchiver'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'truebucha' => 'truebucha@gmail.com' }
  s.source           = { :git => 'https://github.com/truebucha/TBZipArchiver.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '8.0'

  s.source_files = 'TBZipArchiver/Classes/**/*'
  
  # s.resource_bundles = {
  #   'TBZipArchiver' => ['TBZipArchiver/Assets/*.png']
  # }

  s.public_header_files = 'TBZipArchiver/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  s.dependency 'ZipArchive', '~> 1.4'
  s.dependency 'CDBKit', '~> 1.0'
  s.dependency 'TBFileManager', '~> 1.0'
  # s.dependency 'AFNetworking', '~> 2.3'
end
