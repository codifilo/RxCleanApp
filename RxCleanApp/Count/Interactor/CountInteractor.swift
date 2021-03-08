import Foundation
import RxSwift
import RxCocoa

protocol CountInteractor: RxInteractor where
    Event == CountEvent,
    State == CountState,
    Effect == CountEffect {}

struct CountInteractorImplementation: CountInteractor {
    let event = PublishSubject<CountEvent>()
    let state = BehaviorRelay<CountState>(value: .empty)
    let initialState = CountState.empty
    let countRepository: CountRepository
    let disposeBag = DisposeBag()
    
    func handle(event: CountEvent) -> Observable<CountEffect> {
        switch event {
        case .load:
            return processLoadEvent()
        case .incrementCount:
            return processIncrementCountEvent()
        }
    }
    
    private func processLoadEvent() -> Observable<CountEffect> {
        countRepository
            .retrieve()
            .asObservable()
            .compactMap(Effect.setCount)
    }
    
    private func processIncrementCountEvent() -> Observable<CountEffect> {
        Observable.just(.incrementCount)
    }
    
    private func storeIncrement() {
        countRepository
            .store(value: state.value.count + 1)
            .subscribe(onCompleted: { })
            .disposed(by: disposeBag)
    }
    
    func reduce(state: CountState, effect: CountEffect) -> CountState {
        var newState = state
        switch effect {
        case .setCount(let newCount):
            newState.count = newCount
        case .incrementCount:
            newState.count += 1
        }
        return newState
    }
}
