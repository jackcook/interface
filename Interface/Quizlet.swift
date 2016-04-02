//
//  Quizlet.swift
//  Interface
//
//  Created by Jack Cook on 4/2/16.
//  Copyright © 2016 Jack Cook. All rights reserved.
//

import SafariServices
import UIKit

public class Quizlet: NSObject, SFSafariViewControllerDelegate {
    
    let authToken = "bW5nVDI1QTM2QzphWmtDcDlGZGVHZjRlUDJIOTV3dm03"
    private let clientId = "mngT25A36C"
    
    public class var sharedInstance: Quizlet {
        struct Static {
            static let instance = Quizlet()
        }
        return Static.instance
    }
    
    private var safariViewController: SFSafariViewController?
    private var state: String?
    
    func beginAuthorization(viewController: UIViewController) {
        state = NSUUID().UUIDString
        
        guard let url = NSURL(string: "https://quizlet.com/authorize?response_type=code&client_id=\(clientId)&scope=read&state=\(state!)&scope=write_set") else {
            return
        }
        
        safariViewController = SFSafariViewController(URL: url)
        viewController.presentViewController(safariViewController!, animated: true, completion: nil)
    }
    
    func handleAuthorizationResponse(url: NSURL) {
        safariViewController?.dismissViewControllerAnimated(true, completion: nil)
        
        var params = [String: String]()
        
        guard let paramsArray = url.query?.componentsSeparatedByString("&") else {
            return
        }
        
        for param in paramsArray {
            let components = param.componentsSeparatedByString("=")
            let key = components[0], value = components[1]
            
            params[key] = value
        }
        
        guard let code = params["code"], state = params["state"], sentState = self.state else {
            return
        }
        
        guard state == sentState else {
            return
        }
        
        requestTokenWithCode(code)
    }
    
    func requestTokenWithCode(code: String) {
        guard let url = NSURL(string: "https://api.quizlet.com/oauth/token?grant_type=authorization_code&code=\(code)") else {
            return
        }
        
        let request = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "POST"
        
        request.addValue("Basic \(authToken)", forHTTPHeaderField: "Authorization")
        
        let sessionConfig = NSURLSessionConfiguration.defaultSessionConfiguration()
        let session = NSURLSession(configuration: sessionConfig)
        
        let task = session.dataTaskWithRequest(request) { (data, response, error) in
            guard let data = data else {
                return
            }
            
            print(NSString(data: data, encoding: NSUTF8StringEncoding))
        }
        
        task.resume()
    }
}
