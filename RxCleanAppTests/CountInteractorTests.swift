import XCTest
import RxCocoa
import RxSwift
import RxTest
@testable import RxCleanApp

final class CountInteractorTests: XCTestCase {
    private var disposeBag: DisposeBag!
    private var router: CountRouterMock!
    private var repository: CountRepositoryMock!
    private var scheduler: TestScheduler!
    private var sut: CountInteractorImplementation!
    
    override func setUp() {
        super.setUp()
        disposeBag = .init()
        router = .init()
        repository = .init()
        scheduler = .init(initialClock: 0)
        sut = .init(countRepository: repository, router: router)
        sut.setupBindings()
    }
    
    func testLoadPreviousCountAndTapSixTimes() {
        // Set a previous value in the repository
        repository.retrieveReturnValue = Single
            .just(9)
            .delay(.seconds(10), scheduler: scheduler)
        
        // View Events
        let events: [Recorded<Event<CountEvent>>] = [
            .init(time: 100, value: .next(.load)),
            .init(time: 200, value: .next(.incrementCount)),
            .init(time: 300, value: .next(.incrementCount)),
            .init(time: 400, value: .next(.incrementCount)),
            .init(time: 500, value: .next(.incrementCount)),
            .init(time: 600, value: .next(.incrementCount)),
            .init(time: 700, value: .next(.incrementCount)),
        ]
        scheduler.createColdObservable(events)
            .subscribe(onNext: sut.event.onNext)
            .disposed(by: disposeBag)
        
        // Collect events sent to interactor
        let result = scheduler.createObserver(CountState.self)
        sut.state.bind(to: result).disposed(by: disposeBag)
        
        scheduler.start()
        
        // Compare with expected result
        let expectedResult: [Recorded<Event<CountState>>] = [
            .init(time: 0, value: .next(.init(count: 0))),
            .init(time: 110, value: .next(.init(count: 9))),
            .init(time: 200, value: .next(.init(count: 10))),
            .init(time: 300, value: .next(.init(count: 11))),
            .init(time: 400, value: .next(.init(count: 12))),
            .init(time: 500, value: .next(.init(count: 13))),
            .init(time: 600, value: .next(.init(count: 14))),
            .init(time: 700, value: .next(.init(count: 15)))
        ]
        assertEquals(result.events, expectedResult)
        
        // Check it shows the alert message one time
        XCTAssertEqual(router.showAlertCallCount, 1)
    }
}
