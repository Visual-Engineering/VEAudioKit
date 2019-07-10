Pod::Spec.new do |s|
  s.name         = "VEAudioKit"
  s.version      = "0.0.1"
  s.summary      = "A short description of VEAudioKit."
  s.homepage     = "https://github.com/Visual-Engineering/VEAudioKit"
  s.license      = "MIT"
  s.author       = { "Visual Engineering" => "ios@visual-engin.com" }

  # ――― Platform Specifics ――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  s.platform     = :ios, "11.0"
  s.swift_version = "5.0"

  # ――― Source Location ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  s.source       = { :git => "https://github.com/Visual-Engineering/VEAudioKit.git", :tag => "#{s.version}" }

  # ――― Source Code ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  s.source_files  = "Source/**/*.{swift,m,h}"

  # ――― Dependencies ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
end