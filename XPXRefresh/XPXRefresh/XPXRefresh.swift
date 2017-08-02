//
//  XPXRefresh.swift
//  XPXRefresh
//
//  Created by XPX on 2017/7/31.
//  Copyright © 2017年 XTeam. All rights reserved.
//

import UIKit

class XPXRefresh: UIView {

    let RefreshDropHeight : Float = 40.0
    var RefreshTableView = UITableView()
    let arrowImageView = UIImageView()
    var tipLb = UILabel()
    let refreshLoadingView = UIActivityIndicatorView()
    var isHeard : Bool = false
    var isRefreshing : Bool = false
    var isFootFreshing : Bool = false
    typealias refreshBlock = ()->()
    var heardRefresh : refreshBlock = {
        
    }
    var footRefresh : refreshBlock = {
        
    }
    let ScreenW = UIScreen.main.bounds.width
    
    
    // UI
    func setupSelfView() {
        
        tipLb.frame = CGRect(x: ScreenW/2, y: 10, width: 100, height: 15)
        tipLb.textAlignment = .left
        tipLb.textColor = UIColor.gray
        tipLb.font = UIFont.systemFont(ofSize: 10)
        addSubview(tipLb)
        
        arrowImageView.frame = CGRect(x: Double(ScreenW/2-25), y: 0, width: 15, height: 40)
        arrowImageView.image = UIImage(named: "RefreshArrow");
        addSubview(arrowImageView);
        
        let point = CGPoint(x: self.arrowImageView.frame.size.width/2 + self.arrowImageView.frame.origin.x, y: self.arrowImageView.frame.size.height/2 + self.arrowImageView.frame.origin.y)
        let size = CGSize(width: CGFloat(RefreshDropHeight), height: CGFloat(RefreshDropHeight))
        
        refreshLoadingView.frame = CGRect(x: point.x - size.width/2, y: point.y - size.height/2, width: size.width, height: size.height)
        refreshLoadingView.activityIndicatorViewStyle = .gray;
        addSubview(refreshLoadingView);
    }
    
    // 便利构造函数添加XPXRefresh
    convenience init(addRefresh tableView : UITableView, heardBlock : @escaping refreshBlock, footBlok : @escaping refreshBlock) {
        self.init()
        setupSelfView()
        
        tableView.addSubview(self)
        RefreshTableView = tableView
        heardRefresh = heardBlock;
        footRefresh = footBlok;
        
        // 添加contentOffset观察者
        tableView.addObserver(self, forKeyPath: "contentOffset", options: .new, context: nil)
    }
    
    // 监听方法
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        
        // 取到偏移量
        guard let offSetPoint : CGPoint = change?[.newKey] as? CGPoint else { return }
        print(offSetPoint)
        
        // 显示头视图
        changeFrameWithoffY(offY: Float(offSetPoint.y))
        arrowImageView.alpha = 1.0;
        
        if (offSetPoint.y <= CGFloat(-RefreshDropHeight) && (!self.isRefreshing) && !self.isFootFreshing) {
            
            isRefreshing = true;
            
            UIView.animate(withDuration: 0.25, animations: {
                // 旋转180
                self.arrowImageView.transform = CGAffineTransform(rotationAngle: CGFloat(Double.pi));
            }, completion: { (Bool) in
                // 隐藏
                self.arrowImageView.isHidden = true;
                // 恢复位置
                self.arrowImageView.transform = CGAffineTransform(rotationAngle: CGFloat(Double.pi * 2));
                // 菊花开始
                self.refreshLoadingView.startAnimating();
            })
            
            self.RefreshTableView.contentInset = UIEdgeInsetsMake(CGFloat(RefreshDropHeight), 0, 0, 0);
            
            // 执行闭包
            heardRefresh();
        }
        
        // 还原
        if (offSetPoint.y == 0.0) {
                self.refreshLoadingView.stopAnimating();
                self.isRefreshing = false;
        }
        
        // 显示尾视图
        if (offSetPoint.y + RefreshTableView.frame.size.height  >= RefreshTableView.contentSize.height + CGFloat(RefreshDropHeight) && !self.isFootFreshing && self.RefreshTableView.contentSize.height > self.RefreshTableView.frame.size.height && !self.isRefreshing) {
            self.arrowImageView.isHidden = false;
            self.isFootFreshing = true;
            
            UIView.animate(withDuration: 0.25, animations: { 
                self.arrowImageView.transform = CGAffineTransform(rotationAngle: CGFloat(Double.pi));
            }, completion: { (Bool) in
                
                self.arrowImageView.isHidden = true;
                self.arrowImageView.transform = CGAffineTransform(rotationAngle: CGFloat(Double.pi));
                self.refreshLoadingView.startAnimating();
            })
            
            self.RefreshTableView.contentInset = UIEdgeInsetsMake(0, 0, CGFloat(RefreshDropHeight), 0);
            
            self.footRefresh();
        }
    }
    
    func changeFrameWithoffY(offY : Float) {
        
        if (offY <= 0 && !self.isHeard && !self.isFootFreshing) {
            tipLb.text = "下拉刷新";
            self.arrowImageView.transform = CGAffineTransform(rotationAngle: CGFloat(Double.pi * 2));
            self.isHeard = true;
            var frame = self.RefreshTableView.frame
            frame.origin.x = 0;
            frame.origin.y = -(CGFloat(RefreshDropHeight));
            frame.size.height = CGFloat(RefreshDropHeight);
            self.frame = frame;
        } else if (offY > 0 && self.isHeard && !self.isRefreshing) {
            self.isHeard = false;
            self.tipLb.text = "上拉加载更多";
            self.frame = CGRect(x: 0, y: self.RefreshTableView.contentSize.height, width: self.frame.size.width, height: CGFloat(RefreshDropHeight))
            self.arrowImageView.transform = CGAffineTransform(rotationAngle: CGFloat(Double.pi));
        }
    }
    
    
    // 开始刷新
    func beginHeardRefresh() {
        
        UIView.animate(withDuration: 0.25, animations: {
            self.RefreshTableView.contentOffset = CGPoint(x: 0.0, y: Double(-self.RefreshDropHeight))
        }, completion: { (Bool) in
        })
    }
    
    // 结束刷新
    func endRefresh() {
        
        self.refreshLoadingView.stopAnimating();
        UIView.animate(withDuration: 0.25, animations: {
            if (self.isFootFreshing) {
                self.frame = CGRect(x: 0, y: self.RefreshTableView.contentSize.height, width: self.frame.size.width, height: CGFloat(self.RefreshDropHeight))
            }
            self.RefreshTableView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);
            self.isFootFreshing = false;
            self.isRefreshing   = false;
        }, completion: { (Bool) in
            self.arrowImageView.isHidden = false;
        })
    }
}
