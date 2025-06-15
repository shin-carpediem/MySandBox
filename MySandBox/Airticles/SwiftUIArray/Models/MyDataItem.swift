import Foundation

struct MyDataItem: Identifiable, Equatable {
    let id = UUID() // ユニークなID
    var name: String
    // MyDataItemの変更を検知するためにEquatableにも準拠
    static func == (lhs: MyDataItem, rhs: MyDataItem) -> Bool {
        lhs.id == rhs.id && lhs.name == rhs.name
    }
}
