import UIKit
import CoreData

enum PersistanceError: Error {
    case persistance(error: Error)
    case articleExists
    case articleDoesNotExists
//    case userDoesNotExist
//    case usersNotFetched
//    case userNotFound
//    case dbNotFound
//    case noUsersFound
}

enum PersistanceResult {
    case articlePersisted
    case articlesPersisted
    case articleUpdated
//    case userUpdated
//    case usersPersisted
//    case userDeleted
}


class PersistanceController {

    static var shared = PersistanceController()

    // MARK: - Core Data stack
    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
        */
        let container = NSPersistentContainer(name: "Articles")

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

    static let articleEntityName = "Article"


    func save(article: Article, cb: ((Result<PersistanceResult, PersistanceError>) -> Void)) {
        // NSPersistentContainer
        let container = persistentContainer
        // NSManagedObjectContext
        let context = container.viewContext

        let entity = NSEntityDescription.entity(forEntityName: PersistanceController.articleEntityName, in: context)!

        let articleId = article.id!
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entity.name!)
        fetchRequest.predicate = NSPredicate(format: "articleId = \(articleId)")

        do {
            let results = try context.fetch(fetchRequest) as? [ArticleMO]

            guard results?.count == 0 else {
                cb(.failure(PersistanceError.articleExists))
                return
            }

            let newArticle = ArticleMO(entity: entity, insertInto: context)
            newArticle.articleId = article.id
            newArticle.articleDescription = article.description

        } catch {
            cb(.failure(PersistanceError.persistance(error: error)))
            return
        }

        saveContext {
            cb(.success(PersistanceResult.articlePersisted))
        } fail: { (error) in
            cb(.failure(PersistanceError.persistance(error: error)))
        }
    }



    func update(article: Article, cb: ((Result<PersistanceResult, PersistanceError>) -> Void)) {

        let container = persistentContainer
        let context = container.viewContext
        let entity = NSEntityDescription.entity(forEntityName: PersistanceController.articleEntityName, in: context)!


        let articleId = article.id!

        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entity.name!)
        fetchRequest.predicate = NSPredicate(format: "articleId = \(articleId)")


        do {
            let results = try context.fetch(fetchRequest) as? [ArticleMO]

            guard results?.count != 0 else {
                cb(.failure(.articleDoesNotExists))
                return
            }

            // NSManagedObject - property approach
            let oldArticle = results?[0]
            oldArticle?.articleId = article.id
            oldArticle?.articleDescription = article.description

            // NSManagedObject
            // KVO approach
//                results[0].setValue(yourValueToBeSet, forKey: "yourCoreDataAttribute")

        } catch {
            cb(.failure(PersistanceError.persistance(error: error)))
            return
        }

        saveContext {
            cb(.success(PersistanceResult.articleUpdated))
        } fail: { (error) in
            cb(.failure(PersistanceError.persistance(error: error)))
        }
    }

    func saverOrUpdate(articles: [Article], cb: ((Result<PersistanceResult, PersistanceError>) -> Void)) {

        for article in articles {

            saveOrUpdate(article: article) { (result) in
                switch result {
                case .failure(let err):
                    cb(.failure(err))
                    return
                case .success(_):
                    print("saverOrUpdate success")
                }
            }
        }

        cb(.success(PersistanceResult.articlesPersisted))
    }

    func saveOrUpdate(article: Article, cb: ((Result<PersistanceResult, PersistanceError>) -> Void)) {
        // NSPersistentContainer
        let container = persistentContainer

        // NSManagedObjectContext
        let context = container.viewContext

        let entity = NSEntityDescription.entity(forEntityName: PersistanceController.articleEntityName, in: context)!

        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entity.name!)

        let articleId = article.id!
        fetchRequest.predicate = NSPredicate(format: "articleId = \(articleId)")


        do {
            let results = try context.fetch(fetchRequest) as? [ArticleMO]

            guard results?.count != 0 else {

                save(article: article) { (result) in
                    cb(result)
                }
                return
            }

            update(article: article) { (result) in
                cb(result)
            }


        } catch {
            cb(.failure(PersistanceError.persistance(error: error)))
        }
    }

}
