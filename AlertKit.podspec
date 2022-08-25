Pod::Spec.new do |s|
  s.name         	 = "AlertKit"
  s.version      	 = "2.0.0"
  s.license          = { :type => "MIT" }
  s.summary      	 = "AlertKit is a customizable alert and action sheet UI framework"
  s.homepage     	 = "https://github.com/hdtls/swift-alertkit"
  s.author      	 = { "Junfeng Zhang" => "ph.gitio@gmail.com" }
  s.social_media_url = "http://twitter.com/hdtls"
  s.platform   	   	 = :ios, "11.0"
  s.source       	 = { :git => "https://github.com/hdtls/swift-alertkit.git", :tag => s.version }
  s.source_files 	 = "Sources/AlertKit/*.swift"
  s.swift_version    = "5"
end
