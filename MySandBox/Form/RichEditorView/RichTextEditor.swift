import SwiftUI

struct RichTextEditor: UIViewRepresentable {
    @Binding var text: String
    @Binding var showPreview: Bool

    // MARK: - UIViewRepresentable

    func makeUIView(context: Context) -> UITextView {
        let textView = UITextView()
        textView.delegate = context.coordinator
        textView.font = .systemFont(ofSize: 16)
        textView.backgroundColor = .clear
        textView.textContainerInset = UIEdgeInsets(top: 12, left: 8, bottom: 12, right: 8)
        textView.isScrollEnabled = true
        textView.showsVerticalScrollIndicator = true
        context.coordinator.textView = textView
        setupToolbar(for: textView, context: context)
        return textView
    }

    func updateUIView(_ uiView: UITextView, context: Context) {
        context.coordinator.textView = uiView
        if uiView.text != text {
            uiView.text = text
        }
    }

    // MARK: - Coordinator

    typealias Coordinator = RichTextEditorCoordinator
    func makeCoordinator() -> Coordinator { .init(self) }

    // MARK: - Private

    private func setupToolbar(for textView: UITextView, context: Context) {
        let scrollView = UIScrollView()
        scrollView.showsHorizontalScrollIndicator = true
        scrollView.showsVerticalScrollIndicator = false
        scrollView.backgroundColor = .systemGray6

        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .fill
        stackView.alignment = .center
        stackView.spacing = 8
        stackView.translatesAutoresizingMaskIntoConstraints = false

        let boldButton = UIBarButtonItem(
           image: .init(systemName: "bold")?.withTintColor(.black, renderingMode: .alwaysOriginal),
           style: .plain,
           target: context.coordinator,
           action: #selector(Coordinator.insertBold)
        )
        let bulletListButton = UIBarButtonItem(
           image: .init(systemName: "list.bullet")?.withTintColor(.black, renderingMode: .alwaysOriginal),
           style: .plain,
           target: context.coordinator,
           action: #selector(Coordinator.insertBulletList)
        )
        let numberedListButton = UIBarButtonItem(
           image: .init(systemName: "list.number")?.withTintColor(.black, renderingMode: .alwaysOriginal),
           style: .plain,
           target: context.coordinator,
           action: #selector(Coordinator.insertNumberedList)
        )
        let linkButton = UIBarButtonItem(
           image: .init(systemName: "link")?.withTintColor(.black, renderingMode: .alwaysOriginal),
           style: .plain,
           target: context.coordinator,
           action: #selector(Coordinator.insertLink)
        )
        let quoteButton = UIBarButtonItem(
           image: .init(systemName: "quote.bubble")?.withTintColor(.black, renderingMode: .alwaysOriginal),
           style: .plain,
           target: context.coordinator,
           action: #selector(Coordinator.insertQuote)
        )
        let codeBlockButton = UIBarButtonItem(
           image: .init(systemName: "chevron.left.forwardslash.chevron.right")?.withTintColor(.black, renderingMode: .alwaysOriginal),
           style: .plain,
           target: context.coordinator,
           action: #selector(Coordinator.insertCodeBlock)
        )
        let strikethroughButton = UIBarButtonItem(
           image: .init(systemName: "strikethrough")?.withTintColor(.black, renderingMode: .alwaysOriginal),
           style: .plain,
           target: context.coordinator,
           action: #selector(Coordinator.insertStrikethrough)
        )

        let buttons = [
           headingDropdownButton(context: context),
           boldButton,
           strikethroughButton,
           bulletListButton,
           numberedListButton,
           linkButton,
           quoteButton,
           codeBlockButton
        ]

        buttons.forEach { button in
           if let customView = button.customView {
               stackView.addArrangedSubview(customView)
           } else {
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

        scrollView.addSubview(stackView)
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
           stackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 16),
           stackView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -16),
           stackView.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 8),
           stackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: -8),
           stackView.heightAnchor.constraint(equalTo: scrollView.heightAnchor, constant: -16)
        ])

        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        toolbar.setItems([.init(customView: scrollView)], animated: false)
        textView.inputAccessoryView = toolbar
    }

    private func headingDropdownButton(context: Context) -> UIBarButtonItem {
        let button = UIButton(type: .system)
        button.setImage(.init(systemName: "textformat.size")?.withTintColor(.black, renderingMode: .alwaysOriginal), for: .normal)
        button.tintColor = .black
        button.translatesAutoresizingMaskIntoConstraints = false
        button.widthAnchor.constraint(equalToConstant: 44).isActive = true
        button.heightAnchor.constraint(equalToConstant: 44).isActive = true
        button.menu = .init(title: "見出しを選択", children: [
           UIAction(title: "見出し1", image: .init(systemName: "textformat.size")) { _ in
               context.coordinator.insertHeading1()
           },
           UIAction(title: "見出し2", image: .init(systemName: "textformat.size.smaller")) { _ in
               context.coordinator.insertHeading2()
           },
           UIAction(title: "見出し3", image: .init(systemName: "textformat.size.smaller")) { _ in
               context.coordinator.insertHeading3()
           },
           UIAction(title: "見出し4", image: .init(systemName: "textformat.size.smaller")) { _ in
               context.coordinator.insertHeading4()
           }
        ])
        button.showsMenuAsPrimaryAction = true
        return UIBarButtonItem(customView: button)
   }
}
