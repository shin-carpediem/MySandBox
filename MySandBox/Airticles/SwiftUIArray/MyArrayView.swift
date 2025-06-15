import SwiftUI

struct MyArrayView: View {
    @State private var items: [String] = ["りんご", "バナナ", "みかん"]

    var body: some View {
        VStack {
            ForEach(items, id: \.self) { item in
                Text(item) // そのままTextを表示
            }
            Button("項目を追加") {
                items.append("ぶどう")
            }
        }
    }
}
