//
//  SystemConf.swift
//  BMail
//
//  Created by hyperorchid on 2020/4/27.
//  Copyright © 2020 NBS. All rights reserved.
//

import Foundation
import CoreData

public class SystemConf: NSObject{
        public static let DefaultWalletTimeInMin = Int16(15) //In seconds
        public static let DefaultMailCacheSizeInM = Int16(50) //In M
        static public var SCInst = SystemConf()
        
        public var conf:CDSysConfig!
        public var walletTimeOut:Int16 = DefaultWalletTimeInMin{
                didSet{
                        conf.walletTimeoutInMin = walletTimeOut
                        CoreDataUtils.CDInst.saveContext()
                }
        }
        public var mailCacheSize:Int16 = 50{
                didSet{
                        conf.mailCacheSize = mailCacheSize
                        CoreDataUtils.CDInst.saveContext()
                }
        }
        
        public var activeMail:String?{
                didSet{
                        conf.activeMail = activeMail
                        CoreDataUtils.CDInst.saveContext()
                }
        }
        
        public var lastestMailTime:Int64 = 0{
                didSet{
                        conf.lastestMailTime = lastestMailTime
                        CoreDataUtils.CDInst.saveContext()
                }
        }
        
        private override init() {
                guard let c = CoreDataUtils.CDInst.findOneEntity(Constants.DBNAME_SystemConfig) as? CDSysConfig else{
                        
                        conf = CoreDataUtils.CDInst.newEntity(Constants.DBNAME_SystemConfig){ (newObj) in
                                newObj.activeMail = ""
                                newObj.walletTimeoutInMin = SystemConf.DefaultWalletTimeInMin
                                newObj.mailCacheSize = SystemConf.DefaultMailCacheSizeInM
                        }
                        
                        return
                }
                
                conf = c
                activeMail = conf.activeMail
                walletTimeOut = conf.walletTimeoutInMin
                mailCacheSize = conf.mailCacheSize
                lastestMailTime = conf.lastestMailTime
                print("======>basic conf activeMail[\(activeMail ?? "<->")] walletTimeOut[\(walletTimeOut)] mailCacheSize[\(mailCacheSize)] lastestMailTime[\(lastestMailTime)]")
        }
}
