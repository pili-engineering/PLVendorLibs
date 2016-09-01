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
  s.summary          = "Pili iOS FFmpeg Library"
  s.homepage         = "https://github.com/pili-engineering/PLVendorLibs"
  s.license          = 'Apache License, Version 2.0'
  s.author           = { "hzwangsiyu" => "hzwangsiyu@gmail.com" }
  s.source           = { :git => "https://github.com/pili-engineering/PLVendorLibs.git", :tag => "v1.0.0" }

  s.platform         = :ios, '7.0'
  s.requires_arc     = true
  s.vendored_libraries = 'pili-ffmpeg/lib/*.a'
  s.public_header_files = 'pili-ffmpeg/include/**/*.h'
  s.header_mappings_dir = 'pili-ffmpeg/include/'
end
