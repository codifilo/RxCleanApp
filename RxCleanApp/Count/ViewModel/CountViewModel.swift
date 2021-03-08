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
