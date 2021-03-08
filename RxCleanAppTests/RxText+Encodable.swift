import Foundation
import RxTest
import RxSwift
import XCTest

func prettyPrint<E: Equatable & Encodable>(_ list: [Recorded<Event<E>>]) -> String {
    list.map { "=> Recorded Event @ \($0.time) \n\($0.value.element?.prettyPrint ?? "na")" }
        .joined(separator: "\n")
}

func assertEquals<E: Equatable & Encodable>(_ lhs: [Recorded<Event<E>>],
                                            _ rhs: [Recorded<Event<E>>]) {
    guard lhs.count == rhs.count else {
        return XCTFail("Expected Results:\n\(prettyPrint(lhs))")
    }
    for index in 0 ..< lhs.count {
        let diff = calculateDiff(lhs[index], rhs[index])
        XCTAssert(diff.isEmpty, diff)
    }
}


/// Returns the empty string if both values are equal.
/// Otherwise returns which object attributes are different
func calculateDiff<E: Equatable & Encodable>(_ recorded1: Recorded<Event<E>>,
                                             _ recorded2: Recorded<Event<E>>) -> String {
    guard recorded1.time == recorded2.time else {
        return "\nDifferent event times '\(recorded1.time)' != '\(recorded2.time)'"
    }
    
    let element1 = recorded1.value.event.element
    let element2 = recorded2.value.event.element
    guard element1 != element2 else {
        return ""
    }
    if let element1 = element1,
       let element2 = element2 {
        return "\nDifferent elements at time=\(recorded1.time)" + element1.calculateDiff(with: element2)
    } else if element1 == nil {
        return "\nMissing event element 1"
    } else {
        return "\nMissing event element 2"
    }
}
