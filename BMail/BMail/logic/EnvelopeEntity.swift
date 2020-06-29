//
//  MailEntity.swift
//  BMail
//
//  Created by hyperorchid on 2020/4/30.
//  Copyright © 2020 NBS. All rights reserved.
//

import Foundation
import BmailLib
import CoreData
import UIKit


enum RcptType : Int8, Codable {
    case to
    case cc
    case bcc
    case monitor
}

class Receipt : NSObject, Codable{

        var type:RcptType
        var displayName:String?
        var mailName:String
        var mailAddr:String
        var aesKey:Data?
        
        init(typ:RcptType, name:String, addr:String, disName:String?) {
                type = typ
                mailName = name
                mailAddr = addr
                displayName = disName
        }
        
        init(typ:RcptType, contact:BmailContact){
                type = typ
                mailName = contact.MailName
                mailAddr = contact.MailAddr
                displayName = contact.DisplayName
        }
        
        private enum CodingKeys: String, CodingKey {
                case displayName
                case type = "rcptType"
                case mailName = "to"
                case mailAddr = "toAddr"
                case aesKey = "aesKey"
        }
        
        public static func ToData(rcpts:[String:Receipt]) -> Data?{
                guard rcpts.count > 0 else{
                        return nil
                }
                guard let data = try? JSONEncoder().encode(rcpts) else{
                        return nil
                }
                return data
        }
        
        public static func FromData(data:Data?) -> [String:Receipt]{
                guard let d = data else {
                        return [:]
                }
                
                guard let rcpts = try? JSONDecoder().decode([String:Receipt].self, from: d) else{
                        return [:]
                }
                
                return rcpts
        }
}

public class EnvelopeEntity:NSObject, Codable{
        var eid:String!
        var sessionID:String?
        var rawSubject:String?
        var rawBody:String?
        var pinCodedSub:String?
        var pinCodedMsg:String?
        
        var fromAddress:String?
        var fromName:String?
        var timeSince1970:Int64!
        var pinCode:Data?
        var pinCipher:Data?
        var Tos:[String:Receipt] = [:]
        var CCs:[String:Receipt] = [:]
        var BCCs:[String:Receipt] = [:]
        var rcpts:[Receipt] = []
        
        var isInbox:Bool = false {
                didSet{
                       isDraft = false
                }
        }
        var isUnread:Bool = false
        var isSent:Bool = false
        var isDraft:Bool = true
        var isStarred:Bool = false
        var isArchieved:Bool = false
        var isSpam:Bool = false
        var isTrash:Bool = false
        
        var isDecrypted:Bool = false
        var dateStr:String?
        
        lazy var addrImge:UIImage? = {
                guard let img_data = BmailLibMailIcon(self.fromName) else{
                        return nil
                }
                return UIImage.init(data: img_data)
        }()
        
        enum CodingKeys: String, CodingKey {
                case eid = "eid"
                case sessionID = "sessionID"
                case pinCodedSub = "subject"
                case pinCodedMsg = "mailBody"
                case fromName = "fromName"
                case fromAddress = "fromAddr"
                case timeSince1970 = "timeSince1970"
                case rcpts = "rcpts"
        }

        init(SID:String?=nil) {
                eid = BmailLibMailID()
                pinCode = BmailLibPinCode()!
                sessionID = SID == nil ? eid :SID
                super.init()
        }
        
        func hasAttachMent()-> Bool{
                return false
        }
        
        func encodeEnvlopeByPin() ->Bool{
                
                if self.pinCode == nil || self.pinCode?.count == 0{
                        return false
                }
                if self.pinCipher == nil{
                        self.pinCipher = BmailLibEncodePin(self.pinCode)
                }
                if self.rawSubject != nil{
                        self.pinCodedSub = BmailLibEncodeByPin(self.rawSubject, self.pinCode)
                }
                
                if self.rawBody != nil{
                        self.pinCodedMsg = BmailLibEncodeByPin(self.rawBody, self.pinCode)
                }
                return true
        }

        func DecryptByPinCode(){
                
                if self.isSent{
                        if pinCode == nil{
                                self.pinCode = BmailLibDecodePin(self.pinCipher)
                        }
                }else if self.isInbox{//TODO::
                        if pinCode == nil{
                                self.pinCode = BmailLibDecodePinByPeer(self.pinCipher, self.fromAddress)
                        }
                }
                
                if self.rawSubject == nil && self.pinCodedSub != nil{
                        self.rawSubject = BmailLibDecodeByPin(self.pinCodedSub, self.pinCode)
                }
                if self.rawBody == nil && self.pinCodedMsg != nil{
                        self.rawBody = BmailLibDecodeByPin(self.pinCodedMsg, self.pinCode)
                }
                
                self.isDecrypted = true
        }
        
        
        func store() -> Bool{
                defer {
                        CoreDataUtils.CDInst.saveContext()
                }
                let condition = NSPredicate.init(format: "eid == %@", self.eid)
                guard var envelope = CoreDataUtils.CDInst.findOneEntity(Constants.DBNAME_Envelope, where: condition) as? CDEnvelope else{
                        let _:CDEnvelope? = CoreDataUtils.CDInst.newEntity(Constants.DBNAME_Envelope){
                                (newObj) in
                                self._fullfillData(coreData: &newObj)
                                
                        }
                        return true
                }
                _fullfillData(coreData: &envelope)
                return false
        }
        
        public func _fullfillData(coreData obj:inout CDEnvelope){
                obj.eid = self.eid
                obj.timeSince1970 = self.timeSince1970
                obj.isDraft = self.isDraft
                
                if self.isDraft{
                        obj.subject = self.rawSubject
                        obj.msgBody = self.rawBody
                }else{
                        obj.subject = self.pinCodedSub
                        obj.msgBody = self.pinCodedMsg
                }
                obj.sessionID = self.sessionID
                obj.fromAddress = self.fromAddress
                obj.isInbox = self.isInbox
                obj.isUnread = self.isUnread
                obj.isSent = self.isSent
                obj.isStarred = self.isStarred
                obj.isArchieved = self.isArchieved
                obj.isSpam = self.isSpam
                obj.isTrash = self.isTrash
                obj.fromName = self.fromName
                obj.pinCipher = self.pinCipher
                obj.tos = Receipt.ToData(rcpts: self.Tos)
                obj.ccs = Receipt.ToData(rcpts: self.CCs)
                obj.bccs = Receipt.ToData(rcpts: self.BCCs)
        }
        
        public init(coreData obj:CDEnvelope){
                self.eid = obj.eid
                self.timeSince1970 = obj.timeSince1970
                self.dateStr = Date.init(timeIntervalSince1970: TimeInterval(self.timeSince1970 / 1000)).stringVal
                
                if obj.isDraft{
                        self.rawBody = obj.msgBody
                        self.rawSubject = obj.subject
                        self.pinCode = BmailLibPinCode()!
                }else{
                        self.pinCodedSub = obj.subject
                        self.pinCodedMsg = obj.msgBody
                }
                
                self.fromAddress = obj.fromAddress
                self.fromName = obj.fromName
                self.sessionID = obj.sessionID
                self.isInbox = obj.isInbox
                self.isUnread = obj.isUnread
                self.isSent = obj.isSent
                self.isStarred = obj.isStarred
                self.isArchieved = obj.isArchieved
                self.isSpam = obj.isSpam
                self.isTrash = obj.isTrash
                self.isDraft = obj.isDraft
                self.pinCipher = obj.pinCipher
                self.Tos = Receipt.FromData(data: obj.tos)
                self.CCs = Receipt.FromData(data: obj.ccs)
                self.BCCs = Receipt.FromData(data: obj.bccs)
                super.init()
                
        }
        
        func AddRcpt(typ: RcptType, r:Receipt){
                switch typ {
                case .to:
                        self.Tos[r.mailName] = r
                case .cc:
                        self.CCs[r.mailName] = r
                case .bcc:
                        self.BCCs[r.mailName] = r
                default:
                        return
                }
        }
        
        func GetRcpt(typ: RcptType, name:String) -> Receipt?{
                var r:Receipt? = nil
                switch typ {
                case .to:
                        r = self.Tos[name]
                case .cc:
                         r = self.CCs[name]
                case .bcc:
                        r = self.BCCs[name]
                default:
                        return nil
                }
                guard let rcpt = r, rcpt.mailAddr != "" else {
                        return nil
                }
                
                return rcpt
        }
        
        func RemoveRcpt(typ: RcptType, name:String){
              switch typ {
                case .to:
                        self.Tos[name] = nil
                case .cc:
                         self.CCs[name] = nil
                case .bcc:
                        self.BCCs[name] = nil
                default:
                        return
                }
        }
        
        func MergerRcpts(){
                self.rcpts = Array(self.Tos.values)
                self.rcpts.append(contentsOf: Array(self.CCs.values))
                self.rcpts.append(contentsOf: Array(self.BCCs.values))
        }
        
        func BranchRcpts(myAddr:String) {
                for r in self.rcpts{
                        switch r.type {
                        case .to:
                                self.Tos[r.mailName] = r
                        case .cc:
                                self.CCs[r.mailName] = r
                        case .bcc:
                                self.BCCs[r.mailName] = r
                        default:
                                return
                        }
                        if r.mailAddr == myAddr{
                                self.pinCipher = r.aesKey
                        }
                }
        }
        
        func ToJsonString() ->String?{
                guard let data = try? JSONEncoder().encode(self) else{
                        return nil
                }
                return String.init(data: data, encoding: .utf8)
        }
        
        public static func FromJsonString(json:String)->EnvelopeEntity{
                let jsonData = json.data(using: .utf8)!
                let env = try! JSONDecoder().decode(EnvelopeEntity.self, from: jsonData)
                return env
        }
        
        func markAs(typ:MailActionType) {
                
        }
        func markAsUnread() {
        }
}
