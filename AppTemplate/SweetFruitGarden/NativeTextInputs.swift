import SwiftUI
import UIKit

struct NativeTextField: UIViewRepresentable {
    @Binding var text: String
    let placeholder: String
    var textColor: UIColor = .white
    var placeholderColor: UIColor = UIColor.white.withAlphaComponent(0.6)
    var font: UIFont = .systemFont(ofSize: 15)

    final class Coordinator: NSObject, UITextFieldDelegate {
        var parent: NativeTextField
        init(parent: NativeTextField) { self.parent = parent }

        @objc func editingChanged(_ sender: UITextField) {
            parent.text = sender.text ?? ""
        }

        func textFieldShouldReturn(_ textField: UITextField) -> Bool {
            textField.resignFirstResponder()
            return true
        }
    }

    func makeCoordinator() -> Coordinator { Coordinator(parent: self) }

    func makeUIView(context: Context) -> UITextField {
        let field = UITextField()
        field.delegate = context.coordinator
        field.autocorrectionType = .no
        field.autocapitalizationType = .none
        field.keyboardType = .asciiCapable
        field.returnKeyType = .done
        field.isUserInteractionEnabled = true
        field.isEnabled = true
        field.borderStyle = .none
        field.textColor = textColor
        field.font = font
        field.attributedPlaceholder = NSAttributedString(
            string: placeholder,
            attributes: [.foregroundColor: placeholderColor, .font: font]
        )
        field.addTarget(context.coordinator, action: #selector(Coordinator.editingChanged(_:)), for: .editingChanged)
        return field
    }

    func updateUIView(_ uiView: UITextField, context: Context) {
        uiView.isEnabled = true
        uiView.isUserInteractionEnabled = true
        if uiView.text != text { uiView.text = text }
    }
}

struct NativeTextView: UIViewRepresentable {
    @Binding var text: String
    let placeholder: String
    var textColor: UIColor = .white
    var placeholderColor: UIColor = UIColor.white.withAlphaComponent(0.95)
    var font: UIFont = .systemFont(ofSize: 15)

    final class Coordinator: NSObject, UITextViewDelegate {
        var parent: NativeTextView
        private let placeholderTag = 9001

        init(parent: NativeTextView) { self.parent = parent }

        private func placeholderLabel(in textView: UITextView) -> UILabel? {
            textView.viewWithTag(placeholderTag) as? UILabel
        }

        private func updatePlaceholderVisibility(_ textView: UITextView) {
            placeholderLabel(in: textView)?.isHidden = !textView.text.isEmpty
        }

        func textViewDidBeginEditing(_ textView: UITextView) {
            updatePlaceholderVisibility(textView)
        }

        func textViewDidChange(_ textView: UITextView) {
            parent.text = textView.text
            updatePlaceholderVisibility(textView)
        }

        func textViewDidEndEditing(_ textView: UITextView) {
            updatePlaceholderVisibility(textView)
        }

        func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
            if text == "\n" {
                textView.resignFirstResponder()
                return false
            }
            return true
        }
    }

    func makeCoordinator() -> Coordinator { Coordinator(parent: self) }

    func makeUIView(context: Context) -> UITextView {
        let view = UITextView()
        view.delegate = context.coordinator
        view.backgroundColor = .clear
        view.autocorrectionType = .no
        view.autocapitalizationType = .none
        view.keyboardType = .asciiCapable
        view.returnKeyType = .default
        view.isUserInteractionEnabled = true
        view.isEditable = true
        view.isSelectable = true
        view.isScrollEnabled = true
        view.textColor = textColor
        view.font = font
        view.textContainerInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)

        let placeholderLabel = UILabel()
        placeholderLabel.tag = 9001
        placeholderLabel.text = placeholder
        placeholderLabel.textColor = placeholderColor
        placeholderLabel.font = font
        placeholderLabel.numberOfLines = 0
        placeholderLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(placeholderLabel)
        NSLayoutConstraint.activate([
            placeholderLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            placeholderLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 14),
            placeholderLabel.trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor, constant: -16)
        ])
        placeholderLabel.isHidden = !text.isEmpty

        return view
    }

    func updateUIView(_ uiView: UITextView, context: Context) {
        uiView.isEditable = true
        uiView.isSelectable = true
        uiView.isUserInteractionEnabled = true
        if uiView.text != text {
            uiView.text = text
        }
        uiView.textColor = textColor
        let placeholderLabel = uiView.viewWithTag(9001) as? UILabel
        placeholderLabel?.isHidden = !text.isEmpty
    }
}
