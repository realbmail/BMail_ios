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
import SwiftyJSON

class Stamp: NSObject{
        
        var ContractAddr:String!
        var IssuerAddr:String!
        var Name:String!
        var Symbol:String!
        var IconUrl:String?
        var Balance:Int64 = 0
        var ActiveBalance:Int64 = 0
        var Credit:Int64 = 0
        var Epoch:Int64 = 0
        
        override init() {
        }
        
        init(coreData:CDStamp){
                ContractAddr = coreData.sAddress
                IssuerAddr = coreData.issuer
                Name = coreData.name
                Symbol = coreData.symbol
                IconUrl = coreData.iconUrl
                Balance = coreData.balance
                ActiveBalance = coreData.active
                Credit = coreData.credit
                Epoch = coreData.epoch
        }
        
        init(jsonData:Data){
                let json = JSON(jsonData)
                IssuerAddr = json["issuer"].string
                Name = json["name"].string
                Symbol = json["symbol"].string
                IconUrl = json["icon"].string
                Balance = json["balance"].int64 ?? 0
                ActiveBalance = json["active"].int64 ?? 0
                Epoch = json["epoch"].int64 ?? 0 
        }
        
        public static var StampAvailableCache:[String:Stamp] = [:]
        
        public static func StampArray() -> [Stamp]{
                return Array(StampAvailableCache.values)
        }
        
        
        public static func LoadStampDataFromCache(){
                
                StampAvailableCache.removeAll()
                
                guard let domain = AccountManager.currentAccount?.getDomain() else {
                        return
                }
                
                let condition = NSPredicate.init(format: "mailDomain == %@", domain)
                
                guard let result = CoreDataUtils.CDInst.findEntity(Constants.DBNAME_Stamp,
                                                                   sortBy: [NSSortDescriptor(key: "balance", ascending: false)],
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
        
        public static func QueryCreditOf(stampAddr:String){
                guard let domain = AccountManager.currentAccount?.getDomain() else {return}
                guard let json_data = BmailLibStampReceipt(domain, stampAddr) else {return}
                
                let json = JSON(json_data)
                
                let credit = json["credit"].int64 ?? 0
                
                StampAvailableCache[stampAddr]?.Credit = credit
                
                let condition = NSPredicate.init(format: "sAddress == %@ ", stampAddr)
                guard let coreData = CoreDataUtils.CDInst.findOneEntity(Constants.DBNAME_Stamp, where: condition) as? CDStamp else{
                        return
                }
                coreData.credit = credit
                CoreDataUtils.CDInst.saveContext()
        }
        
        public static func LoadAvailableStampAddressFromDomainOwner(){
                guard let domain = AccountManager.currentAccount?.getDomain() else { return }
                               
                guard let json_data = BmailLibQueryStampListOf(domain) else{
                        return
                }
                let json = JSON(json_data)
                let addr_arr = json["stampAddr"].arrayValue as Array<JSON>
                if addr_arr.count == 0{
                        return
                }
                
                StampAvailableCache.removeAll()
                for addr in addr_arr{
                        guard let detail_data = BmailLibStampDetails(addr.string) else{
                                NSLog("query detailf for[\(addr.string ?? "<->")] failed")
                                continue
                        }
                        let stamp = Stamp.init(jsonData:detail_data)
                        stamp.ContractAddr = addr.string
                        StampAvailableCache[stamp.ContractAddr] = stamp
                        let condition = NSPredicate.init(format: "sAddress == %@ ", stamp.ContractAddr)
                        
                        let _:CDStamp? = CoreDataUtils.CDInst.updateOrInsert(Constants.DBNAME_Stamp, where: condition){
                                (newObj)in
                                newObj.active = stamp.ActiveBalance
                                newObj.balance = stamp.Balance
                                newObj.iconUrl = stamp.IconUrl
                                newObj.issuer = stamp.IssuerAddr
                                newObj.mailDomain = domain
                                newObj.sAddress = stamp.ContractAddr
                                newObj.name = stamp.Name
                                newObj.symbol = stamp.Symbol
                                newObj.epoch = stamp.Epoch
                        }
                }
                
                CoreDataUtils.CDInst.saveContext()
        }
        
        public static func ReloadStampDetailsFromEth(addr:String){
                guard let domain = AccountManager.currentAccount?.getDomain() else { return }
                guard let detail_data = BmailLibStampDetails(addr) else{
                        NSLog("query detailf for[\(addr)] failed")
                        return
                }
                
                let stamp = Stamp.init(jsonData:detail_data)
                stamp.ContractAddr = addr
                StampAvailableCache[addr] = stamp

                let condition = NSPredicate.init(format: "sAddress == %@ ", stamp.ContractAddr)
                let _:CDStamp? = CoreDataUtils.CDInst.updateOrInsert(Constants.DBNAME_Stamp, where: condition){
                        (newObj)in
                        newObj.active = stamp.ActiveBalance
                        newObj.balance = stamp.Balance
                        newObj.iconUrl = stamp.IconUrl
                        newObj.issuer = stamp.IssuerAddr
                        newObj.mailDomain = domain
                        newObj.sAddress = stamp.ContractAddr
                        newObj.name = stamp.Name
                        newObj.symbol = stamp.Symbol
                        newObj.epoch = stamp.Epoch
                }
                
                CoreDataUtils.CDInst.saveContext()
        }
}
