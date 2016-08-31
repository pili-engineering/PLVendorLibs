#
# Be sure to run `pod lib lint pili-ffmpeg.podspec' to ensure this is a
# valid spec and remove all comments before submitting the spec.
#
# Any lines starting with a # are optional, but encouraged
#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = "pili-ffmpeg"
  s.version          = "3.1.0"
  s.summary          = "Pili iOS ffmpeg"
  s.homepage         = "https://github.com/pili-engineering/PLVendorLibs"
  s.license          = 'Apache License, Version 2.0'
  s.author           = { "0dayZh" => "0day.zh@gmail.com" }
  s.source           = { :git => "https://github.com/pili-engineering/PLVendorLibs.git", :tag => "v#{s.version}" }

  s.platform     = :ios, '7.0'
  s.requires_arc = true

  s.default_subspec = "precompiled"

  s.subspec "precompiled" do |ss|
    ss.vendored_libraries   = 'pili-ffmpeg/lib/*.a'
    ss.preserve_paths         = "pili-ffmpeg/include/**/*.h", 'pili-ffmpeg/lib/*.a'
    ss.xcconfig = { 'HEADER_SEARCH_PATHS' => "${PODS_ROOT}/#{s.name}/pili-ffmpeg/include" }
  end
end
