Pod::Spec.new do |s|
  s.name             = 'ZJAttributedText'
  s.version          = '0.1.0'
  s.summary          = 'A short description of ZJAttributedText.'

  s.description      = <<-DESC
TODO: Add long description of the pod here.
                       DESC

  s.homepage         = 'https://github.com/syik/ZJAttributedText'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Jsoul1227@hotmail.com' => 'Jsoul1227@hotmail.com' }
  s.source           = { :git => 'https://github.com/syik/ZJAttributedText.git', :tag => s.version.to_s }
  s.ios.deployment_target = '8.0'

  s.source_files = 'ZJAttributedText/**/*.{h,m}'
  s.resource = 'ZJAttributedText/test.png'

end
