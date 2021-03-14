import Foundation

struct CountViewState: Equatable, Encodable {
    let countLabelText: String?
    
    static var empty: CountViewState {
        .init(countLabelText: "")
    }
}
