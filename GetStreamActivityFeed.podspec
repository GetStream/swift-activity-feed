Pod::Spec.new do |spec|
  spec.name         = "GetStreamActivityFeed"
  spec.version      = "2.1.0"
  spec.summary      = "Stream iOS Activity Feed Components"
  
  spec.description  = <<-DESC
Easy to use UI components with built-in support for Open Graph scraping, hashtags, @mentions, likes, comments, file uploads and realtime; empowering you to quickly launch engaging activity feeds and notification feeds.
DESC

  spec.homepage     = "https://getstream.io/react-activity-feed/"
  spec.license = { :type => "BSD-3", :file => "LICENSE" }
  spec.author = { "Alexey Bukhtin" => "alexey@getstream.io" }
  spec.social_media_url = "https://getstream.io"
  spec.swift_version = "5.0"
  spec.platform = :ios, "11.0"
  spec.source = { :git => "https://github.com/GetStream/swift-activity-feed.git", :tag => "#{spec.version}" }
  spec.source_files  = "Sources/**/*.swift"
  spec.resources = ["Sources/**/*.xib", "Sources/Icons.xcassets"]
  spec.framework = "Foundation", "UIKit"
  spec.dependency "GetStream", "~> 2.1"
  spec.dependency "Nuke", "~> 8.1"
  spec.dependency "Reusable", "~> 4.1"
  spec.dependency "SnapKit", "~> 5.0"
  spec.requires_arc = true
end
