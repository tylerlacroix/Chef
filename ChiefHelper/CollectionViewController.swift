//
//  CollectionViewController.swift
//  CircularCollectionView
//
//  Created by Rounak Jain on 10/05/15.
//  Copyright (c) 2015 Rounak Jain. All rights reserved.
//

import UIKit


let reuseIdentifier = "Cell"

class CollectionViewController: UICollectionViewController {
  
  //let images: [String] = NSBundle.mainBundle().pathsForResourcesOfType("png", inDirectory: "Images")
    var recipes = [Recipe]()
    var titleLabel: UILabel!
    var pageWidth: Float {
        return Float(self.collectionView!.contentSize.width/CGFloat(recipes.count+1))
    }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    // Register cell classes
    collectionView!.registerNib(UINib(nibName: "CircularCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: reuseIdentifier)
    //let imageView = UIImageView(image: UIImage(named: "bg-dark.jpg"))
    //imageView.contentMode = UIViewContentMode.ScaleAspectFill
    //collectionView!.backgroundView = imageView
    collectionView!.backgroundColor = UIColor.clearColor()
    collectionView!.backgroundView = UIView(frame: CGRect.zero)
    
    titleLabel = UILabel(frame: CGRectMake(0, 0, view.frame.width-40, 21))
    titleLabel.center = CGPointMake(view.frame.width/2, 384)
    titleLabel.textAlignment = NSTextAlignment.Center
    titleLabel.text = recipes[0].title
    titleLabel.textColor = UIColor.whiteColor()
    titleLabel.font = titleLabel.font.fontWithSize(18)
  }
    
    override func viewWillAppear(animated: Bool) {
<<<<<<< Updated upstream
=======
        titleLabel = UILabel(frame: CGRectMake(0, 0, view.frame.width-40, 80))
        titleLabel.center = CGPointMake(view.frame.width/2, 384)
        titleLabel.textAlignment = NSTextAlignment.Center
        titleLabel.text = recipes[0].title
        titleLabel.textColor = UIColor.blackColor()
        titleLabel.font = UIFont(name: "AvenirNext-Regular", size: 25.0)
        
>>>>>>> Stashed changes
        self.view.addSubview(titleLabel)
        self.view.bringSubviewToFront(titleLabel)
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
        titleLabel.text = recipes[Int(scrollView.contentOffset.x)/Int(pageWidth)].title
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
