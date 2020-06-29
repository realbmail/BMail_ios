//
//  Contact.swift
//  BMail
//
//  Created by hyperorchid on 2020/5/8.
//  Copyright © 2020 NBS. All rights reserved.
//

import Foundation
import CoreData
import BmailLib

class BmailContact: NSObject{
        
        var MailAddr:String!
        var MailName:String!
        var DisplayName:String?
        var Expire:Int64!
        static let cqueue = DispatchQueue.init(label: "BmailContact Task Queue")
        
        init(ma:String, mn:String, dn:String?) {
                MailAddr = ma
                MailName = mn
                DisplayName = dn
                Expire = Int64(Date().timeIntervalSince1970.advanced(by: Constants.ContactExpireDuration))
        }
        
        public static var ContactsCache:[String:BmailContact] = [:]
        public static var FilteredData:[BmailContact] = []
        
        public class func ObjAt(idx:Int) -> BmailContact?{
                return Array(ContactsCache.values)[idx]
        }
        public class func LoadContact(){
                
                ContactsCache.removeAll()
                guard let mail_acc = AccountManager.currentAccount else{
                        return
                }
                
                guard let owner = mail_acc.MailName() else{
                        return
                }
               
                let condition = NSPredicate.init(format: "ownerMail == %@", owner)
                
                guard let result = CoreDataUtils.CDInst.findEntity(Constants.DBNAME_Contract,
                                                                   where: condition) as? [CDContact]? else{
                        return
                }
                
                guard let arr = result, arr.count > 0 else{
                        return
                }
                
                for cc in arr{
                        let obj = BmailContact.init(coreData:cc)
                        ContactsCache[obj.MailName] = obj
                }
        }
        
        public init(coreData obj:CDContact){
                self.MailAddr = obj.mailAddr!
                self.MailName = obj.mailName!
                self.DisplayName = obj.displayName
                self.Expire = obj.expireSince1970
        }
        
        public func _fullfillData(coreData obj:inout CDContact){
                obj.mailAddr = self.MailAddr
                obj.mailName = self.MailName
                obj.displayName = self.DisplayName
                obj.expireSince1970 = self.Expire
        }
        
        public func saveDisk() -> Bool{
                
                defer {CoreDataUtils.CDInst.saveContext()}
                let owner =  AccountManager.currentAccount?.MailName()
                let condition = NSPredicate.init(format: "mailName == %@ AND ownerMail == %@", self.MailAddr, owner!)
                guard var contact = CoreDataUtils.CDInst.findOneEntity(Constants.DBNAME_Contract, where: condition) as? CDContact else{
                        
                       let _:CDContact? = CoreDataUtils.CDInst.newEntity(Constants.DBNAME_Contract){
                               (newObj) in
                                newObj.ownerMail = owner!
                                self._fullfillData(coreData: &newObj)
                               
                       }
                       return true
                }
                
                _fullfillData(coreData: &contact)
                return false
        }
        
        public class func FileterBy(key:String?){
                guard let fileter =  key, fileter.count > 0 else{
                        FilteredData = []
                        return
                }
                
                let result = ContactsCache.filter { $1.MailName.contains(fileter) }
                if result.count == 0{
                        FilteredData = []
                        return
                }
                
                FilteredData = Array(result.values)
        }
        
        public class func QueryAddress(mailName: String) -> BmailContact?{
                let now = Int64(Date().timeIntervalSince1970)
                guard let contact = ContactsCache[mailName], contact.Expire > now else{
                        return syncFromBlockChain(mailName: mailName)
                }
                return contact
        }
        
        public class func syncFromBlockChain(mailName:String) -> BmailContact?{
                
                let (mail_addr, mail_cname) = QueryMailAddrBy(name: mailName)
                guard mail_addr != "" else{
                        return nil
                }
                
                let contact = BmailContact.init(ma: mail_addr, mn: mailName, dn: mail_cname)
                addContact(contact: contact)
                return contact
        }
        
        public class func addContact(contact:BmailContact){
                ContactsCache[contact.MailName] = contact
                cqueue.async {
                        let _ = contact.saveDisk()
                }
        }
        
        public class func removeContact(mailName:String){
                BmailContact.ContactsCache[mailName] = nil
                cqueue.async {
                        defer {CoreDataUtils.CDInst.saveContext()}
                        let owner =  AccountManager.currentAccount?.MailName()
                        let condition = NSPredicate.init(format: "mailName == %@ AND ownerMail == %@", mailName, owner!)
                        CoreDataUtils.CDInst.Remove(Constants.DBNAME_Contract, where: condition)
                }
        }
}
