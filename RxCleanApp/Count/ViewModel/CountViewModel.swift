import Foundation
import RxSwift
import RxCocoa

protocol CountViewModel: RxBasicViewModel where
    ViewEvent == CountViewEvent,
    ViewState == CountViewState {}

typealias CountInteractor = RxInteractor<CountEvent, CountEffect, CountState>

struct CountViewModelImplementation: RxViewModel, CountViewModel {
    let viewEvent = PublishSubject<CountViewEvent>()
    
    let disposeBag = DisposeBag()
    
    let interactor: CountInteractor
    
    let router: CountRouter
    
    init(interactor: CountInteractor, router: CountRouter) {
        self.interactor = interactor
        self.router = router
        
        viewEvent
            .subscribe(onNext: { _ in
                switch interactor.state.value.count {
                case 4:
                    router.showAlert(title: "Warning",
                                     message: "You're tapping too much")
                case 9:
                    router.showAlert(title: "Last Warning",
                                     message: "Are you trying to set a world record?. Take it easy. ")
                case let x where x > 19:
                    router.showAlert(title: "FUCK OFF!",
                                     message: "")
                default:
                    break
                }
            })
            .disposed(by: disposeBag)
    }
    
    func transform(viewEvent: CountViewEvent) -> CountEvent? {
        switch viewEvent {
        case .viewDidLoad:
            return .load
        case .didTapButton:
            return .incrementCount
        }
    }
    
    func transform(state: CountState) -> CountViewState {
        CountViewState(
            countLabelText: "\(state.count) taps so far"
        )
    }
}
