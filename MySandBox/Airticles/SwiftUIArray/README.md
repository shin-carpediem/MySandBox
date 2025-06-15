# この内容は正しく無いことがわかった。

- `MyDataItem`がclassじゃなくてstructなので、このパターンでもちゃんと再描画してくれる。
- `@Published` on class だと、そうはいかないのだと思う。
- SwiftUI.Viewの中に`@Stateでstructを指定したら、それは再描画可能なclassになるっぽい。

---

もちろんです！SwiftUIのViewの配列に関するブログ記事を、ご指定のブログの文体に合わせ、コード例を交えながら作成しますね。

---

## 【SwiftUIの落とし穴？】Viewの配列を扱うときに気をつけたい再描画のワナ

皆さん、こんにちは！STMNテックブログ編集部です。

SwiftUI、楽しいですよね！サクッとUIが組めて、リアクティブな挙動が気持ちいい。でも、ちょっと込み入ったUIを組もうとすると、「あれ、なんで再描画されないの！？」と頭を抱えること、ありませんか？

今回は、SwiftUIのViewの配列を扱う際に、特にハマりやすい「再描画のワナ」について、具体的なコードを交えながら解説していきたいと思います。これを知っておけば、あなたのSwiftUIライフはもっと快適になるはず！

### その1：「配列内のViewが分離されてないと再描画できない」問題

まずはこちら。「配列の中にViewを直接突っ込んで、それが更新されたら再描画されるでしょ？」と思いきや、そう簡単にはいかないケースがあるんです。

例えば、こんなコードを考えてみましょう。

```swift
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
```

このコードでは、`items`配列に新しい要素を追加すると、`ForEach`が検知して新しい`Text`が表示されます。これは期待通りの挙動ですね。

では、もし`Text`ではなく、少し複雑なカスタムViewを配列に入れたらどうなるでしょうか？

```swift
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
```

このコードを実行して、「項目を追加」ボタンを押してみてください。新しい`MyCustomItemView`は表示されますが、既存の`MyCustomItemView`の中にある`counter`の状態は保持されたままで、再描画によってリセットされたりすることはありません。これは一見すると正しい挙動に見えます。

しかし、もし`MyCustomItemView`が`name`の値に応じて表示を完全に再構築する必要がある場合、問題が発生します。`ForEach`は`id`によって各Viewを識別し、変更がないと判断されたViewは再利用される傾向があるため、内部の状態に依存しない変更が検知されにくいのです。

**ポイントは、配列の要素が変更されたときに、`ForEach`が各要素を「新しいView」として再構築するかどうかです。**

もし配列の要素が、`Equatable`に準拠していて、かつその値が変更されたら、`ForEach`はそれを検知して再構築します。しかし、単にViewのインスタンスが再生成されても、SwiftUIの内部的な最適化によって、実際のUIが再描画されないことがあるんです。

この問題を避けるためには、**配列の各要素がユニークなIDを持ち、そのIDが変更された場合にのみViewが再構築されるようにする**のが定石です。

例えば、カスタムのデータ構造を用意し、`Identifiable`プロトコルに準拠させる方法です。

```swift
import SwiftUI

struct MyDataItem: Identifiable, Equatable {
    let id = UUID() // ユニークなID
    var name: String
    // MyDataItemの変更を検知するためにEquatableにも準拠
    static func == (lhs: MyDataItem, rhs: MyDataItem) -> Bool {
        lhs.id == rhs.id && lhs.name == rhs.name
    }
}

struct MyImprovedCustomItemView: View {
    let data: MyDataItem // データを受け取る
    @State private var counter: Int = 0

    var body: some View {
        HStack {
            Text(data.name)
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
```

このコードでは、`MyDataItem`が`Identifiable`になっているため、`ForEach(items)`だけでOKです。そして、「項目を追加」ボタンを押すと、やはり新しいアイテムが追加されます。

### その2：「配列の内部の値更新では再描画できない」問題

さて、先ほどの`MyArrayImprovedView`のコードに、「最初の項目名を変更」ボタンを追加しました。

このボタンを押すとどうなるでしょうか？

驚くことに、`items[0].name = "新しいりんご"`という行で`MyDataItem`の`name`プロパティを更新しても、**画面上の「りんご」は「新しいりんご」にはなりません！**

これが「配列の内部の値更新では再描画できない」問題です。

なぜこんなことが起きるのでしょうか？

SwiftUIは、`@State`で宣言されたプロパティが変更されたときに、Viewの`body`プロパティを再評価します。しかし、`items[0].name`のように、**配列の要素の内部のプロパティを直接変更しても、配列そのものが新しい配列に置き換わったわけではないため、`@State`は変更を検知してくれないのです。**

Swiftの構造体は値型なので、`items[0]`は配列のコピーです。そのコピーの`name`プロパティを変更しても、元の配列の`items[0]`が指すデータは変わっていません。SwiftUIから見れば、`items`配列は「変更されていない」と判断されてしまうわけです。

では、どうすればこの問題を解決できるのでしょうか？

答えは、**配列の要素を更新する際には、新しい配列として再代入する**ことです。

```swift
import SwiftUI

// MyDataItemとMyImprovedCustomItemViewは上記と同じ

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
```

これでどうでしょう？「最初の項目名を変更 (修正版)」ボタンを押すと、無事に「りんご」が「新しいりんご」に変わったはずです！

ポイントは、`items = updatedItems` の行です。これで`@State`が管理する`items`プロパティ自体が新しい配列に置き換わるため、SwiftUIが変更を検知し、`body`プロパティが再評価され、対応するViewが再描画されるのです。

### まとめ

SwiftUIでViewの配列を扱う際には、以下の2点に注意すると、再描画に関する悩みがぐっと減ります。

1.  **配列内のViewが分離されてないと再描画できない（特に内部状態を持つカスタムViewの場合）**:
    * `ForEach`に渡すデータは`Identifiable`に準拠させ、各要素がユニークなIDを持つようにしましょう。
    * カスタムViewは、データ（値型）を受け取るように設計し、そのデータが変更されたら再描画されるようにしましょう。

2.  **配列の内部の値更新では再描画できない**:
    * 配列の要素のプロパティを更新する際は、**配列全体を新しいものとして再代入**しましょう。
    * これにより、`@State`が変更を検知し、Viewの再描画がトリガーされます。

SwiftUIは宣言的UIで非常にパワフルですが、その裏側にあるデータフローの仕組みを理解しておくと、よりスムーズに開発を進めることができます。

今回の内容が、皆さんのSwiftUI開発の一助となれば幸いです！それでは、また次回のブログでお会いしましょう！

---
