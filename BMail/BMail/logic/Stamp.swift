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
        var IsInused:Bool = false
        var ContractAddr:String!
        var IssuerAddr:String!
        var Name:String!
        var Symbol:String!
        var IconUrl:String?
        var Balance:Int64 = 0
        var ActiveBalance:Int64 = 0
        var Credit:Int64 = 0
        
        override init() {
        }
        
        init(coreData:CDStamp){
        }
        
        init(jsonStr:String){
        }
        
        public static var StampAvailableCache:[String:Stamp] = [:]
        
        public static func StampArray() -> [Stamp]{
                let testObj2 = Stamp()
                testObj2.ContractAddr = "0xc6aA4C9dF3a65470D73b5919ec90a54a04BE409e"
                testObj2.IssuerAddr = "0xea8a3a416799d582bC46987E084886524E7449Df"
                testObj2.Name = "Gmail Stamp Token"
                testObj2.Symbol = "GST"
                testObj2.Balance = 85
                testObj2.ActiveBalance = 15
                testObj2.Credit = 12
                testObj2.IsInused = true
                StampAvailableCache[testObj2.ContractAddr] = testObj2
                
                let testObj1 = Stamp()
                testObj1.ContractAddr = "0xea8a3a416799d582bC46987E084886524E7449Df"
                testObj1.IssuerAddr = "0xc6aA4C9dF3a65470D73b5919ec90a54a04BE409e"
                testObj1.Name = "Outlook Stamp Token"
                testObj1.Symbol = "OST"
                testObj1.Balance = 208
                testObj1.ActiveBalance = 72
                testObj1.Credit = 45
                StampAvailableCache[testObj1.ContractAddr] = testObj1
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
