import Foundation
import RxSwift
import RxCocoa
@testable import RxCleanApp

struct CountViewModelMock: CountViewModel {
    let viewEvent = PublishSubject<CountViewEvent>()
    let viewStateSubject = PublishSubject<CountViewState>()
    
    var viewState: Driver<CountViewState> {
        viewStateSubject.asDriver(onErrorJustReturn: .empty)
    }
    
    func setupBindings() {}
}
