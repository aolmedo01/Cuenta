import UIKit

final class SearchViewController: UIViewController {
    
    // MARK: - Properties
    private var allTransactions: [Transaction] = []
    private var groupedTransactions: [TransactionSection] = []
    private var filteredTransactions: [TransactionSection] = []
    
    // MARK: - UI Components
    
    private let searchContainerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor(red: 0.969, green: 0.969, blue: 0.969, alpha: 1.0) // #F7F7F7
        view.layer.cornerRadius = 24
        return view
    }()
    
    private let searchIcon: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(systemName: "magnifyingglass")?
            .withConfiguration(UIImage.SymbolConfiguration(pointSize: 17, weight: .medium))
        imageView.tintColor = UIColor(red: 0.251, green: 0.251, blue: 0.251, alpha: 1.0) // #404040
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private let searchTextField: UITextField = {
        let textField = UITextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.attributedPlaceholder = NSAttributedString(
            string: "Buscar nombre o com...",
            attributes: [.foregroundColor: UIColor(red: 0.851, green: 0.851, blue: 0.851, alpha: 1.0)] // #D9D9D9
        )
        textField.font = UIFont.systemFont(ofSize: 17, weight: .medium)
        textField.textColor = UIColor(red: 0.129, green: 0.106, blue: 0.224, alpha: 1.0)
        textField.borderStyle = .none
        textField.backgroundColor = .clear
        textField.returnKeyType = .search
        textField.clearButtonMode = .whileEditing
        return textField
    }()
    
    private let cancelButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Cancelar", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 17, weight: .regular)
        button.setTitleColor(UIColor(red: 0.129, green: 0.106, blue: 0.224, alpha: 1.0), for: .normal)
        return button
    }()
    
    private let filterChipsView: FilterChipsView = {
        let view = FilterChipsView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.showsVerticalScrollIndicator = false
        scrollView.alwaysBounceVertical = true
        scrollView.keyboardDismissMode = .onDrag
        return scrollView
    }()
    
    private let contentStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = 8  // gap: 8px between items per CSS
        stackView.alignment = .fill
        return stackView
    }()
    
    private var currentlyExpandedCell: TransactionCell?
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupConstraints()
        setupActions()
        loadTransactions()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        searchTextField.becomeFirstResponder()
    }
    
    // MARK: - Setup
    
    private func setupUI() {
        view.backgroundColor = UIColor(red: 0.988, green: 0.988, blue: 0.992, alpha: 1.0) // #FCFCFD
        
        view.addSubview(searchContainerView)
        searchContainerView.addSubview(searchIcon)
        searchContainerView.addSubview(searchTextField)
        view.addSubview(cancelButton)
        view.addSubview(filterChipsView)
        view.addSubview(scrollView)
        scrollView.addSubview(contentStackView)
        
        searchTextField.delegate = self
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // Search container
            searchContainerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            searchContainerView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            searchContainerView.trailingAnchor.constraint(equalTo: cancelButton.leadingAnchor, constant: -12),
            searchContainerView.heightAnchor.constraint(equalToConstant: 48),
            
            // Search icon
            searchIcon.leadingAnchor.constraint(equalTo: searchContainerView.leadingAnchor, constant: 16),
            searchIcon.centerYAnchor.constraint(equalTo: searchContainerView.centerYAnchor),
            searchIcon.widthAnchor.constraint(equalToConstant: 20),
            searchIcon.heightAnchor.constraint(equalToConstant: 20),
            
            // Search text field
            searchTextField.leadingAnchor.constraint(equalTo: searchIcon.trailingAnchor, constant: 8),
            searchTextField.trailingAnchor.constraint(equalTo: searchContainerView.trailingAnchor, constant: -16),
            searchTextField.centerYAnchor.constraint(equalTo: searchContainerView.centerYAnchor),
            
            // Cancel button
            cancelButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            cancelButton.centerYAnchor.constraint(equalTo: searchContainerView.centerYAnchor),
            
            // Filter chips
            filterChipsView.topAnchor.constraint(equalTo: searchContainerView.bottomAnchor, constant: 16),
            filterChipsView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            filterChipsView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            filterChipsView.heightAnchor.constraint(equalToConstant: 50),
            
            // Scroll view
            scrollView.topAnchor.constraint(equalTo: filterChipsView.bottomAnchor, constant: 8),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            // Content stack view - 16px horizontal padding to match outer container
            contentStackView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentStackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 16),
            contentStackView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -16),
            contentStackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: -100),
            contentStackView.widthAnchor.constraint(equalTo: scrollView.widthAnchor, constant: -32)
        ])
    }
    
    private func setupActions() {
        cancelButton.addTarget(self, action: #selector(cancelTapped), for: .touchUpInside)
        
        // Handle filter callbacks
        filterChipsView.onFilterSelected = { [weak self] filterType, anchorView in
            self?.handleFilterSelection(filterType, anchorView: anchorView)
        }
        
        filterChipsView.onFilterCleared = { [weak self] filterType in
            self?.handleFilterCleared(filterType)
        }
    }
    
    // MARK: - Data
    
    private func loadTransactions() {
        // Sample transactions - in real app, these would come from a data source
        let today = Date()
        let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: today)!
        
        allTransactions = [
            Transaction(
                id: UUID(),
                name: "Retiro sin tarjeta",
                description: "",
                amount: -50.00,
                balance: 200.00,
                date: today,
                type: .withdrawal,
                status: .toWithdraw,
                recipientName: nil,
                recipientPhone: nil,
                timeRemaining: "23 h",
                progressRemaining: 0.95
            ),
            Transaction(
                id: UUID(),
                name: "Daniel Rodriguez",
                description: "Movimiento interno",
                amount: 1600.00,
                balance: 1640.00,
                date: today,
                type: .transfer
            ),
            Transaction(
                id: UUID(),
                name: "CNEL",
                description: "Servicio de luz",
                amount: -120.21,
                balance: 1200.00,
                date: today,
                type: .electricity,
                status: .completed,
                recipientName: nil,
                recipientPhone: nil,
                timeRemaining: nil,
                progressRemaining: nil,
                contractNumber: "123456789",
                meterNumber: "987654321",
                serviceAmount: 120.00,
                commission: 0.18,
                tax: 0.03
            ),
            Transaction(
                id: UUID(),
                name: "Fernanda Ortiz Viveka",
                description: "Mercado frutas",
                amount: -60.00,
                balance: 200.00,
                date: today,
                type: .transfer
            ),
            Transaction(
                id: UUID(),
                name: "Uber rides",
                description: "",
                amount: 60.00,
                balance: 200.00,
                date: yesterday,
                type: .deposit,
                status: .pending
            ),
            Transaction(
                id: UUID(),
                name: "Transferencia a tu meta",
                description: "Vacaciones Argentina",
                amount: -10.00,
                balance: 250.00,
                date: yesterday,
                type: .goal
            )
        ]
        
        groupTransactionsByDate()
        filteredTransactions = groupedTransactions
        rebuildTransactionViews()
    }
    
    private func groupTransactionsByDate() {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let yesterday = calendar.date(byAdding: .day, value: -1, to: today)!
        
        var todayTransactions: [Transaction] = []
        var yesterdayTransactions: [Transaction] = []
        var otherTransactions: [String: [Transaction]] = [:]
        
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "es_ES")
        
        for transaction in allTransactions {
            let transactionDate = calendar.startOfDay(for: transaction.date)
            
            if transactionDate == today {
                todayTransactions.append(transaction)
            } else if transactionDate == yesterday {
                yesterdayTransactions.append(transaction)
            } else {
                dateFormatter.dateFormat = "d MMM"
                let dateString = dateFormatter.string(from: transaction.date)
                if otherTransactions[dateString] == nil {
                    otherTransactions[dateString] = []
                }
                otherTransactions[dateString]?.append(transaction)
            }
        }
        
        groupedTransactions = []
        
        if !todayTransactions.isEmpty {
            groupedTransactions.append(TransactionSection(title: "Hoy", transactions: todayTransactions))
        }
        
        if !yesterdayTransactions.isEmpty {
            dateFormatter.dateFormat = "d MMM"
            let yesterdayString = "Ayer " + dateFormatter.string(from: yesterday)
            groupedTransactions.append(TransactionSection(title: yesterdayString, transactions: yesterdayTransactions))
        }
        
        for (dateString, transactions) in otherTransactions.sorted(by: { $0.key > $1.key }) {
            groupedTransactions.append(TransactionSection(title: dateString, transactions: transactions))
        }
    }
    
    private func rebuildTransactionViews() {
        // Clear existing views
        contentStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        for section in filteredTransactions {
            // Add section header with proper padding to align with transaction icons
            let headerContainer = UIView()
            headerContainer.translatesAutoresizingMaskIntoConstraints = false
            
            let headerLabel = UILabel()
            headerLabel.translatesAutoresizingMaskIntoConstraints = false
            headerLabel.text = section.title
            headerLabel.font = .manrope(size: 15, weight: .bold)
            headerLabel.textColor = UIColor(red: 0.235, green: 0.235, blue: 0.263, alpha: 0.6)
            
            headerContainer.addSubview(headerLabel)
            NSLayoutConstraint.activate([
                headerContainer.heightAnchor.constraint(equalToConstant: 52),
                // 16px padding to align with TransactionCell's internal icon padding
                headerLabel.leadingAnchor.constraint(equalTo: headerContainer.leadingAnchor, constant: 16),
                headerLabel.centerYAnchor.constraint(equalTo: headerContainer.centerYAnchor)
            ])
            contentStackView.addArrangedSubview(headerContainer)
            
            // Add transactions directly - they have internal 16px padding for icon
            for transaction in section.transactions {
                let cell = TransactionCell()
                cell.configure(with: transaction)
                cell.onExpansionChanged = { [weak self] isExpanded in
                    guard let self = self else { return }
                    if isExpanded {
                        if let previous = self.currentlyExpandedCell, previous !== cell {
                            previous.collapse()
                        }
                        self.currentlyExpandedCell = cell
                    } else {
                        if self.currentlyExpandedCell === cell {
                            self.currentlyExpandedCell = nil
                        }
                    }
                }
                
                // Add cell directly - TransactionCell's internal padding aligns icon with header text
                contentStackView.addArrangedSubview(cell)
            }
        }
    }
    
    // MARK: - Search
    
    private func performSearch(_ query: String) {
        if query.isEmpty {
            filteredTransactions = groupedTransactions
        } else {
            let lowercasedQuery = query.lowercased()
            filteredTransactions = groupedTransactions.compactMap { section in
                let filteredList = section.transactions.filter { transaction in
                    transaction.name.lowercased().contains(lowercasedQuery) ||
                    transaction.description.lowercased().contains(lowercasedQuery)
                }
                return filteredList.isEmpty ? nil : TransactionSection(title: section.title, transactions: filteredList)
            }
        }
        rebuildTransactionViews()
    }
    
    // MARK: - Filter Handling
    
    private func handleFilterSelection(_ filterType: String, anchorView: UIView) {
        // In a real app, you would show filter pickers here
        print("Filter selected: \(filterType)")
    }
    
    private func handleFilterCleared(_ filterType: String) {
        print("Filter cleared: \(filterType)")
    }
    
    // MARK: - Actions
    
    @objc private func cancelTapped() {
        searchTextField.resignFirstResponder()
        dismiss(animated: true)
    }
}

// MARK: - UITextFieldDelegate

extension SearchViewController: UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let currentText = textField.text ?? ""
        let updatedText = (currentText as NSString).replacingCharacters(in: range, with: string)
        performSearch(updatedText)
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        performSearch("")
        return true
    }
}
