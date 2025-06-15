import Foundation

struct MyDataItem: Identifiable, Equatable {
    let id = UUID() // ユニークなID
    var name: String
}
