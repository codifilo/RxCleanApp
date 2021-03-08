import Foundation

protocol UpdatableLayout {
    associatedtype Layout
    
    var layout: Layout { get }
    
    func updateLayout()
}
