//
//  ViewController.swift
//  sample
//
//  Created by ヨト　ジャンフランソワ on 28/10/2017.
//  Copyright © 2017 tcmobile. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet var counterLabel: UILabel!
    
    @IBOutlet var stepper: UIStepper!
    
    var itemCount = 0
    fileprivate var items = [String]()
    fileprivate var dataIndices = [Int]()
    
    var colors = [UIColor.lightGray, UIColor.cyan, UIColor.red, UIColor.green, UIColor.orange]
    
    var page = 0
    
    fileprivate lazy var collectionView: UICollectionView = {
//        let layout = CenterCollectionViewFlowLayout()
        let layout = CarouselCollectionViewLayout()
//        let layout = InfiniteHorizontalLayout()
//        let layout = UICollectionViewFlowLayout()
        
        return UICollectionView(frame: .zero, collectionViewLayout: layout)
    }()

//    required init?(coder aDecoder: NSCoder) {
//        for i in 0...1 {
//            items.append(String(i))
//        }
//        super.init(coder: aDecoder)
////        fatalError("init(coder:) has not been implemented")
//    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViews()
        setupData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    private func setupViews() {
        var frame = view.bounds
        frame.origin.y = 50
        frame.size.height = 200
        
        if let layout = collectionView.collectionViewLayout as? InfiniteHorizontalLayout {
            layout.itemSize = CGSize(width: frame.width - 60, height: frame.height)
            layout.spacing = 10
            layout.effect = true
        } else if let layout = collectionView.collectionViewLayout as? CarouselCollectionViewLayout {
            layout.spacing = 10
            layout.scrollDirection = .horizontal
            layout.itemSize = CGSize(width: frame.width - 60, height: frame.height)
            layout.footerReferenceSize = .zero
            layout.headerReferenceSize = .zero
            layout.minimumInteritemSpacing = 10
            layout.minimumLineSpacing = 10
        } else if let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.scrollDirection = .horizontal
            layout.itemSize = CGSize(width: frame.width - 60, height: frame.height)
            layout.footerReferenceSize = .zero
            layout.headerReferenceSize = .zero
            layout.minimumInteritemSpacing = 10
            layout.minimumLineSpacing = 10
        }
        
        collectionView.frame = frame
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(MyCell.self, forCellWithReuseIdentifier: "MyCell")
        view.addSubview(collectionView)
    }
    
    private func setupData() {
        items = {
            var items = [String]()
            for i in 0 ..< itemCount {
                items.append(String(i))
            }
            return items
        }()

        dataIndices = buildItemIndices(numberOfItems: items.count)
        
        collectionView.reloadData()
        
        guard items.count > 0 else {
            return
        }
        
        let row = items.count == 1 ? 0 : 2
        page = row
        let indexPath = IndexPath(row: row, section: 0)
        collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: false)
    }
    
    private func buildItemIndices(numberOfItems: Int) -> [Int] {
        var items = [Int]()
        for item in 0 ..< numberOfItems {
            items.append(item)
        }
        
        guard numberOfItems > 1 else {
            return items
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
    
    @IBAction func didTapResetButton(_ sender: Any) {
        setupData()
    }
    
    @IBAction func didStepperValueChange(_ sender: UIStepper) {
        itemCount = Int(sender.value)
        self.counterLabel.text = "\(itemCount)"
    }
}

extension ViewController : UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataIndices.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MyCell", for: indexPath) as! MyCell
        
        let dataIndex = dataIndices[indexPath.row]
        
        cell.title = self.items[dataIndex]
        cell.backgroundColor = self.colors[dataIndex % self.colors.count]
        return cell
    }
    
}

extension ViewController : UICollectionViewDelegate {

    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        
        if velocity.x > 0 {
            page += 1
        } else if velocity.x < 0 {
            page -= 1
        }
        
        let indexPath = IndexPath(row: page, section: 0)
        collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
    }
    
    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        if page >= dataIndices.count - 2 {
            page = 2
            let indexPath = IndexPath(row: page, section: 0)
            collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: false)
        } else if page <= 1 {
            page = dataIndices.count - 2
            let indexPath = IndexPath(row: page, section: 0)
            collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: false)
        }
    }
    
}
