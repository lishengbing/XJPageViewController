//
//  XJMainVC.swift
//  XJPageViewController
//
//  Created by 李胜兵 on 2017/5/31.
//  Copyright © 2017年 善林(中国)金融信息服务有限公司. All rights reserved.
//

import UIKit
private let kPageTitleH: CGFloat = 45
private let kTopMargin: CGFloat = 5

class XJPageMainVC: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        automaticallyAdjustsScrollViewInsets = false
        setupUI()
    }
    
    fileprivate var titles = ["李荣浩","周杰伦","那英","鹿晗","金志文","毛泽少","周传雄","黄子韬","赵丽颖","关晓彤","张子涵","张芸京","费玉清","邓紫棋","叶倩文","吉克俊逸","崔子建","王铮亮","谭维维","韩磊","小包总","安迪","曲筱绡","关关","张信哲","范玮琪","林宥嘉","杨宗纬","李宇春","伍思凯","汪苏泷","郁可唯","薛之谦","李克勤","古巨基"]
    
    fileprivate lazy var pageTitleView : XJPageTitleView = { [unowned self] in
        let titleFrame = CGRect(x: 0, y: kNavBarH + kTopMargin, width: kScreenW, height: kPageTitleH)
        let pageTitleView = XJPageTitleView(frame: titleFrame, titles: self.titles)
        pageTitleView.delegate = self
        return pageTitleView
    }()
    
    fileprivate lazy var pageContentView : XJPageContentView = { [unowned self] in
        
        // 子控制器
        var childVC = [UIViewController]()
        for _ in 0..<self.titles.count {
            childVC.append(FirstVC())
        }
        
        // 自定义view的时候必须传Frame
        let contentH = kScreenH - kNavBarH - kPageTitleH - kTabBarH - kTopMargin * 2
        let contentFrame = CGRect(x: 0, y: kNavBarH + kPageTitleH + kTopMargin, width: kScreenW, height: contentH)
        let pageContentView = XJPageContentView(frame: contentFrame, childVC: childVC, parentVC: self)
        pageContentView.delegate = self
        return pageContentView
        
    }()
}


extension XJPageMainVC {
    fileprivate func setupUI() {
        view.backgroundColor = UIColor.white
        view.addSubview(pageTitleView)
        view.addSubview(pageContentView)
    }
}


extension XJPageMainVC: XJpageTitleViewDelegate {
    func pageTitleView(_ pageTitleView: XJPageTitleView, selectedindex: Int) {
        pageContentView.setCurrentIndex(selectedindex)
    }
}

extension XJPageMainVC: XJPageContentViewDelegate {
    func pageContentView(_ contentView: XJPageContentView, progress: CGFloat, sourceIndex: Int, targetIndex: Int) {
        pageTitleView.setTitleViewWithProgress(progress, sourceIndex: sourceIndex, targetIndex: targetIndex)
    }
}
