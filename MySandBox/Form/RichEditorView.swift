import SwiftUI
import UIKit

struct RichEditorView: View {
    @State private var text: String = ""
    @State private var showImagePicker = false
    
    var body: some View {
        VStack(spacing: 0) {
            // Text Editor
            RichTextEditor(text: $text)
                .frame(minHeight: 200)
                .padding()
                .background(Color(.systemBackground))
                .cornerRadius(8)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color(.systemGray4), lineWidth: 1)
                )
            
            Spacer()
        }
        .padding()
        .navigationTitle("Rich Text Editor")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct RichTextEditor: UIViewRepresentable {
    @Binding var text: String
    
    func makeUIView(context: Context) -> UITextView {
        let textView = UITextView()
        textView.delegate = context.coordinator
        textView.font = UIFont.systemFont(ofSize: 16)
        textView.backgroundColor = UIColor.clear
        textView.textContainerInset = UIEdgeInsets(top: 12, left: 8, bottom: 12, right: 8)
        textView.isScrollEnabled = true
        textView.showsVerticalScrollIndicator = true
        
        // Setup toolbar
        setupToolbar(for: textView, context: context)
        
        // Setup drag and drop
        setupDragAndDrop(for: textView, context: context)
        
        return textView
    }
    
    func updateUIView(_ uiView: UITextView, context: Context) {
        if uiView.text != text {
            uiView.text = text
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    private func setupToolbar(for textView: UITextView, context: Context) {
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        
        // Create toolbar items with SF Symbols
        let heading1Button = UIBarButtonItem(
            image: UIImage(systemName: "textformat.size")?.withTintColor(.black, renderingMode: .alwaysOriginal),
            style: .plain,
            target: context.coordinator,
            action: #selector(Coordinator.insertHeading1)
        )
        
        let heading2Button = UIBarButtonItem(
            image: UIImage(systemName: "textformat.size.smaller")?.withTintColor(.black, renderingMode: .alwaysOriginal),
            style: .plain,
            target: context.coordinator,
            action: #selector(Coordinator.insertHeading2)
        )
        
        let heading3Button = UIBarButtonItem(
            image: UIImage(systemName: "textformat.size.smaller")?.withTintColor(.black, renderingMode: .alwaysOriginal),
            style: .plain,
            target: context.coordinator,
            action: #selector(Coordinator.insertHeading3)
        )
        
        let heading4Button = UIBarButtonItem(
            image: UIImage(systemName: "textformat.size.smaller")?.withTintColor(.black, renderingMode: .alwaysOriginal),
            style: .plain,
            target: context.coordinator,
            action: #selector(Coordinator.insertHeading4)
        )
        
        let boldButton = UIBarButtonItem(
            image: UIImage(systemName: "bold")?.withTintColor(.black, renderingMode: .alwaysOriginal),
            style: .plain,
            target: context.coordinator,
            action: #selector(Coordinator.insertBold)
        )
        
        let bulletListButton = UIBarButtonItem(
            image: UIImage(systemName: "list.bullet")?.withTintColor(.black, renderingMode: .alwaysOriginal),
            style: .plain,
            target: context.coordinator,
            action: #selector(Coordinator.insertBulletList)
        )
        
        let numberedListButton = UIBarButtonItem(
            image: UIImage(systemName: "list.number")?.withTintColor(.black, renderingMode: .alwaysOriginal),
            style: .plain,
            target: context.coordinator,
            action: #selector(Coordinator.insertNumberedList)
        )
        
        let linkButton = UIBarButtonItem(
            image: UIImage(systemName: "link")?.withTintColor(.black, renderingMode: .alwaysOriginal),
            style: .plain,
            target: context.coordinator,
            action: #selector(Coordinator.insertLink)
        )
        
        let quoteButton = UIBarButtonItem(
            image: UIImage(systemName: "quote.bubble")?.withTintColor(.black, renderingMode: .alwaysOriginal),
            style: .plain,
            target: context.coordinator,
            action: #selector(Coordinator.insertQuote)
        )
        
        let codeBlockButton = UIBarButtonItem(
            image: UIImage(systemName: "chevron.left.forwardslash.chevron.right")?.withTintColor(.black, renderingMode: .alwaysOriginal),
            style: .plain,
            target: context.coordinator,
            action: #selector(Coordinator.insertCodeBlock)
        )
        
        let strikethroughButton = UIBarButtonItem(
            image: UIImage(systemName: "strikethrough")?.withTintColor(.black, renderingMode: .alwaysOriginal),
            style: .plain,
            target: context.coordinator,
            action: #selector(Coordinator.insertStrikethrough)
        )
        
        let imageButton = UIBarButtonItem(
            image: UIImage(systemName: "photo")?.withTintColor(.black, renderingMode: .alwaysOriginal),
            style: .plain,
            target: context.coordinator,
            action: #selector(Coordinator.insertImage)
        )
        
        // Add flexible space and organize buttons
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        
        toolbar.items = [
            heading1Button,
            heading2Button,
            heading3Button,
            heading4Button,
            flexibleSpace,
            boldButton,
            strikethroughButton,
            flexibleSpace,
            bulletListButton,
            numberedListButton,
            flexibleSpace,
            linkButton,
            quoteButton,
            codeBlockButton,
            flexibleSpace,
            imageButton
        ]
        
        textView.inputAccessoryView = toolbar
    }
    
    private func setupDragAndDrop(for textView: UITextView, context: Context) {
        textView.isUserInteractionEnabled = true
        let dropInteraction = UIDropInteraction(delegate: context.coordinator)
        textView.addInteraction(dropInteraction)
    }
    
    class Coordinator: NSObject, UITextViewDelegate, UIDropInteractionDelegate {
        var parent: RichTextEditor
        weak var textView: UITextView?
        
        init(_ parent: RichTextEditor) {
            self.parent = parent
        }
        
        func textViewDidChange(_ textView: UITextView) {
            parent.text = textView.text
            self.textView = textView
        }
        
        // MARK: - Markdown Insertion Methods
        
        @objc func insertHeading1() {
            insertMarkdownAtCursor("# ")
        }
        
        @objc func insertHeading2() {
            insertMarkdownAtCursor("## ")
        }
        
        @objc func insertHeading3() {
            insertMarkdownAtCursor("### ")
        }
        
        @objc func insertHeading4() {
            insertMarkdownAtCursor("#### ")
        }
        
        @objc func insertBold() {
            wrapSelectedText(with: "**")
        }
        
        @objc func insertBulletList() {
            insertMarkdownAtCursor("- ")
        }
        
        @objc func insertNumberedList() {
            insertMarkdownAtCursor("1. ")
        }
        
        @objc func insertLink() {
            if let selectedText = getSelectedText(), !selectedText.isEmpty {
                let linkMarkdown = "[\(selectedText)](url)"
                replaceSelectedText(with: linkMarkdown)
            } else {
                insertMarkdownAtCursor("[リンクテキスト](url)")
            }
        }
        
        @objc func insertQuote() {
            insertMarkdownAtCursor("> ")
        }
        
        @objc func insertCodeBlock() {
            wrapSelectedText(with: "```", suffix: "```")
        }
        
        @objc func insertStrikethrough() {
            wrapSelectedText(with: "~~")
        }
        
        @objc func insertImage() {
            insertMarkdownAtCursor("![画像の説明](画像URL)")
        }
        
        // MARK: - Helper Methods
        
        private func insertMarkdownAtCursor(_ markdown: String) {
            guard let textView = textView else { return }
            
            let selectedRange = textView.selectedRange
            let currentText = textView.text ?? ""
            let newText = (currentText as NSString).replacingCharacters(in: selectedRange, with: markdown)
            
            textView.text = newText
            parent.text = newText
            
            // Update cursor position
            let newPosition = selectedRange.location + markdown.count
            textView.selectedRange = NSRange(location: newPosition, length: 0)
        }
        
        private func wrapSelectedText(with prefix: String, suffix: String? = nil) {
            guard let textView = textView else { return }
            
            let selectedRange = textView.selectedRange
            let currentText = textView.text ?? ""
            
            if selectedRange.length > 0 {
                // Text is selected, wrap it
                let selectedText = (currentText as NSString).substring(with: selectedRange)
                let suffix = suffix ?? prefix
                let wrappedText = "\(prefix)\(selectedText)\(suffix)"
                
                let newText = (currentText as NSString).replacingCharacters(in: selectedRange, with: wrappedText)
                textView.text = newText
                parent.text = newText
                
                // Update selection to include the wrapped text
                let newRange = NSRange(location: selectedRange.location, length: wrappedText.count)
                textView.selectedRange = newRange
            } else {
                // No text selected, insert markdown at cursor
                let suffix = suffix ?? prefix
                insertMarkdownAtCursor("\(prefix)\(suffix)")
                
                // Position cursor between prefix and suffix
                let newPosition = selectedRange.location + prefix.count
                textView.selectedRange = NSRange(location: newPosition, length: 0)
            }
        }
        
        private func getSelectedText() -> String? {
            guard let textView = textView else { return nil }
            let selectedRange = textView.selectedRange
            if selectedRange.length > 0 {
                return (textView.text as NSString?)?.substring(with: selectedRange)
            }
            return nil
        }
        
        private func replaceSelectedText(with newText: String) {
            guard let textView = textView else { return }
            let selectedRange = textView.selectedRange
            let currentText = textView.text ?? ""
            let newText = (currentText as NSString).replacingCharacters(in: selectedRange, with: newText)
            
            textView.text = newText
            parent.text = newText
            
            // Update cursor position
            let newPosition = selectedRange.location + newText.count
            textView.selectedRange = NSRange(location: newPosition, length: 0)
        }
        
        // MARK: - UIDropInteractionDelegate
        
        func dropInteraction(_ interaction: UIDropInteraction, canHandle session: UIDropSession) -> Bool {
            return session.hasItemsConforming(toTypeIdentifiers: ["public.image"])
        }
        
        func dropInteraction(_ interaction: UIDropInteraction, sessionDidUpdate session: UIDropSession) -> UIDropProposal {
            return UIDropProposal(operation: .copy)
        }
        
        func dropInteraction(_ interaction: UIDropInteraction, performDrop session: UIDropSession) {
            session.loadObjects(ofClass: UIImage.self) { [weak self] images in
                DispatchQueue.main.async {
                    guard let self = self,
                          let textView = self.textView,
                          let image = images.first as? UIImage else { return }
                    
                    // For now, we'll insert a placeholder for the image
                    // In a real implementation, you'd upload the image and get a URL
                    let imageMarkdown = "![画像](画像URL)"
                    self.insertMarkdownAtCursor(imageMarkdown)
                }
            }
        }
    }
}

#Preview {
    NavigationView {
    RichEditorView()
    }
}
