import Foundation
import SwiftyJSON
import RxTest
import RxSwift

/// Helpers to calculate human readable diffs to be used in unit tests fail messages
extension Encodable  {
    
    /// Returns the empty string if both values are equal.
    /// Otherwise returns which object attributes are different
    func calculateDiff(with other: Self) -> String {
        let encoder = JSONEncoder()
        guard let json1 = (try? encoder.encode(self))
                .flatMap({ try? JSON(data: $0) }),
              let json2 = (try? encoder.encode(other))
                .flatMap({ try? JSON(data: $0) }) else {
            return "Encoding Error"
        }
        
        return "\nDiff: " + calculateDiff(json1, json2, path: String(describing: type(of: self)))
    }
    
    private func calculateDiff(_ param1: JSON?, _ param2: JSON?, path: String) -> String {
        guard let json1 = param1, let json2 = param2 else {
            if param1 != nil && param2 == nil {
                return "\n\(path) missing from second paramater"
            }
            if param1 == nil && param2 != nil {
                return "\n\(path) missing from first paramater"
            }
            return ""
        }
        
        guard json1.type == json2.type else {
            return "\n\(path) types are different '\(json1.type)' != '\(json2.type)'"
        }
        
        switch json1.type {
        case .number, .string, .bool:
            return calculateValueDiff(json1, json2, path: path)
        case .array:
            return calculateArrayDiff(json1, json2, path: path)
        case .dictionary:
            return calculateDictDiff(json1, json2, path: path)
        case .null:
            return ""
        case .unknown:
            return "\n\(path): Unknown"
        }
    }
    
    private func calculateValueDiff(_ json1: JSON, _ json2: JSON, path: String) -> String {
        guard json1.stringValue == json2.stringValue else {
            return "\n\(path): \(String(describing: json1.type).capitalized) -> " +
                "'\(json1.stringValue)' != '\(json2.stringValue)'"
        }
        return ""
    }
    
    private func calculateArrayDiff(_ json1: JSON, _ json2: JSON, path: String) -> String {
        guard let array1 = json1.array,
              let array2 = json2.array else {
            return "\n\(path) Missing array"
        }
        
         var result = ""
         if array1.count == array2.count {
             let zippedArray = zip(array1, array2)
             for (index, (child1, child2)) in zippedArray.enumerated() {
                 result += calculateDiff(child1, child2, path: "\(path)[\(index)]")
             }
         } else {
             let set1 = Set(array1.map(String.init))
             let set2 = Set(array2.map(String.init))
             let missingItemsIn2 = set1.subtracting(set2)
             let missingItemsIn1 = set2.subtracting(set1)
             if !missingItemsIn1.isEmpty {
                 result += "\n\(path) missing items in first param '\(missingItemsIn1.joined(separator: ", "))'"
             }
             if !missingItemsIn2.isEmpty {
                 result += "\n\(path) missing items in second param '\(missingItemsIn2.joined(separator: ", "))'"
             }
         }
         return result
    }
    
    private func calculateDictDiff(_ json1: JSON, _ json2: JSON, path: String) -> String {
        guard let dict1 = json1.dictionary,
              let dict2 = json2.dictionary else {
            return "\n\(path) Missing dictionaries"
        }
        
        let keys1 = Set(dict1.keys)
        let keys2 = Set(dict2.keys)
        
        var result = ""
        
        let commonKeys = keys1.intersection(keys2)
        for key in commonKeys {
            let value1 = dict1[key]
            let value2 = dict2[key]
            result += calculateDiff(value1, value2, path: "\(path).\(key)")
        }
        
        let missingKeysIn1 = keys2.subtracting(keys1)
        if !missingKeysIn1.isEmpty {
            result += "\n\(path) missing keys in first param '\(missingKeysIn1.joined(separator: ", "))' "
        }
        
        let missingKeysIn2 = keys1.subtracting(keys2)
        if !missingKeysIn2.isEmpty {
            result += "\n\(path) missing keys in second param '\(missingKeysIn2.joined(separator: ", "))' "
        }
        
        return result
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
