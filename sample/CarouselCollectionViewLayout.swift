//
//  CarouselCollectionViewLayout.swift
//  sample
//
//  Created by ヨト　ジャンフランソワ on 28/10/2017.
//  Copyright © 2017 tcmobile. All rights reserved.
//

import Foundation
import UIKit

class CarouselCollectionViewLayout : UICollectionViewFlowLayout {

    var spacing: CGFloat = 40
    var sideItemScale: CGFloat = 0.6
    var sideItemAlpha: CGFloat = 0.6
    
    private var size: CGSize = .zero
    
    override func prepare() {
        super.prepare()
        
        let currentSize = self.collectionView!.bounds.size
        
        if currentSize != size {
            setupCollectionView()
            updateLayout()
            size = currentSize
        }
    }
    
    private func setupCollectionView() {
        guard let collectionView = self.collectionView else {
            return
        }
        if collectionView.decelerationRate != UIScrollViewDecelerationRateFast {
            collectionView.decelerationRate = UIScrollViewDecelerationRateFast
        }
    }
    
    private func updateLayout() {
        guard let collectionView = self.collectionView else {
            return
        }
        let collectionSize = collectionView.bounds.size
        let yInset = (collectionSize.height - self.itemSize.height) / 2
        let xInset = (collectionSize.width - self.itemSize.width) / 2
        self.sectionInset = UIEdgeInsetsMake(yInset, xInset, yInset, xInset)
        
        let side = self.itemSize.width
        let scaledItemOffset =  (side - side*self.sideItemScale) / 2
        self.minimumLineSpacing = spacing - scaledItemOffset
    }
    
    override open func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return true
    }
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        // Get attributes for all visible elements
        guard let superAttributes = super.layoutAttributesForElements(in: rect), let attributes = NSArray(array: superAttributes, copyItems: true) as? [UICollectionViewLayoutAttributes] else {
                return nil
        }

        return attributes.map({ self.transformLayoutAttributes($0) })
    }
    
    /// Resize the item attribute following its position.
    private func transformLayoutAttributes(_ attributes: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutAttributes {
        guard let collectionView = self.collectionView else {
            return attributes
        }
        
        let collectionCenter = collectionView.frame.size.width / 2
        let offset = collectionView.contentOffset.x
        let normalizedCenter = attributes.center.x - offset
        
        let maxDistance = self.itemSize.width + self.minimumLineSpacing
        let distance = min(abs(collectionCenter - normalizedCenter), maxDistance)
        let ratio = (maxDistance - distance) / maxDistance
        
        let alpha = ratio * (1 - self.sideItemAlpha) + self.sideItemAlpha
        let scale = ratio * (1 - self.sideItemScale) + self.sideItemScale
        attributes.alpha = alpha
        attributes.transform3D = CATransform3DScale(CATransform3DIdentity, scale, scale, 1)
        attributes.zIndex = Int(alpha * 10)
        
        return attributes
    }
    
    /// Returns the point at which to stop scrolling.
    /// Simulate a paging effect
    override func targetContentOffset(forProposedContentOffset proposedContentOffset: CGPoint, withScrollingVelocity velocity: CGPoint) -> CGPoint {
        guard let collectionView = collectionView , !collectionView.isPagingEnabled, let layoutAttributes = self.layoutAttributesForElements(in: collectionView.bounds) else {
            return super.targetContentOffset(forProposedContentOffset: proposedContentOffset)
        }
        
        let midSide = collectionView.bounds.size.width / 2
        let proposedContentOffsetCenterOrigin = proposedContentOffset.x + midSide
        
        var targetContentOffset: CGPoint
        let closest = layoutAttributes.sorted { abs($0.center.x - proposedContentOffsetCenterOrigin) < abs($1.center.x - proposedContentOffsetCenterOrigin) }.first ?? UICollectionViewLayoutAttributes()
        targetContentOffset = CGPoint(x: floor(closest.center.x - midSide), y: proposedContentOffset.y)
        
        return targetContentOffset
    }
    
}
