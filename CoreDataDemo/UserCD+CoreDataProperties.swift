//
//  UserCD+CoreDataProperties.swift
//  CoreDataDemo
//
//  Created by Pavle Mijatovic on 07/12/2020.
//  Copyright © 2020 Shashikant Jagtap. All rights reserved.
//
//

import Foundation
import CoreData


extension UserCD {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<UserCD> {
        return NSFetchRequest<UserCD>(entityName: "UserCD")
    }

    @NSManaged public var age: String?
    @NSManaged public var password: String?
    @NSManaged public var userId: String?
    @NSManaged public var username: String?
    @NSManaged public var pets: Data?

}
