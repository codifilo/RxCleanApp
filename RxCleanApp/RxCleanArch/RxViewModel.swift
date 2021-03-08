import Foundation
import RxSwift
import RxCocoa

/// A ViewModel transforms an interactor state changes into a ViewState
/// including only the formatted data needed by a view
protocol RxViewModel {
    /// An event represents every event (user actions, view lifecycle...).
    associatedtype ViewEvent
    
    /// A ViewState represents the current state of a view.
    associatedtype ViewState: Equatable
    
    /// The interactor that contains the state and events to transform
    associatedtype Interactor: RxInteractor
    
    /// The event from the view. Bind user inputs to this subject.
    var viewEvent: PublishSubject<ViewEvent> { get }
    
    /// Interactor which this view model uses to transform its events and state
    var interactor: Interactor {  get }
    
    /// Transforms a view event into an interactor event
    func transform(viewEvent: ViewEvent) -> Interactor.Event?
    
    /// Transforms an interactor state into a view state
    func transform(state: Interactor.State) -> ViewState
    
    var disposeBag: DisposeBag { get }
}

extension RxViewModel {
    /// Setup bindings.
    /// Call this function when you are ready to send view events and receive view state updates
    func setupBindings() {
        interactor.setupBindings()
        
        // Send transformed events to interactor
        viewEvent
            .compactMap(transform(viewEvent:))
            .bind(to: interactor.event)
            .disposed(by: disposeBag)
    }
    
    /// View state updates ready to be consumed by a view
    var viewState: Driver<ViewState> {
        // Transform interactor state into view state
        interactor
            .state
            .map(transform(state:))
            .asDriver(onErrorDriveWith: .empty())
    }
}
