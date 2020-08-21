//
//  AppDelegate.swift
//  BMail
//
//  Created by hyperorchid on 2020/4/24.
//  Copyright © 2020 NBS. All rights reserved.
//

import UIKit
import CoreData
import BmailLib

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

        var window: UIWindow?
        var timer:Timer?

        func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
                
                window = UIWindow(frame: UIScreen.main.bounds)
                var initialVC:UIViewController!
                AccountManager.initSys()
                BmailLibInitSystem(self, true)
                MailManager.loadCounter()
                BmailContact.LoadContact()
                StampWallet.LoadWallet()
                if AccountManager.mailAccounts.count > 0{
                        initialVC = ContainerViewController()
                }else{
                        initialVC = UIStoryboard.viewController(name: "SignInNaviViewController")
                }
                
                self.window?.rootViewController = initialVC
                self.window?.makeKeyAndVisible()

                return true
        }

        
        func applicationWillResignActive(_ application: UIApplication) {
//                self.timer = Timer.scheduledTimer(withTimeInterval: Constants.TimerCheckInterval, repeats: true) { (timer) in
//                        Wallet.CheckTimeOut()
//                }
        }
        
        func applicationDidEnterBackground(_ application: UIApplication) {
                self.timer?.invalidate()
        }
        
        func applicationWillTerminate(_ application: UIApplication) {
                CoreDataUtils.CDInst.saveContext()
        }
}

extension AppDelegate:BmailLibUICallBackProtocol{
        
        func error(_ typ: Int, msg: String?) {
                 print("======>typ=>\(typ) message:=>\(msg ?? "<->")")
        }
        
        
        func notification(_ typ: Int, msg: String?) {
                switch typ {
                case 0:
                        print(msg ?? "<->")
                default:
                        print("======>unknown notification")
                }
        }
}
