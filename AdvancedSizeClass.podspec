#
# Be sure to run `pod lib lint AdvancedSizeClass.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'AdvancedSizeClass'
  s.version          = '0.1.2'
  s.summary          = 'iOS屏幕尺寸变更工具'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
  在大机子上直接模拟显示小屏幕机子的UI，不用再去借一堆的机子，提高工作效率！
                       DESC
                       
  s.homepage         = 'https://github.com/Pixocial/AdvancedSizeClass'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'East.zhang' => 'xiaodong.zhang@pixocial.com' }
  s.source           = { :git => 'git@github.com:Pixocial/AdvancedSizeClass.git', :tag => s.version.to_s }

  s.ios.deployment_target = '9.0'
  s.swift_version = '5.0'

  s.source_files = 'AdvancedSizeClass/Classes/**/*'
  
  # s.resource_bundles = {
  #   'AdvancedSizeClass' => ['AdvancedSizeClass/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'
end
