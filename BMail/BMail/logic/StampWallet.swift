//
//  StampWallet.swift
//  BMail
//
//  Created by wesley on 2020/8/11.
//  Copyright © 2020 NBS. All rights reserved.
//

import Foundation
import UIKit
import BmailLib
import CoreData

class StampWallet: NSObject {
        
        public static var CurSWallet = StampWallet()
        var cdWallet:CDStampWallet?
        var Balance:Double = 0 {
                didSet{
                        cdWallet?.balance = Balance
                        CoreDataUtils.CDInst.saveContext()
                }
        }
        var Address:String?
        override init() {
        }
        
        init(coredata:CDStampWallet){
                cdWallet = coredata
                Address = coredata.address
                Balance = coredata.balance
        }
        
        func isEmpty() -> Bool {
                return self.Address == nil
        }
        
        func openWallet(auth:String) -> Bool{
                return BmailLibOpenStampWallet(auth)
        }
        
        func loadBalance() {
                guard let address = self.Address else {
                        return
                }
                self.Balance = Double(BmailLibWalletEthBalance(address))
        }
        
        public static func LoadWallet(){
                guard let wallet = CoreDataUtils.CDInst.findOneEntity(Constants.DBNAME_StampWallet)
                        as? CDStampWallet else{ return }
                print(wallet.jsonStr!)
                guard BmailLibStampWalletFromJson(wallet.jsonStr) == true else{
                        return
                }
                
                CurSWallet = StampWallet(coredata:wallet)
                DispatchQueue.global(qos: .background).async {
                        CurSWallet.Balance = Double(BmailLibWalletEthBalance(wallet.address))
                }
        }
        
        public static func NewWallet(auth:String) -> Bool{
                guard CurSWallet.isEmpty() else{
                        return false
                }
                
                let jsonStr = BmailLibNewStampWallet(auth)
                if jsonStr == ""{
                        return false
                }
                print(jsonStr)
                CurSWallet.Address = BmailLibStampWalletAddress()
                CurSWallet.cdWallet = CoreDataUtils.CDInst.newEntity(Constants.DBNAME_StampWallet){
                        (newObj) in
                        newObj.address = CurSWallet.Address
                        newObj.balance = 0
                        newObj.jsonStr = jsonStr
                }
                CoreDataUtils.CDInst.saveContext()
                return true
        }
        
        public static func ActiveBalance(amount:Int64, tokenAddr:String) throws{
                guard BmailLibActiveStamp(amount, tokenAddr) else{
                        throw BMailError.swallet("Active balance failed")
                }
        }
}
