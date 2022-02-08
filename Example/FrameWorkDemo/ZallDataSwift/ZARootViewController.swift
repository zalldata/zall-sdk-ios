//
//  ZARootViewController.swift
//  ZallDataSwift
//
//  Created by Mac on 2022/1/26.
//  Copyright © 2022 Zall Data Co., Ltd. All rights reserved.
//

import UIKit


func rootViewController() -> UIViewController {
    return UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "rootViewController")
}

class ZARootViewController: UIViewController {
    var dataList = ZASDKAction.sdkActionWithDataList(nil)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        self.title = "Track"
    }
}

extension ZARootViewController:UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        dataList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellid", for: indexPath)
        cell.textLabel?.text = dataList.cellForWithRow(indexPath.row)
        return cell;
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        dataList.cellForSelectWithRow(indexPath.row) { [weak self] action in
            let vc:ZARootViewController = rootViewController() as! ZARootViewController
            vc.dataList = action
            vc.title = self?.dataList.cellForWithRow(indexPath.row)
            self?.navigationController?.show(vc, sender: nil)
            
        }
    }
    
   
    
}
