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
    private var sut: CountInteractorImplementation!
    
    override class func setUp() {
        super.setUp()

        // This is a global flag, if it's `true`, when the test runs it'll create a reference jsons
        // instead of check the assertions.
        // When the reference jsons have been generated, this flag should be `false`.
        isRecording = false
    }
    
    override func setUp() {
        super.setUp()
        disposeBag = .init()
        repository = .init()
        scheduler = .init(initialClock: 0)
        sut = .init(countRepository: repository)
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
        
        let times = result.events.map(\.time)
        assertSnapshot(matching: times, as: .json)
        let elements = result.events.compactMap(\.value.element)
        assertSnapshot(matching: elements, as: .json)
    }
}
