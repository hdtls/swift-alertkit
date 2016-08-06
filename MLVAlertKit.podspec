Pod::Spec.new do |s|

  s.name         = "MLVAlertKit"
  s.version      = "1.1.0"
  s.summary      = "MLVAlertKit is a customizable alert and action sheet UI framework"
  s.homepage     = "https://github.com/melvyndev/MLVAlertKit"
  s.license      = "MIT"
  s.author             = { "melvyndev" => "melvyndev@icloud.com" }
  s.social_media_url   = "http://twitter.com/melvyndev"
  s.platform     = :ios, "7.0"
  s.source       = { :git => "https://github.com/melvyndev/MLVAlertKit.git", :tag => "1.1.0" }
  s.source_files = "MLVAlertKit/*.{h,m}"
  s.requires_arc = true

end
