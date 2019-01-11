Pod::Spec.new do |s|

	s.name         = "RefreshableKit"
	s.version      = "0.0.1"

	s.summary      = "Support pull to refresh and load more for UIScrollView"
	s.description  = "Support pull to refresh and load more for UIScrollView"

	s.homepage     = "https://github.com/Hoangtaiki/RefreshableKit"
	s.license      = { :type => "MIT", :file => "LICENSE" }
	s.author       = { 'Hoangtaiki' => 'duchoang.vp@gmail.com' }

	s.platform     = :ios, "9.0"
	s.source       = { :git => "git@github.com:Hoangtaiki/RefreshableKit.git", :tag => s.version.to_s }

	s.source_files  = 'Classes/**/*.swift'
    s.resource_bundles = {'RefreshableKit' => 'Assets/**/*.{png,xcassets}'}

	s.requires_arc = true

	s.frameworks = 'UIKit', 'Foundation'
    
    # Other source code.
    s.dependency 'SWActivityIndicatorView'
end
