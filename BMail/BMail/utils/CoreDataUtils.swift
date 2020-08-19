//
//  CoreData.swift
//  BMail
//
//  Created by hyperorchid on 2020/4/27.
//  Copyright © 2020 NBS. All rights reserved.
//

import Foundation
import UIKit

import CoreData

public class CoreDataUtils: NSObject{
        
        public static var CDInst = CoreDataUtils()
        var context:NSManagedObjectContext!
        let coreDataManager = CoreDataManager(modelName: "BMail")
        
        private override init() {
//                let appDelegate = UIApplication.shared.delegate as! AppDelegate
                context = coreDataManager.managedObjectContext// appDelegate.persistentContainer.viewContext
        }
        
        open func findEntity(_ entityName: String, where w:NSPredicate? = nil) -> [AnyObject]?{
                let request = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
                request.predicate = w
                let result: [AnyObject]?
                do {
                        result = try self.context.fetch(request)
                } catch let error as NSError {
                        print(error)
                        result = nil
                }
                return result
        }
        
        open func findLimitedEntity(_ entityName: String, limit:Int, sortBy:[NSSortDescriptor]? = nil, where w:NSPredicate? = nil) -> [AnyObject]?{
                let request = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
                request.predicate = w
                request.fetchLimit = limit
                request.sortDescriptors = sortBy
                let result: [AnyObject]?
                do {
                        result = try self.context.fetch(request)
                } catch let error as NSError {
                        print(error)
                        result = nil
                }
                return result
        }
        
        open func findOneEntity(_ entityName: String, where w:NSPredicate? = nil) -> AnyObject? {
                
                let request = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
                request.fetchLimit = 1
                request.predicate = w
                
                let result: AnyObject?
                do {
                        let ret = try context.fetch(request)
                        return ret.last as AnyObject?
                } catch let error as NSError {
                        print(error)
                        result = nil
                }
                return result
        }
        
        
        open func saveContext() {
                if let moc = context {
                        if moc.hasChanges {
                                do {
                                        try moc.save()
                                } catch let err{
                                        NSLog("=======>+++++context save err:\(err.localizedDescription)")
                                }
                        }
                }
        }
        
        open func syncContext(obj:NSManagedObject) {
                if let moc = context {
                        moc.refresh(obj, mergeChanges: true)
                }
        }
        
        open func syncAllContext() {
                if let moc = context {
                        moc.refreshAllObjects()
                }
        }
        
        open func newEntity<T>(_ entityName: String, fillDataAction:((inout T)->Void)? = nil) -> T?{
                
                let entity = NSEntityDescription.entity(forEntityName: entityName, in: context)
                guard  let e = entity else {
                        return nil
                }
                
                guard var newObj = NSManagedObject(entity: e, insertInto: context) as? T else{
                        return nil
                }
                
                fillDataAction?(&newObj)
                
                return newObj
        }
        
        open func Counter(_ entityName: String, where w:NSPredicate? = nil) -> Int{
                let request = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
                request.predicate = w
                do { return try self.context.count(for: request)}catch let err{
                        print(err)
                        return 0
                }
        }
        
        open func Remove(_ entityName: String, where w:NSPredicate? = nil){
                
                let request = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
                request.predicate = w
                
                if let result = try? context.fetch(request) as? [NSManagedObject]{
                        for object in result {
                                context.delete(object)
                        }
                }
        }
        
        open func updateOrInsert<T>(_ entityName: String, where w:NSPredicate, updateField:((inout T)->Void))->T?{
                       
                let request = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
                request.predicate = w
                request.fetchLimit = 1
                       
                guard let result = try? context.fetch(request) else{
                        return nil
                }
                
                if result.count == 0{
                        let entity = NSEntityDescription.entity(forEntityName: entityName, in: context)
                        guard  let e = entity else {
                                return nil
                        }
                        
                        guard var newObj = NSManagedObject(entity: e, insertInto: context) as? T else{
                                return nil
                        }
                        updateField(&newObj)
                        return newObj
                }
                
                guard var oldObj = result.last as? T else{
                        return nil
                }
                
                updateField(&oldObj)
                return oldObj
        }
}
