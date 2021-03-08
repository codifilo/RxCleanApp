import Foundation
import RxSwift
import RxCocoa

protocol CountViewModel: RxViewModel where
    ViewEvent == CountViewEvent,
    ViewState == CountViewState,
    Interactor.State == CountState,
    Interactor.Effect == CountEffect,
    Interactor.Event == CountEvent {
    
    var interactor: Interactor { get }
}

struct CountViewModelImplementation<Interactor: CountInteractor>: CountViewModel {
    let viewEvent = PublishSubject<CountViewEvent>()
    
    let disposeBag = DisposeBag()
    
    let interactor: Interactor
    
    let router: CountRouter
    
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
    
    func didChange(state: CountState) {
        switch state.count {
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
    }
}