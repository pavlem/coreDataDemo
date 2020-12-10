import UIKit

class ArticlesVC: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        let stringPath = Bundle.main.path(forResource: "catalog", ofType: "json")
        let urlPath = URL(fileURLWithPath: stringPath!)
        let articlesData = try? Data(contentsOf: urlPath)
        let articles = try? JSONDecoder().decode([Article].self, from: articlesData!)
        print(articles)


        PersistanceController.shared.saverOrUpdate(articles: articles!) { (result) in
            switch result {
            case .failure(let err):
                print(err)
            case .success(let status):
                print(status)
            }
        }



//        PersistanceHelper.shared.saverOrUpdate(users: usersLocal) { (result) in
//            switch result {
//            case .failure(let err):
//                print(err)
//            case .success(let status):
//                print(status)
//            }
//        }


        
    }
}
