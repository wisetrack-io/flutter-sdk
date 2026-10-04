#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint wisetrack.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'wisetrack'
  s.version          = '2.5.0'
  s.summary          = 'WiseTrack Flutter plugin: attribution and analytics for iOS apps.'
  s.description      = <<-DESC
Flutter plugin wrapping the WiseTrack iOS SDK (WiseTrackLib).
                       DESC
  s.homepage         = 'https://wisetrack.io'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'WiseTrack' => 'https://wisetrack.io' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.dependency 'Flutter'
  s.dependency 'WiseTrackLib', '~> 2.5.0'
  s.platform = :ios, '13.0'

  # Flutter.framework does not contain a i386 slice.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' }
  s.swift_version = '5.0'

end
