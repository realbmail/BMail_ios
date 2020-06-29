//
//  MailManager.swift
//  BMail
//
//  Created by hyperorchid on 2020/4/30.
//  Copyright © 2020 NBS. All rights reserved.
//

import Foundation
import BmailLib

public class MailManager:NSObject{
        public static var CurrentMailList:[EnvelopeEntity] = [EnvelopeEntity()]
        
        static var counter:[MailActionType:Int] = [:]
        static var upOffset:Int64 = -1
        public static let PopMailDefaultPieceSize = 15
        
        public class func increadCounter(typ:MailActionType, no:Int){
                counter[typ] = counter[typ] ?? 0 + no
                
                if counter[typ]! < 0 {
                        counter[typ] = 0
                }
        }
        
        public class func reloadCounter(typ:MailActionType){
                guard let account = AccountManager.currentAccount else{
                        return
                }
                
                let address = account.Address()!
                var condition:NSPredicate?// = NSPredicate.init(format: "toAddress == %@ AND isUnread == true AND isTrash == false", address)
                
                switch typ{
                case .Inbox:
                        condition = NSPredicate.init(format: "toAddress == %@ AND isUnread == true AND isTrash == false", address)
                        break
                case .Draft:
                        condition = NSPredicate.init(format: "fromAddress == %@ AND isDraft == true", address)
                case .Sent:
                        condition = NSPredicate.init(format: "fromAddress == %@ AND isSent == true AND isUnread == true", address)
                case .StarMail:
                        condition = NSPredicate.init(format: "(fromAddress == %@ OR toAddress == %@) AND isStarred == true AND isUnread == true", address, address)
                case .Archieved:
                        condition = NSPredicate.init(format: "(fromAddress == %@ OR toAddress == %@) AND isArchieved == true AND isUnread == true", address, address)
                case .Spam:
                        condition = NSPredicate.init(format: "toAddress == %@ AND isSpam == true AND isUnread == true", address, address)
                case .Recycle:
                        condition = NSPredicate.init(format: "(fromAddress == %@ OR toAddress == %@) AND isTrash == true AND isUnread == true", address, address)
                default:
                        return
                }
                
                MailManager.counter[typ] = CoreDataUtils.CDInst.Counter(Constants.DBNAME_Envelope, where: condition)
                
                condition = NSPredicate.init(format: "(fromAddress == %@ OR toAddress == %@) AND isUnread == true", address, address)
                MailManager.counter[.AllMail] = CoreDataUtils.CDInst.Counter(Constants.DBNAME_Envelope, where: condition)
        }
        
        
        public class func loadCounter(){
                
                guard let account = AccountManager.currentAccount else{
                        return
                }
                let address = account.Address()!
                
                var condition = NSPredicate.init(format: "toAddress == %@ AND isUnread == true AND isTrash == false", address)
                
                MailManager.counter[.Inbox] = CoreDataUtils.CDInst.Counter(Constants.DBNAME_Envelope, where: condition)
                
                condition = NSPredicate.init(format: "fromAddress == %@ AND  isDraft == true", address)
                MailManager.counter[.Draft] = CoreDataUtils.CDInst.Counter(Constants.DBNAME_Envelope, where: condition)
                
                condition = NSPredicate.init(format: "fromAddress == %@ AND isSent == true AND isUnread == true", address)
                MailManager.counter[.Sent] = CoreDataUtils.CDInst.Counter(Constants.DBNAME_Envelope, where: condition)
                
                condition = NSPredicate.init(format: "(fromAddress == %@ OR toAddress == %@) AND isStarred == true AND isUnread == true", address, address)
                MailManager.counter[.StarMail] = CoreDataUtils.CDInst.Counter(Constants.DBNAME_Envelope, where: condition)
                
                condition = NSPredicate.init(format: "(fromAddress == %@ OR toAddress == %@) AND isArchieved == true AND isUnread == true", address, address)
                MailManager.counter[.Archieved] = CoreDataUtils.CDInst.Counter(Constants.DBNAME_Envelope, where: condition)
                
                condition = NSPredicate.init(format: "toAddress == %@ AND isSpam == true AND isUnread == true", address, address)
                MailManager.counter[.Spam] = CoreDataUtils.CDInst.Counter(Constants.DBNAME_Envelope, where: condition)
                
                condition = NSPredicate.init(format: "(fromAddress == %@ OR toAddress == %@) AND isTrash == true AND isUnread == true", address, address)
                MailManager.counter[.Recycle] = CoreDataUtils.CDInst.Counter(Constants.DBNAME_Envelope, where: condition)
                
                condition = NSPredicate.init(format: "(fromAddress == %@ OR toAddress == %@) AND isUnread == true", address, address)
                MailManager.counter[.AllMail] = CoreDataUtils.CDInst.Counter(Constants.DBNAME_Envelope, where: condition)
        }
        
        public  class func LoadCachedMail(type:MailActionType, isDecryptMode:Bool, since:Int64? = nil) -> Bool{
                
                var lastest = 1000 * Int64(Date().timeIntervalSince1970)
                
                if since != nil{
                        lastest = since!
                }else{
                        CurrentMailList.removeAll()
                }
                
                guard let arr = executeSql(type: type, since:lastest), arr.count > 0 else{
                        return false
                }
                
                for cd_mail in arr {
                        let obj = EnvelopeEntity.init(coreData: cd_mail)
                        if isDecryptMode{
                                obj.DecryptByPinCode()
                        }
                        CurrentMailList.append(obj)
                }
                
                if type == .Inbox && CurrentMailList.count > 0 && since == nil{
                        upOffset = CurrentMailList[0].timeSince1970
                }
                
                return true
        }
        
        public class func executeSql(type:MailActionType, since:Int64) -> [CDEnvelope]?{
                
                guard let account = AccountManager.currentAccount else{
                        return nil
                }
                let address = account.Address()!
                var condition:NSPredicate?
                switch type {
                case .Inbox:
                        condition = NSPredicate.init(format: "toAddress == %@ AND isTrash == false AND timeSince1970 < %ld",
                                                     address,
                                                     since as CVarArg)
                case.Draft:
                        condition = NSPredicate.init(format: "fromAddress == %@ AND isDraft == true AND timeSince1970 < %ld",
                                                     address,
                                                     since as CVarArg)
                case.Sent:
                        condition = NSPredicate.init(format: "fromAddress == %@ AND isTrash == false AND isSent == true AND timeSince1970 < %ld",
                                                  address,
                                                  since as CVarArg)
                case.StarMail:
                        condition = NSPredicate.init(format: "(fromAddress == %@ OR toAddress == %@) AND isStarred == true AND timeSince1970 < %ld",
                                                    address,address,
                                                    since as CVarArg)
                case.Archieved:
                        condition = NSPredicate.init(format: "(fromAddress == %@ OR toAddress == %@) AND isArchieved == true AND timeSince1970 < %ld",
                                                    address,address,
                                                    since as CVarArg)
                case.Spam:
                        condition = NSPredicate.init(format: "toAddress == %@ AND isSpam == true AND timeSince1970 < %ld",
                                                    address,
                                                    since as CVarArg)
                case.Recycle:
                        condition = NSPredicate.init(format: "(fromAddress == %@ OR toAddress == %@) AND isTrash == true AND timeSince1970 < %ld",
                                                    address, address,
                                                    since as CVarArg)
                case.AllMail:
                        condition = NSPredicate.init(format: "(fromAddress == %@ OR toAddress == %@) AND timeSince1970 < %ld",
                                                    address,address,
                                                    since as CVarArg)
                default:
                        return nil
                }
                
                let sort = [NSSortDescriptor(key: "timeSince1970", ascending: false)]
                guard let result = CoreDataUtils.CDInst.findLimitedEntity(Constants.DBNAME_Envelope,
                                                                          limit: PopMailDefaultPieceSize,
                                                                          sortBy:sort,
                                                                          where: condition) as? [CDEnvelope]? else{
                        return nil
                }
                return result
        }
        
        public class func removeFromLocDB(Eid:String) {
                let condition = NSPredicate.init(format: "eid == %@", Eid)
                CoreDataUtils.CDInst.Remove(Constants.DBNAME_Envelope, where: condition)
        }
        
        public class func ClearTrashes(){
                guard let account = AccountManager.currentAccount else{ return }
                CurrentMailList.removeAll()
                
                let address = account.Address()!
                let condition = NSPredicate.init(format: "(fromAddress == %@ OR toAddress == %@) AND isTrash == true", address, address)
                CoreDataUtils.CDInst.Remove(Constants.DBNAME_Envelope, where: condition)
                counter[.Recycle] = 0
        }
        
        public class func ClearDrafts(){
                guard let account = AccountManager.currentAccount else{
                        return
                }
                CurrentMailList.removeAll()
                let address = account.Address()!
                let condition = NSPredicate.init(format: "fromAddress == %@ AND isSent == false", address)
                CoreDataUtils.CDInst.Remove(Constants.DBNAME_Envelope, where: condition)
                counter[.Draft] = 0
        }
        
        public class func removeAtIndex(_ index:Int){
                //TODO:: notification and change the no of menu
                guard index <  CurrentMailList.count else{
                        return
                }
                
                let env = CurrentMailList[index]
                let condition = NSPredicate.init(format: "eid == %@", env.eid)
                CoreDataUtils.CDInst.Remove(Constants.DBNAME_Envelope, where: condition)
                CurrentMailList.remove(at: index)
        }
        
        public class func trashAtIndex(_ index:Int){
                //TODO:: notification and change the no of menu
                guard index <  CurrentMailList.count else{
                        return
                }
                
                let env = CurrentMailList[index]
                env.isTrash = true
                let _ = env.store()
                CurrentMailList.remove(at: index)
        }
        
        private class func saveToDataCache(_ envs:[EnvelopeEntity]){
                let to_addr = AccountManager.currentAccount?.Address()
                for env_obj in envs{
                        env_obj.isInbox = true
                        env_obj.BranchRcpts(myAddr: to_addr!)
//                        print("=======33333333==\(env_obj.timeSince1970 ?? -1)===>")
                        let condition = NSPredicate.init(format: "eid == %@", env_obj.eid)
                        guard var envelope = CoreDataUtils.CDInst.findOneEntity(Constants.DBNAME_Envelope, where: condition) as? CDEnvelope else{
                                
                                let _:CDEnvelope? = CoreDataUtils.CDInst.newEntity(Constants.DBNAME_Envelope){
                                        (newObj) in
                                        
                                        env_obj.isUnread = true
                                        newObj.toAddress = to_addr
                                        env_obj._fullfillData(coreData: &newObj)
                                }
                                continue
                        }
                        envelope.toAddress = to_addr
                        env_obj._fullfillData(coreData: &envelope)
                }
        }
        
        public class func PopInboxMail(olderThanSince:Bool, cb: BmailLibMailCallBackProtocol) -> Bool{
                if upOffset < 0{
                        upOffset = SystemConf.SCInst.lastestMailTime
                }
                var loadedCount = 0
                repeat{
                        guard let json_data = BmailLibBPop(upOffset, olderThanSince, PopMailDefaultPieceSize, cb) else{
                                break
                        }
                        
                        guard let envs = try? JSONDecoder().decode([EnvelopeEntity].self, from: json_data)  else {
                                print("======>mail parse data failed")
                                break
                        }
                        if envs.count == 0{
                                print("======>pop no more mails")
                                break;
                        }
                        upOffset = envs[envs.count - 1].timeSince1970
                        
                        saveToDataCache(envs)
                        loadedCount += envs.count
                        if envs.count < PopMailDefaultPieceSize{
                                print("======>lastest mails:\(envs.count)")
                                break
                        }
                }while true
                
                if loadedCount == 0{
                        return false
                }
                
                SystemConf.SCInst.lastestMailTime = upOffset
                reloadCounter(typ: .Inbox)
                CoreDataUtils.CDInst.saveContext()
                return true
        }
        
        public static func EnDecryptMails(decrypt:Bool, callback:(()->Void)?){
                for env in CurrentMailList{
                        if decrypt{
                                env.DecryptByPinCode()
                        }else{
                                env.isDecrypted = false
                        }
                }
                callback?()
        }
}
