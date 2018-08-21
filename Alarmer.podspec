Pod::Spec.new do |s|

  s.name         	= "Alarmer"
  s.version      	= "2.0.0"
  s.license          = "MIT"
  s.summary      	= "AlertKit is a customizable alert and action sheet UI framework"
  s.homepage     	= "https://github.com/melvyndev/Alarmer"
  s.author             	= { "melvyndev" => "melvyndev@gmail.com" }
  s.social_media_url   	= "http://twitter.com/melvyndev"
  s.platform   	   	= :ios, "9.0"
  s.source       	= { :git => "https://github.com/melvyndev/Alarmer.git", :tag => s.version }
  s.source_files 	= "Source/*.swift"

end
