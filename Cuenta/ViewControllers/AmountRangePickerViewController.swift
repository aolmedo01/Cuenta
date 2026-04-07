import UIKit

// MARK: - Amount Range Picker Delegate
@MainActor
protocol AmountRangePickerDelegate: AnyObject {
    func amountRangePicker(_ picker: AmountRangePickerViewController, didSelectMinAmount minAmount: Double?, maxAmount: Double?)
    func amountRangePickerDidCancel(_ picker: AmountRangePickerViewController)
}

// MARK: - Amount Range Picker View Controller
final class AmountRangePickerViewController: UIViewController {
    
    // MARK: - Properties
    weak var delegate: AmountRangePickerDelegate?
    
    private var minAmount: Double?
    private var maxAmount: Double?
    private var containerBottomConstraint: NSLayoutConstraint?
    
    private let currencyFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = Locale(identifier: "en_US")
        formatter.currencySymbol = "$"
        formatter.maximumFractionDigits = 2
        formatter.minimumFractionDigits = 2
        return formatter
    }()
    
    private let numberFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.locale = Locale(identifier: "en_US")
        formatter.maximumFractionDigits = 2
        return formatter
    }()
    
    // MARK: - UI Components
    private let containerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor(red: 0.96, green: 0.965, blue: 0.973, alpha: 1) // #F5F6F8
        view.layer.cornerRadius = 38
        view.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.18
        view.layer.shadowOffset = CGSize(width: 0, height: -15)
        view.layer.shadowRadius = 75
        return view
    }()
    
    private let grabberView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor(red: 0.8, green: 0.8, blue: 0.8, alpha: 1) // #CCCCCC
        view.layer.cornerRadius = 2.5
        return view
    }()
    
    private let toolbarView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var closeButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = UIColor(red: 0.47, green: 0.47, blue: 0.5, alpha: 0.16)
        button.layer.cornerRadius = 22
        button.setImage(UIImage(systemName: "xmark")?
            .withConfiguration(UIImage.SymbolConfiguration(pointSize: 15, weight: .semibold)), for: .normal)
        button.tintColor = UIColor(red: 0.6, green: 0.6, blue: 0.6, alpha: 1)
        button.addTarget(self, action: #selector(closeTapped), for: .touchUpInside)
        return button
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Filtrar monto"
        label.font = .manrope(size: 17, weight: .semibold)
        label.textColor = UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 1)
        label.textAlignment = .center
        return label
    }()
    
    private lazy var confirmButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = UIColor(red: 0, green: 0.533, blue: 1, alpha: 1) // #0088FF
        button.layer.cornerRadius = 22
        button.setImage(UIImage(systemName: "checkmark")?
            .withConfiguration(UIImage.SymbolConfiguration(pointSize: 15, weight: .semibold)), for: .normal)
        button.tintColor = .white
        button.addTarget(self, action: #selector(confirmTapped), for: .touchUpInside)
        return button
    }()
    
    private let filterCardView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor(red: 0.988, green: 0.988, blue: 0.992, alpha: 1) // #FCFCFD
        view.layer.cornerRadius = 24
        return view
    }()
    
    // Min amount row
    private let minAmountTextField: UITextField = {
        let textField = UITextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.placeholder = "$0.00"
        textField.font = .manrope(size: 17, weight: .regular)
        textField.textColor = .black
        textField.keyboardType = .decimalPad
        textField.backgroundColor = .clear
        return textField
    }()
    
    private let minLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Valor mínimo"
        label.font = .manrope(size: 13, weight: .regular)
        label.textColor = UIColor(red: 0.6, green: 0.6, blue: 0.6, alpha: 1)
        return label
    }()
    
    private let separatorLine: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor(red: 0.9, green: 0.9, blue: 0.9, alpha: 1)
        return view
    }()
    
    // Max amount row
    private let maxAmountTextField: UITextField = {
        let textField = UITextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.placeholder = "$0.00"
        textField.font = .manrope(size: 17, weight: .regular)
        textField.textColor = .black
        textField.keyboardType = .decimalPad
        textField.backgroundColor = .clear
        return textField
    }()
    
    private let maxLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Valor máximo"
        label.font = .manrope(size: 13, weight: .regular)
        label.textColor = UIColor(red: 0.6, green: 0.6, blue: 0.6, alpha: 1)
        return label
    }()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupKeyboardDismissal()
        setupKeyboardObservers()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - Setup
    private func setupView() {
        view.backgroundColor = UIColor.black.withAlphaComponent(0.3)
        
        // Tap background to dismiss
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(backgroundTapped(_:)))
        view.addGestureRecognizer(tapGesture)
        
        view.addSubview(containerView)
        containerView.addSubview(grabberView)
        containerView.addSubview(toolbarView)
        toolbarView.addSubview(closeButton)
        toolbarView.addSubview(titleLabel)
        toolbarView.addSubview(confirmButton)
        
        containerView.addSubview(filterCardView)
        filterCardView.addSubview(minLabel)
        filterCardView.addSubview(minAmountTextField)
        filterCardView.addSubview(separatorLine)
        filterCardView.addSubview(maxLabel)
        filterCardView.addSubview(maxAmountTextField)
        
        NSLayoutConstraint.activate([
            containerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            containerView.heightAnchor.constraint(equalToConstant: 280),
            
            grabberView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 5),
            grabberView.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            grabberView.widthAnchor.constraint(equalToConstant: 36),
            grabberView.heightAnchor.constraint(equalToConstant: 5),
            
            toolbarView.topAnchor.constraint(equalTo: grabberView.bottomAnchor, constant: 5),
            toolbarView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            toolbarView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            toolbarView.heightAnchor.constraint(equalToConstant: 44),
            
            closeButton.leadingAnchor.constraint(equalTo: toolbarView.leadingAnchor, constant: 16),
            closeButton.centerYAnchor.constraint(equalTo: toolbarView.centerYAnchor),
            closeButton.widthAnchor.constraint(equalToConstant: 44),
            closeButton.heightAnchor.constraint(equalToConstant: 44),
            
            titleLabel.centerXAnchor.constraint(equalTo: toolbarView.centerXAnchor),
            titleLabel.centerYAnchor.constraint(equalTo: toolbarView.centerYAnchor),
            
            confirmButton.trailingAnchor.constraint(equalTo: toolbarView.trailingAnchor, constant: -16),
            confirmButton.centerYAnchor.constraint(equalTo: toolbarView.centerYAnchor),
            confirmButton.widthAnchor.constraint(equalToConstant: 44),
            confirmButton.heightAnchor.constraint(equalToConstant: 44),
            
            filterCardView.topAnchor.constraint(equalTo: toolbarView.bottomAnchor, constant: 16),
            filterCardView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            filterCardView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            filterCardView.heightAnchor.constraint(equalToConstant: 120),
            
            minLabel.topAnchor.constraint(equalTo: filterCardView.topAnchor, constant: 8),
            minLabel.leadingAnchor.constraint(equalTo: filterCardView.leadingAnchor, constant: 16),
            minLabel.trailingAnchor.constraint(equalTo: filterCardView.trailingAnchor, constant: -16),
            
            minAmountTextField.topAnchor.constraint(equalTo: minLabel.bottomAnchor, constant: 2),
            minAmountTextField.leadingAnchor.constraint(equalTo: filterCardView.leadingAnchor, constant: 16),
            minAmountTextField.trailingAnchor.constraint(equalTo: filterCardView.trailingAnchor, constant: -16),
            minAmountTextField.heightAnchor.constraint(equalToConstant: 30),
            
            separatorLine.topAnchor.constraint(equalTo: minAmountTextField.bottomAnchor, constant: 8),
            separatorLine.leadingAnchor.constraint(equalTo: filterCardView.leadingAnchor, constant: 16),
            separatorLine.trailingAnchor.constraint(equalTo: filterCardView.trailingAnchor, constant: -16),
            separatorLine.heightAnchor.constraint(equalToConstant: 1),
            
            maxLabel.topAnchor.constraint(equalTo: separatorLine.bottomAnchor, constant: 8),
            maxLabel.leadingAnchor.constraint(equalTo: filterCardView.leadingAnchor, constant: 16),
            maxLabel.trailingAnchor.constraint(equalTo: filterCardView.trailingAnchor, constant: -16),
            
            maxAmountTextField.topAnchor.constraint(equalTo: maxLabel.bottomAnchor, constant: 2),
            maxAmountTextField.leadingAnchor.constraint(equalTo: filterCardView.leadingAnchor, constant: 16),
            maxAmountTextField.trailingAnchor.constraint(equalTo: filterCardView.trailingAnchor, constant: -16),
            maxAmountTextField.heightAnchor.constraint(equalToConstant: 30),
        ])
        
        // Setup bottom constraint separately so we can animate it
        containerBottomConstraint = containerView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        containerBottomConstraint?.isActive = true
    }
    
    private func setupKeyboardObservers() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow(_:)),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillHide(_:)),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
    }
    
    private func setupKeyboardDismissal() {
        // Set delegates for formatting
        minAmountTextField.delegate = self
        maxAmountTextField.delegate = self
        
        // Add tap gesture to dismiss keyboard when tapping on container
        let tapToDismiss = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboardOnTap))
        tapToDismiss.cancelsTouchesInView = false
        containerView.addGestureRecognizer(tapToDismiss)
    }
    
    @objc private func dismissKeyboardOnTap() {
        view.endEditing(true)
    }
    
    // MARK: - Actions
    @objc private func backgroundTapped(_ gesture: UITapGestureRecognizer) {
        let location = gesture.location(in: view)
        if !containerView.frame.contains(location) {
            // If keyboard is showing, just dismiss keyboard first
            if minAmountTextField.isFirstResponder || maxAmountTextField.isFirstResponder {
                view.endEditing(true)
            } else {
                closeTapped()
            }
        }
    }
    
    @objc private func closeTapped() {
        view.endEditing(true)
        dismiss(animated: true) {
            self.delegate?.amountRangePickerDidCancel(self)
        }
    }
    
    @objc private func confirmTapped() {
        view.endEditing(true)
        
        // Parse amounts (remove $ and , formatting)
        if let minText = minAmountTextField.text, !minText.isEmpty {
            let cleanedText = minText
                .replacingOccurrences(of: "$", with: "")
                .replacingOccurrences(of: ",", with: "")
                .replacingOccurrences(of: " ", with: "")
            minAmount = Double(cleanedText)
        }
        
        if let maxText = maxAmountTextField.text, !maxText.isEmpty {
            let cleanedText = maxText
                .replacingOccurrences(of: "$", with: "")
                .replacingOccurrences(of: ",", with: "")
                .replacingOccurrences(of: " ", with: "")
            maxAmount = Double(cleanedText)
        }
        
        dismiss(animated: true) {
            self.delegate?.amountRangePicker(self, didSelectMinAmount: self.minAmount, maxAmount: self.maxAmount)
        }
    }
    
    @objc private func keyboardWillShow(_ notification: Notification) {
        guard let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect,
              let duration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double else {
            return
        }
        
        let keyboardHeight = keyboardFrame.height
        
        UIView.animate(withDuration: duration) {
            self.containerBottomConstraint?.constant = -keyboardHeight
            self.view.layoutIfNeeded()
        }
    }
    
    @objc private func keyboardWillHide(_ notification: Notification) {
        guard let duration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double else {
            return
        }
        
        UIView.animate(withDuration: duration) {
            self.containerBottomConstraint?.constant = 0
            self.view.layoutIfNeeded()
        }
    }
}

// MARK: - Presentation Helper
extension AmountRangePickerViewController {
    static func present(from viewController: UIViewController, delegate: AmountRangePickerDelegate? = nil) {
        let picker = AmountRangePickerViewController()
        picker.delegate = delegate
        picker.modalPresentationStyle = .overFullScreen
        picker.modalTransitionStyle = .coverVertical
        viewController.present(picker, animated: true)
    }
}

// MARK: - UITextFieldDelegate
extension AmountRangePickerViewController: UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        // Allow backspace
        if string.isEmpty {
            return true
        }
        
        // Only allow numbers and decimal point
        let allowedCharacters = CharacterSet(charactersIn: "0123456789.")
        let characterSet = CharacterSet(charactersIn: string)
        
        if !allowedCharacters.isSuperset(of: characterSet) {
            return false
        }
        
        // Get current text without formatting
        let currentText = textField.text ?? ""
        let cleanedCurrent = currentText
            .replacingOccurrences(of: "$", with: "")
            .replacingOccurrences(of: ",", with: "")
            .replacingOccurrences(of: " ", with: "")
        
        // If adding decimal point, check if one already exists
        if string == "." && cleanedCurrent.contains(".") {
            return false
        }
        
        // Build new clean number string
        let newCleanText = cleanedCurrent + string
        
        // Limit decimal places to 2
        if let decimalIndex = newCleanText.firstIndex(of: ".") {
            let decimalPart = newCleanText[newCleanText.index(after: decimalIndex)...]
            if decimalPart.count > 2 {
                return false
            }
        }
        
        // Validate it's a valid number format
        if !newCleanText.isEmpty && Double(newCleanText) == nil && newCleanText != "." {
            return false
        }
        
        // Update text with $ prefix
        if newCleanText.isEmpty {
            textField.text = ""
        } else {
            textField.text = "$" + newCleanText
        }
        
        return false
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        // Parse and format the final value
        let cleanedText = (textField.text ?? "")
            .replacingOccurrences(of: "$", with: "")
            .replacingOccurrences(of: ",", with: "")
            .replacingOccurrences(of: " ", with: "")
        
        if let value = Double(cleanedText) {
            // Format with currency
            if let formattedText = currencyFormatter.string(from: NSNumber(value: value)) {
                textField.text = formattedText
            }
            
            if textField == minAmountTextField {
                minAmount = value
            } else if textField == maxAmountTextField {
                maxAmount = value
            }
        } else {
            // Clear invalid text
            textField.text = ""
            if textField == minAmountTextField {
                minAmount = nil
            } else if textField == maxAmountTextField {
                maxAmount = nil
            }
        }
    }
}
