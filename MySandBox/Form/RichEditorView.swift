import SwiftUI
import UIKit
import MarkdownUI

struct RichEditorView: View {
    @State private var text: String = ""
    @State private var showImagePicker = false
    @State private var showPreview = false
    
    var body: some View {
        VStack(spacing: 0) {
            // Text Editor or Preview
            ZStack {
                if showPreview {
                    // Markdown Preview
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
                } else {
                    // Text Editor
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
                
                // Preview Toggle Button
                VStack {
                    HStack {
                        Spacer()
                        Button(action: {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                showPreview.toggle()
                                if showPreview {
                                    // Hide keyboard when showing preview
                                    UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                                } else {
                                    // Show keyboard and focus at end when returning to editor
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                        // Focus the text view and move cursor to end
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
                    Spacer()
                }
            }
            
            Spacer()
        }
        .padding()
        .navigationTitle("Rich Text Editor")
        .navigationBarTitleDisplayMode(.inline)
    }
    
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
}

struct RichTextEditor: UIViewRepresentable {
    @Binding var text: String
    @Binding var showPreview: Bool
    
    func makeUIView(context: Context) -> UITextView {
        let textView = UITextView()
        textView.delegate = context.coordinator
        textView.font = UIFont.systemFont(ofSize: 16)
        textView.backgroundColor = UIColor.clear
        textView.textContainerInset = UIEdgeInsets(top: 12, left: 8, bottom: 12, right: 8)
        textView.isScrollEnabled = true
        textView.showsVerticalScrollIndicator = true
        
        // Set the textView reference immediately
        context.coordinator.textView = textView
        
        // Setup toolbar
        setupToolbar(for: textView, context: context)
        
        return textView
    }
    
    func updateUIView(_ uiView: UITextView, context: Context) {
        // Update the textView reference
        context.coordinator.textView = uiView
        
        if uiView.text != text {
            uiView.text = text
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    private func setupToolbar(for textView: UITextView, context: Context) {
        // Create a scroll view for the toolbar
        let scrollView = UIScrollView()
        scrollView.showsHorizontalScrollIndicator = true
        scrollView.showsVerticalScrollIndicator = false
        scrollView.backgroundColor = UIColor.systemGray6
        
        // Create a stack view to hold all buttons
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .fill
        stackView.alignment = .center
        stackView.spacing = 8
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
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
        
        
        // Add all buttons to stack view
        let buttons = [
            heading1Button, heading2Button, heading3Button, heading4Button,
            boldButton, strikethroughButton,
            bulletListButton, numberedListButton,
            linkButton, quoteButton, codeBlockButton
        ]
        
        for button in buttons {
            if let customView = button.customView {
                stackView.addArrangedSubview(customView)
            } else {
                // Create a button view for the UIBarButtonItem
                let buttonView = UIButton(type: .system)
                buttonView.setImage(button.image, for: .normal)
                buttonView.tintColor = .black
                buttonView.addTarget(button.target, action: button.action!, for: .touchUpInside)
                buttonView.translatesAutoresizingMaskIntoConstraints = false
                buttonView.widthAnchor.constraint(equalToConstant: 44).isActive = true
                buttonView.heightAnchor.constraint(equalToConstant: 44).isActive = true
                stackView.addArrangedSubview(buttonView)
            }
        }
        
        // Add stack view to scroll view
        scrollView.addSubview(stackView)
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        
        // Set up constraints
        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 16),
            stackView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -16),
            stackView.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 8),
            stackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: -8),
            stackView.heightAnchor.constraint(equalTo: scrollView.heightAnchor, constant: -16)
        ])
        
        // Set up the toolbar container
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        toolbar.setItems([UIBarButtonItem(customView: scrollView)], animated: false)
        
        textView.inputAccessoryView = toolbar
    }
    
    
    class Coordinator: NSObject, UITextViewDelegate {
        var parent: RichTextEditor
        weak var textView: UITextView?
        
        init(_ parent: RichTextEditor) {
            self.parent = parent
        }
        
        func textViewDidChange(_ textView: UITextView) {
            parent.text = textView.text
            self.textView = textView
        }
        
        func textViewDidBeginEditing(_ textView: UITextView) {
            // Ensure cursor is at the end when editing begins
            let endPosition = textView.endOfDocument
            textView.selectedTextRange = textView.textRange(from: endPosition, to: endPosition)
        }
        
        // MARK: - Markdown Insertion Methods
        
        @objc func insertHeading1() {
            insertHeadingAtSelection("# ")
        }
        
        @objc func insertHeading2() {
            insertHeadingAtSelection("## ")
        }
        
        @objc func insertHeading3() {
            insertHeadingAtSelection("### ")
        }
        
        @objc func insertHeading4() {
            insertHeadingAtSelection("#### ")
        }
        
        @objc func insertBold() {
            wrapSelectedText(with: "**")
        }
        
        @objc func insertBulletList() {
            insertListAtSelection("- ")
        }
        
        @objc func insertNumberedList() {
            insertListAtSelection("1. ")
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
            insertQuoteAtSelection("> ")
        }
        
        @objc func insertCodeBlock() {
            insertCodeBlockAtSelection()
        }
        
        @objc func insertStrikethrough() {
            wrapSelectedText(with: "~~")
        }
        
        
        // MARK: - Helper Methods
        
        private func insertHeadingAtSelection(_ heading: String) {
            guard let textView = textView else { return }
            
            let selectedRange = textView.selectedRange
            let currentText = textView.text ?? ""
            
            if selectedRange.length > 0 {
                // Text is selected, add heading prefix
                let selectedText = (currentText as NSString).substring(with: selectedRange)
                let newText = "\(heading)\(selectedText)"
                let updatedText = (currentText as NSString).replacingCharacters(in: selectedRange, with: newText)
                
                textView.text = updatedText
                parent.text = updatedText
                
                // Select the entire heading text
                let newRange = NSRange(location: selectedRange.location, length: newText.count)
                textView.selectedRange = newRange
            } else {
                // No text selected, insert heading at cursor
                insertMarkdownAtCursor(heading)
            }
        }
        
        private func insertListAtSelection(_ listPrefix: String) {
            guard let textView = textView else { return }
            
            let selectedRange = textView.selectedRange
            let currentText = textView.text ?? ""
            
            if selectedRange.length > 0 {
                // Text is selected, convert to list
                let selectedText = (currentText as NSString).substring(with: selectedRange)
                let lines = selectedText.components(separatedBy: .newlines)
                let listItems = lines.map { line in
                    let trimmedLine = line.trimmingCharacters(in: .whitespaces)
                    return trimmedLine.isEmpty ? "" : "\(listPrefix)\(trimmedLine)"
                }
                let newText = listItems.joined(separator: "\n")
                let updatedText = (currentText as NSString).replacingCharacters(in: selectedRange, with: newText)
                
                textView.text = updatedText
                parent.text = updatedText
                
                // Select the entire list
                let newRange = NSRange(location: selectedRange.location, length: newText.count)
                textView.selectedRange = newRange
            } else {
                // No text selected, insert list prefix at cursor
                insertMarkdownAtCursor(listPrefix)
            }
        }
        
        private func insertQuoteAtSelection(_ quotePrefix: String) {
            guard let textView = textView else { return }
            
            let selectedRange = textView.selectedRange
            let currentText = textView.text ?? ""
            
            if selectedRange.length > 0 {
                // Text is selected, convert to quote
                let selectedText = (currentText as NSString).substring(with: selectedRange)
                let lines = selectedText.components(separatedBy: .newlines)
                let quoteLines = lines.map { line in
                    let trimmedLine = line.trimmingCharacters(in: .whitespaces)
                    return trimmedLine.isEmpty ? "" : "\(quotePrefix)\(trimmedLine)"
                }
                let newText = quoteLines.joined(separator: "\n")
                let updatedText = (currentText as NSString).replacingCharacters(in: selectedRange, with: newText)
                
                textView.text = updatedText
                parent.text = updatedText
                
                // Select the entire quote
                let newRange = NSRange(location: selectedRange.location, length: newText.count)
                textView.selectedRange = newRange
            } else {
                // No text selected, insert quote prefix at cursor
                insertMarkdownAtCursor(quotePrefix)
            }
        }
        
        private func insertCodeBlockAtSelection() {
            guard let textView = textView else { return }
            
            let selectedRange = textView.selectedRange
            let currentText = textView.text ?? ""
            
            if selectedRange.length > 0 {
                // Text is selected, wrap with code block
                let selectedText = (currentText as NSString).substring(with: selectedRange)
                let codeBlockText = "```\n\(selectedText)\n```"
                let updatedText = (currentText as NSString).replacingCharacters(in: selectedRange, with: codeBlockText)
                
                textView.text = updatedText
                parent.text = updatedText
                
                // Select the entire code block
                let newRange = NSRange(location: selectedRange.location, length: codeBlockText.count)
                textView.selectedRange = newRange
            } else {
                // No text selected, insert code block with cursor in the middle
                let codeBlockText = "```\n\n```"
                let updatedText = (currentText as NSString).replacingCharacters(in: selectedRange, with: codeBlockText)
                
                textView.text = updatedText
                parent.text = updatedText
                
                // Position cursor between the code block markers
                let cursorPosition = selectedRange.location + 4 // After "```\n"
                textView.selectedRange = NSRange(location: cursorPosition, length: 0)
            }
        }
        
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
        
    }
}

#Preview {
    NavigationView {
    RichEditorView()
    }
}
