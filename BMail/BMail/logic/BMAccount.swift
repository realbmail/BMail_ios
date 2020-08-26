//
//  BMAccount.swift
//  BMail
//
//  Created by hyperorchid on 2020/4/25.
//  Copyright © 2020 NBS. All rights reserved.
//

import Foundation
import UIKit
import BmailLib

class BMAccount: NSObject {
        
        var openTime:Date = Date()
        private var cdAccount:CDMailAccount?
        private var nameImage:UIImage?
        
        private override init() {
                super.init()
        }
        
        init?(coredata:CDMailAccount){
                guard let c_txt = coredata.walletJson else {
                        NSLog("======>empty wallet json data in mail account core data")
                        return nil
                }
                guard BmailLibLoadWallet(c_txt) else{
                        NSLog("======>parse wallet json of core data failed")
                        return nil
                }
                self.cdAccount  = coredata
        }
        
        init?(json:String, auth:String){

                guard BmailLibLoadWallet(json) else{
                        NSLog("======>>parse wallet json of input parameter failed")
                        return nil
                }
                
                guard BmailLibOpenWallet(auth) else{
                        NSLog("======>open the wallet when parse json data failed, password invalid")
                        return nil
                }
                
                let address = BmailLibAddress()
                let mailName = BmailLibMailName()
                self.openTime = Date()
                self.cdAccount = CoreDataUtils.CDInst.newEntity(Constants.DBNAME_MailAccount){
                        (newObj) in
                        newObj.address = address
                        newObj.createTime = Date()
                        newObj.walletJson = json
                        newObj.mailName = mailName
                }
        }
        
        public static func newAccount(auth:String) -> BMAccount? {
                
                let acc_json = BmailLibNewWallet(auth)
                guard acc_json != "" else{
                        return nil
                }
                                
                let obj = BMAccount()
                let address = BmailLibAddress()
                obj.openTime = Date()
                obj.cdAccount = CoreDataUtils.CDInst.newEntity(Constants.DBNAME_MailAccount){
                        (newObj) in
                        newObj.address = address
                        newObj.createTime = Date()
                        newObj.walletJson = acc_json
                }
                return obj
        }
        
        func resetNameImg(){
                nameImage = nil
        }
        
        func NameIconImg() -> UIImage? {
                if nameImage != nil{
                        return nameImage
                }
                guard let m_name = self.cdAccount?.mailName, m_name != "" else{
                        return nil
                }
                
                guard let img_data = BmailLibMailIcon(m_name) else{
                        return nil
                }
                nameImage = UIImage.init(data: img_data)
                return nameImage
        }
        
        public func Address() -> String?{
                return self.cdAccount?.address
        }
        public func MailName() -> String?{
                return self.cdAccount?.mailName
        }
        public func NickName() -> String?{
                return self.cdAccount?.displayName
        }
        
        
        public func isEmpty() ->Bool{
                return self.cdAccount == nil
        }
        
        public func isOpen()->Bool{
                let opened = BmailLibWalletIsOpen()
                if opened {
                        self.openTime = Date()
                }
                return opened
        }
        
        public func openWallet(auth:String) -> Bool{
                let is_open = BmailLibOpenWallet(auth)
                if is_open{
                       self.openTime = Date()
                }
                return is_open
        }
        
        public func Close(){
                BmailLibCloseWallet()
        }
        
        public func JsonString() -> String{
                return BmailLibWalletJson()
        }
        
        public func setBMailName(_ name:String){
                self.cdAccount?.mailName = name
                let newJson = BmailLibSetMailName(name)
                self.cdAccount?.walletJson = newJson
                CoreDataUtils.CDInst.saveContext()
        }
        
        public func CipherTxt() ->String?{
                return cdAccount?.walletJson
        }
        
        public func getDomain() -> String?{
                guard let owner = self.cdAccount?.mailName else{
                        return nil
                }
                
                let mailDomains = owner.split(separator: "@")
                guard mailDomains.count == 2 else {
                        return nil
                }
                
                return String(mailDomains[1])
        }
}
