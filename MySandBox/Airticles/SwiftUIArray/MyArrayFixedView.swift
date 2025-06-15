import SwiftUI

struct MyArrayFixedView: View {
    @State private var items: [MyDataItem] = [
        MyDataItem(name: "りんご"),
        MyDataItem(name: "バナナ"),
        MyDataItem(name: "みかん")
    ]

    var body: some View {
        VStack {
            ForEach(items) { item in
                MyImprovedCustomItemView(data: item)
            }
            Button("項目を追加") {
                items.append(MyDataItem(name: "ぶどう"))
            }
            Button("最初の項目名を変更 (修正版)") {
                if !items.isEmpty {
                    var updatedItems = items // 配列をコピー
                    updatedItems[0].name = "新しいりんご" // コピーの要素を変更
                    items = updatedItems // 変更した配列を再代入
                }
            }
        }
    }
}
