import SwiftUI

struct MyImprovedCustomItemView: View {
    let data: MyDataItem // データを受け取る
    @State private var counter: Int = 0

    var body: some View {
        HStack {
            Text(data.name)
            Text(data.fullName?.first ?? "")
            Text(data.fullName?.last ?? "")
            Spacer()
            Text("カウント: \(counter)")
            Button("+") {
                counter += 1
            }
        }
        .padding()
        .border(Color.green)
    }
}
