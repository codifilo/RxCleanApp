import Foundation
import RxSwift

protocol CountRepository {
    func store(value: Int) -> Completable
    func retrieve() -> Single<Int>
}

struct CountUserDefaultsRepository: CountRepository {
    private let storeKey = "count_key"
    
    func store(value: Int) -> Completable {
        Completable.create { promise in
            UserDefaults.standard.set(value, forKey: storeKey)
            promise(.completed)
            return Disposables.create()
        }.subscribe(on: MainScheduler.asyncInstance)
    }
    
    func retrieve() -> Single<Int> {
        Single.create { promise in
            let value = UserDefaults.standard.integer(forKey: storeKey)
            promise(.success(value))
            return Disposables.create()
        }.subscribe(on: MainScheduler.asyncInstance)
    }
}
