//
//  Stamp.swift
//  BMail
//
//  Created by wesley on 2020/8/8.
//  Copyright © 2020 NBS. All rights reserved.
//

import Foundation
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
        
        public static func LoadStampDataFromCache() -> [Stamp]{
                return []
        }
}
