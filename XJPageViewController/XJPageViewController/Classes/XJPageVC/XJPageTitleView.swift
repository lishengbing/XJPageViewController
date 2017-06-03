//
//  XJPageTitleView.swift
//  XJPageViewController
//
//  Created by 李胜兵 on 2017/5/31.
//  Copyright © 2017年 善林(中国)金融信息服务有限公司. All rights reserved.
//

import UIKit

private let kCellID = "kCellID"
private let kNormalColor : (CGFloat , CGFloat , CGFloat) = (255,255,255)  // 白色
private let kSelectColor : (CGFloat , CGFloat , CGFloat) = (255,128,0)    // 橘色

private let kNormalFont: CGFloat = 20
private let kSelectFont: CGFloat = 15
private let kDistanceValue : CGFloat = kNormalFont - kSelectFont

private let kColumn: CGFloat = 4
private let kMargin: CGFloat = 1
private let kSizeW: CGFloat = (kScreenW - (kColumn + 1) * kMargin) / kColumn


// MARK: - 代理
protocol XJpageTitleViewDelegate: class  {
    func pageTitleView(_ pageTitleView: XJPageTitleView, selectedindex: Int)
}

class XJPageTitleView: UIView {

    weak var delegate: XJpageTitleViewDelegate?
    fileprivate lazy var arr : [XJPageModel] = [XJPageModel]()
    fileprivate var titles: [String]
    var bottomMargin: CGFloat = 3
    
    init(frame: CGRect, titles: [String]) {
        self.titles = titles
        super.init(frame: frame)
        setupUI()
        setupData()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    lazy var collectionView: UICollectionView  = { [weak self] in
        let collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: XJTitleLayout())
        collectionView.isPagingEnabled = true
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.backgroundColor = UIColor.white
        collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: kCellID)
        return collectionView
    }()
    
    
    fileprivate lazy var line: UIView = { [weak self] in
        let line = UIView()
        line.backgroundColor = UIColor.red
        return line
    }()
}

extension XJPageTitleView {
    fileprivate func setupUI() {
        collectionView.frame = bounds
        addSubview(collectionView)
        
        line.frame = CGRect(x: kMargin, y: frame.height - bottomMargin, width: kSizeW, height: bottomMargin)
        collectionView.addSubview(line)
    }
    
    fileprivate func setupData() {
        arr.removeAll()
        for (index ,value) in titles.enumerated() {
            let model = XJPageModel()
            model.title = value
            if index == 0 {
                model.isSelected = true
                model.labelColor = UIColor(r: kSelectColor.0, g: kSelectColor.1, b: kSelectColor.2)
                model.labelfont = UIFont.systemFont(ofSize: kNormalFont)
            }else {
                model.isSelected = false
                model.labelColor = UIColor.white
                model.labelfont = UIFont.systemFont(ofSize: kSelectFont)
            }
            arr.append(model)
        }
        
        collectionView.reloadData()
    }
}

extension XJPageTitleView : UICollectionViewDataSource, UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return arr.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: kCellID, for: indexPath)
        let model = arr[indexPath.item]
        
        // 防止复用、先移除再添加
        for view in cell.contentView.subviews {
            view.removeFromSuperview()
        }
        // 添加一个label、不能懒加载
        let label = UILabel()
        label.textAlignment = .center
        label.text = model.title
        if model.isSelected {
            label.textColor = model.labelColor
            label.font = model.labelfont
        }else {
            label.textColor = model.labelColor
            label.font = model.labelfont
            
        }
        label.frame = CGRect(x: 0, y: 0, width: kSizeW, height: frame.height - bottomMargin)
        cell.contentView.addSubview(label)
        label.backgroundColor = UIColor.gray
        cell.backgroundColor = UIColor.white
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        // 切换字体状态
        for (index, model) in arr.enumerated() {
            if index == indexPath.item {
                model.isSelected = true
                model.labelColor = UIColor(r: kSelectColor.0, g: kSelectColor.1, b: kSelectColor.2)
                model.labelfont = UIFont.systemFont(ofSize: kNormalFont)
            }else {
                model.isSelected = false
                model.labelColor = UIColor(r: kNormalColor.0, g: kNormalColor.1, b: kNormalColor.2)
                model.labelfont = UIFont.systemFont(ofSize: kSelectFont)
            }
        }
        
        // line
        let lineX = CGFloat(indexPath.item) * (kSizeW + kMargin) + kMargin
        UIView.animate(withDuration: 0.5) {
            self.line.frame.origin.x = lineX
        }
        
        // 刷新表格
        collectionView.reloadData()
        
        // 通知代理去做事
        delegate?.pageTitleView(self, selectedindex: indexPath.item)
    }
}

extension XJPageTitleView {
    func setTitleViewWithProgress(_ progress: CGFloat, sourceIndex: Int, targetIndex: Int) {
        
        // 滚动区域标题居中
        var offsetX = CGFloat(targetIndex + 1) * kSizeW + CGFloat(targetIndex) * kMargin + 2 * kMargin - kScreenW * 0.60
        if offsetX < 0 {
            offsetX = 0
        }
        
        let maxOffsetX = CGFloat(arr.count) * kSizeW + CGFloat(arr.count - 1) * kMargin + 2 * kMargin - kScreenW
        if offsetX > maxOffsetX {
            offsetX = maxOffsetX
        }
        collectionView.setContentOffset(CGPoint(x: offsetX, y: 0), animated: true)
        
        // line
        let moveLineX = (CGFloat(targetIndex) * (kSizeW + kMargin) + kMargin) - (CGFloat(sourceIndex) * kSizeW + kMargin)
        let moveX = moveLineX * progress
        self.line.frame.origin.x = CGFloat(sourceIndex) * (kSizeW) + moveX + kMargin
        
        
        // 颜色字体变化范围
        let colorDelta = (kSelectColor.0 - kNormalColor.0, kSelectColor.1 - kNormalColor.1,kSelectColor.2 - kNormalColor.2)
        let sourceModel = arr[sourceIndex]
        sourceModel.isSelected = false
        sourceModel.labelColor = UIColor(r: kSelectColor.0 - colorDelta.0 * progress, g: kSelectColor.1 - colorDelta.1 * progress, b: kSelectColor.2 - colorDelta.2 * progress)
        sourceModel.labelfont = UIFont.systemFont(ofSize: kNormalFont - kDistanceValue * progress)
        
        let targetModel = arr[targetIndex]
        targetModel.isSelected = true
        targetModel.labelColor = UIColor(r: kNormalColor.0 + colorDelta.0 * progress, g: kNormalColor.1 + colorDelta.1 * progress, b: kNormalColor.2 + colorDelta.2 * progress)
        targetModel.labelfont = UIFont.systemFont(ofSize: kSelectFont + kDistanceValue * progress)
    
        // 刷新表格
        collectionView.reloadData()
    }
}

class XJTitleLayout: UICollectionViewFlowLayout {
    override func prepare() {
        super.prepare()
        itemSize = CGSize(width: kSizeW, height: collectionView!.height)
        minimumLineSpacing = kMargin
        minimumInteritemSpacing = 0
        sectionInset = UIEdgeInsets(top: 0, left: kMargin, bottom: 0, right: kMargin)
        scrollDirection = .horizontal
    }
}


