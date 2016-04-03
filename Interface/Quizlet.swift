//
//  Quizlet.swift
//  Interface
//
//  Created by Jack Cook on 4/2/16.
//  Copyright © 2016 Jack Cook. All rights reserved.
//

import SafariServices
import SwiftyJSON
import UIKit

public class Quizlet: NSObject, SFSafariViewControllerDelegate {
    
    private let authToken = "bW5nVDI1QTM2QzphWmtDcDlGZGVHZjRlUDJIOTV3dm03"
    private let clientId = "mngT25A36C"
    
    public class var sharedInstance: Quizlet {
        struct Static {
            static let instance = Quizlet()
        }
        return Static.instance
    }
    
    public var accessToken: String? {
        get {
            return NSUserDefaults.standardUserDefaults().stringForKey("QuizletAccessToken")
        }
        
        set(newValue) {
            NSUserDefaults.standardUserDefaults().setObject(newValue, forKey: "QuizletAccessToken")
        }
    }
    
    public var setId: Int {
        get {
            return NSUserDefaults.standardUserDefaults().integerForKey("QuizletSetID")
        }
        
        set(newValue) {
            NSUserDefaults.standardUserDefaults().setInteger(newValue, forKey: "QuizletSetID")
        }
    }
    
    private var safariViewController: SFSafariViewController?
    private var state: String?
    
    func addTermsToSet(terms: [String: String]) {
        guard let accessToken = accessToken else {
            return
        }
        
        let sessionConfig = NSURLSessionConfiguration.defaultSessionConfiguration()
        let session = NSURLSession(configuration: sessionConfig)
        
        for (term, definition) in terms {
            guard let url = NSURL(string: "https://api.quizlet.com/2.0/sets/\(setId)/terms?term=\(term)&definition=\(definition)") else {
                continue
            }
            
            let request = NSMutableURLRequest(URL: url)
            request.HTTPMethod = "POST"
            
            request.addValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
            
            let task = session.dataTaskWithRequest(request)
            task.resume()
        }
    }
    
    func beginAuthorization(viewController: UIViewController) {
        state = NSUUID().UUIDString
        
        guard let url = NSURL(string: "https://quizlet.com/authorize?response_type=code&client_id=\(clientId)&scope=read&state=\(state!)&scope=write_set") else {
            return
        }
        
        safariViewController = SFSafariViewController(URL: url)
        viewController.presentViewController(safariViewController!, animated: true, completion: nil)
    }
    
    func createSet(words: [String: String], completion: (url: NSURL?) -> Void) {
        guard let accessToken = accessToken else {
            return
        }
        
        let url = NSURL(string: "https://api.quizlet.com/2.0/sets")!
        let request = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "POST"
        
        request.addValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        request.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        
        let sessionConfig = NSURLSessionConfiguration.defaultSessionConfiguration()
        let session = NSURLSession(configuration: sessionConfig)
        
        var bodyParameters = [
            "lang_terms": "fr",
            "lang_definitions": "en",
            "title": "Article Words"
        ]
        
        for (idx, (term, definition)) in words.enumerate() {
            bodyParameters["terms[]\(idx)"] = term
            bodyParameters["definitions[]\(idx)"] = definition
        }
        
        var parts = [String]()
        for (key, value) in bodyParameters {
            let part = NSString(format: "%@=%@",
                                String(key).stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())!,
                                String(value).stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())!)
            parts.append(part as String)
        }
        
        var bodyString = parts.joinWithSeparator("&")
        
        for i in 0..<words.count {
            bodyString = bodyString.stringByReplacingOccurrencesOfString("terms[]\(i)", withString: "terms[]")
            bodyString = bodyString.stringByReplacingOccurrencesOfString("definitions[]\(i)", withString: "definitions[]")
        }
        
        request.HTTPBody = bodyString.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: true)
        
        let task = session.dataTaskWithRequest(request) { (data, response, error) in
            guard let data = data else {
                return
            }
            
            let json = JSON(data: data, error: nil)
            
            guard let url = json["url"].string, id = json["id"].int, quizletUrl = NSURL(string: "https://quizlet.com\(url)") else {
                return
            }
            
            self.setId = id
            
            completion(url: quizletUrl)
        }
        
        task.resume()
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
    
    func openSetWithURL(viewController: UIViewController, url: NSURL) {
        let svc = SFSafariViewController(URL: url)
        viewController.presentViewController(svc, animated: true, completion: nil)
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
            
            let json = JSON(data: data, error: nil)
            
            guard let accessToken = json["access_token"].string else {
                return
            }
            
            self.accessToken = accessToken
        }
        
        task.resume()
    }
}
