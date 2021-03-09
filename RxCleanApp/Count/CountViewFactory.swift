import Foundation
import UIKit

struct CountViewFactory: ViewFactory {
    func createView() -> UIViewController {
        let view = CountViewController<CountViewModelImplementation<CountInteractorImplementation>>()
        
        view.viewModel = CountViewModelImplementation(
            interactor: CountInteractorImplementation(
                countRepository: CountUserDefaultsRepository()
            ),
            router: CountRouterImplementation(view: view)
        )
        
        return view
    }
}
