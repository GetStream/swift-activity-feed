Pod::Spec.new do |s|
  s.name = "GetStreamActivityFeed"
  s.version = "1.0.0"
  s.summary = "Stream iOS Activity Feed Components - easy to use UI components with built-in support for Open Graph scraping, #hashtags, @mentions, likes, comments, file uploads and realtime updates."
  s.homepage = "https://github.com/GetStream/swift-activity-feed"
  s.license = { :type => "BSD-3", :file => "LICENSE" }
  s.author = { "Alexey Bukhtin" => "alexey@getstream.io" }
  s.social_media_url = "https://getstream.io"
  s.swift_version = "4.2"
  s.platform = :ios, "11.0"
  s.source = { :git => "https://github.com/GetStream/swift-activity-feed.git", :tag => s.version.to_s }
  s.default_subspecs = "Core"
  
  s.subspec "Core" do |ss|
    ss.source_files = "Sources/**/*.{swift}"
    ss.resource_bundles = { "GetStreamActivityFeed" => ["Source/**/*.{xib}"] }
    ss.framework = "UIKit"
    ss.dependency "GetStream", "~> 1.1"
    ss.dependency "Nuke", "~> 7.5"
    ss.dependency "Reusable", "~> 4.0"
    ss.dependency "SnapKit", "~> 4.2"
  end
end
