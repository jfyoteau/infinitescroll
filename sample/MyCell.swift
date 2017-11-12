//
//  MyCell.swift
//  sample
//
//  Created by ヨト　ジャンフランソワ on 28/10/2017.
//  Copyright © 2017 tcmobile. All rights reserved.
//

import Foundation
import UIKit

class MyCell : UICollectionViewCell {
    
    private var labelView = UILabel()
    
    var title: String = "" {
        didSet {
            labelView.text = title
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        labelView.frame = self.bounds
        labelView.textColor = .black
        labelView.text = title
        labelView.textAlignment = .center
        addSubview(labelView)
        backgroundColor = .red
    }
    
}
