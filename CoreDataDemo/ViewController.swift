import UIKit
import CoreData

// MOC data
let usersLocal = [
    UserModel(id: "11", username: "Paja 111", password: "111", age: "1", pets: pets),
    UserModel(id: "12", username: "Pera 222_222", password: "222", age: "2", pets: pets),
    UserModel(id: "13", username: "Gaja 333", password: "333", age: "3", pets: pets),
    UserModel(id: "14", username: "Vlaja 444", password: "333", age: "3", pets: pets),
    UserModel(id: "15", username: "Paja 555", password: "555", age: "5", pets: pets)
]

let pets = [Pet(type: "Dog"), Pet(type: "Cat"), Pet(type: "Turtle")]

// MODELS
struct UserModel: Codable {
    let id: String
    let username: String?
    let password: String?
    let age: String?
    let pets: [Pet]?
}

struct Pet: Codable {
    let type: String
}

// LOGIC
class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

//        let stringPath = Bundle.main.path(forResource: "catalog", ofType: "json")
//        let urlPath = URL(fileURLWithPath: stringPath!)
//        let articlesData = try? Data(contentsOf: urlPath)
//        let articles = try? JSONDecoder().decode([Article].self, from: articlesData!)


        //AppDelegate
        //======================================

//        PersistanceHelper.shared.filter(by: "Pera")
//        PersistanceHelper.shared.dropDB()
//        PersistanceHelper.shared.deleteUser(userId: "17")



        // fetchUsers users
        // ===========
        PersistanceHelper.shared.fetchUser(forId: "15") { (result) in
            switch result {
            case .failure(let err):
                print(err)
            case .success(let user):
                print(user)
            }
        }

        // fetchUsers users
        // ===========
//        PersistanceHelper.shared.fetchUsers { (result) in
//            switch result {
//            case .failure(let err):
//                print(err)
//            case .success(let users):
//                print(users)
//            }
//        }

        // saverOrUpdate users
        // ===========
//        PersistanceHelper.shared.saverOrUpdate(users: usersLocal) { (result) in
//            switch result {
//            case .failure(let err):
//                print(err)
//            case .success(let status):
//                print(status)
//            }
//        }

        // update user
        // ============
//        let user = UserModel(id: "18", username: "Gaja update 1122", password: "ddd", age: "12", pets: pets)
//        PersistanceHelper.shared.update(user: user) { (result) in
//            switch result {
//            case .failure(let err):
//                print(err)
//            case .success(()):
//                print("update success")
//            }
//        }

        // Save user
        // ============
//        PersistanceHelper.shared.save(user: user) { (result) in
//            switch result {
//            case .failure(let err):
//                print(err)
//            case .success(()):
//                print("save success")
//            }
//        }
    }
}

