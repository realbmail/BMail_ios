//
//  AccountManager.swift
//  BMail
//
//  Created by hyperorchid on 2020/4/25.
//  Copyright © 2020 NBS. All rights reserved.
//

import Foundation
import CoreData

class AccountManager{
        
        public static var currentAccount:BMAccount?
        
        public static var mailAccounts:[BMAccount] = []
        
        public static func initSys(){
                guard let arr = CoreDataUtils.CDInst.findEntity(Constants.DBNAME_MailAccount) as? [CDMailAccount] else{
                        return
                }
                
                if arr.count == 0{
                        return
                }
                var acc_list:[BMAccount] = []
                for ma in arr{
                        guard let bma = BMAccount.init(coredata:ma) else{
                                continue
                        }
                        acc_list.append(bma)
                }
                
                mailAccounts = acc_list
                
               for bma in mailAccounts{
                       if bma.Address() == SystemConf.SCInst.activeMail{
                               currentAccount = bma
                                return
                       }
               }
               
               currentAccount = mailAccounts[0]
        }
        
        public static func replaceActiveMail(_ newMail:BMAccount){
                currentAccount = newMail
                SystemConf.SCInst.activeMail = newMail.Address()
                mailAccounts.append(newMail)
                NotificationCenter.default.post(name: Constants.NOTI_SYSTEM_ACTIVE_MAIL_CHANGED,
                                                object: nil,
                                                userInfo: nil)
        }
        
        public static func CheckTimeOut(){
                
                guard let account = currentAccount else{
                        return
                }
                
                guard account.isOpen() else {
                        return
                }
                
                let time_inteval = account.openTime.timeIntervalSinceNow
                guard Double(time_inteval) < -Constants.WalletTimeOut else {
                        return
                }
                
                account.Close()
        }
        
        public static func isDuplicate(address:String) -> Bool{
                
                let w : NSPredicate = NSPredicate.init(format: "address = %@", address)
                guard let _ = CoreDataUtils.CDInst.findOneEntity(Constants.DBNAME_MailAccount, where: w) as? CDMailAccount else{
                        return false
                }
                
                return true
        }
}
