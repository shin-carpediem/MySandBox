// import CachedAsyncImage
import SwiftUI

struct HudeImagesView: View {
    var body: some View {
        ScrollView {
            LazyVStack {
                ForEach(1..<100) { _ in
                    // CachedAsyncImage(url: URL(string: "https://picsum.photos/100?random\(UUID())"))
                }
            }
        }
    }
}

#Preview {
    HudeImagesView()
}
