//
//  BMError.swift
//  BMail
//
//  Created by hyperorchid on 2020/4/27.
//  Copyright © 2020 NBS. All rights reserved.
//

import Foundation

public enum BMailError: Error, CustomStringConvertible {
        
        case coredata(String)
        public var description: String {
                switch self {
                case .coredata(let err): return "coredata err:=>[\(err)]"
                }
        }
}
