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
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    var client: Client?
    
    var currentUser: User? {
        return client?.currentUser as? User
    }
    
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        setupClient()
        
        let router = RootRouter(rootViewController: application.rootViewController)
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
        
        client = Client(apiKey: apiKey, appId: appId, token: token)
    }
}
