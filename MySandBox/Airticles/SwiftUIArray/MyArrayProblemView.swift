import SwiftUI

struct MyArrayProblemView: View {
    @State private var items: [String] = ["りんご", "バナナ", "みかん"]

    var body: some View {
        VStack {
            // MyCustomItemViewを直接生成
            ForEach(items, id: \.self) { item in
                MyCustomItemView(name: item)
            }
            Button("項目を追加") {
                items.append("ぶどう")
            }
        }
    }
}
