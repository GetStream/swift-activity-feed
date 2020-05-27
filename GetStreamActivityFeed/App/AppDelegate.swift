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
        Bundle.main.setupStreamClient(logsEnabled: true)
        
        if let timelineFeedId = FeedId.timeline, let userFeedId = FeedId.user {
            Client.shared.flatFeed(timelineFeedId).follow(toTarget: userFeedId) { _ in }
        }
    }
}
