//
//  CenterCollectionViewFlowLayout.swift
//  sample
//
//  Created by ヨト　ジャンフランソワ on 28/10/2017.
//  Copyright © 2017 tcmobile. All rights reserved.
//

import Foundation
import UIKit

class CenterCollectionViewFlowLayout : UICollectionViewFlowLayout {
    
    var mostRecentOffset: CGPoint = CGPoint()
    
    override func targetContentOffset(forProposedContentOffset proposedContentOffset: CGPoint, withScrollingVelocity velocity: CGPoint) -> CGPoint {
        if velocity.x == 0 {
            return mostRecentOffset
        }
        
        if let cv = self.collectionView {
            let cvBounds = cv.bounds
            let halfWidth = cvBounds.size.width * 0.5
            
            if let attributesForVisibleCells = self.layoutAttributesForElements(in: cvBounds) {
                var canditateAttributes: UICollectionViewLayoutAttributes?
                for attributes in attributesForVisibleCells {
                    // Skip comparison with non-cell items (headers and footers)
                    if attributes.representedElementCategory != .cell {
                        continue
                    }
                    
                    if attributes.center.x == 0 || (attributes.center.x > (cv.contentOffset.x + halfWidth) && velocity.x < 0) {
                        continue
                    }
                    canditateAttributes = attributes
                }
                
                if proposedContentOffset.x == -cv.contentInset.left {
                    return proposedContentOffset
                }
                
                guard let _ = canditateAttributes else {
                    return mostRecentOffset
                }
                
                mostRecentOffset = CGPoint(x: floor(canditateAttributes!.center.x - halfWidth), y: proposedContentOffset.y)
                return mostRecentOffset
            }
        }
        
        // fallback
        mostRecentOffset = super.targetContentOffset(forProposedContentOffset: proposedContentOffset)
        return mostRecentOffset
    }
}
