import Foundation
import RxSwift
import RxCocoa

final class CountMiddleware: RxMiddleware {
    let countRepository: CountRepository
    
    let event = PublishSubject<CountEvent>()
    
    var effect: Observable<CountEffect> {
        effectSubject.asObservable()
    }
    
    let state = PublishSubject<CountState>()
    
    let disposeBag = DisposeBag()
    
    private let effectSubject = PublishSubject<CountEffect>()
    
    init(countRepository: CountRepository) {
        self.countRepository = countRepository
        
        // Handle state changes
        state
            .skip(2)
            .map(\.count)
            .distinctUntilChanged()
            .flatMap { [weak self] in
                self?.countRepository.store(value: $0) ?? .empty()
            }.subscribe()
            .disposed(by: disposeBag)
        
        
        // Handle events
        event
            .flatMap { [weak self] in
                self?.handle(event: $0) ?? .empty()
            }.bind(to: effectSubject)
            .disposed(by: disposeBag)
    }
    
    private func handle(event: CountEvent) -> Observable<CountEffect> {
        switch event {
        case .load:
            return countRepository
                .retrieve()
                .asObservable()
                .compactMap(Effect.setCount)
        case .incrementCount:
            return Observable
                .just(.incrementCount)
        }
    }
}
