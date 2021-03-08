import Foundation
import UIKit

protocol CountViewFactory {
    func createView() -> UIViewController
}

struct CountViewFactoryImplementation: CountViewFactory {
    func createView() -> UIViewController {
        let view = CountViewController<CountViewModelImplementation<CountInteractorImplementation>>()
        
        view.viewModel = CountViewModelImplementation(
            interactor: CountInteractorImplementation(
                countRepository: CountUserDefaultsRepository()
            ), router: CountRouterImplementation(view: view)
        )
        
        return view
    }
}
