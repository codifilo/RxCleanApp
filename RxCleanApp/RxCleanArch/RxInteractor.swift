import Foundation
import RxSwift
import RxCocoa

/// Contains the business logic as specified by a use case
/// An event represents external signals that triggers state changes or side-effects
/// An effect represents state changes.
/// An State represents the current interactor state.
struct RxInteractor<Event, Effect, State> {
    
    /// Events coming in from the outside.
    let event = PublishSubject<Event>()
    
    /// Generates an effect from the event.
    /// This is the best place to perform side-effects such as async tasks.
    let middleware: AnyRxMiddleware<Event, Effect, State>
    
    /// Generates a new state with the previous state and the action. It should be purely functional
    /// so it should not perform any side-effects here. This method is called every time when the
    /// effect is committed.
    let reducer: Reducer<Effect, State>
    
    /// The state stream. Use this observable to observe the state changes.
    let state: BehaviorRelay<State>
    
    private let disposeBag = DisposeBag()
    
    init(_ middleware: AnyRxMiddleware<Event, Effect, State>,
         _ reducer: Reducer<Effect, State>,
         _ initialState: State) {
        
        self.middleware = middleware
        self.reducer = reducer
        self.state = BehaviorRelay<State>(value: initialState)
        
        // Send states to middleware
        state
            .bind(to: middleware.state)
            .disposed(by: disposeBag)
        
        // Send events to middleware
        event
            .bind(to: middleware.event)
            .disposed(by: disposeBag)
        
        // Perform effects from middleware
        let performEffects = middleware.effect
            .scan(initialState, accumulator: {
                state, effect in reducer.reduce(effect, state)  
            }).catch { _ in .empty() }
            .startWith(initialState)
        
        // Notify state updates
        let transformedState = performEffects
            .do(onNext: state.accept)
            .replay(1)
        
        transformedState
            .connect()
            .disposed(by: disposeBag)
    }
}
