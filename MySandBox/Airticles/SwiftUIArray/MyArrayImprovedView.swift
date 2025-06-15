import SwiftUI

struct MyArrayImprovedView: View {
    @State private var items: [MyDataItem] = [
        MyDataItem(name: "りんご"),
        MyDataItem(name: "バナナ"),
        MyDataItem(name: "みかん")
    ]

    var body: some View {
        VStack {
            ForEach(items) { item in // Identifiableなのでidを省略できる
                MyImprovedCustomItemView(data: item)
            }
            Button("項目を追加") {
                items.append(MyDataItem(name: "ぶどう"))
            }
            Button("最初の項目名を変更") {
                if !items.isEmpty {
                    items[0].name = "新しいりんご" // これが後述のワナ！
                }
            }
        }
    }
}
