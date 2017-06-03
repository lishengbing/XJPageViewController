//
//  XJModel.swift
//  XJPageViewController
//
//  Created by 李胜兵 on 2017/5/31.
//  Copyright © 2017年 善林(中国)金融信息服务有限公司. All rights reserved.
//

import UIKit

class XJPageModel: NSObject {

    
    var title: String = ""
    var isSelected: Bool = false
    var labelColor: UIColor = UIColor.white
    var labelfont: UIFont = UIFont.systemFont(ofSize: 10)
    
    // 重写init方法
    override init() {
        super.init()
    }
    
    // 自定义init方法
    init(dict: [String : Any]) {
        super.init()
        setValuesForKeys(dict)
    }
    
    override func setValue(_ value: Any?, forUndefinedKey key: String) { }
}
