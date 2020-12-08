import UIKit
import CoreData


class PersistanceHelper {

    static var shared = PersistanceHelper()

    func save(user: UserModel) {
        // Reference to C.D.S
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let container = appDelegate.persistentContainer
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
            print("Fetch Failed: \(error)")
        }

        do {
            try context.save()
        } catch {
            print("Failed saving: \(error)")
        }

    }

    func update(user: UserModel) {
        // Reference to C.D.S
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let container = appDelegate.persistentContainer
        let context = container.viewContext
        let entity = NSEntityDescription.entity(forEntityName: "UserCD", in: context)!

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
            print("Fetch Failed: \(error)")
        }

        do {
            try context.save()
        } catch {
            print("Failed saving: \(error)")
        }
    }


    func saveOrUpdate(user: UserModel) {

        // Reference to C.D.S
        let appDelegate = UIApplication.shared.delegate as! AppDelegate

        // NSPersistentContainer
        let container = appDelegate.persistentContainer

        // NSManagedObjectContext
        let context = container.viewContext

        let entity = NSEntityDescription.entity(forEntityName: "UserCD", in: context)!

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
            print("Fetch Failed: \(error)")
        }

        do {
            try context.save()
        } catch {
            print("Failed saving: \(error)")
        }
    }

    func fetchUsers() {

        // Reference to C.D.S
        let appDelegate = UIApplication.shared.delegate as! AppDelegate

        // NSPersistentContainer
        let container = appDelegate.persistentContainer

        // NSManagedObjectContext
        let context = container.viewContext

        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "UserCD")
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

        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext

        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "UserCD")
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


        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let persistentContainer = appDelegate.persistentContainer



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

        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext


        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "UserCD")
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
            print("fetchUser Failed: \(error)")
        }


    }

    func deleteUser(userId: String) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext

        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "UserCD")
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
            print("fetchUser Failed: \(error)")
        }


        do {
            try context.save()
        } catch {
            print("Failed saving: \(error)")
        }

    }

}
