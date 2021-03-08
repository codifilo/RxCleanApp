import Foundation
import RxSwift
@testable import RxCleanApp

final class CountRouterMock: CountRouter {
    var showAlertCallCount = 0
    
    func showAlert(title: String, message: String) {
        showAlertCallCount += 1
    }
}

