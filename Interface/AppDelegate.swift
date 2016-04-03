//
//  AppDelegate.swift
//  Interface
//
//  Created by Jack Cook on 4/2/16.
//  Copyright © 2016 Jack Cook. All rights reserved.
//

import UIKit

var language: String? {
    get {
        return NSUserDefaults.standardUserDefaults().stringForKey("InterfaceLanguage")
    }

    set(newValue) {
        NSUserDefaults.standardUserDefaults().setObject(newValue, forKey: "InterfaceLanguage")
    }
}

var lang: String {
    get {
        return language!.componentsSeparatedByString("-")[0]
    }
}

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        if language != nil {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let avc = storyboard.instantiateViewControllerWithIdentifier("ArticlesViewController") as! ArticlesViewController
            
            let navController = UINavigationController()
            window?.rootViewController = navController
            
            navController.pushViewController(avc, animated: false)
        }
        
        return true
    }
    
    func application(application: UIApplication, openURL url: NSURL, sourceApplication: String?, annotation: AnyObject) -> Bool {
        guard let host = url.host else {
            return true
        }
        
        switch host {
        case "auth":
            if let component = url.pathComponents?[1] {
                switch component {
                case "quizlet":
                    Quizlet.sharedInstance.handleAuthorizationResponse(url)
                default:
                    break
                }
            }
        default:
            break
        }
        
        return true
    }
}
