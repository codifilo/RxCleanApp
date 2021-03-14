import Foundation

let countReducer = Reducer<CountEffect, CountState> { effect, state in
    var newState = state
    switch effect {
    case .setCount(let newCount):
        newState.count = newCount
    case .incrementCount:
        newState.count += 1
    }
    return newState
}
