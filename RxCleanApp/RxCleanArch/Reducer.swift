import Foundation

/// Reducer is a pure function wrapped in a container, that takes an effect and the current state to calculate the new state.
struct Reducer<Effect, State> {
    typealias ReduceFunction = (Effect, State) -> State
    
    let reduce: ReduceFunction
    
    init(_ function: @escaping ReduceFunction) {
        self.reduce = function
    }
    
    init(r1: Reducer<Effect, State>, r2: Reducer<Effect,State>) {
        self.reduce = { effect, state in
            r2.reduce(effect, r1.reduce(effect, state))
        }
    }
}

infix operator <>
extension Reducer {
    static func <> (lhs: Reducer<Effect, State>,
                    rhs: Reducer<Effect, State>) -> Reducer<Effect, State> {
        Reducer { effect, state in
            rhs.reduce(effect, lhs.reduce(effect, state))
        }
    }
    
    static var identity: Reducer<Effect, State> {
        .init { _, state in state }
    }
}
