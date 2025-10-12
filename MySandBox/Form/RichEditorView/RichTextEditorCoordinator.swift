import UIKit

final class RichTextEditorCoordinator: NSObject, UITextViewDelegate {
    var parent: RichTextEditor
    weak var textView: UITextView?

    init(_ parent: RichTextEditor) {
        self.parent = parent
    }

    // MARK: - UITextViewDelegate

    func textViewDidChange(_ textView: UITextView) {
        parent.text = textView.text
        self.textView = textView
    }

    func textViewDidBeginEditing(_ textView: UITextView) {
        // Ensure cursor is at the end when editing begins
        let endPosition = textView.endOfDocument
        textView.selectedTextRange = textView.textRange(from: endPosition, to: endPosition)
    }

    // MARK: - Markdown Insertion

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
            replaceSelectedText(with: "[\(selectedText)](url)")
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

    // MARK: - Private

    private func insertHeadingAtSelection(_ heading: String) {
        guard let textView else { return }

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
            textView.selectedRange = .init(location: selectedRange.location, length: newText.count)
        } else {
            // No text selected, insert heading at cursor
            insertMarkdownAtCursor(heading)
        }
    }

    private func insertListAtSelection(_ listPrefix: String) {
        guard let textView else { return }

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
            textView.selectedRange = .init(location: selectedRange.location, length: newText.count)
        } else {
            // No text selected, insert list prefix at cursor
            insertMarkdownAtCursor(listPrefix)
        }
    }

    private func insertQuoteAtSelection(_ quotePrefix: String) {
        guard let textView else { return }

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
            textView.selectedRange = .init(location: selectedRange.location, length: newText.count)
        } else {
            // No text selected, insert quote prefix at cursor
            insertMarkdownAtCursor(quotePrefix)
        }
    }

    private func insertCodeBlockAtSelection() {
        guard let textView else { return }

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
            textView.selectedRange = .init(location: selectedRange.location, length: codeBlockText.count)
        } else {
            // No text selected, insert code block with cursor in the middle
            let codeBlockText = "```\n\n```"
            let updatedText = (currentText as NSString).replacingCharacters(in: selectedRange, with: codeBlockText)

            textView.text = updatedText
            parent.text = updatedText

            // Position cursor between the code block markers
            let cursorPosition = selectedRange.location + 4 // After "```\n"
            textView.selectedRange = .init(location: cursorPosition, length: 0)
        }
    }

    private func insertMarkdownAtCursor(_ markdown: String) {
        guard let textView else { return }

        let selectedRange = textView.selectedRange
        let currentText = textView.text ?? ""
        let newText = (currentText as NSString).replacingCharacters(in: selectedRange, with: markdown)

        textView.text = newText
        parent.text = newText

        // Update cursor position
        textView.selectedRange = .init(location: selectedRange.location + markdown.count, length: 0)
    }

    private func wrapSelectedText(with prefix: String) {
        guard let textView else { return }

        let selectedRange = textView.selectedRange
        let currentText = textView.text ?? ""

        if selectedRange.length > 0 {
            // Text is selected, wrap it
            let selectedText = (currentText as NSString).substring(with: selectedRange)
            let suffix = prefix
            let wrappedText = "\(prefix)\(selectedText)\(suffix)"

            let newText = (currentText as NSString).replacingCharacters(in: selectedRange, with: wrappedText)
            textView.text = newText
            parent.text = newText

            // Update selection to include the wrapped text
            textView.selectedRange = .init(location: selectedRange.location, length: wrappedText.count)
        } else {
            // No text selected, insert markdown at cursor
            let suffix = prefix
            insertMarkdownAtCursor("\(prefix)\(suffix)")

            // Position cursor between prefix and suffix
            textView.selectedRange = .init(location: selectedRange.location + prefix.count, length: 0)
        }
    }

    private func getSelectedText() -> String? {
        guard let textView else { return nil }
        let selectedRange = textView.selectedRange
        if selectedRange.length > 0 {
            return (textView.text as NSString?)?.substring(with: selectedRange)
        }
        return nil
    }

    private func replaceSelectedText(with newText: String) {
        guard let textView else { return }
        let selectedRange = textView.selectedRange
        let currentText = textView.text ?? ""
        let newText = (currentText as NSString).replacingCharacters(in: selectedRange, with: newText)

        textView.text = newText
        parent.text = newText

        // Update cursor position
        textView.selectedRange = .init(location: selectedRange.location + newText.count, length: 0)
    }
}
