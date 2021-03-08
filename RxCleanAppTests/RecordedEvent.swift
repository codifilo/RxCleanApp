//
//  RecordedEvent.swift
//  RxCleanAppTests
//
//  Created by Agus on 8/3/21.
//

import Foundation
import RxTest
import RxSwift

struct RecordedValue<V: Encodable>: Encodable {
    let time: Int
    let value: V?
    
    init(_ recording: Recorded<Event<V>>) {
        self.time = recording.time
        self.value = recording.value.element
    }
}
