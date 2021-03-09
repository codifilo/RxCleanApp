import UIKit
import RxSwift
import RxCocoa

protocol RxView: AnyObject {
    associatedtype BindingModel: RxBasicViewModel

    /// A view's viewModel. `bind(viewModel:)` gets called when the new value is assigned to this property.
    var viewModel: BindingModel? { get set }
    
    /// Creates RxSwift bindings. This method is called each time the `viewModel` is assigned.
    func bind(viewModel: BindingModel)
    
    var disposeBag: DisposeBag { get }
}

extension RxView where Self: UIViewController {
    /// Setup view and viewModel bindings. Call this method in your view is loaded and ready
    func setupBindings() {
        guard let viewModel = viewModel else {
            return assertionFailure("ViewModel not available")
        }
        viewModel.setupBindings()
        bind(viewModel: viewModel)
    }
    
    /// Binds a view state property to UI element binder
    func bind<T: Equatable>(_ transformState: @escaping (BindingModel.ViewState) -> T,
                            to binder: Binder<T>) {
        viewModel?.viewState
            .map(transformState)
            .distinctUntilChanged()
            .drive(binder)
            .disposed(by: disposeBag)
    }
}

extension KeyPath {
    var asOptional: (Root) -> Value? {
        return { $0[keyPath: self] }
    }
}
