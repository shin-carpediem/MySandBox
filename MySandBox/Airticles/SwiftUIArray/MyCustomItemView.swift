import SwiftUI

struct MyCustomItemView: View {
    let name: String
    @State private var counter: Int = 0 // 内部で状態を持つ

    var body: some View {
        HStack {
            Text(name)
            Spacer()
            Text("カウント: \(counter)")
            Button("+") {
                counter += 1
            }
        }
        .padding()
        .border(Color.gray)
    }
}
