#
# Be sure to run `pod lib lint OrangeLabel.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'OrangeLabel'
  s.version          = '0.2.0'
  s.summary          = 'OrangeLabel is extensions of UILabel linkable, available line background and placeholder text'
  s.description      = 'OrangeLabel is extensions of UILabel linkable, available line background and placeholder text'
  s.homepage         = 'https://github.com/pisces/OrangeLabel.git'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Steve Kim' => 'hh963103@@gmail.com' }
  s.source           = { :git => 'https://github.com/pisces/OrangeLabel.git', :tag => s.version.to_s }
  s.ios.deployment_target = '9.0'
  s.source_files = 'OrangeLabel/Classes/**/*'
end
