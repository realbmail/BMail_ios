//
//  TimeOutSettingsTVC.swift
//  BMail
//
//  Created by hyperorchid on 2020/5/27.
//  Copyright © 2020 NBS. All rights reserved.
//

import UIKit

class SysDataSettingsTVC: UITableViewController {
        var dataType:Int = 0
        let TimeOutData = [5, 10, 15, 30, 60]
        let CacheSizeData = [30, 50, 100, 500, 1000]
        var SelectedCell:UITableViewCell?
        override func viewDidLoad() {
                super.viewDidLoad()
        }

    // MARK: - Table view data source
        override func numberOfSections(in tableView: UITableView) -> Int {
                return 1
        }

        override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
                if dataType == 1{
                        return TimeOutData.count
                }else{
                        return CacheSizeData.count
                }
        }

    /**/
        override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
                let cell = tableView.dequeueReusableCell(withIdentifier: "SysSettingDateItemCell", for: indexPath)
                if dataType == 1{
                        let data = TimeOutData[indexPath.row]
                        cell.textLabel?.text = "\(data) "+"Min".locStr
                        if data == SystemConf.SCInst.walletTimeOut{
                                cell.accessoryType = .checkmark
                                SelectedCell = cell
                        }
                }else if dataType == 2{
                        let data = CacheSizeData[indexPath.row]
                        cell.textLabel?.text = "\(data) M"
                        if data == SystemConf.SCInst.mailCacheSize{
                                cell.accessoryType = .checkmark
                                SelectedCell = cell
                        }
                }
                cell.tintColor = UIColor.init(hexColorCode: "#F69049")
                return cell
        }
        
        
        override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
                if SelectedCell != nil{
                        SelectedCell?.accessoryType = .none
                }
                
                let newCell = tableView.cellForRow(at: indexPath)
                if dataType == 1{
                        let data = TimeOutData[indexPath.row]
                        SystemConf.SCInst.walletTimeOut = Int16(data)
                }else if dataType == 2{
                        let data = CacheSizeData[indexPath.row]
                        SystemConf.SCInst.mailCacheSize = Int16(data)
                }
                newCell?.accessoryType = .checkmark
                self.SelectedCell = newCell
        }
}
