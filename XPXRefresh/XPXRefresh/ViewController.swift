//
//  ViewController.swift
//  XPXRefresh
//
//  Created by XPX on 2017/7/31.
//  Copyright © 2017年 XTeam. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    let tableView = UITableView()
    var dataArr = NSMutableArray()
    var refresh = XPXRefresh()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.white
        
        createTableView()
        createData()
        
        refresh = XPXRefresh(addRefresh: tableView, heardBlock: {
            // 刷新事件
            self.dataArr.removeAllObjects()
            self.createData()
        }) {
            // 加载事件
            self.createData()
        }
    }
    
    func createData() {
        
        // 延时提交任务
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            
            for index in 1...20 {
                self.dataArr.add(index)
            }
            self.tableView.reloadData()
            self.refresh.endRefresh()
        }
    }
}

extension ViewController {
    
    func createTableView() {
        
        // 去掉分割线
        tableView.frame = CGRect(x: 0, y: 0, width: Int(UIScreen.main.bounds.width), height: Int(UIScreen.main.bounds.height-64))
        tableView.backgroundColor = UIColor.white
        tableView.delegate = self
        tableView.dataSource = self
        self.view.addSubview(tableView)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataArr.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
         var cell = tableView.dequeueReusableCell(withIdentifier: "cellID")
         if cell == nil {
            cell = UITableViewCell(style: UITableViewCellStyle.default, reuseIdentifier: "cellID")
         }
        
         cell!.textLabel!.text = "\(indexPath.row)"
        
         return cell!
    }
}
