import SwiftUI

struct MyArrayFixedView: View {
    @State private var items: [MyDataItem] = [
        MyDataItem(name: "りんご"),
        MyDataItem(name: "バナナ"),
        MyDataItem(name: "みかん")
    ]
    @ObservedObject var observedObject =  MyArrayFixedObervableObject()

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
                    items[0].name = "新しいりんご"
                }
            }

            ForEach(observedObject.items) { item in
                MyImprovedCustomItemView(data: item)
            }
            Button("項目を追加") {
                observedObject.items.append(MyDataItem(name: "ぶどう"))
            }
            Button("最初の項目名を変更 (修正版)") {
                if !observedObject.items.isEmpty {
                    if !observedObject.items.isEmpty {
                        observedObject.update()
                    }
                }
            }
        }
    }
}

@MainActor final class MyArrayFixedObervableObject: ObservableObject {
    @Published var items: [MyDataItem] = [
        MyDataItem(name: "りんご"),
        MyDataItem(name: "バナナ"),
        MyDataItem(name: "みかん")
    ]

    init() {}

    func update() {
        if !items.isEmpty {
            items[0].name = "新しいりんご"
        }
    }
}
