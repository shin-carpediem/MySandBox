import UIKit

final class RichTextEditorCoordinator: NSObject, UITextViewDelegate {
    var parent: RichTextEditor
    weak var textView: UITextView?

    private var lastAction: String?
    private var preActionSnapshot: (text: String, selectedRange: NSRange)?
    private var isProgrammaticChange = false

    init(_ parent: RichTextEditor) {
        self.parent = parent
    }

    // MARK: - UITextViewDelegate

    func textViewDidChange(_ textView: UITextView) {
        parent.text = textView.text
        self.textView = textView
        if !isProgrammaticChange {
            lastAction = nil
            preActionSnapshot = nil
        }
    }

    func textViewDidBeginEditing(_ textView: UITextView) {
        // Ensure cursor is at the end when editing begins
        let endPosition = textView.endOfDocument
        textView.selectedTextRange = textView.textRange(from: endPosition, to: endPosition)
    }

    // MARK: - Markdown Insertion

    @objc func insertHeading1() {
        performAction("heading1") { self.insertHeadingAtSelection("# ") }
    }

    @objc func insertHeading2() {
        performAction("heading2") { self.insertHeadingAtSelection("## ") }
    }

    @objc func insertHeading3() {
        performAction("heading3") { self.insertHeadingAtSelection("### ") }
    }

    @objc func insertHeading4() {
        performAction("heading4") { self.insertHeadingAtSelection("#### ") }
    }

    @objc func insertBold() {
        performAction("bold") { self.wrapSelectedText(with: "**") }
    }

    @objc func insertBulletList() {
        performAction("bulletList") { self.insertListAtSelection("- ") }
    }

    @objc func insertNumberedList() {
        performAction("numberedList") { self.insertListAtSelection("1. ") }
    }

    @objc func insertLink() {
        performAction("link") {
            if let selectedText = self.getSelectedText(), !selectedText.isEmpty {
                self.replaceSelectedText(with: "[\(selectedText)](url)")
            } else {
                self.insertMarkdownAtCursor("[リンクテキスト](url)")
            }
        }
    }

    @objc func insertQuote() {
        performAction("quote") { self.insertQuoteAtSelection("> ") }
    }

    @objc func insertCodeBlock() {
        performAction("codeBlock") { self.insertCodeBlockAtSelection() }
    }

    @objc func insertStrikethrough() {
        performAction("strikethrough") { self.wrapSelectedText(with: "~~") }
    }

    // MARK: - Action State Management

    private func performAction(_ actionId: String, _ action: () -> Void) {
        if tryUndoLastAction(actionId: actionId) { return }
        saveActionState(actionId: actionId)
        isProgrammaticChange = true
        action()
        isProgrammaticChange = false
    }

    private func tryUndoLastAction(actionId: String) -> Bool {
        guard lastAction == actionId, let snapshot = preActionSnapshot, let textView else {
            return false
        }
        isProgrammaticChange = true
        textView.text = snapshot.text
        parent.text = snapshot.text
        textView.selectedRange = snapshot.selectedRange
        isProgrammaticChange = false
        lastAction = nil
        preActionSnapshot = nil
        return true
    }

    private func saveActionState(actionId: String) {
        guard let textView else { return }
        preActionSnapshot = (textView.text ?? "", textView.selectedRange)
        lastAction = actionId
    }

    // MARK: - Private

    private func insertHeadingAtSelection(_ heading: String) {
        guard let textView else { return }

        let selectedRange = effectiveRange()
        let currentText = textView.text ?? ""

        if selectedRange.length > 0 {
            let selectedText = (currentText as NSString).substring(with: selectedRange)
            if selectedText.hasPrefix(heading) {
                // Already has this heading → remove it
                let stripped = String(selectedText.dropFirst(heading.count))
                let updatedText = (currentText as NSString).replacingCharacters(in: selectedRange, with: stripped)
                textView.text = updatedText
                parent.text = updatedText
                textView.selectedRange = .init(location: selectedRange.location, length: stripped.count)
            } else {
                // Add heading prefix
                let newText = "\(heading)\(selectedText)"
                let updatedText = (currentText as NSString).replacingCharacters(in: selectedRange, with: newText)
                textView.text = updatedText
                parent.text = updatedText
                textView.selectedRange = .init(location: selectedRange.location, length: newText.count)
            }
        } else {
            // No text selected, insert heading at cursor
            insertMarkdownAtCursor(heading)
        }
    }

    private func insertListAtSelection(_ listPrefix: String) {
        guard let textView else { return }

        let selectedRange = effectiveRange()
        let currentText = textView.text ?? ""

        if selectedRange.length > 0 {
            let selectedText = (currentText as NSString).substring(with: selectedRange)
            let lines = selectedText.components(separatedBy: .newlines)
            let nonEmptyLines = lines.filter { !$0.isEmpty }
            let allPrefixed = !nonEmptyLines.isEmpty && nonEmptyLines.allSatisfy { $0.hasPrefix(listPrefix) }

            let newText: String
            if allPrefixed {
                // Remove list prefix from all lines
                let unformatted = lines.map { line -> String in
                    line.hasPrefix(listPrefix) ? String(line.dropFirst(listPrefix.count)) : line
                }
                newText = unformatted.joined(separator: "\n")
            } else {
                // Add list prefix to non-empty lines
                let listItems = lines.map { line -> String in
                    let trimmedLine = line.trimmingCharacters(in: .whitespaces)
                    return trimmedLine.isEmpty ? "" : "\(listPrefix)\(trimmedLine)"
                }
                newText = listItems.joined(separator: "\n")
            }

            let updatedText = (currentText as NSString).replacingCharacters(in: selectedRange, with: newText)
            textView.text = updatedText
            parent.text = updatedText
            textView.selectedRange = .init(location: selectedRange.location, length: newText.count)
        } else {
            // No text selected, insert list prefix at cursor
            insertMarkdownAtCursor(listPrefix)
        }
    }

    private func insertQuoteAtSelection(_ quotePrefix: String) {
        guard let textView else { return }

        let selectedRange = effectiveRange()
        let currentText = textView.text ?? ""

        if selectedRange.length > 0 {
            let selectedText = (currentText as NSString).substring(with: selectedRange)
            let lines = selectedText.components(separatedBy: .newlines)
            let nonEmptyLines = lines.filter { !$0.isEmpty }
            let allPrefixed = !nonEmptyLines.isEmpty && nonEmptyLines.allSatisfy { $0.hasPrefix(quotePrefix) }

            let newText: String
            if allPrefixed {
                // Remove quote prefix from all lines
                let unformatted = lines.map { line -> String in
                    line.hasPrefix(quotePrefix) ? String(line.dropFirst(quotePrefix.count)) : line
                }
                newText = unformatted.joined(separator: "\n")
            } else {
                // Add quote prefix to non-empty lines
                let quoteLines = lines.map { line -> String in
                    let trimmedLine = line.trimmingCharacters(in: .whitespaces)
                    return trimmedLine.isEmpty ? "" : "\(quotePrefix)\(trimmedLine)"
                }
                newText = quoteLines.joined(separator: "\n")
            }

            let updatedText = (currentText as NSString).replacingCharacters(in: selectedRange, with: newText)
            textView.text = updatedText
            parent.text = updatedText
            textView.selectedRange = .init(location: selectedRange.location, length: newText.count)
        } else {
            // No text selected, insert quote prefix at cursor
            insertMarkdownAtCursor(quotePrefix)
        }
    }

    private func insertCodeBlockAtSelection() {
        guard let textView else { return }

        let selectedRange = effectiveRange()
        let currentText = textView.text ?? ""

        if selectedRange.length > 0 {
            let selectedText = (currentText as NSString).substring(with: selectedRange)
            if selectedText.hasPrefix("```\n") && selectedText.hasSuffix("\n```") {
                // Already wrapped → unwrap
                let inner = String(selectedText.dropFirst(4).dropLast(4))
                let updatedText = (currentText as NSString).replacingCharacters(in: selectedRange, with: inner)
                textView.text = updatedText
                parent.text = updatedText
                textView.selectedRange = .init(location: selectedRange.location, length: inner.count)
            } else {
                // Wrap with code block
                let codeBlockText = "```\n\(selectedText)\n```"
                let updatedText = (currentText as NSString).replacingCharacters(in: selectedRange, with: codeBlockText)
                textView.text = updatedText
                parent.text = updatedText
                textView.selectedRange = .init(location: selectedRange.location, length: codeBlockText.count)
            }
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

        let selectedRange = effectiveRange()
        let currentText = textView.text ?? ""
        let newText = (currentText as NSString).replacingCharacters(in: selectedRange, with: markdown)

        textView.text = newText
        parent.text = newText

        // Update cursor position
        textView.selectedRange = .init(location: selectedRange.location + markdown.count, length: 0)
    }

    private func wrapSelectedText(with prefix: String) {
        guard let textView else { return }

        let selectedRange = effectiveRange()
        let currentText = textView.text ?? ""

        if selectedRange.length > 0 {
            let selectedText = (currentText as NSString).substring(with: selectedRange)
            if selectedText.hasPrefix(prefix) && selectedText.hasSuffix(prefix)
                && selectedText.count > prefix.count * 2 {
                // Already wrapped → unwrap
                let inner = String(selectedText.dropFirst(prefix.count).dropLast(prefix.count))
                let newText = (currentText as NSString).replacingCharacters(in: selectedRange, with: inner)
                textView.text = newText
                parent.text = newText
                textView.selectedRange = .init(location: selectedRange.location, length: inner.count)
            } else {
                // Wrap the selected text
                let wrappedText = "\(prefix)\(selectedText)\(prefix)"
                let newText = (currentText as NSString).replacingCharacters(in: selectedRange, with: wrappedText)
                textView.text = newText
                parent.text = newText
                textView.selectedRange = .init(location: selectedRange.location, length: wrappedText.count)
            }
        } else {
            // No text selected, insert markdown at cursor
            insertMarkdownAtCursor("\(prefix)\(prefix)")
            // Position cursor between prefix and suffix
            textView.selectedRange = .init(location: selectedRange.location + prefix.count, length: 0)
        }
    }

    private func effectiveRange() -> NSRange {
        guard let textView else { return NSRange(location: 0, length: 0) }
        if let markedTextRange = textView.markedTextRange, !markedTextRange.isEmpty {
            let location = textView.offset(from: textView.beginningOfDocument, to: markedTextRange.start)
            let length = textView.offset(from: markedTextRange.start, to: markedTextRange.end)
            return NSRange(location: location, length: length)
        }
        return textView.selectedRange
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
        let updatedText = (currentText as NSString).replacingCharacters(in: selectedRange, with: newText)

        textView.text = updatedText
        parent.text = updatedText

        // Update cursor position
        textView.selectedRange = .init(location: selectedRange.location + newText.count, length: 0)
    }
}
