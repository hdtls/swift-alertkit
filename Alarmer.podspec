Pod::Spec.new do |s|
  s.name         	 = "Alarmer"
  s.version      	 = "2.0.0"
  s.license          = { :type => "MIT" }
  s.summary      	 = "Alarmer is a customizable alert and action sheet UI framework"
  s.homepage     	 = "https://github.com/hdtls/swift-alarmer"
  s.author      	 = { "Junfeng Zhang" => "melvyndev@gmail.com" }
  s.social_media_url = "http://twitter.com/hdtls"
  s.platform   	   	 = :ios, "11.0"
  s.source       	 = { :git => "https://github.com/hdtls/swift-alarmer.git", :tag => s.version }
  s.source_files 	 = "Sources/Alarmer/*.swift"
  s.swift_version    = "5"
end
