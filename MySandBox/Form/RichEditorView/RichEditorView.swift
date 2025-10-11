import SwiftUI
import MarkdownUI

struct RichEditorView: View {
    @State private var text: String = ""
    @State private var showImagePicker = false
    @State private var showPreview = false

    var body: some View {
        ZStack {
            preview
                .opacity(showPreview ? 1 : 0)
            editor
                .opacity(showPreview ? 0 : 1)
            VStack {
                HStack {
                    Spacer()
                    showPreviewIcon
                }
                Spacer()
            }
        }
        .padding()
    }

    // MARK: - Private

    private func findTextView(in view: UIView) -> UITextView? {
        if let textView = view as? UITextView {
            return textView
        }
        for subview in view.subviews {
            if let textView = findTextView(in: subview) {
                return textView
            }
        }
        return nil
    }

    private var editor: some View {
        RichTextEditor(text: $text, showPreview: $showPreview)
            .frame(minHeight: 200)
            .padding()
            .background(Color(.systemBackground))
            .cornerRadius(8)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color(.systemGray4), lineWidth: 1)
            )
    }

    private var preview: some View {
        ScrollView {
            Markdown(text)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
        }
        .frame(minHeight: 200)
        .background(Color(.systemBackground))
        .cornerRadius(8)
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color(.systemGray4), lineWidth: 1)
        )
    }

    private var showPreviewIcon: some View {
        Button(action: {
            showPreview.toggle()
            if showPreview {
                // Hide keyboard when showing preview
                UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
            } else {
                if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                   let window = windowScene.windows.first {
                    window.endEditing(false)
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        // Find the text view and make it first responder
                        if let textView = findTextView(in: window) {
                            textView.becomeFirstResponder()
                            // Move cursor to end
                            let endPosition = textView.endOfDocument
                            textView.selectedTextRange = textView.textRange(from: endPosition, to: endPosition)
                        }
                    }
                }
            }
        }) {
            Image(systemName: showPreview ? "eye.slash" : "eye")
                .foregroundColor(.black)
                .font(.system(size: 16, weight: .medium))
                .frame(width: 32, height: 32)
                .background(Color(.systemGray6))
                .clipShape(Circle())
                .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
        }
        .padding(.top, 8)
        .padding(.trailing, 8)
    }
}

#Preview {
    RichEditorView()
}
