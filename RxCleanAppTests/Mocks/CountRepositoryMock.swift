import Foundation
import RxSwift
@testable import RxCleanApp

final class CountRepositoryMock: CountRepository {
    var storeReturnValue: Completable = .empty()
    var retrieveReturnValue: Single<Int> = .just(0)
    
    func store(value: Int) -> Completable {
        storeReturnValue
    }
    
    func retrieve() -> Single<Int> {
        retrieveReturnValue
    }
}
