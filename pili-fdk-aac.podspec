#
# Be sure to run `pod lib lint pili-fdk-aac.podspec' to ensure this is a
# valid spec and remove all comments before submitting the spec.
#
# Any lines starting with a # are optional, but encouraged
#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = "pili-fdk-aac"
  s.version          = "0.1.4"
  s.summary          = "Pili iOS FDK AAC Library"
  s.homepage         = "https://github.com/pili-engineering/PLVendorLibs"
  s.license          = 'Apache License, Version 2.0'
  s.author           = { "hzwangsiyu" => "hzwangsiyu@gmail.com" }
  s.source           = { :git => "https://github.com/pili-engineering/PLVendorLibs.git", :tag => "v1.0.0" }

  s.platform         = :ios, '7.0'
  s.requires_arc     = true
  s.source_files     = 'pili-fdk-aac/include/**/*.h'
  s.vendored_libraries  = 'pili-fdk-aac/lib/*.a'
  s.xcconfig = { 'USER_HEADER_SEARCH_PATHS' => "${PODS_ROOT}/Headers/Public/#{s.name}" }
end
