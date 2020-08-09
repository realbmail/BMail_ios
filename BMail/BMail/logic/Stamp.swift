//
//  Stamp.swift
//  BMail
//
//  Created by wesley on 2020/8/8.
//  Copyright © 2020 NBS. All rights reserved.
//

import Foundation
import CoreData
import BmailLib

class Stamp: NSObject{
        
        var ContractAddr:String!
        var IssuerAddr:String!
        var Name:String!
        var Symbol:String!
        var IconUrl:String?
        var Balance:Int64!
        var ActiveBalance:Int64!
        var Credit:Int64 = 0
        
        override init() {
        }
        
        init(coreData:CDStamp){
        }
        
        init(jsonStr:String){
        }
        
        public static var StampAvailableCache:[String:Stamp] = [:]
        
        public static func StampArray() -> [Stamp]{
                return Array(StampAvailableCache.values)
        }
        
        
        public static func LoadStampDataFromCache(){
                
                StampAvailableCache.removeAll()
                guard let mail_acc = AccountManager.currentAccount else{
                        return
                }
                
                guard let owner = mail_acc.MailName() else{
                        return
                }
                
                let mailDomains = owner.split(separator: "@")
                guard mailDomains.count == 2 else {
                        return
                }
                
                let condition = NSPredicate.init(format: "mailDomain == %@", String(mailDomains[1]))
                
                guard let result = CoreDataUtils.CDInst.findEntity(Constants.DBNAME_Stamp,
                                                                   where: condition) as? [CDStamp]? else{
                        return
                }
                
                guard let arr = result, arr.count > 0 else{
                        return
                }
                
                for cc in arr{
                        let obj = Stamp.init(coreData:cc)
                        StampAvailableCache[obj.ContractAddr] = obj
                }
        }
        
        public static func LoadAvailableStampAddressFromDomainOwner() -> [String]{
                return []
        }
        
        public static func FetchStampDetailfFromBlockchain(addrArr:[String]){
                StampAvailableCache.removeAll()
                for addr in addrArr{
                        let detail_str = BmailLibStampDetails(addr)
                        let stamp = Stamp.init(jsonStr:detail_str)
                        StampAvailableCache[stamp.ContractAddr] = stamp
                }
        }
}
