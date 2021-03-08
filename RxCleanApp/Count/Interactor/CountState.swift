import Foundation

struct CountState: Equatable, Encodable {
    var count: Int
    
    static var empty: CountState {
        return .init(count: 0)
    }
}
