//
//  ViewController.swift
//  ChiefHelper
//
//  Created by Tyler Lacroix on 8/20/16.
//  Copyright © 2016 Tyler Lacroix. All rights reserved.
//

import UIKit

class CameraViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func Next(sender: AnyObject) {
        
        getRecipes(["chicken breast", "bell pepper"], callback: { recipes in
            var layout = CircularCollectionViewLayout()
            layout.invalidateLayout()
            var cir = CollectionViewController(collectionViewLayout: layout)
            cir.recipes = recipes
            self.presentViewController(cir, animated: true, completion: {})
        })
    }

}

