//
//  BYWaterFlowLayout.swift
//
//  Created by 黄海龙 on 16/11/21.
//  Copyright © 2016年 qianwang. All rights reserved.
//

import UIKit
import Foundation

protocol BYWaterFlowLayoutDelegate {
    func heightForItemAtIndex(_ waterFlow:BYWaterFlowLayout , index:Int , itemWidth:CGFloat) -> CGFloat
    func columnCountInWaterflowLayout(_ waterflowLayout:BYWaterFlowLayout) -> CGFloat
    func columnMarginInWaterflowLayout(_ waterflowLayout:BYWaterFlowLayout) -> CGFloat
    func rowMarginInWaterflowLayout(_ waterflowLayout:BYWaterFlowLayout) -> CGFloat
    func edgeInsetsInWaterflowLayout(_ waterflowLayout:BYWaterFlowLayout) -> UIEdgeInsets
}

class BYWaterFlowLayout: UICollectionViewFlowLayout {
    
    var delegate:BYWaterFlowLayoutDelegate?
    
    let DefaultColumnCount:CGFloat = 3
    let DefaultColumnMargin:CGFloat = 5
    let DefaultRowMargin:CGFloat = 5
    let DefaultEdgeInsets:UIEdgeInsets = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)

    var attrsArray = [UICollectionViewLayoutAttributes]()
    var columnHeights = [CGFloat]()
    var contentHeight:CGFloat = 0
    
    func rowMargin() -> CGFloat {
        
        if ((self.delegate?.rowMarginInWaterflowLayout(self)) != nil) {
            return (self.delegate?.rowMarginInWaterflowLayout(self))!
        } else {
            return DefaultRowMargin
        }
    }
    
    func columnMargin() -> CGFloat {
        if ((self.delegate?.columnMarginInWaterflowLayout(self)) != nil) {
            return (self.delegate?.columnMarginInWaterflowLayout(self))!
        } else {
            return DefaultColumnMargin
        }
    }
    
    func columnCount() -> CGFloat {
        
        if ((self.delegate?.columnCountInWaterflowLayout(self)) != nil) {
            return (self.delegate?.columnCountInWaterflowLayout(self))!
        } else {
            return DefaultColumnCount
        }
    }
    
    func edgeInsets() -> UIEdgeInsets {
        if ((self.delegate?.edgeInsetsInWaterflowLayout(self)) != nil) {
            return (self.delegate?.edgeInsetsInWaterflowLayout(self))!
        } else {
            return DefaultEdgeInsets
        }
    }
    
    
    override func prepare() {
        super.prepare()
        
        self.contentHeight = 0
        self.columnHeights.removeAll()
        
        for _ in 0 ..< Int(self.columnCount()) {
            self.columnHeights.append(self.edgeInsets().top)
        }
        
        // 清除之前所有布局
        self.attrsArray.removeAll()
        let count = self.collectionView?.numberOfItems(inSection: 0)
        
        for i in 0..<count! {
            let indexPath = IndexPath(row: i, section: 0)
            let attrs = self.layoutAttributesForItem(at: indexPath)
            self.attrsArray.append(attrs!)
        }
    }
    
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        return attrsArray
    }
    
    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        
        let attrs = UICollectionViewLayoutAttributes(forCellWith: indexPath)
        
        let collectionViewW = self.collectionView?.frame.size.width
        let w = (collectionViewW! - self.edgeInsets().left - self.edgeInsets().right - (self.columnCount() - 1) * self.columnMargin()) / self.columnCount()
        let h = self.delegate?.heightForItemAtIndex(self, index: indexPath.item, itemWidth: w)
        
        var destColumn:CGFloat = 0
        
        var minColumnHeight = self.columnHeights[0]
        
        for columnHeight in self.columnHeights {
            if minColumnHeight > columnHeight {
                minColumnHeight = columnHeight
                destColumn += 1
            }
        }
        
        let x = self.edgeInsets().left + destColumn * (w + self.columnMargin())
        
        var y = minColumnHeight
        
        if y != self.edgeInsets().top {
            
            y += self.rowMargin()
        }
        
        attrs.frame = CGRect(x: x, y: y, width: w, height: h!)
        self.columnHeights[Int(destColumn)] = attrs.frame.maxY
        
        let columnHeight:CGFloat = self.columnHeights[Int(destColumn)]
        
        if self.contentHeight < columnHeight {
            self.contentHeight = columnHeight
        }
        
        return attrs
    }
    
    override var collectionViewContentSize: CGSize {
        return CGSize(width: 0, height: self.contentHeight + self.edgeInsets().bottom)
    }
    
    
}
