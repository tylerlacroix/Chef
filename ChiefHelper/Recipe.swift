//
//  Recipe.swift
//  ChiefHelper
//
//  Created by Tyler Lacroix on 8/20/16.
//  Copyright © 2016 Tyler Lacroix. All rights reserved.
//

import UIKit

class Recipe: NSObject {
    public var id: String
    public var title: String
    public var imgURL: String
    public var URL: String
    public var uses: [String]
    
    init(id: String, title: String, imgURL: String, URL: String, uses: [String]) {
        self.id = id
        self.title = title
        self.imgURL = imgURL
        self.URL = URL
        self.uses = uses
    }
}
