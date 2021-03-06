import XCTest
import RxCocoa
import RxSwift
import RxTest
import SnapshotTesting
@testable import RxCleanApp

final class CountViewModelTests: XCTestCase {
    private var disposeBag: DisposeBag!
    private var router: CountRouterMock!
    private var interactor: RxInteractor<CountEvent, CountEffect, CountState>!
    private var sut: CountViewModelImplementation!
    private var repository: CountRepositoryMock!
    private var scheduler: TestScheduler!

    override func setUp() {
        super.setUp()
        isRecording = false
        disposeBag = .init()
        router = .init()
        scheduler = .init(initialClock: 0)
        router = .init()
        repository = .init()
        interactor = .init(AnyRxMiddleware(CountMiddleware(countRepository: repository)),
                           countReducer,
                           .empty)
        sut = .init(interactor: interactor, router: router)
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
        let result = scheduler.createObserver(CountViewState.self)
        sut.viewState.drive(result).disposed(by: disposeBag)
        
        scheduler.start()
        
        assertSnapshot(matching: result.events.map(RecordedValue.init), as: .json)
        
        // Check it shows the alert message one time
        XCTAssertEqual(router.showAlertCallCount, 2)
    }
}
