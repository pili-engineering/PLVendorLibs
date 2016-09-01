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
  s.summary          = "Pili iOS fdk aac"
  s.homepage         = "https://github.com/pili-engineering/PLVendorLibs"
  s.license          = 'Apache License, Version 2.0'
  s.author           = { "0dayZh" => "0day.zh@gmail.com" }
  s.source           = { :git => "https://github.com/pili-engineering/PLVendorLibs.git", :tag => "v#{s.version}" }

  s.platform     = :ios, '7.0'
  s.requires_arc = true

  s.default_subspec = "precompiled"

  s.subspec "precompiled" do |ss|
    ss.source_files = 'pili-fdk-aac/include/**/*.h'
    ss.vendored_libraries   = 'pili-fdk-aac/lib/*.a'
    ss.preserve_paths         = "pili-fdk-aac/include/**/*.h", 'pili-fdk-aac/lib/*.a'
    ss.xcconfig = { 'HEADER_SEARCH_PATHS' => "${PODS_ROOT}/#{s.name}/pili-fdk-aac/include" }
  end
end
