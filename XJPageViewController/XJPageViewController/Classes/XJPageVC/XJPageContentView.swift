//
//  XJPageContentView.swift
//  XJPageViewController
//
//  Created by 李胜兵 on 2017/5/31.
//  Copyright © 2017年 善林(中国)金融信息服务有限公司. All rights reserved.
//

import UIKit
private let kCellID = "kCellID"
private let kNormalColor : (CGFloat , CGFloat , CGFloat) = (255,255,255)  // 白色
private let kSelectColor : (CGFloat , CGFloat , CGFloat) = (255,128,0)    // 橘色


protocol XJPageContentViewDelegate: class {
    func pageContentView(_ contentView: XJPageContentView, progress: CGFloat, sourceIndex: Int, targetIndex: Int)
}
class XJPageContentView: UIView {

    fileprivate var childVC: [UIViewController]
    fileprivate weak var parentVC: UIViewController?
    fileprivate var starOffsetX: CGFloat = 0
    weak var delegate : XJPageContentViewDelegate?
    fileprivate var isClick: Bool = false
    
    
    // MARK: 自定义view的时候提前保存属性和super.init(frame: frame)之后保存是有问题的，初始化的问题
    init(frame: CGRect, childVC: [UIViewController], parentVC: UIViewController) {
        self.childVC = childVC
        self.parentVC = parentVC
        super.init(frame: frame)
       setupUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    fileprivate lazy var collectionView: UICollectionView  = { [weak self] in
        let collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: XJLayout())
        collectionView.isPagingEnabled = true
        collectionView.bounces = false
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: kCellID)
        return collectionView
    }()
}

extension XJPageContentView {
    fileprivate func setupUI() {
        // 1.将所有子控制器加到父控制器中
        for childVc in childVC {
            parentVC?.addChildViewController(childVc)
        }
        
        // 2: 添加UICollectionView，用于在cell中存放控制器的view
        addSubview(collectionView)
        collectionView.frame = bounds
    }
}

extension XJPageContentView : UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return childVC.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: kCellID, for: indexPath)
        
        // 2.1cell有循环复用的问题，为了防止复用，我们每次添加之前先移除之前的view
        for view in cell.contentView.subviews {
            view.removeFromSuperview()
        }
        
        let childVc = childVC[(indexPath as NSIndexPath).item]
        childVc.view.frame = cell.contentView.bounds
        cell.contentView.addSubview(childVc.view)
        
        return cell
    }
}

extension XJPageContentView: UICollectionViewDelegate {
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        
        isClick = false
        starOffsetX = scrollView.contentOffset.x
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        // 0.如果是点击的话就不走这个方法
        if isClick { return }
        
        // 1.定义需要的数据
        var progress: CGFloat = 0
        var sourceIndex: Int = 0
        var targetIndex: Int = 0
        
        // 2.判断是左滑动还是右滑动
        let currentOffsetX = scrollView.contentOffset.x
        let scrollViewWidth = scrollView.bounds.width
        
        //  3.从左到👉 // 左滑动
        if currentOffsetX > starOffsetX {
            progress = currentOffsetX / scrollViewWidth - floor(currentOffsetX / scrollViewWidth)
            sourceIndex = Int(currentOffsetX / scrollViewWidth)
            targetIndex = sourceIndex + 1
            if targetIndex >= childVC.count {
                targetIndex = childVC.count - 1
            }
            
            // 解决快速滑动的时候最后一个不变色 && 快速滑动的时候颜色有时候和标记表不同步，显示两个高亮颜色
            if progress == 0 {
                progress = 1
                targetIndex = sourceIndex
            }
            
            // 如果完全滑动过去，progress应该为1
            if  currentOffsetX - starOffsetX == scrollViewWidth {
                progress = 1
                targetIndex = sourceIndex
            }
        }else { // 从右边向⬅️
            progress = 1 - (currentOffsetX / scrollViewWidth - floor(currentOffsetX / scrollViewWidth))
            targetIndex = Int(currentOffsetX / scrollViewWidth)
            sourceIndex = targetIndex + 1
            if sourceIndex >= childVC.count {
                sourceIndex = childVC.count - 1
            }
        }
        
        // 4.通知代理去做事情
        delegate?.pageContentView(self, progress: progress, sourceIndex: sourceIndex, targetIndex: targetIndex)
    }
}

extension XJPageContentView {
    func setCurrentIndex(_ currentIndex: Int) {
        isClick = true
        let offsetX = CGFloat(currentIndex) * collectionView.bounds.width
        collectionView.setContentOffset(CGPoint(x: offsetX, y: 0), animated: true)
    }
}

class XJLayout: UICollectionViewFlowLayout {
    override func prepare() {
        super.prepare()
        itemSize = (collectionView?.bounds.size)!
        minimumLineSpacing = 0
        minimumInteritemSpacing = 0
        scrollDirection = .horizontal
    }
}
