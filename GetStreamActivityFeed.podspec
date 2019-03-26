Pod::Spec.new do |spec|
  spec.name         = "GetStreamActivityFeed"
  spec.version      = "1.0.9"
  spec.summary      = "Stream iOS Activity Feed Components"
  
  spec.description  = <<-DESC
Easy to use UI components with built-in support for Open Graph scraping, hashtags, @mentions, likes, comments, file uploads and realtime; empowering you to quickly launch engaging activity feeds and notification feeds.
DESC

  spec.homepage     = "https://getstream.io/react-activity-feed/"
  spec.license = { :type => "BSD-3", :file => "LICENSE" }
  spec.author = { "Alexey Bukhtin" => "alexey@getstream.io" }
  spec.social_media_url = "https://getstream.io"
  spec.swift_version = "4.2"
  spec.platform = :ios, "11.0"
  spec.source = { :git => "https://github.com/GetStream/swift-activity-feed.git", :tag => "#{spec.version}" }
  spec.source_files  = "Sources/**/*.swift"
  spec.resources = ["Sources/**/*.xib", "Sources/Icons.xcassets"]
  spec.framework = "Foundation", "UIKit"
  spec.dependency "GetStream", "~> 1.1"
  spec.dependency "Nuke", "~> 7.5"
  spec.dependency "Reusable", "~> 4.0"
  spec.dependency "SnapKit", "~> 4.2"
  spec.requires_arc = true
end
