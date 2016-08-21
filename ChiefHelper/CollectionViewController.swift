//
//  CollectionViewController.swift
//  CircularCollectionView
//
//  Created by Rounak Jain on 10/05/15.
//  Copyright (c) 2015 Rounak Jain. All rights reserved.
//

import UIKit
import SafariServices


let reuseIdentifier = "Cell"

class CollectionViewController: UICollectionViewController, UIGestureRecognizerDelegate, SFSafariViewControllerDelegate {
    
    public weak var parent: CameraViewController!
  
  //let images: [String] = NSBundle.mainBundle().pathsForResourcesOfType("png", inDirectory: "Images")
    var recipes = [Recipe]()
    var titleLabel: UILabel!
    var pageWidth: Float {
        return Float((self.collectionView!.contentSize.width-375)/CGFloat(recipes.count-1))
    }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    collectionView!.registerNib(UINib(nibName: "CircularCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: reuseIdentifier)
    collectionView!.backgroundColor = UIColor.clearColor()
    collectionView!.backgroundView = UIView(frame: CGRect.zero)
    collectionView!.showsVerticalScrollIndicator = false
    collectionView!.showsHorizontalScrollIndicator = false
    
    titleLabel = UILabel(frame: CGRectMake(0, 0, view.frame.width-40, 150))
    titleLabel.center = CGPointMake(view.frame.width/2, 474)
    titleLabel.textAlignment = NSTextAlignment.Center
    titleLabel.textColor = UIColor.blackColor()
    titleLabel.font = UIFont(name: "AvenirNext-Regular", size: 25.0)
    titleLabel.lineBreakMode = .ByWordWrapping
    titleLabel.numberOfLines = 0
    
    let recognizer = UITapGestureRecognizer(target: self, action:Selector("handleTap:"))
    recognizer.delegate = self
    view.addGestureRecognizer(recognizer)
  }
    
    func handleTap(recognizer: UITapGestureRecognizer) {
        if let url = NSURL(string: recipes[Int(collectionView!.contentOffset.x)/Int(pageWidth)].URL) {
            let vc = SFSafariViewController(URL: url, entersReaderIfAvailable: true)
            vc.delegate = self
            
            presentViewController(vc, animated: true, completion: nil)
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        titleLabel.text = recipes[0].title
        parent.recipeUses(recipes[0].uses)
        collectionView?.reloadData()
        self.view.addSubview(titleLabel)
        self.view.bringSubviewToFront(titleLabel)
        collectionView?.contentOffset.x = 0
    }
  
    override func collectionView(collectionView: UICollectionView,
                                 numberOfItemsInSection section: Int) -> Int {
        return recipes.count
    }
    
    override func collectionView(collectionView: UICollectionView,
                                 cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as! CircularCollectionViewCell
        cell.imageView?.kf_setImageWithURL(NSURL(string:recipes[indexPath.row].imgURL))
        return cell
    }
    
    override func scrollViewDidEndScrollingAnimation(scrollView: UIScrollView) {
        print("\(scrollView.contentOffset.x/CGFloat(pageWidth)) to \(Int(scrollView.contentOffset.x)/Int(pageWidth))")
        let i = Int(scrollView.contentOffset.x)/Int(pageWidth)
        titleLabel.text = recipes[i].title
        parent.recipeUses(recipes[i].uses)
    }
    
    func safariViewControllerDidFinish(controller: SFSafariViewController) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    override func scrollViewWillEndDragging(scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        
        // width + space
        var currentOffset = Float(scrollView.contentOffset.x)
        var targetOffset = Float(targetContentOffset.memory.x)
        var newTargetOffset = Float(0)
        if targetOffset > currentOffset {
            newTargetOffset = ceilf(currentOffset / pageWidth) * pageWidth
        }
        else {
            newTargetOffset = floorf(currentOffset / pageWidth) * pageWidth
        }
        if newTargetOffset < 0 {
            newTargetOffset = 0
        }
        else if newTargetOffset > Float(scrollView.contentSize.width) {
            newTargetOffset = Float(scrollView.contentSize.width)
        }
        
        targetContentOffset.memory.x = CGFloat(currentOffset)
        scrollView.setContentOffset(CGPointMake(CGFloat(newTargetOffset), scrollView.contentOffset.y), animated: true)
        
        
    }
    
}
