//
//  RecognizeImage.swift
//  ChiefHelper
//
//  Created by Tyler Lacroix on 8/20/16.
//  Copyright © 2016 Tyler Lacroix. All rights reserved.
//

import UIKit
import Alamofire

func RecognizeImage(image: NSData) {
    
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
    var keys = dic?.sortedKeysByValue(>)
    print("\(keys!.first!) - \(dic![keys!.first!]!)")

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
    
    // Faster because of no lookups, may take more memory because of duplicating contents
    func keysSortedByValue(isOrderedBefore:(Value, Value) -> Bool) -> [Key] {
        return Array(self)
            .sort() {
                let (_, lv) = $0
                let (_, rv) = $1
                return isOrderedBefore(lv, rv)
            }
            .map {
                let (k, _) = $0
                return k
        }
    }
}
