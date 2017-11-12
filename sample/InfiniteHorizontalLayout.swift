//
//  InfiniteHorizontalLayout.swift
//  sample
//
//  Created by ヨト　ジャンフランソワ on 29/10/2017.
//  Copyright © 2017 tcmobile. All rights reserved.
//

import Foundation
import UIKit

class InfiniteHorizontalLayout : UICollectionViewLayout {
    
    var effect = false
    var itemSize : CGSize = .zero
    var spacing: CGFloat = 40
    var sideItemScale: CGFloat = 0.6
    var sideItemAlpha: CGFloat = 0.6
    
    private var size: CGSize = .zero
    
    private var cache = [UICollectionViewLayoutAttributes]()
    
    private var minimumLineSpacing: CGFloat = 0
    private var sectionInset: UIEdgeInsets = .zero

    private var contentWidth: CGFloat  = 0.0
    
    private var contentHeight: CGFloat {
        guard let collectionView = self.collectionView else {
            return 0
        }
        let insets = collectionView.contentInset
        return collectionView.bounds.height - (insets.top + insets.bottom)
    }
    
    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return true
    }

    override func prepare() {
        // Reset
        cache = [UICollectionViewLayoutAttributes]()
        contentWidth = 0
        
        guard let collectionView = self.collectionView else {
            return
        }
        
//        guard collectionView.numberOfSections == 1 else {
//            return
//        }

        let currentSize = self.collectionView!.bounds.size
        if currentSize != size {
            setupCollectionView()
            updateLayout()
            size = currentSize
        }

        var x: CGFloat = self.sectionInset.left
        let section = 0
        let numberOfItems = collectionView.numberOfItems(inSection: 0)
//        let items = buildItems(numberOfItems: numberOfItems)
//        for item in items {
        for item in 0 ..< numberOfItems {
            print("[DEBUG]", "item:", item)
            let indexPath = IndexPath(item: item, section: section)
            
            // Compute frame
            let frame = CGRect(x: x, y: 0, width: itemSize.width, height: itemSize.height)
            
            // Create attributes
            let attributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
            attributes.frame = frame
            
            // Add attributes into cache
            cache.append(attributes)
            
            x += itemSize.width + minimumLineSpacing
            contentWidth = max(contentWidth, frame.maxX)
        }
        
        contentWidth += self.sectionInset.right
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
        guard self.effect else {
            return
        }
        guard let collectionView = self.collectionView else {
            return
        }
        
        let collectionSize = collectionView.bounds.size
        let yInset = (collectionSize.height - self.itemSize.height) / 2
        let xInset = (collectionSize.width - self.itemSize.width) / 2
        self.sectionInset = UIEdgeInsetsMake(yInset, xInset, yInset, xInset)
        
        let side = self.itemSize.width
        let scaledItemOffset =  (side - side * self.sideItemScale) / 2
        self.minimumLineSpacing = spacing - scaledItemOffset
    }
    
    private func buildItems(numberOfItems: Int) -> [Int] {
        var items = [Int]()
        for item in 0 ..< numberOfItems {
            items.append(item)
        }
        
        var item = 0
        for _ in 0 ..< 2 {
            items.append(item)
            item = (item + 1) % numberOfItems
        }
        item = numberOfItems - 1
        for _ in 0 ..< 2 {
            items.insert(item, at: 0)
            item = (item - 1) % numberOfItems
        }

        return items
    }
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        var visibleLayoutAttributes = [UICollectionViewLayoutAttributes]()
        print("[DEBUG]", "--------------------")
        for attributes in cache {
            if attributes.frame.intersects(rect) {
                let attr = effect ? self.transformLayoutAttributes(attributes) : attributes
                visibleLayoutAttributes.append(attr)
                print("[DEBUG]", "visible attr index:", attr.indexPath.row, "section:", attr.indexPath.section)
            }
        }
        return visibleLayoutAttributes
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
    
    override var collectionViewContentSize: CGSize {
        return CGSize(width: contentWidth, height: contentHeight)
    }
    
    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        print("[DEBUG]", "layoutAttributesForItem:", indexPath.row, indexPath.section)
        return cache.first { attributes -> Bool in
            return attributes.indexPath == indexPath
        }
    }
    
}
