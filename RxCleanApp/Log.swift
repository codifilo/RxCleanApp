import Foundation

public enum Log {}

// MARK: - Public

public extension Log {
    static func d(tag: @autoclosure () -> String = "",
                  _ msg: @autoclosure () -> String = "",
                  _ item: @autoclosure () -> Any? = nil,
                  functionName: StaticString = #function,
                  fileName: StaticString = #file,
                  lineNumber: Int = #line) {
        #if DEBUG
        debugPrint(format(.debug, tag(), msg(), item(), fileName, lineNumber))
        #endif
    }
    
    static func e(tag: @autoclosure () -> String = "",
                  _ msg: @autoclosure () -> String = "",
                  _ item: @autoclosure () -> Any? = nil,
                  functionName: StaticString = #function,
                  fileName: StaticString = #file,
                  lineNumber: Int = #line) {
        debugPrint(format(.error, tag(), msg(), item(), fileName, lineNumber))
    }
    
    static func e(tag: @autoclosure () -> String = "",
                  _ msg: @autoclosure () -> String,
                  _ error: @autoclosure () -> Error,
                  functionName: StaticString = #function,
                  fileName: StaticString = #file,
                  lineNumber: Int = #line) {
        debugPrint(format(.error, tag(), msg(), error(), fileName, lineNumber))
    }
    
    static func `do`(functionName: StaticString = #function,
                     fileName: StaticString = #file,
                     lineNumber: Int = #line,
                     _ block: (() throws -> Void)) {
        do {
            try block()
        } catch {
            Log.e("",
                  error,
                  functionName: functionName,
                  fileName: fileName,
                  lineNumber: lineNumber)
        }
    }
}

// MARK: - Private

private extension Log {
    private enum Level: String {
        case debug = "D"
        case error = "E"
    }
    
    private static var dateFormatter = { () -> DateFormatter in
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss"
        return formatter
    }()
    
    private static var now: String {
        return dateFormatter.string(from: Date())
    }
    
    private static func format(_ level: Level,
                               _ tag: String,
                               _ msg: String,
                               _ item: Any?,
                               _ fileName: StaticString,
                               _ lineNumber: Int) -> String {
        "\(now)" +
            "|\(level.rawValue)" +
            "|M=\(Thread.current.isMainThread ? "T" : "F")" +
            "|\(String(fileName).lastPathComponent.withoutExtension):\(lineNumber)" +
            (!tag.isEmpty
                ? "|\(tag)"
                : "") +
            (!msg.isEmpty
                ? "|\(msg)"
                : "") +
            (item
                .map { "|\(String(describing: $0))" }
                ?? "")
    }
}

// MARK: - Helpers

private extension String {
    var withoutExtension: String {
        guard let index = self.lastIndex(of: ".") else { return self }
        return String(prefix(upTo: index))
    }
    
    var lastPathComponent: String {
        return (self as NSString).lastPathComponent
    }
    
    init(_ staticString: StaticString) {
        self = staticString.withUTF8Buffer {
            String(decoding: $0, as: UTF8.self)
        }
    }
}

