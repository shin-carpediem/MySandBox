import Foundation

struct MyDataItem: Identifiable, Equatable {
    let id = UUID() // ユニークなID
    var name: String
    var fullName: FullName?

    struct FullName: Equatable {
        var first: String
        var last: String
    }
}
