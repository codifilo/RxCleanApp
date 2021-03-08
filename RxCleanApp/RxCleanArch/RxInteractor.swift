import Foundation
import RxSwift
import RxCocoa

/// Contains the business logic as specified by a use case
protocol RxInteractor {
    /// An event represents external signals that triggers state changes or side-effects
    associatedtype Event
    
    /// An effect represents state changes.
    associatedtype Effect
    
    /// An State represents the current interactor state.
    associatedtype State: Equatable

    /// Events coming in from the outside.
    var event: PublishSubject<Event> { get }
    
    /// The state stream. Use this observable to observe the state changes.
    var state: BehaviorRelay<State> { get }
    
    /// The initial state.
    var initialState: State { get }
    
    var disposeBag: DisposeBag { get }
    
    /// Generates an effect from the event.
    /// This is the best place to perform side-effects such as async tasks.
    func handle(event: Event) -> Observable<Effect>
    
    /// Generates a new state with the previous state and the action. It should be purely functional
    /// so it should not perform any side-effects here. This method is called every time when the
    /// effect is committed.
    func reduce(state: State, effect: Effect) -> State
}

extension RxInteractor {
    /// Setup internal bindings.
    /// Call this function when you are ready to send events and receive state updates.
    func setupBindings() {
        let resultEffect = event.flatMap { event -> Observable<Effect> in
            handle(event: event).catch { _ in .empty() }
        }
        
        let performEffects = resultEffect
            .scan(initialState, accumulator: reduce(state: effect: ))
            .catch { _ in .empty() }
            .startWith(initialState)
        
        let transformedState = performEffects
            .do(onNext: state.accept)
            .replay(1)
        
        transformedState
            .connect()
            .disposed(by: disposeBag)
    }
}
