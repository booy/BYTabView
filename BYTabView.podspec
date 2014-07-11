Pod::Spec.new do |s|  
  s.name             = "BYTabView"  
  s.version          = "1.0.0"  
  s.summary          = "A simple tabView for iOS."  
  s.description      = <<-DESC  
                       It is a tab view used on iOS, which implement by Objective-C.  
                       DESC  
  s.homepage         = "https://github.com/booy/BYTabView"  
  s.license          = 'MIT'  
  s.author           = { "Booy" => "xxhushaomin@gmail.com" }  
  s.source           = { :git => "git@github.com:booy/BYTabView.git", :tag => s.version.to_s }  
  
  s.platform     = :ios, '4.3'  
  s.ios.deployment_target = '5.0'  
  # s.osx.deployment_target = '10.7'  
  s.requires_arc = true  
  
  s.source_files = 'BYTabView/*'  
  s.frameworks = 'Foundation', 'CoreGraphics', 'UIKit'
end 