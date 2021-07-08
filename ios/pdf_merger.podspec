#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint pdf_merger.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'pdf_merger'
  s.version          = '0.0.2'
  s.summary          = 'A new flutter plugin project.'
  s.description      = <<-DESC
A new Flutter plugin for merging a list of PDF files. It supports both android and IOS. Before call this package make sure you allow permission and file picker see example.
                       DESC
  s.homepage         = 'https://github.com/vvvirani/pdf_merger'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Vishal Virani' => 'vvvirani@gmail.com' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.dependency 'Flutter'
  s.platform = :ios, '10.0'

  # Flutter.framework does not contain a i386 slice.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' }
  s.swift_version = '5.0'
end
