#TopScrollTabView.podspec

Pod::Spec.new do |s|
s.name         = "TopScrollTabView"
s.version      = "1.0"
s.summary      = "A tabview like neteasy news app. you can scroll top tabs and tap them to switch the content at the bottom."

s.homepage     = "https://github.com/fanlyfrank/TopScrollTabView"
s.license      = 'MIT'
s.author       = { "Fanly Frank" => "fanly1987444@126.com" }
s.platform     = :ios, "6.0"
s.ios.deployment_target = "8.1"
s.source       = { :git => "git@github.com:fanlyfrank/TopScrollTabView.git", :tag => s.version}
s.source_files  = 'TopScrollTabViewTest/TopScrollTabViewTest/TSTview*.{h,m},TopScrollTabViewTest/TopScrollTabViewTest/NSLayoutConstraint+Util*.{h,m}'
s.requires_arc = true
end