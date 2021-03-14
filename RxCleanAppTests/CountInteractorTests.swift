import XCTest
import RxCocoa
import RxSwift
import RxTest
import SnapshotTesting
@testable import RxCleanApp

final class CountInteractorTests: XCTestCase {
    private var disposeBag: DisposeBag!
    private var repository: CountRepositoryMock!
    private var scheduler: TestScheduler!
    private var sut: RxInteractor<CountEvent, CountEffect, CountState>!
    
    override func setUp() {
        super.setUp()
        isRecording = false
        disposeBag = .init()
        repository = .init()
        scheduler = .init(initialClock: 0)
        sut = RxInteractor(
            AnyRxMiddleware(CountMiddleware(countRepository: repository)),
            countReducer,
            .empty
        )
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
        
        assertSnapshot(matching: result.events.map(RecordedValue.init), as: .json)
    }
}
