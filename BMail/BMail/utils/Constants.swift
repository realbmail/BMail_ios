//
//  Constants.swift
//  bpassword
//
//  Created by hyperorchid on 2020/3/21.
//  Copyright © 2020 NBS. All rights reserved.
//

import Foundation

struct Constants {
        public static let SysVersion = "1.0"
        public static let PasswordLeastLen = 8
        public static var WalletTimeOut = Double(300)//
        public static var TimerCheckInterval = TimeInterval(5)//
        public static let CoinDecimal = Double(1e18)
        public static let DefaultServicePrice = Double(2e18)
        public static let ContactExpireDuration = TimeInterval(60*60*24)
        
        public static let KEY_CURRENT_NETWORK = "KEY_CURRENT_NETWORK"
        public static let KEY_CURRENT_WALLET_DURATION = "KEY_CURRENT_WALLET_DURATION"
        
        public static let NOTI_ITEM_CHANGED = Notification.Name("NOTI_ITEM_CHANGED")
        public static let NOTI_BASIC_INFO_CHANGE = Notification.Name("NOTI_BASIC_INFO_CHANGE")
        
        
        public static let DBNAME_MailAccount = "CDMailAccount"
        public static let DBNAME_SystemConfig = "CDSysConfig"
        public static let DBNAME_Envelope = "CDEnvelope"
        public static let DBNAME_Contract = "CDContact"
        public static let DBNAME_Stamp = "CDStamp"
        public static let DBNAME_StampWallet = "CDStampWallet"
        
        
        static let NOTI_SYSTEM_ACTIVE_MAIL_CHANGED = Notification.Name("NOTI_SYSTEM_ACTIVE_MAIL_CHANGED")
}


public enum MailActionType :Int{
        case Inbox
        case Draft
        case Sent
        case Recycle
        
        case StarMail
        case Archieved
        case Spam
        case AllMail
        
        
        case Help  = 20
        case Contact
        case Setting
        case Account
        case Stamp
        
        case BugReport
        
        public var Name:String{
                switch self {
                case .Inbox:
                        return "Inbox".locStr
                case .Draft:
                        return "Draft".locStr
                case .Sent:
                        return "Sent".locStr
                case .StarMail:
                        return "Stars".locStr
                case .Archieved:
                        return "Archieved".locStr
                case .Spam:
                        return "Spam".locStr
                case .Recycle:
                        return "Trash".locStr
                case .AllMail:
                        return "AllMail".locStr
                case .Contact:
                        return "Contact".locStr
                case .Stamp:
                        return "Stamp".locStr
                case .Setting:
                        return "Setting".locStr
                case .Account:
                        return "Account".locStr
                case .BugReport:
                        return "BugReport".locStr
                case .Help:
                        return "Help".locStr
                }
        }
        
        public func IcoinName() ->(String, String){
                switch self {
                case .Inbox:
                        return ("inbox-icon", "inbox-icon")
                case .Draft:
                        return ("draft-icon", "draft-icon")
                case .Sent:
                        return ("sent-icon", "sent-icon")
                case .StarMail:
                        return ("menu_starred", "menu_starred-active")
                case .Archieved:
                        return ("menu_archive", "menu_archive-active")
                case .Spam:
                        return ("menu_spam", "menu_spam-active")
                case .Recycle:
                        return ("trash-icon", "trash-icon")
                case .AllMail:
                        return ("menu_allmail", "menu_allmail-active")
                case .Contact:
                        return ("cont-icon", "cont-icon")
                case .Stamp:
                        return ("stamp_icon", "stamp_icon")
                case .Setting:
                        return ("setting-icon", "setting-icon")
                case .Account:
                        return ("account", "account")
                case .BugReport:
                        return ("menu_bugs", "menu_bugs-active")
                case .Help:
                        return ("help-icon", "help-icon")
                }
        }
        
        public func ViewControllerID() ->String{
                switch self {
                case .Contact:
                        return "ContactViewController"
                case .Setting:
                        return "SettingViewController"
                case .Account:
                        return "AccountSettingViewController"
                case .BugReport:
                        return "BugReportViewController"
                case .Help:
                        return "HelpViewController"
                case .Stamp:
                        return "StampViewController"
                default:
                        return "InboxViewController"
                }
        }
}
