import XCTest
import RxCocoa
import RxSwift
import RxTest
@testable import RxCleanApp

final class CountViewModelTests: XCTestCase {
    private var disposeBag: DisposeBag!
    private var router: CountRouterMock!
    private var interactor: CountInteractorMock!
    private var sut: CountViewModelImplementation<CountInteractorMock>!
    private var scheduler: TestScheduler!
    
    override func setUp() {
        super.setUp()
        disposeBag = .init()
        router = .init()
        interactor = .init()
        scheduler = .init(initialClock: 0)
        sut = .init(interactor: interactor)
        sut.setupBindings()
    }
    
    func testViewEvents() {
        // View Events
        let viewEvents: [Recorded<Event<CountViewEvent>>] = [
            .init(time: 100, value: .next(.viewDidLoad)),
            .init(time: 200, value: .next(.didTapButton)),
            .init(time: 300, value: .next(.didTapButton)),
            .init(time: 400, value: .next(.didTapButton)),
        ]
        
        scheduler.createColdObservable(viewEvents)
            .subscribe(onNext: sut.viewEvent.onNext)
            .disposed(by: disposeBag)
        
        // Collect events sent to interactor
        let resultEvents = scheduler.createObserver(CountEvent.self)
        interactor.event.bind(to: resultEvents).disposed(by: disposeBag)
        
        scheduler.start()
        
        // Compare with expected result
        let expectedResult: [Recorded<Event<CountEvent>>] = [
            .init(time: 100, value: .next(.load)),
            .init(time: 200, value: .next(.incrementCount)),
            .init(time: 300, value: .next(.incrementCount)),
            .init(time: 400, value: .next(.incrementCount)),
        ]
        XCTAssertEqual(resultEvents.events, expectedResult)
    }
    
    func testViewState() {
        // Interactor state changes
        let stateChanges: [Recorded<Event<CountState>>] = [
            .init(time: 100, value: .next(.init(count: 5))),
            .init(time: 200, value: .next(.init(count: 199))),
            .init(time: 300, value: .next(.init(count: 38742))),
        ]
        
        scheduler.createColdObservable(stateChanges)
            .subscribe(onNext: interactor.state.accept)
            .disposed(by: disposeBag)
        
        // Collect view states
        let viewStates = scheduler.createObserver(CountViewState.self)
        sut.viewState.drive(viewStates).disposed(by: disposeBag)
        
        scheduler.start()
        
        // Compare with expected result
        let expectedResult: [Recorded<Event<CountViewState>>] = [
            .init(time: 0, value: .next(.init(countLabelText: "0 taps so far"))),
            .init(time: 100, value: .next(.init(countLabelText: "5 taps so far"))),
            .init(time: 200, value: .next(.init(countLabelText: "199 taps so far"))),
            .init(time: 300, value: .next(.init(countLabelText: "38742 taps so far"))),
        ]
        XCTAssertEqual(viewStates.events.count, expectedResult.count)
        for index in 0 ..< viewStates.events.count {
            let diff = calculateDiff(viewStates.events[index], expectedResult[index])
            XCTAssert(diff.isEmpty, diff)
        }
    }
}
