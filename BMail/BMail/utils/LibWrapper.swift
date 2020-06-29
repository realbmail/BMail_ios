//
//  LibWrapper.swift
//  BMail
//
//  Created by hyperorchid on 2020/6/19.
//  Copyright © 2020 NBS. All rights reserved.
//

import Foundation
import BmailLib


func QueryMailAddrBy(name:String) -> (String, String){
        
        let str = BmailLibMailBcaByMailName(name)
        let arr = str.split(separator: ",")
        if arr.count == 2{
                return (String(arr[0]), String(arr[1]))
        }else if arr.count == 1{
                return (String(arr[0]), "")
        }
        return ("", "")
}
