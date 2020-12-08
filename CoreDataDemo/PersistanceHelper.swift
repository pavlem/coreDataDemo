import UIKit
import CoreData

enum PersistanceError: Error {
    case persistance(error: Error)
    case internalReason
}


class PersistanceHelper {

    static var shared = PersistanceHelper()

    // MARK: - Core Data stack
    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
        */
        let container = NSPersistentContainer(name: "CoreDataDemo")

        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.

                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()

    // MARK: - Core Data Saving support
    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }

    static let userEntityName = "UserCD"

    // MARK: - API
    func save(user: UserModel) {
        let container = persistentContainer
        let context = container.viewContext
        let entity = NSEntityDescription.entity(forEntityName: "UserCD", in: context)!

        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entity.name!)
        fetchRequest.predicate = NSPredicate(format: "userId = \(user.id)")

        do {
            let results = try context.fetch(fetchRequest) as? [UserCD]

            if results?.count != 0 { // At least one was returned
                print("user exists....")

            } else {
                print("user created....")

                let newUser = UserCD(entity: entity, insertInto: context)
                newUser.username = user.username
                newUser.password = user.password
                newUser.age = user.age
                newUser.userId = user.id

                let petsData = try? JSONEncoder().encode(user.pets)
                newUser.pets = petsData
            }
        } catch {

//            PersistanceError.persistance(error: error)
            print("Fetch Failed: \(error)")
        }

        saveContext()
    }

    func update(user: UserModel) {
        let container = persistentContainer
        let context = container.viewContext
        let entity = NSEntityDescription.entity(forEntityName: PersistanceHelper.userEntityName, in: context)!

        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entity.name!)
        fetchRequest.predicate = NSPredicate(format: "userId = \(user.id)")

        do {
            let results = try context.fetch(fetchRequest) as? [UserCD]

            if results?.count != 0 { // At least one was returned

                // NSManagedObject
                // property approach
                let oldUser = results?[0]
                oldUser?.username = user.username
                oldUser?.password = user.password
                oldUser?.age = user.age
                oldUser?.userId = user.id

                let petsData = try? JSONEncoder().encode(user.pets)
                oldUser?.pets = petsData

                // NSManagedObject
                // KVO approach
    //                results[0].setValue(yourValueToBeSet, forKey: "yourCoreDataAttribute")
            }
        } catch {
            print("Update Failed: \(error)")
        }

        saveContext()
    }

    func saverOrUpdate(users: [UserModel]) {
        for user in users {
            saveOrUpdate(user: user)
        }
    }

    func saveOrUpdate(user: UserModel) {
        // NSPersistentContainer
        let container = persistentContainer

        // NSManagedObjectContext
        let context = container.viewContext

        let entity = NSEntityDescription.entity(forEntityName: PersistanceHelper.userEntityName, in: context)!

        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entity.name!)
        fetchRequest.predicate = NSPredicate(format: "userId = \(user.id)")

        do {
            let results = try context.fetch(fetchRequest) as? [UserCD]

            if results?.count != 0 { // At least one was returned

                // NSManagedObject
                // property approach
                let oldUser = results?[0]
                oldUser?.username = user.username
                oldUser?.password = user.password
                oldUser?.age = user.age
                oldUser?.userId = user.id

                let petsData = try? JSONEncoder().encode(user.pets)
                oldUser?.pets = petsData

                // NSManagedObject
                // KVO approach
    //                results[0].setValue(yourValueToBeSet, forKey: "yourCoreDataAttribute")

            } else {
                let newUser = UserCD(entity: entity, insertInto: context)
                newUser.username = user.username
                newUser.password = user.password
                newUser.age = user.age
                newUser.userId = user.id

                let petsData = try? JSONEncoder().encode(user.pets)
                newUser.pets = petsData

    //                    let reversePetsData = newUser.pets!
    //                    let petsReversed = try? JSONDecoder().decode([Pet].self, from: reversePetsData)
            }
        } catch {
            print("S or U Failed: \(error)")
        }

        saveContext()
    }

    func fetchUsers() {

        // NSPersistentContainer
        let container = persistentContainer

        // NSManagedObjectContext
        let context = container.viewContext

        let request = NSFetchRequest<NSFetchRequestResult>(entityName: PersistanceHelper.userEntityName)
        request.returnsObjectsAsFaults = false

        do {
            // NSManagedObject property approach
            if let resultsUsersCD = try context.fetch(request) as? [UserCD] {
                for user in resultsUsersCD {
                    print(user.username ?? "")
                }
            }

            // KVO
    //        let result = try context.fetch(request)
    //        for data in result as! [NSManagedObject] {
    //           print(data.value(forKey: "username") as! String)
    //        }

        } catch {
            print("fetchUsers Failed: \(error)")
        }
    }

    func fetchUser(forId userId: String) {

        let context = persistentContainer.viewContext

        let request = NSFetchRequest<NSFetchRequestResult>(entityName: PersistanceHelper.userEntityName)
        request.predicate = NSPredicate(format: "userId = %@", userId)
        request.returnsObjectsAsFaults = false

        do {
            let result = try context.fetch(request)

            // NSManagedObject property approach
            if result.count != 0 { // At least one was returned
                let userCD = result[0] as! UserCD
                print(userCD.username ?? "")
            }

            // KVO
    //        for data in result as! [NSManagedObject] {
    //           print(data.value(forKey: "username") as! String)
    //        }
        } catch {
            print("fetchUser Failed: \(error)")
        }
    }

    func dropDB() {
        let datamodelName = "CoreDataDemo"
        let storeType = "sqlite"

        let url: URL = {
            let url = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0].appendingPathComponent("\(datamodelName).\(storeType)")

            assert(FileManager.default.fileExists(atPath: url.path))

            return url
        }()

        func loadStores() {
            persistentContainer.loadPersistentStores(completionHandler: { (nsPersistentStoreDescription, error) in
                if let error = error {
                    fatalError(error.localizedDescription)
                }
            })
        }

        func deleteAndRebuild() {
            try! persistentContainer.persistentStoreCoordinator.destroyPersistentStore(at: url, ofType: storeType, options: nil)

            loadStores()
        }

        deleteAndRebuild()
    }

    func filter(by userName: String) {

        let context = persistentContainer.viewContext


        let request = NSFetchRequest<NSFetchRequestResult>(entityName: PersistanceHelper.userEntityName)
//        request.predicate = NSPredicate(format: "username = %@", userName)

        request.predicate = NSPredicate(format: "username contains %@", userName)

        request.returnsObjectsAsFaults = false

        do {
            let result = try context.fetch(request)

            // NSManagedObject property approach
            if result.count != 0 { // At least one was returned

                for user in result as! [UserCD] {
                    print(user.username ?? "")
                }
            }

            // KVO
    //        for data in result as! [NSManagedObject] {
    //           print(data.value(forKey: "username") as! String)
    //        }
        } catch {
            print("filter Failed: \(error)")
        }
    }




    func deleteUser(userId: String) {
        let context = persistentContainer.viewContext

        let request = NSFetchRequest<NSFetchRequestResult>(entityName: PersistanceHelper.userEntityName)
        request.predicate = NSPredicate(format: "userId = %@", userId)
        request.returnsObjectsAsFaults = false

        do {
            let result = try context.fetch(request)

            // NSManagedObject property approach
            if result.count != 0 { // At least one was returned

                for object in result {
                    context.delete(object as! NSManagedObject)
                }

//                let userCD = result[0] as! UserCD
//                print("user: \(userCD.username ?? "")")
//                context.delete(userCD)
//                print("user: \(userCD.username ?? "")")
//                print("")
            }

            // KVO
    //        for data in result as! [NSManagedObject] {
    //           print(data.value(forKey: "username") as! String)
    //        }
        } catch {
            print("deleteUser Failed: \(error)")
        }

        saveContext()
    }
}
