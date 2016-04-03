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
    
    func getArticleThumbnail(article: Article, completion: (image: UIImage?) -> Void) {
        if let image = imageCache[article.imageUrl] {
            dispatch_async(dispatch_get_main_queue(), { 
                completion(image: image)
            })
            
            return
        }
        
        guard let url = NSURL(string: article.imageUrl) else {
            return
        }
        
        let request = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "GET"
        
        let sessionConfig = NSURLSessionConfiguration.defaultSessionConfiguration()
        let session = NSURLSession(configuration: sessionConfig)
        
        let task = session.dataTaskWithRequest(request) { (data, response, erro) in
            guard let data = data else {
                return
            }
            
            let image = UIImage(data: data)
            
            dispatch_async(dispatch_get_main_queue(), {
                completion(image: image)
            })
        }
        
        task.resume()
    }
    
    func retrieveArticles(completion: (articles: [Article]?) -> Void) {
        guard let language = language, url = NSURL(string: "\(baseUrl)/articles?lang=\(language)") else {
            return
        }
        
        let request = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "GET"
        
        let sessionConfig = NSURLSessionConfiguration.defaultSessionConfiguration()
        let session = NSURLSession(configuration: sessionConfig)
        
        let task = session.dataTaskWithRequest(request) { (data, response, error) in
            guard let data = data else {
                return
            }
            
            var retrievedArticles = [Article]()
            
            let json = JSON(data: data, error: nil)
            if let articles = json["articles"].array {
                for article in articles {
                    if let url = article["url"].string,
                        image = article["image"].string,
                        title = article["title"].string,
                        description = article["description"].string {
                        let articleObject = Article(articleUrl: url, description: description == "" ? nil : description, imageUrl: image, text: article["text"].string, title: title)
                        retrievedArticles.append(articleObject)
                    }
                }
            }
            
            completion(articles: retrievedArticles)
        }
        
        task.resume()
    }
    
    func translateTerm(term: String, completion: (translation: String?) -> Void) {
        if let translation = savedTranslations[term] {
            completion(translation: translation)
            return
        }
        
        guard !requestsMade.contains(term) else {
            return
        }
        
        guard let urlString = "\(baseUrl)/translate?term=\(term)&lang=\(lang)".stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet()), url = NSURL(string: urlString) else {
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

struct Article {
    let articleUrl: String
    let description: String?
    let imageUrl: String
    let text: String?
    let title: String
}
