import XCTest
import RxCocoa
import RxSwift
import RxTest
import SnapshotTesting
@testable import RxCleanApp

final class CountViewControllerTests: XCTestCase {
    private var disposeBag: DisposeBag!
    private var scheduler: TestScheduler!
    private var viewModel: CountViewModelMock!
    private var sut: CountViewController<CountViewModelMock>!
    
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
        scheduler = .init(initialClock: 0)
        viewModel = .init()
        sut = .init()
        sut.viewModel = viewModel
    }
    
    func testView() {
        viewModel.viewStateSubject.onNext(.init(countLabelText: "Hey Joe!"))
        assertSnapshot(matching: sut, as: .image)
        
        viewModel.viewStateSubject.onNext(.init(countLabelText: "999999 taps so far"))
        assertSnapshot(matching: sut, as: .image)
        
        viewModel.viewStateSubject.onNext(.init(countLabelText: ""))
        assertSnapshot(matching: sut, as: .image)
    }
}
