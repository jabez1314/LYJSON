Pod::Spec.new do |s|
  s.name             = 'LYJSON'
  s.version          = '0.1.0'
  s.summary          = 'By far the most fantastic view I have seen in my entire life. No joke.'
 
  s.description      = <<-DESC
This fantastic view changes its color gradually makes your app look fantastic!
                       DESC
 
  s.homepage         = 'https://github.com/jabez1314/LYJSON'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'jabez1314' => 'jabez4ly@gmail.com' }
  s.source           = { :git => 'https://github.com/jabez1314/LYJSON.git', :tag => s.version.to_s }
 
  s.ios.deployment_target = '8.0'
  s.osx.deployment_target = "10.9"
  s.source_files = 'LYJSON/*.{h,m}'
  s.requires_arc = true
  s.pod_target_xcconfig = { 'OTHER_LDFLAGS' => '-lObjC' }
  s.frameworks  = "Foundation"
end
