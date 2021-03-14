import Foundation
import UIKit

struct CountViewFactory: ViewFactory {
    func createView() -> UIViewController {
        let view = CountViewController<CountViewModelImplementation>()
        
        view.viewModel = CountViewModelImplementation(
            interactor: RxInteractor(
                AnyRxMiddleware(CountMiddleware(countRepository: CountUserDefaultsRepository())),
                countReducer,
                .empty
            ),
            router: CountRouterImplementation(view: view)
        )
        
        return view
    }
}
