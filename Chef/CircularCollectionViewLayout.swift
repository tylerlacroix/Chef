//
//  CircularCollectionViewLayout.swift
//  CircularCollectionView
//
//  Created by Rounak Jain on 27/05/15.
//  Copyright (c) 2015 Rounak Jain. All rights reserved.
//

import UIKit

class CircularCollectionViewLayoutAttributes: UICollectionViewLayoutAttributes {
  
  var anchorPoint = CGPoint(x: 0.5, y: 0.5)
  
  var angle: CGFloat = 0 {
    didSet {
      zIndex = Int(angle*1000000)
      transform = CGAffineTransformMakeRotation(angle)
    }
  }
  
  override func copyWithZone(zone: NSZone) -> AnyObject {
    let copiedAttributes: CircularCollectionViewLayoutAttributes = super.copyWithZone(zone) as! CircularCollectionViewLayoutAttributes
    copiedAttributes.anchorPoint = self.anchorPoint
    copiedAttributes.angle = self.angle
    return copiedAttributes
  }
  
}

class CircularCollectionViewLayout: UICollectionViewLayout {
  
  let itemSize = CGSize(width: 260, height: 180)
  
  var angleAtExtreme: CGFloat {
    return collectionView!.numberOfItemsInSection(0) > 0 ? -CGFloat(collectionView!.numberOfItemsInSection(0)-1)*anglePerItem : 0
  }
  
  var angle: CGFloat {
    return angleAtExtreme*collectionView!.contentOffset.x/(collectionViewContentSize().width - CGRectGetWidth(collectionView!.bounds))
  }
  
  var radius: CGFloat = 1500 {
    didSet {
      invalidateLayout()
    }
  }
  
  var anglePerItem: CGFloat {
    return atan(itemSize.width/radius)
  }
  
  var attributesList = [CircularCollectionViewLayoutAttributes]()
  
  override func collectionViewContentSize() -> CGSize {
    return CGSize(width: CGFloat(collectionView!.numberOfItemsInSection(0))*itemSize.width,
      height: CGRectGetHeight(collectionView!.bounds))
  }
  
  override class func layoutAttributesClass() -> AnyClass {
    return CircularCollectionViewLayoutAttributes.self
  }
  
  override func prepareLayout() {
    super.prepareLayout()
    let centerX = collectionView!.contentOffset.x + (CGRectGetWidth(collectionView!.bounds)/2.0)
    let anchorPointY = ((itemSize.height/2.0) + radius)/itemSize.height
    //1
    let theta = atan2(CGRectGetWidth(collectionView!.bounds)/2.0, radius + (itemSize.height/2.0) - (CGRectGetHeight(collectionView!.bounds)/2.0)) //1
    //2
    var startIndex = 0
    var endIndex = collectionView!.numberOfItemsInSection(0) - 1
    //3
    if (angle < -theta) {
      startIndex = Int(floor((-theta - angle)/anglePerItem))
    }
    //4
    endIndex = min(endIndex, Int(ceil((theta - angle)/anglePerItem)))
    //5
    if (endIndex < startIndex) {
      endIndex = 0
      startIndex = 0
    }
    attributesList = (startIndex...endIndex).map { (i) -> CircularCollectionViewLayoutAttributes in
      let attributes = CircularCollectionViewLayoutAttributes(forCellWithIndexPath: NSIndexPath(forItem: i, inSection: 0))
      attributes.size = self.itemSize
      attributes.center = CGPoint(x: centerX, y: CGRectGetMidY(self.collectionView!.bounds))
      attributes.angle = self.angle + (self.anglePerItem*CGFloat(i))
      attributes.anchorPoint = CGPoint(x: 0.5, y: anchorPointY)
      return attributes
    }
  }
  
  override func layoutAttributesForElementsInRect(rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
    return attributesList
  }
  
  override func layoutAttributesForItemAtIndexPath(indexPath: NSIndexPath)
    -> UICollectionViewLayoutAttributes! {
        
      return attributesList[indexPath.row]
  }
  
  override func shouldInvalidateLayoutForBoundsChange(newBounds: CGRect) -> Bool {
    return true
  }
  
//Uncomment the section below to activate snapping behavior
/*
  override func targetContentOffsetForProposedContentOffset(proposedContentOffset: CGPoint, withScrollingVelocity velocity: CGPoint) -> CGPoint {
    var finalContentOffset = proposedContentOffset
    let factor = -angleAtExtreme/(collectionViewContentSize().width - CGRectGetWidth(collectionView!.bounds))
    let proposedAngle = proposedContentOffset.x*factor
    let ratio = proposedAngle/anglePerItem
    var multiplier: CGFloat
    if (velocity.x > 0) {
      multiplier = ceil(ratio)
    } else if (velocity.x < 0) {
      multiplier = floor(ratio)
    } else {
      multiplier = round(ratio)
    }
    finalContentOffset.x = multiplier*anglePerItem/factor
    return finalContentOffset
  }
*/
}
