//
//  File.swift
//  BMail
//
//  Created by hyperorchid on 2020/5/8.
//  Copyright © 2020 NBS. All rights reserved.
//

import Foundation
class File: NSObject {
        enum uploadStatus {
            case none
            case pending
            case processing
            case finish
            case failed
        }
        
        enum RequestType {
            case upload
            case download
        }
        var token = ""
        var name = ""
        var size = 0
        var status = 1
        var date = Date()
        var emailId = 0
        var mimeType = ""
        var shouldDuplicate = false
        var originalToken: String?
        var fileKey:String = ""
        var cid:String?
        var filePath = ""
        var progress = -1
        var filepath = ""
        var chunksProgress = [Int]()
        var requestType: RequestType = .upload
        var requestStatus: uploadStatus = .none
        
        override init(){
                
        }
}
