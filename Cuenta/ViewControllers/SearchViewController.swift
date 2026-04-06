import UIKit

final class SearchViewController: UIViewController {
    
    // MARK: - Properties
    private var allTransactions: [Transaction] = []
    private var groupedTransactions: [TransactionSection] = []
    private var filteredTransactions: [TransactionSection] = []
    
    // Filter state
    private var selectedDateRange: (start: Date, end: Date)?
    private var selectedType: String?
    private var selectedAmountRange: (min: Double, max: Double)?
    private var currentSearchQuery: String = ""
    
    // Dropdown state
    private var activeDropdown: DropdownMenuView?
    private var activeFilterType: String?
    
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
        stackView.spacing = 0
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
        view.backgroundColor = UIColor(red: 0.961, green: 0.965, blue: 0.973, alpha: 1) // #F5F6F8 - same as movements background
        
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
        
        filterChipsView.onResetAllFilters = { [weak self] in
            guard let self = self else { return }
            self.selectedDateRange = nil
            self.selectedType = nil
            self.selectedAmountRange = nil
            self.applyFilters()
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
        
        // Initial display with all transactions
        applyFilters()
    }
    
    private func rebuildTransactionViews() {
        // Clear existing views
        contentStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        for section in filteredTransactions {
            // Add section header with proper padding
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
                // No extra padding - label starts at edge, stack already has 16px padding
                headerLabel.leadingAnchor.constraint(equalTo: headerContainer.leadingAnchor),
                headerLabel.centerYAnchor.constraint(equalTo: headerContainer.centerYAnchor)
            ])
            contentStackView.addArrangedSubview(headerContainer)
            
            // Create a section stack for transactions with 16px spacing
            let sectionStack = UIStackView()
            sectionStack.axis = .vertical
            sectionStack.spacing = 16
            sectionStack.translatesAutoresizingMaskIntoConstraints = false
            
            // Add transactions to section stack
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
                sectionStack.addArrangedSubview(cell)
            }
            
            contentStackView.addArrangedSubview(sectionStack)
        }
    }
    
    // MARK: - Search
    
    private func performSearch(_ query: String) {
        currentSearchQuery = query
        applyFilters()
    }
    
    // MARK: - Filter Handling
    
    private func handleFilterSelection(_ filterType: String, anchorView: UIView) {
        switch filterType {
        case "fecha":
            showDateRangePicker(anchorView: anchorView)
        case "tipo":
            showTypePicker(anchorView: anchorView)
        case "monto":
            showAmountRangePicker(anchorView: anchorView)
        case "todos":
            showAllFilters()
        default:
            break
        }
    }
    
    private func handleFilterCleared(_ filterType: String) {
        switch filterType {
        case "fecha":
            selectedDateRange = nil
        case "tipo":
            selectedType = nil
        case "monto":
            selectedAmountRange = nil
        default:
            break
        }
        applyFilters()
    }
    
    private func showDateRangePicker(anchorView: UIView) {
        DateRangePickerViewController.present(from: self, delegate: self)
    }
    
    private func showTypePicker(anchorView: UIView) {
        let types = ["Transferencia", "Retiro", "Depósito", "Pago", "Meta", "Compra"]
        
        let alertController = UIAlertController(title: "Tipo de movimiento", message: nil, preferredStyle: .actionSheet)
        
        for type in types {
            alertController.addAction(UIAlertAction(title: type, style: .default) { [weak self] _ in
                self?.selectedType = type
                self?.filterChipsView.setTypeFilter(type)
                self?.applyFilters()
            })
        }
        
        alertController.addAction(UIAlertAction(title: "Cancelar", style: .cancel))
        
        if let popover = alertController.popoverPresentationController {
            popover.sourceView = anchorView
            popover.sourceRect = anchorView.bounds
        }
        
        present(alertController, animated: true)
    }
    
    private func showAmountRangePicker(anchorView: UIView) {
        AmountRangePickerViewController.present(from: self, delegate: self)
    }
    
    private func showAllFilters() {
        AllFiltersViewController.present(from: self, delegate: self)
    }
    
    private func applyFilters() {
        var filtered = allTransactions
        
        // Apply date filter
        if let dateRange = selectedDateRange {
            filtered = filtered.filter { transaction in
                transaction.date >= dateRange.start && transaction.date <= dateRange.end
            }
        }
        
        // Apply type filter
        if let type = selectedType {
            filtered = filtered.filter { transaction in
                switch type.lowercased() {
                case "transferencia":
                    return transaction.type == .transfer
                case "retiro":
                    return transaction.type == .withdrawal
                case "depósito":
                    return transaction.type == .deposit
                case "pago":
                    return transaction.type == .payment || transaction.type == .electricity
                case "meta":
                    return transaction.type == .goal
                case "compra":
                    return transaction.type == .cardPurchase
                default:
                    return true
                }
            }
        }
        
        // Apply amount filter
        if let amountRange = selectedAmountRange {
            filtered = filtered.filter { transaction in
                let absAmount = abs(transaction.amount)
                return absAmount >= amountRange.min && absAmount <= amountRange.max
            }
        }
        
        // Apply search query
        if !currentSearchQuery.isEmpty {
            let query = currentSearchQuery.lowercased()
            filtered = filtered.filter { transaction in
                transaction.name.lowercased().contains(query) ||
                transaction.description.lowercased().contains(query)
            }
        }
        
        // Group by date
        groupAndDisplayTransactions(filtered)
    }
    
    private func groupAndDisplayTransactions(_ transactions: [Transaction]) {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let yesterday = calendar.date(byAdding: .day, value: -1, to: today)!
        
        var todayList: [Transaction] = []
        var yesterdayList: [Transaction] = []
        var olderByDate: [Date: [Transaction]] = [:]
        
        for transaction in transactions {
            let transactionDay = calendar.startOfDay(for: transaction.date)
            
            if transactionDay == today {
                todayList.append(transaction)
            } else if transactionDay == yesterday {
                yesterdayList.append(transaction)
            } else {
                if olderByDate[transactionDay] == nil {
                    olderByDate[transactionDay] = []
                }
                olderByDate[transactionDay]?.append(transaction)
            }
        }
        
        var sections: [TransactionSection] = []
        
        if !todayList.isEmpty {
            sections.append(TransactionSection(title: "Hoy", transactions: todayList))
        }
        
        if !yesterdayList.isEmpty {
            let formatter = DateFormatter()
            formatter.dateFormat = "d MMM"
            formatter.locale = Locale(identifier: "es_ES")
            sections.append(TransactionSection(title: "Ayer \(formatter.string(from: yesterday))", transactions: yesterdayList))
        }
        
        // Sort older dates and add sections
        let sortedDates = olderByDate.keys.sorted(by: >)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "d MMM"
        dateFormatter.locale = Locale(identifier: "es_ES")
        
        for date in sortedDates {
            if let transactions = olderByDate[date] {
                sections.append(TransactionSection(title: dateFormatter.string(from: date), transactions: transactions))
            }
        }
        
        filteredTransactions = sections
        rebuildTransactionViews()
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

// MARK: - UIPopoverPresentationControllerDelegate

extension SearchViewController: UIPopoverPresentationControllerDelegate {
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }
}

// MARK: - DateRangePickerDelegate

extension SearchViewController: DateRangePickerDelegate {
    func dateRangePicker(_ picker: DateRangePickerViewController, didSelectStartDate startDate: Date, endDate: Date) {
        selectedDateRange = (startDate, endDate)
        
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "es_ES")
        formatter.dateFormat = "d MMM"
        
        let dateText = "\(formatter.string(from: startDate)) - \(formatter.string(from: endDate))"
        filterChipsView.setDateFilter(dateText)
        
        applyFilters()
    }
    
    func dateRangePickerDidCancel(_ picker: DateRangePickerViewController) {
        // Nothing to do
    }
}

// MARK: - AmountRangePickerDelegate

extension SearchViewController: AmountRangePickerDelegate {
    func amountRangePicker(_ picker: AmountRangePickerViewController, didSelectMinAmount minAmount: Double?, maxAmount: Double?) {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = Locale(identifier: "en_US")
        formatter.maximumFractionDigits = 0
        
        var amountText = ""
        if let min = minAmount, let max = maxAmount {
            selectedAmountRange = (min, max)
            let minStr = formatter.string(from: NSNumber(value: min)) ?? "$\(Int(min))"
            let maxStr = formatter.string(from: NSNumber(value: max)) ?? "$\(Int(max))"
            amountText = "\(minStr)- \(maxStr)"
        } else if let min = minAmount {
            selectedAmountRange = (min, Double.greatestFiniteMagnitude)
            let minStr = formatter.string(from: NSNumber(value: min)) ?? "$\(Int(min))"
            amountText = "> \(minStr)"
        } else if let max = maxAmount {
            selectedAmountRange = (0, max)
            let maxStr = formatter.string(from: NSNumber(value: max)) ?? "$\(Int(max))"
            amountText = "< \(maxStr)"
        }
        
        if !amountText.isEmpty {
            filterChipsView.setAmountFilter(amountText)
        }
        
        applyFilters()
    }
    
    func amountRangePickerDidCancel(_ picker: AmountRangePickerViewController) {
        // Nothing to do
    }
}

// MARK: - AllFiltersDelegate

extension SearchViewController: AllFiltersDelegate {
    func allFiltersDidApply(_ filters: AllFiltersViewController.FilterState) {
        // Apply date filter
        selectedDateRange = (filters.startDate, filters.endDate)
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "es_ES")
        formatter.dateFormat = "d MMM"
        let dateText = "\(formatter.string(from: filters.startDate)) - \(formatter.string(from: filters.endDate))"
        filterChipsView.setDateFilter(dateText)
        
        // Apply type filter
        if filters.transactionType != "Todos" {
            selectedType = filters.transactionType
            filterChipsView.setTypeFilter(filters.transactionType)
        }
        
        // Apply amount filter
        if let min = filters.minAmount, let max = filters.maxAmount {
            selectedAmountRange = (min, max)
            filterChipsView.setAmountFilter("$\(Int(min)) - $\(Int(max))")
        }
        
        applyFilters()
    }
    
    func allFiltersDidCancel() {
        // Nothing to do
    }
    
    func allFiltersDidReset() {
        selectedDateRange = nil
        selectedType = nil
        selectedAmountRange = nil
        filterChipsView.clearAllFilters()
        applyFilters()
    }
}
