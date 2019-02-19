//
//  AppDelegate.swift
//  GetStreamActivityFeed
//
//  Created by Alexey Bukhtin on 14/01/2019.
//  Copyright © 2019 Stream.io Inc. All rights reserved.
//

import UIKit
import GetStream

@UIApplicationMain
final class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    var client: Client?
    var currentUser: User? { return client?.currentUser as? User }
    lazy var userFeed: FlatFeed? = client?.flatFeed(feedSlug: "user")
    
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        setupClient()
        Appearance.setup()
        
        let activityBuilder = ActivityFeedBuilder()
        let profileBuilder = ProfileBuilder()
        activityBuilder.profileBuilder = profileBuilder
        profileBuilder.activityFeedBuilder = activityBuilder
        
        let router = RootRouter(rootBuilder: RootBuilder(activityFeedBuilder: activityBuilder,
                                                         notificationsBuilder: NotificationsBuilder(),
                                                         profileBuilder: profileBuilder),
                                rootViewController: application.rootViewController)
        
        application.rootViewController.presenter = RootPresenter(router: router)
        
        return true
    }
    
    private func setupClient() {
        guard let apiKey = Bundle.main.streamAPIKey,
            let appId = Bundle.main.streamAppId,
            let token = Bundle.main.streamToken,
            !apiKey.isEmpty,
            !appId.isEmpty,
            !token.isEmpty else {
            return
        }
        
        let client = Client(apiKey: apiKey, appId: appId, token: token)
        self.client = client
        
        if let timelineFeed = client.flatFeed(feedSlug: "timeline"),
            let userFeed = userFeed {
            timelineFeed.follow(toTarget: userFeed.feedId) { _ in}
        }
    }
}
