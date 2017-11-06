Pod::Spec.new do |s|

  s.name         	= "AlertKit"
  s.version      	= "2.0.0"
  s.license          = "MIT"
  s.summary      	= "AlertKit is a customizable alert and action sheet UI framework"
  s.homepage     	= "https://github.com/melvyndev/AlertKit"
  s.author             	= { "melvyndev" => "melvyndev@icloud.com" }
  s.social_media_url   	= "http://twitter.com/melvyndev"
  s.platform   	   	= :ios, "8.0"
  s.source       	= { :git => "https://github.com/melvyndev/AlertKit.git", :tag => s.version }
  s.source_files 	= "Source/*.swift"

end
