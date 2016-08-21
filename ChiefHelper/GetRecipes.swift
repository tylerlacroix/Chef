//
//  GetRecipes.swift
//  ChiefHelper
//
//  Created by Tyler Lacroix on 8/20/16.
//  Copyright © 2016 Tyler Lacroix. All rights reserved.
//

import UIKit
//import Alamofire

extension NSMutableURLRequest {
    
    /// Percent escape
    ///
    /// Percent escape in conformance with W3C HTML spec:
    ///
    /// See http://www.w3.org/TR/html5/forms.html#application/x-www-form-urlencoded-encoding-algorithm
    ///
    /// - parameter string:   The string to be percent escaped.
    /// - returns:            Returns percent-escaped string.
    
    private func percentEscapeString(string: String) -> String {
        let characterSet = NSCharacterSet.alphanumericCharacterSet().mutableCopy() as! NSMutableCharacterSet
        characterSet.addCharactersInString("-._* ")
        
        return string
            .stringByAddingPercentEncodingWithAllowedCharacters(characterSet)!
            .stringByReplacingOccurrencesOfString(" ", withString: "+", options: [], range: nil)
    }
    
    /// Encode the parameters for `application/x-www-form-urlencoded` request
    ///
    /// - parameter parameters:   A dictionary of string values to be encoded in POST request
    
    func encodeParameters(parameters: [String : String]) {
        HTTPMethod = "POST"
        
        let parameterArray = parameters.map { (key, value) -> String in
            return "\(key)=\(self.percentEscapeString(value))"
        }
        
        HTTPBody = parameterArray.joinWithSeparator("&").dataUsingEncoding(NSUTF8StringEncoding)
    }
}

func getRecipes(food_:[String], callback:([Recipe]) -> Void) {
    var food = food_
    if food.contains("tomato") && food.contains("onion") && food.contains("cucumber") {
        food.append("mayonnaise")
    }
    let config = NSURLSessionConfiguration.defaultSessionConfiguration()
    config.HTTPAdditionalHeaders = [
        "Accept" : "application/json",
        "Content-Type" : "application/x-www-form-urlencoded"
    ]
    
    let session = NSURLSession(configuration: config)
    
    let request = NSMutableURLRequest(URL: NSURL(string:"http://www.supercook.com/dyn/results")!)
    request.encodeParameters(["kitchen": food.joinWithSeparator(","), "needsimage" : "1"])
    
    let task = session.dataTaskWithRequest(request) { data, response, error in
        guard error == nil && data != nil else {
            print(error)
            return
        }
        let json = JSON(data: data!)
        var recipes = [Recipe]()
        for recipe in json["results"] {
            if let title = recipe.1["title"].string, url = recipe.1["url"].string, uses = recipe.1["uses"].string, needsArray = recipe.1["needs"].array {
                let idString = "\(recipe.1["id"].intValue)"
                if needsArray.count == 0 {
                    recipes.append(Recipe(id: idString, title: title, imgURL: "http://www.supercook.com/thumbs/\(idString).jpg", URL: url, uses: uses.componentsSeparatedByString(", ")))
                }
            }
        }
        callback(recipes)
    }
    task.resume()
    
}

extension String {
    
    var parseJSONString: AnyObject? {
        
        let data = self.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)
        
        if let jsonData = data {
            // Will return an object or nil if JSON decoding fails
            do {
                let a = try NSJSONSerialization.JSONObjectWithData(jsonData, options: NSJSONReadingOptions.MutableContainers)
                return a
            } catch {
                return nil
            }
        } else {
            // Lossless conversion of the string was not possible
            return nil
        }
    }
}

