Pod::Spec.new do |s|

  s.name             = "BYTabView"  
  s.version          = "1.0.0"  
  s.summary          = "A simple tabView for iOS."  
  
  s.homepage         = "https://github.com/booy/BYTabView"  
  s.license          = 'MIT'  
  s.author           = { "Booy" => "xxhushaomin@gmail.com" }
  s.source           = { :git => "git@github.com:booy/BYTabView.git", :tag => s.version.to_s }  
  
  s.platform     = :ios, '6.0'  
  s.ios.deployment_target = '6.0'  
  s.requires_arc = true  
  
  s.source_files = 'BYTabView/*'  
  s.frameworks = 'Foundation', 'CoreGraphics', 'UIKit'

end 