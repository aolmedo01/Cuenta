import UIKit

final class CuentaViewController: UIViewController {
    
    // MARK: - Properties
    private var account = Account(
        accountNumber: "12788373662",
        accountType: "AHO",
        balance: 1482000.00
    )
    
    private var transactionSections: [TransactionSection] = []
    
    // MARK: - UI Components
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.showsVerticalScrollIndicator = false
        scrollView.alwaysBounceVertical = true
        return scrollView
    }()
    
    private let contentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let mainStackView: UIStackView = {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.spacing = 8
        stack.alignment = .fill
        return stack
    }()
    
    // MARK: - Header Components
    private let headerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .clear
        return view
    }()
    
    private let toolbarView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var backButton: CircleIconButton = {
        let button = CircleIconButton(systemName: "chevron.left")
        button.addTarget(self, action: #selector(backTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var cardButton: CircleIconButton = {
        let button = CircleIconButton(systemName: "creditcard")
        button.addTarget(self, action: #selector(cardTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var moreButton: CircleIconButton = {
        let button = CircleIconButton(systemName: "ellipsis")
        button.addTarget(self, action: #selector(moreTapped), for: .touchUpInside)
        return button
    }()
    
    private let balanceLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .balanceTitle
        label.textColor = .textPrimary
        return label
    }()
    
    private let accountNumberContainer: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let accountNumberLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .accountSubtitle
        label.textColor = .textSecondary
        return label
    }()
    
    private lazy var copyButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage(systemName: "square.and.arrow.up")?
            .withConfiguration(UIImage.SymbolConfiguration(pointSize: 12, weight: .medium)), for: .normal)
        button.tintColor = .textNavy
        button.addTarget(self, action: #selector(copyAccountNumber), for: .touchUpInside)
        return button
    }()
    
    // MARK: - Transfer Button
    private lazy var transferButton: TransferButton = {
        let button = TransferButton()
        button.addTarget(self, action: #selector(transferTapped), for: .touchUpInside)
        return button
    }()
    
    private let transferContainer: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    // MARK: - Search
    private let searchBarView = SearchBarView()
    
    private let searchContainer: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    // MARK: - Filter Chips
    private let filterChipsView: FilterChipsView = {
        let view = FilterChipsView()
        view.isHidden = true
        view.alpha = 0
        return view
    }()
    
    private var isFilterVisible = false
    private var activeDropdown: DropdownMenuView?
    private var activeFilterType: String?
    
    // MARK: - Transactions Container
    private let transactionsStackView: UIStackView = {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.spacing = 0
        return stack
    }()
    
    // MARK: - History
    private let historyStackView: UIStackView = {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.spacing = 16
        return stack
    }()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupData()
        updateUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    // MARK: - Setup
    private func setupUI() {
        view.backgroundColor = .appBackground
        
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        contentView.addSubview(mainStackView)
        
        setupHeader()
        setupTransferButton()
        setupSearchBar()
        setupTransactions()
        setupHistory()
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            mainStackView.topAnchor.constraint(equalTo: contentView.topAnchor),
            mainStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            mainStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            mainStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -32)
        ])
    }
    
    private func setupHeader() {
        mainStackView.addArrangedSubview(headerView)
        
        headerView.addSubview(toolbarView)
        toolbarView.addSubview(backButton)
        toolbarView.addSubview(cardButton)
        toolbarView.addSubview(moreButton)
        
        headerView.addSubview(balanceLabel)
        headerView.addSubview(accountNumberContainer)
        accountNumberContainer.addSubview(accountNumberLabel)
        accountNumberContainer.addSubview(copyButton)
        
        NSLayoutConstraint.activate([
            headerView.heightAnchor.constraint(equalToConstant: 136),
            
            // Toolbar
            toolbarView.topAnchor.constraint(equalTo: headerView.topAnchor, constant: 10),
            toolbarView.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 16),
            toolbarView.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -16),
            toolbarView.heightAnchor.constraint(equalToConstant: 44),
            
            // Back Button
            backButton.leadingAnchor.constraint(equalTo: toolbarView.leadingAnchor),
            backButton.centerYAnchor.constraint(equalTo: toolbarView.centerYAnchor),
            
            // More Button
            moreButton.trailingAnchor.constraint(equalTo: toolbarView.trailingAnchor),
            moreButton.centerYAnchor.constraint(equalTo: toolbarView.centerYAnchor),
            
            // Card Button
            cardButton.trailingAnchor.constraint(equalTo: moreButton.leadingAnchor, constant: -10),
            cardButton.centerYAnchor.constraint(equalTo: toolbarView.centerYAnchor),
            
            // Balance
            balanceLabel.topAnchor.constraint(equalTo: toolbarView.bottomAnchor, constant: 16),
            balanceLabel.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 16),
            
            // Account Number Container
            accountNumberContainer.topAnchor.constraint(equalTo: balanceLabel.bottomAnchor, constant: 8),
            accountNumberContainer.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 16),
            
            accountNumberLabel.leadingAnchor.constraint(equalTo: accountNumberContainer.leadingAnchor),
            accountNumberLabel.centerYAnchor.constraint(equalTo: accountNumberContainer.centerYAnchor),
            
            copyButton.leadingAnchor.constraint(equalTo: accountNumberLabel.trailingAnchor, constant: 8),
            copyButton.trailingAnchor.constraint(equalTo: accountNumberContainer.trailingAnchor),
            copyButton.centerYAnchor.constraint(equalTo: accountNumberContainer.centerYAnchor),
            copyButton.widthAnchor.constraint(equalToConstant: 20),
            copyButton.heightAnchor.constraint(equalToConstant: 20),
            
            accountNumberContainer.heightAnchor.constraint(equalToConstant: 17)
        ])
    }
    
    private func setupTransferButton() {
        mainStackView.addArrangedSubview(transferContainer)
        transferContainer.addSubview(transferButton)
        
        NSLayoutConstraint.activate([
            transferContainer.heightAnchor.constraint(equalToConstant: 64),
            
            transferButton.centerXAnchor.constraint(equalTo: transferContainer.centerXAnchor),
            transferButton.centerYAnchor.constraint(equalTo: transferContainer.centerYAnchor)
        ])
    }
    
    private func setupSearchBar() {
        mainStackView.addArrangedSubview(searchContainer)
        searchContainer.addSubview(searchBarView)
        
        // Add filter chips below search bar
        mainStackView.addArrangedSubview(filterChipsView)
        
        // Wire up filter button
        searchBarView.filterButton.addTarget(self, action: #selector(filterButtonTapped), for: .touchUpInside)
        
        // Handle filter selection
        filterChipsView.onFilterSelected = { [weak self] filterType, anchorView in
            self?.handleFilterSelection(filterType, anchorView: anchorView)
        }
        
        NSLayoutConstraint.activate([
            searchContainer.heightAnchor.constraint(equalToConstant: 64),
            
            searchBarView.leadingAnchor.constraint(equalTo: searchContainer.leadingAnchor, constant: 16),
            searchBarView.trailingAnchor.constraint(equalTo: searchContainer.trailingAnchor, constant: -16),
            searchBarView.centerYAnchor.constraint(equalTo: searchContainer.centerYAnchor)
        ])
    }
    
    private func setupTransactions() {
        mainStackView.addArrangedSubview(transactionsStackView)
    }
    
    private func setupHistory() {
        let historyContainer = UIView()
        historyContainer.translatesAutoresizingMaskIntoConstraints = false
        
        mainStackView.addArrangedSubview(historyContainer)
        historyContainer.addSubview(historyStackView)
        
        NSLayoutConstraint.activate([
            historyStackView.topAnchor.constraint(equalTo: historyContainer.topAnchor, constant: 16),
            historyStackView.leadingAnchor.constraint(equalTo: historyContainer.leadingAnchor, constant: 16),
            historyStackView.trailingAnchor.constraint(equalTo: historyContainer.trailingAnchor, constant: -16),
            historyStackView.bottomAnchor.constraint(equalTo: historyContainer.bottomAnchor)
        ])
        
        // Movimientos 2025
        let monthsSection = HistorySectionView()
        monthsSection.configure(title: "Movimientos 2025", items: ["Febrero", "Enero"])
        historyStackView.addArrangedSubview(monthsSection)
        
        // Movimientos por año
        let yearsSection = HistorySectionView()
        yearsSection.configure(title: "Movimientos por año", items: ["2025", "2024", "2023", "2022"])
        historyStackView.addArrangedSubview(yearsSection)
    }
    
    // MARK: - Data
    private func setupData() {
        // Sample transactions
        let today = Date()
        let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: today)!
        let twoDaysAgo = Calendar.current.date(byAdding: .day, value: -2, to: today)!
        
        let todayTransactions: [Transaction] = [
            Transaction(id: UUID(), name: "Daniel Rodriguez", description: "Movimiento interno", amount: 1600.00, balance: 1640.00, date: today, type: .transfer),
            Transaction(id: UUID(), name: "Retiro sin tarjeta", description: "Cajero automático", amount: -40.00, balance: 1600.00, date: today, type: .withdrawal)
        ]
        
        let yesterdayTransactions: [Transaction] = [
            Transaction(id: UUID(), name: "Fernanda Ortiz Viveka", description: "Mercado frutas", amount: -60.00, balance: 200.00, date: yesterday, type: .payment),
            Transaction(id: UUID(), name: "David Guerra", description: "Alquiler", amount: 60.00, balance: 260.00, date: yesterday, type: .deposit),
            Transaction(id: UUID(), name: "Transferencia a tu meta", description: "Vacaciones Argentina", amount: -10.00, balance: 250.00, date: yesterday, type: .goal),
            Transaction(id: UUID(), name: "Retiro en ventanilla", description: "Agencia Mall del Sol", amount: -50.00, balance: 260.00, date: yesterday, type: .withdrawal),
            Transaction(id: UUID(), name: "Emapad", description: "Pago de servicio agua", amount: -10.00, balance: 310.00, date: yesterday, type: .payment),
            Transaction(id: UUID(), name: "Guerrero Keyla", description: "Salida sushi", amount: 60.00, balance: 320.00, date: yesterday, type: .deposit),
            Transaction(id: UUID(), name: "Retiro de tu meta", description: "Carrito 2026", amount: 100.00, balance: 260.00, date: yesterday, type: .goal)
        ]
        
        let twoDaysAgoTransactions: [Transaction] = [
            Transaction(id: UUID(), name: "Chocolateria San Ferna", description: "Compra con tarjeta", amount: -80.00, balance: 160.00, date: twoDaysAgo, type: .cardPurchase),
            Transaction(id: UUID(), name: "Transferencia a tu meta", description: "Vacaciones Argentina", amount: -220.00, balance: 240.00, date: twoDaysAgo, type: .goal),
            Transaction(id: UUID(), name: "Sueldo acreditado", description: "Transferencia recibida", amount: 460.00, balance: 480.00, date: twoDaysAgo, type: .salary)
        ]
        
        transactionSections = [
            TransactionSection(title: "Hoy", transactions: todayTransactions),
            TransactionSection(title: "Ayer 6 mar", transactions: yesterdayTransactions),
            TransactionSection(title: "Jueves 5 mar", transactions: twoDaysAgoTransactions)
        ]
    }
    
    // MARK: - Update UI
    private func updateUI() {
        // Use attributed strings for proper letter-spacing
        balanceLabel.attributedText = .balance(account.formattedBalance)
        accountNumberLabel.attributedText = .accountNumber(account.formattedAccountNumber)
        
        // Clear existing transactions
        transactionsStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        // Add transaction sections
        for section in transactionSections {
            let sectionContainer = UIView()
            sectionContainer.translatesAutoresizingMaskIntoConstraints = false
            
            let sectionStack = UIStackView()
            sectionStack.translatesAutoresizingMaskIntoConstraints = false
            sectionStack.axis = .vertical
            sectionStack.spacing = 0
            
            // Section header
            let header = SectionHeaderView(title: section.title)
            sectionStack.addArrangedSubview(header)
            
            // Transaction cells
            for transaction in section.transactions {
                let cell = TransactionCell()
                cell.configure(with: transaction)
                sectionStack.addArrangedSubview(cell)
            }
            
            sectionContainer.addSubview(sectionStack)
            
            NSLayoutConstraint.activate([
                sectionStack.topAnchor.constraint(equalTo: sectionContainer.topAnchor),
                sectionStack.leadingAnchor.constraint(equalTo: sectionContainer.leadingAnchor, constant: 16),
                sectionStack.trailingAnchor.constraint(equalTo: sectionContainer.trailingAnchor, constant: -16),
                sectionStack.bottomAnchor.constraint(equalTo: sectionContainer.bottomAnchor)
            ])
            
            transactionsStackView.addArrangedSubview(sectionContainer)
        }
    }
    
    // MARK: - Actions
    @objc private func backTapped() {
        navigationController?.popViewController(animated: true)
    }
    
    @objc private func cardTapped() {
        print("Card tapped")
    }
    
    @objc private func moreTapped() {
        print("More tapped")
    }
    
    @objc private func copyAccountNumber() {
        UIPasteboard.general.string = account.accountNumber
        
        // Visual feedback
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
    }
    
    @objc private func transferTapped() {
        print("Transfer tapped")
    }
    
    @objc private func filterButtonTapped() {
        isFilterVisible.toggle()
        
        // Haptic feedback
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
        
        // Update filter button appearance
        UIView.animate(withDuration: 0.2) {
            if self.isFilterVisible {
                // Active state - blue background, white icon
                self.searchBarView.filterOverlay.backgroundColor = .accentBlue
                self.searchBarView.filterButton.tintColor = .white
            } else {
                // Inactive state - glass background, blue icon
                self.searchBarView.filterOverlay.backgroundColor = UIColor(red: 0.969, green: 0.969, blue: 0.969, alpha: 0.85)
                self.searchBarView.filterButton.tintColor = .accentBlue
            }
        }
        
        // Show/hide filter chips
        if isFilterVisible {
            filterChipsView.show()
        } else {
            filterChipsView.hide()
        }
    }
    
    private func handleFilterSelection(_ filterType: String, anchorView: UIView) {
        // Haptic feedback
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
        
        // If same filter is tapped again, close the dropdown
        if activeFilterType == filterType && activeDropdown != nil {
            activeDropdown?.dismiss()
            activeDropdown = nil
            activeFilterType = nil
            return
        }
        
        // Dismiss any existing dropdown
        activeDropdown?.dismiss()
        activeDropdown = nil
        activeFilterType = nil
        
        switch filterType {
        case "fecha":
            showDateFilterDropdown(from: anchorView)
            activeFilterType = filterType
        case "tipo":
            showTypeFilterDropdown(from: anchorView)
            activeFilterType = filterType
        case "monto":
            showAmountFilterDropdown(from: anchorView)
            activeFilterType = filterType
        case "todos":
            showAllFilters()
        default:
            break
        }
    }
    
    private func showDateFilterDropdown(from anchorView: UIView) {
        let dropdown = DropdownMenuView.dateFilterMenu(selectedIndex: 0)
        dropdown.onItemSelected = { [weak self] index, item in
            guard let self = self else { return }
            print("Date filter selected: \(item.title)")
            
            // If "Personalizado" is selected, dismiss dropdown and show date picker
            if item.title == "Personalizado" {
                self.activeDropdown?.dismiss()
                self.activeDropdown = nil
                self.activeFilterType = nil
                
                // Present date range picker
                DateRangePickerViewController.present(from: self, delegate: self)
            }
            // For other options, just update the selection (dropdown stays open)
        }
        dropdown.onDismiss = { [weak self] in
            self?.activeDropdown = nil
            self?.activeFilterType = nil
        }
        dropdown.show(from: anchorView, in: view)
        activeDropdown = dropdown
    }
    
    private func showTypeFilterDropdown(from anchorView: UIView) {
        let dropdown = DropdownMenuView.typeFilterMenu()
        dropdown.onItemSelected = { [weak self] index, item in
            print("Type filter selected: \(item.title)")
            // Apply filter logic here
        }
        dropdown.onDismiss = { [weak self] in
            self?.activeDropdown = nil
            self?.activeFilterType = nil
        }
        dropdown.show(from: anchorView, in: view)
        activeDropdown = dropdown
    }
    
    private func showAmountFilterDropdown(from anchorView: UIView) {
        let dropdown = DropdownMenuView.amountFilterMenu()
        dropdown.onItemSelected = { [weak self] index, item in
            guard let self = self else { return }
            print("Amount filter selected: \(item.title)")
            
            // If "Personalizado" is selected, dismiss dropdown and show amount range picker
            if item.title == "Personalizado" {
                self.activeDropdown?.dismiss()
                self.activeDropdown = nil
                self.activeFilterType = nil
                
                // Present amount range picker
                AmountRangePickerViewController.present(from: self, delegate: self)
            }
        }
        dropdown.onDismiss = { [weak self] in
            self?.activeDropdown = nil
            self?.activeFilterType = nil
        }
        dropdown.show(from: anchorView, in: view)
        activeDropdown = dropdown
    }
    
    private func showAllFilters() {
        AllFiltersViewController.present(from: self, delegate: self)
    }
}

// MARK: - DateRangePickerDelegate
extension CuentaViewController: DateRangePickerDelegate {
    func dateRangePicker(_ picker: DateRangePickerViewController, didSelectStartDate startDate: Date, endDate: Date) {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "es_ES")
        formatter.dateFormat = "d MMM yyyy"
        
        print("Date range selected: \(formatter.string(from: startDate)) - \(formatter.string(from: endDate))")
        
        // TODO: Apply date filter to transactions
        // You can filter transactionSections here based on the selected date range
    }
    
    func dateRangePickerDidCancel(_ picker: DateRangePickerViewController) {
        print("Date range picker cancelled")
    }
}

// MARK: - AmountRangePickerDelegate
extension CuentaViewController: AmountRangePickerDelegate {
    func amountRangePicker(_ picker: AmountRangePickerViewController, didSelectMinAmount minAmount: Double?, maxAmount: Double?) {
        var rangeDescription = "Amount range:"
        if let min = minAmount {
            rangeDescription += " min $\(min)"
        }
        if let max = maxAmount {
            rangeDescription += " max $\(max)"
        }
        print(rangeDescription)
        
        // TODO: Apply amount filter to transactions
        // You can filter transactionSections here based on the selected amount range
    }
    
    func amountRangePickerDidCancel(_ picker: AmountRangePickerViewController) {
        print("Amount range picker cancelled")
    }
}

// MARK: - AllFiltersDelegate
extension CuentaViewController: AllFiltersDelegate {
    func allFiltersDidApply(_ filters: AllFiltersViewController.FilterState) {
        print("Filters applied:")
        print("  Date: \(filters.startDate) - \(filters.endDate)")
        print("  Type: \(filters.transactionType)")
        print("  Amount: \(filters.minAmount ?? 0) - \(filters.maxAmount ?? 0)")
        
        // TODO: Apply all filters to transactions
    }
    
    func allFiltersDidCancel() {
        print("All filters cancelled")
    }
    
    func allFiltersDidReset() {
        print("Filters reset")
    }
}
