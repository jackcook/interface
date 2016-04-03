//
//  Interface.swift
//  Interface
//
//  Created by Jack Cook on 4/3/16.
//  Copyright © 2016 Jack Cook. All rights reserved.
//

import SwiftyJSON

public class Interface {
    
    let baseUrl = "http://45.55.202.8"
    
    private var savedTranslations = [String: String]()
    private var requestsMade = [String]()
    
    public class var sharedInstance: Interface {
        struct Static {
            static let instance = Interface()
        }
        return Static.instance
    }
    
    func translateTerm(term: String, completion: (translation: String?) -> Void) {
        if let translation = savedTranslations[term] {
            completion(translation: translation)
            return
        }
        
        guard !requestsMade.contains(term) else {
            return
        }
        
        guard let url = NSURL(string: "\(baseUrl)/translate?term=\(term)") else {
            completion(translation: nil)
            return
        }
        
        let request = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "GET"
        
        let sessionConfig = NSURLSessionConfiguration.defaultSessionConfiguration()
        let session = NSURLSession(configuration: sessionConfig)
        
        requestsMade.append(term)
        
        let task = session.dataTaskWithRequest(request) { (data, response, error) in
            guard let data = data else {
                completion(translation: nil)
                return
            }
            
            let json = JSON(data: data, error: nil)
            let translation = json["translation"].string
            
            completion(translation: translation)
            
            guard let translatedTerm = translation else {
                return
            }
            
            self.savedTranslations[term] = translatedTerm
        }
        
        task.resume()
    }
}
