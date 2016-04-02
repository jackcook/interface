//
//  AppDelegate.swift
//  Interface
//
//  Created by Jack Cook on 4/2/16.
//  Copyright © 2016 Jack Cook. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        print(Quizlet.sharedInstance.accessToken)
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
