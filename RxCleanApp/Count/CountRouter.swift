import Foundation
import UIKit

protocol CountRouter {
    func showAlert(title: String, message: String)
}

final class CountRouterImplementation: CountRouter {
    private weak var view: UIViewController?
    
    init(view: UIViewController) {
        self.view = view
    }
    
    func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok",
                                      style: .cancel,
                                      handler: nil))
        view?.present(alert, animated: true, completion: nil)
    }
}
