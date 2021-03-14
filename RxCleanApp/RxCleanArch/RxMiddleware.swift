import Foundation
import RxSwift
import RxCocoa

/// A middleware dispatches effects as a result of events taking into account the current state
protocol RxMiddleware {
    /// An event represents external signals that triggers state changes or side-effects
    associatedtype Event
    
    /// An effect represents state changes.
    associatedtype Effect
    
    /// An State represents the current interactor state.
    associatedtype State
    
    /// The middleware recevies event updates from this PublishSubject
    var event: PublishSubject<Event> { get }
    
    /// Effects produced by this Middleware
    var effect: Observable<Effect> { get }
    
    /// The middleware recevies state updates from this PublishSubject
    var state: PublishSubject<State> { get }
    
    var disposeBag: DisposeBag { get }
}

/// A type-erased Middleware
final class AnyRxMiddleware<Event, Effect, State>: RxMiddleware {
    let event: PublishSubject<Event>
    let effect: Observable<Effect>
    let state: PublishSubject<State>
    let disposeBag: DisposeBag
    private let middleware: Any
    
    init<M: RxMiddleware>(_ middleware: M) where M.Event == Event,
                                                 M.Effect == Effect,
                                                 M.State == State {
        self.event = middleware.event
        self.effect = middleware.effect
        self.state = middleware.state
        self.disposeBag = middleware.disposeBag
        self.middleware = middleware
    }
}
