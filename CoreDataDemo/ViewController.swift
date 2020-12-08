import UIKit
import CoreData

// MOC data
let usersLocal = [
    UserModel(id: "11", username: "Paja 111_111", password: "111", age: "1", pets: pets),
    UserModel(id: "12", username: "Pera 222_222", password: "222", age: "2", pets: pets),
    UserModel(id: "13", username: "Gaja 333", password: "333", age: "3", pets: pets),
    UserModel(id: "14", username: "Vlaja 444", password: "333", age: "3", pets: pets),
    UserModel(id: "15", username: "Paja 555_555", password: "555", age: "5", pets: pets)
]

let pets = [Pet(type: "Dog"), Pet(type: "Cat"), Pet(type: "Turtle")]

// MODELS
struct UserModel: Codable {
    let id: String
    let username: String
    let password: String
    let age: String
    let pets: [Pet]
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
//        for user in usersLocal {
//            PersistanceHelper.shared.saveOrUpdate(user: user)
//        }

//        PersistanceHelper.shared.saverOrUpdate(users: usersLocal)

//        PersistanceHelper.shared.filter(by: "Pera")
//        PersistanceHelper.shared.fetchUser(forId: "15")
//        PersistanceHelper.shared.fetchUsers()
//        PersistanceHelper.shared.dropDB()

//        PersistanceHelper.shared.deleteUser(userId: "17")

//        let user = UserModel(id: "16", username: "Gaja update", password: "ddd", age: "12", pets: pets)
//        PersistanceHelper.shared.update(user: user)
//        PersistanceHelper.shared.save(user: user)
    }
}

