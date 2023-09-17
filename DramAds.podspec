
Pod::Spec.new do |s|
  s.name             = "DramAds"
  s.version          = "0.1.0"
  s.summary          = "The open source fonts for Artsy apps + UIFont categories."
  s.homepage         = "https://github.com/dram-inc"
  s.license          = 'Code is MIT, then custom font licenses.'
  s.author           = { "Orta" => "orta.therox@gmail.com" }
  s.source           = { :git => "https://github.com/dram-inc/dram-ads-ios.git", :tag => s.version }
  s.social_media_url = 'https://twitter.com/artsy'

  s.platform     = :ios, '13.0'
  s.source_files = 'DramAds/Classes'
  #s.resources = 'Pod/Assets/*'

  #s.frameworks = 'UIKit', 'CoreText'
  s.module_name = 'DramAds'
end