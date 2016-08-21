//
//  RecognizeImage.swift
//  ChiefHelper
//
//  Created by Tyler Lacroix on 8/20/16.
//  Copyright © 2016 Tyler Lacroix. All rights reserved.
//

import UIKit

func RecognizeImage(image: NSData, callback:(String?) -> Void) {
    
    let urlString = "http://10.71.134.168:8888/load.php"
    var request = NSMutableURLRequest()
    request.URL = NSURL(string: urlString)!
    request.HTTPMethod = "POST"
    var boundary = "---------------------------14737809831466499882746641449"
    var contentType = "multipart/form-data; boundary=\(boundary)"
    request.addValue(contentType, forHTTPHeaderField: "Content-Type")
    var body = NSMutableData()
    body.appendData("\r\n--\(boundary)\r\n".dataUsingEncoding(NSUTF8StringEncoding)!)
    body.appendData(String(format: "Content-Disposition: form-data; name=\"uploadedfile\"; filename=\"test.png\"\r\n").dataUsingEncoding(NSUTF8StringEncoding)!)
    body.appendData("Content-Type: application/octet-stream\r\n\r\n".dataUsingEncoding(NSUTF8StringEncoding)!)
    body.appendData(image)
    body.appendData("\r\n--\(boundary)--\r\n".dataUsingEncoding(NSUTF8StringEncoding)!)
    
    request.HTTPBody = body
    var returnData = try! NSURLConnection.sendSynchronousRequest(request, returningResponse: nil)
    var returnString = String(data: returnData, encoding: NSUTF8StringEncoding)
    //print("Image Return String: \(returnString)")
    
    var dic = convertStringToDictionary(returnString!)
    var keys = (dic?.sortedKeysByValue(>))!
    for i in 0...5 {
        if dic![keys.first!]! > 0.1 {
            if let val = knownFoodItems[keys[i]] {
                callback(val)
                return
            }
        }
    }
    print("\(keys.first!) - \(dic![keys.first!]!)")
    callback(nil)
}

func convertStringToDictionary(text: String) -> [String:Float]? {
    if let data = text.dataUsingEncoding(NSUTF8StringEncoding) {
        do {
            return try NSJSONSerialization.JSONObjectWithData(data, options: []) as? [String:Float]
        } catch let error as NSError {
            print(error)
        }
    }
    return nil
}

extension Dictionary {
    func sortedKeys(isOrderedBefore:(Key,Key) -> Bool) -> [Key] {
        return Array(self.keys).sort(isOrderedBefore)
    }
    
    // Slower because of a lot of lookups, but probably takes less memory (this is equivalent to Pascals answer in an generic extension)
    func sortedKeysByValue(isOrderedBefore:(Value, Value) -> Bool) -> [Key] {
        return sortedKeys {
            isOrderedBefore(self[$0]!, self[$1]!)
        }
    }
}
