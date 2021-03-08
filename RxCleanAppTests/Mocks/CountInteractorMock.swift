import Foundation
import RxSwift
import RxCocoa
@testable import RxCleanApp

struct CountInteractorMock: CountInteractor {
    let event = PublishSubject<CountEvent>()
    
    let state = BehaviorRelay<CountState>(value: .empty)
    
    var initialState: CountState = .empty
    
    let disposeBag = DisposeBag()
    
    var handleEventClousure: (CountEvent) -> Observable<CountEffect> = { _ in .empty() }
    
    var reduceClosure: (CountState, CountEffect) -> CountState = { _, _ in .empty }
    
    func handle(event: CountEvent) -> Observable<CountEffect> {
        handleEventClousure(event)
    }
    
    func reduce(state: CountState, effect: CountEffect) -> CountState {
        reduceClosure(state, effect)
    }
}
