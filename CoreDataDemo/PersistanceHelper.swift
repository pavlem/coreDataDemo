import UIKit
import CoreData

enum PerError: Error {
    case persistance(error: Error)
    case userExists
    case userDoesNotExist
    case usersNotFetched
    case userNotFound
    case dbNotFound
    case noUsersFound
}

enum PerResult {
    case userSaved
    case userUpdated
    case usersPersisted
    case userDeleted
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
    func saveContext(success: () -> Void, fail: (Error) -> Void) {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
                success()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
//                let nserror = error as NSError
//                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
                fail(error)
            }
        }
    }

    static let userEntityName = "UserCD"

    // MARK: - API
    func save(user: UserModel, cb: ((Result<PerResult, PerError>) -> Void)) {
        // NSPersistentContainer
        let container = persistentContainer
        // NSManagedObjectContext
        let context = container.viewContext

        let entity = NSEntityDescription.entity(forEntityName: PersistanceHelper.userEntityName, in: context)!

        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entity.name!)
        fetchRequest.predicate = NSPredicate(format: "userId = \(user.id)")

        do {
            let results = try context.fetch(fetchRequest) as? [UserCD]
            
            guard results?.count == 0 else {
                cb(.failure(PerError.userExists))
                return
            }

            let newUser = UserCD(entity: entity, insertInto: context)
            newUser.username = user.username
            newUser.password = user.password
            newUser.age = user.age
            newUser.userId = user.id

            let petsData = try? JSONEncoder().encode(user.pets)
            newUser.pets = petsData

        } catch {
            cb(.failure(PerError.persistance(error: error)))
            return
        }

        saveContext {
            cb(.success(.userSaved))
        } fail: { (error) in
            cb(.failure(PerError.persistance(error: error)))
        }
    }

    func update(user: UserModel, cb: ((Result<PerResult, PerError>) -> Void)) {

        let container = persistentContainer
        let context = container.viewContext
        let entity = NSEntityDescription.entity(forEntityName: PersistanceHelper.userEntityName, in: context)!

        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entity.name!)
        fetchRequest.predicate = NSPredicate(format: "userId = \(user.id)")

        do {
            let results = try context.fetch(fetchRequest) as? [UserCD]

            guard results?.count != 0 else {
                cb(.failure(PerError.userDoesNotExist))
                return
            }

            // NSManagedObject - property approach
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

        } catch {
            cb(.failure(PerError.persistance(error: error)))
            return
        }

        saveContext {
            cb(.success(.userUpdated))
        } fail: { (error) in
            cb(.failure(PerError.persistance(error: error)))
        }
    }

    func saverOrUpdate(users: [UserModel], cb: ((Result<PerResult, PerError>) -> Void)) {

        for user in users {
            saveOrUpdate(user: user) { (result) in
                switch result {
                case .failure(let err):
                    cb(.failure(err))
                    return
                case .success(_):
                    print("saverOrUpdate success")
                }
            }
        }

        cb(.success(.usersPersisted))
    }

    func saveOrUpdate(user: UserModel, cb: ((Result<PerResult, PerError>) -> Void)) {
        // NSPersistentContainer
        let container = persistentContainer

        // NSManagedObjectContext
        let context = container.viewContext

        let entity = NSEntityDescription.entity(forEntityName: PersistanceHelper.userEntityName, in: context)!

        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entity.name!)
        fetchRequest.predicate = NSPredicate(format: "userId = \(user.id)")


        do {
            let results = try context.fetch(fetchRequest) as? [UserCD]

            guard results?.count != 0 else {

                save(user: user) { (result) in
                    cb(result)
                }
    //                    let reversePetsData = newUser.pets!
    //                    let petsReversed = try? JSONDecoder().decode([Pet].self, from: reversePetsData)
                return
            }

            update(user: user) { (result) in
                cb(result)
            }


        } catch {
            cb(.failure(PerError.persistance(error: error)))
        }
    }

    func fetchUsers(cb: ((Result<[UserModel], PerError>) -> Void)) {

        // NSPersistentContainer
        let container = persistentContainer

        // NSManagedObjectContext
        let context = container.viewContext

        let request = NSFetchRequest<NSFetchRequestResult>(entityName: PersistanceHelper.userEntityName)
        request.returnsObjectsAsFaults = false

        do {
            // NSManagedObject property approach

            guard let resultsUsersCD = try context.fetch(request) as? [UserCD], resultsUsersCD.count > 0 else {
                cb(.failure(PerError.usersNotFetched))
                return
            }

            var users = [UserModel]()

            for userCD in resultsUsersCD {

                let pets = try? JSONDecoder().decode([Pet].self, from: userCD.pets ?? Data())

                let userModel = UserModel(
                    id: userCD.userId ?? "",
                    username: userCD.username,
                    password: userCD.password,
                    age: userCD.age,
                    pets: pets
                )
                print(userCD.username ?? "")
                users.append(userModel)
            }

            cb(.success(users))

            // KVO
    //        let result = try context.fetch(request)
    //        for data in result as! [NSManagedObject] {
    //           print(data.value(forKey: "username") as! String)
    //        }

        } catch {
            print("fetchUsers Failed: \(error)")
            cb(.failure(PerError.persistance(error: error)))
        }
    }

    func fetchUser(forId userId: String, cb: ((Result<UserModel, PerError>) -> Void)) {

        let context = persistentContainer.viewContext

        let request = NSFetchRequest<NSFetchRequestResult>(entityName: PersistanceHelper.userEntityName)
        request.predicate = NSPredicate(format: "userId = %@", userId)
        request.returnsObjectsAsFaults = false

        do {
            let result = try context.fetch(request)
            guard result.count != 0 else { // At least one was returned
                cb(.failure(PerError.userNotFound))
                return
            }

            // NSManagedObject property approach
            let userCD = result[0] as! UserCD
            print(userCD.username ?? "")

            let pets = try? JSONDecoder().decode([Pet].self, from: userCD.pets ?? Data())

            let userModel = UserModel(
                id: userCD.userId ?? "",
                username: userCD.username,
                password: userCD.password,
                age: userCD.age,
                pets: pets
            )

            cb(.success(userModel))

            // KVO
    //        for data in result as! [NSManagedObject] {
    //           print(data.value(forKey: "username") as! String)
    //        }
        } catch {
            cb(.failure(PerError.persistance(error: error)))
        }
    }

    func dropDB(cb: @escaping ((Result<(), PerError>) -> Void)) {

        let datamodelName = "CoreDataDemo"
        let storeType = "sqlite"

        let url: URL = {
            let url = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0].appendingPathComponent("\(datamodelName).\(storeType)")

            if FileManager.default.fileExists(atPath: url.path) == false {
                cb(.failure(PerError.dbNotFound))
            }
            return url
        }()

        func loadStores() {
            persistentContainer.loadPersistentStores(completionHandler: { (nsPersistentStoreDescription, error) in
                if let error = error {
                    cb(.failure(PerError.persistance(error: error)))
                }
            })
        }

        func deleteAndRebuild() {
            try! persistentContainer.persistentStoreCoordinator.destroyPersistentStore(at: url, ofType: storeType, options: nil)

            loadStores()
        }

        deleteAndRebuild()
        cb(.success(()))
    }

    func filter(by userName: String, cb: ((Result<[UserModel], PerError>) -> Void)) {

        let context = persistentContainer.viewContext

        let request = NSFetchRequest<NSFetchRequestResult>(entityName: PersistanceHelper.userEntityName)
        request.predicate = NSPredicate(format: "username contains %@", userName)
        request.returnsObjectsAsFaults = false

        do {
            guard let result = try context.fetch(request) as? [UserCD], result.count != 0 else {
                cb(.failure(.noUsersFound))
                return
            }

            var usersLo = [UserModel]()

            for userCD in result {

                let pets = try? JSONDecoder().decode([Pet].self, from: userCD.pets ?? Data())

                let userModel = UserModel(
                    id: userCD.userId ?? "",
                    username: userCD.username,
                    password: userCD.password,
                    age: userCD.age,
                    pets: pets
                )

                usersLo.append(userModel)
            }

            cb(.success(usersLo))

            // KVO
    //        for data in result as! [NSManagedObject] {
    //           print(data.value(forKey: "username") as! String)
    //        }
        } catch {
            cb(.failure(PerError.persistance(error: error)))
        }
    }

    func deleteUser(userId: String, cb: ((Result<PerResult, PerError>) -> Void)) {

        let context = persistentContainer.viewContext

        let request = NSFetchRequest<NSFetchRequestResult>(entityName: PersistanceHelper.userEntityName)
        request.predicate = NSPredicate(format: "userId = %@", userId)
        request.returnsObjectsAsFaults = false

        do {
            let result = try context.fetch(request)

            guard result.count != 0 else {
                cb(.failure(.userDoesNotExist))
                return
            }

            for object in result {
                context.delete(object as! NSManagedObject)
            }

            // KVO
    //        for data in result as! [NSManagedObject] {
    //           print(data.value(forKey: "username") as! String)
    //        }
        } catch {
            cb(.failure(PerError.persistance(error: error)))
        }

        saveContext {
            cb(.success(.userDeleted))
        } fail: { (error) in
            cb(.failure(PerError.persistance(error: error)))
        }
    }
}
