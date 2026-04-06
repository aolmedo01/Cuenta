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
    private var selectedDateFilterIndex: Int = 0 // 0=7días, 1=15días, 2=30días, 4=personalizado
    
    // Dropdown state
    private var activeDropdown: DropdownMenuView?
    private var activeFilterType: String?
    
    // Pre-loaded pickers to avoid first-open lag
    private var preloadedDatePicker: DateRangePickerViewController?
    private var preloadedAmountPicker: AmountRangePickerViewController?
    
    // Scroll state for filter chips visibility
    private var filtersVisible: Bool = true
    private var filterChipsTopConstraint: NSLayoutConstraint?
    private var scrollViewTopToFiltersConstraint: NSLayoutConstraint?
    private var scrollViewTopToSearchConstraint: NSLayoutConstraint?
    
    // MARK: - UI Components
    
    private lazy var exportButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = .white
        button.layer.cornerRadius = 28
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOpacity = 0.15
        button.layer.shadowOffset = CGSize(width: 0, height: 4)
        button.layer.shadowRadius = 12
        button.setImage(UIImage(systemName: "square.and.arrow.up")?
            .withConfiguration(UIImage.SymbolConfiguration(pointSize: 18, weight: .medium)), for: .normal)
        button.tintColor = UIColor(red: 0, green: 0.478, blue: 1, alpha: 1) // Accent blue
        button.alpha = 0
        button.isHidden = true
        button.addTarget(self, action: #selector(exportTapped), for: .touchUpInside)
        return button
    }()
    
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
        preloadPickerResources()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // Don't auto-focus keyboard - let user tap first
        
        // Pre-load pickers after view appears to avoid lag on first use
        preloadPickers()
        
        // Pre-generate CSV file for faster export
        preloadExportFile()
    }
    
    // MARK: - Preloading
    
    /// Pre-instantiate pickers in main thread after small delay to avoid blocking UI
    private func preloadPickers() {
        // Small delay to let the view finish appearing
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [weak self] in
            guard let self = self else { return }
            
            // Pre-create DateRangePickerViewController (creates 35 calendar buttons, formatters, etc.)
            if self.preloadedDatePicker == nil {
                let picker = DateRangePickerViewController()
                picker.loadViewIfNeeded() // Force view hierarchy creation
                self.preloadedDatePicker = picker
            }
            
            // Pre-create AmountRangePickerViewController
            if self.preloadedAmountPicker == nil {
                let picker = AmountRangePickerViewController()
                picker.loadViewIfNeeded()
                self.preloadedAmountPicker = picker
            }
        }
    }
    
    /// Pre-generate CSV file so it's ready when user wants to export
    private func preloadExportFile() {
        DispatchQueue.global(qos: .background).async { [weak self] in
            guard let self = self else { return }
            
            // Pre-create the CSV file
            let fileName = self.generateExcelFileName()
            let csvContent = self.generateCSVContent()
            let tempDirectory = FileManager.default.temporaryDirectory
            let fileURL = tempDirectory.appendingPathComponent(fileName)
            
            try? csvContent.write(to: fileURL, atomically: true, encoding: .utf8)
            
            // Pre-warm UIActivityViewController (loads share extensions in background)
            DispatchQueue.main.async {
                let dummyItem = "preload"
                let _ = UIActivityViewController(activityItems: [dummyItem], applicationActivities: nil)
            }
        }
    }
    
    /// Pre-load expensive resources (DateFormatters, locales) in background to avoid lag on first picker presentation
    private func preloadPickerResources() {
        DispatchQueue.global(qos: .userInitiated).async {
            // Warm up DateFormatter with Spanish locale
            let formatter = DateFormatter()
            formatter.locale = Locale(identifier: "es_ES")
            formatter.dateFormat = "d MMM yyyy"
            _ = formatter.string(from: Date())
            
            // Warm up month/year formatter
            let monthFormatter = DateFormatter()
            monthFormatter.locale = Locale(identifier: "es_ES")
            monthFormatter.dateFormat = "MMMM yyyy"
            _ = monthFormatter.string(from: Date())
            
            // Warm up NumberFormatter
            let numberFormatter = NumberFormatter()
            numberFormatter.numberStyle = .currency
            numberFormatter.locale = Locale(identifier: "en_US")
            _ = numberFormatter.string(from: NSNumber(value: 100))
        }
    }
    
    /// Present pre-loaded date picker or create new one if not ready
    private func presentDateRangePicker() {
        let picker: DateRangePickerViewController
        if let preloaded = preloadedDatePicker {
            picker = preloaded
            preloadedDatePicker = nil // Clear so we create a fresh one next time
        } else {
            picker = DateRangePickerViewController()
        }
        picker.delegate = self
        picker.modalPresentationStyle = .overFullScreen
        picker.modalTransitionStyle = .coverVertical
        present(picker, animated: true)
    }
    
    /// Present pre-loaded amount picker or create new one if not ready
    private func presentAmountRangePicker() {
        let picker: AmountRangePickerViewController
        if let preloaded = preloadedAmountPicker {
            picker = preloaded
            preloadedAmountPicker = nil // Clear so we create a fresh one next time
        } else {
            picker = AmountRangePickerViewController()
        }
        picker.delegate = self
        picker.modalPresentationStyle = .overFullScreen
        picker.modalTransitionStyle = .coverVertical
        present(picker, animated: true)
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
        view.addSubview(exportButton)
        
        searchTextField.delegate = self
        scrollView.delegate = self
    }
    
    private func setupConstraints() {
        // Create variable constraints for filter chips animation
        filterChipsTopConstraint = filterChipsView.topAnchor.constraint(equalTo: searchContainerView.bottomAnchor, constant: 16)
        scrollViewTopToFiltersConstraint = scrollView.topAnchor.constraint(equalTo: filterChipsView.bottomAnchor, constant: 8)
        scrollViewTopToSearchConstraint = scrollView.topAnchor.constraint(equalTo: searchContainerView.bottomAnchor, constant: 8)
        scrollViewTopToSearchConstraint?.isActive = false
        
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
            filterChipsTopConstraint!,
            filterChipsView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            filterChipsView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            filterChipsView.heightAnchor.constraint(equalToConstant: 50),
            
            // Scroll view
            scrollViewTopToFiltersConstraint!,
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            // Content stack view - 16px horizontal padding to match outer container
            contentStackView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentStackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 16),
            contentStackView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -16),
            contentStackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: -100),
            contentStackView.widthAnchor.constraint(equalTo: scrollView.widthAnchor, constant: -32),
            
            // Export button
            exportButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            exportButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -24),
            exportButton.widthAnchor.constraint(equalToConstant: 56),
            exportButton.heightAnchor.constraint(equalToConstant: 56)
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
            self.selectedDateFilterIndex = 0
            // UI only - filters cleared visually, no actual filtering
        }
    }
    
    // MARK: - Data
    
    private func loadTransactions() {
        // Same transactions as CuentaViewController
        let today = Date()
        let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: today)!
        let twoDaysAgo = Calendar.current.date(byAdding: .day, value: -2, to: today)!
        
        allTransactions = [
            // Hoy
            Transaction(
                id: UUID(),
                name: "Retiro sin tarjeta",
                description: "",
                amount: -50.00,
                balance: 0,
                date: today,
                type: .atmWithdrawal,
                status: .toWithdraw,
                recipientName: "Dani Olmedo",
                recipientPhone: "099 999 9999",
                timeRemaining: "23h 15m",
                progressRemaining: 0.75
            ),
            Transaction(id: UUID(), name: "Jessica Alfonso", description: "Movimiento interno", amount: 1600.00, balance: 1640.00, date: today, type: .transfer),
            Transaction(id: UUID(), name: "CNEL", description: "Pago de servicio luz", amount: -120.21, balance: 80.00, date: today, type: .electricity, serviceAmount: 120.00, commission: 0.18, tax: 0.03),
            Transaction(id: UUID(), name: "Carla Lecaro", description: "Mercado frutas", amount: -60.00, balance: 200.00, date: today, type: .payment),
            
            // Ayer
            Transaction(id: UUID(), name: "Isabela Jacome", description: "Alquiler", amount: 60.00, balance: 260.00, date: yesterday, type: .deposit),
            Transaction(id: UUID(), name: "Transferencia a tu meta", description: "Vacaciones Argentina", amount: -10.00, balance: 250.00, date: yesterday, type: .goal),
            Transaction(id: UUID(), name: "Retiro en ventanilla", description: "Agencia Mall del Sol", amount: -50.00, balance: 260.00, date: yesterday, type: .withdrawal),
            Transaction(id: UUID(), name: "Emapad", description: "Pago de servicio agua", amount: -10.00, balance: 310.00, date: yesterday, type: .payment),
            Transaction(id: UUID(), name: "Guerrero Keyla", description: "Salida sushi", amount: 60.00, balance: 320.00, date: yesterday, type: .deposit),
            Transaction(id: UUID(), name: "Retiro de tu meta", description: "Carrito 2026", amount: 100.00, balance: 260.00, date: yesterday, type: .goal),
            
            // Hace 2 días
            Transaction(id: UUID(), name: "Chocolateria San Ferna", description: "Compra con tarjeta", amount: -80.00, balance: 160.00, date: twoDaysAgo, type: .cardPurchase),
            Transaction(id: UUID(), name: "Transferencia a tu meta", description: "Vacaciones Argentina", amount: -220.00, balance: 240.00, date: twoDaysAgo, type: .goal),
            Transaction(id: UUID(), name: "Sueldo acreditado", description: "Transferencia recibida", amount: 460.00, balance: 480.00, date: twoDaysAgo, type: .salary)
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
            sectionStack.spacing = 8
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
            selectedDateFilterIndex = 0
        case "tipo":
            break
        case "monto":
            break
        default:
            break
        }
        // UI only - no actual filtering
    }
    
    private func showDateRangePicker(anchorView: UIView) {
        // If same filter is tapped again, close the dropdown
        if activeFilterType == "fecha" && activeDropdown != nil {
            activeDropdown?.dismiss()
            activeDropdown = nil
            activeFilterType = nil
            return
        }
        
        // Dismiss any existing dropdown
        activeDropdown?.dismiss()
        activeDropdown = nil
        activeFilterType = nil
        
        let dropdown = DropdownMenuView.dateFilterMenu(selectedIndex: selectedDateFilterIndex)
        dropdown.onItemSelected = { [weak self] index, item in
            guard let self = self else { return }
            
            // If "Personalizado" is selected, dismiss dropdown and show date picker
            if item.title == "Personalizado" {
                self.selectedDateFilterIndex = 4
                self.activeDropdown?.dismiss()
                self.activeDropdown = nil
                self.activeFilterType = nil
                
                // Present date range picker immediately (same as working copy)
                self.presentDateRangePicker()
            } else {
                // Calculate date range based on selection
                let today = Date()
                var startDate: Date
                
                switch item.title {
                case "Últimos 7 días":
                    self.selectedDateFilterIndex = 0
                    startDate = Calendar.current.date(byAdding: .day, value: -7, to: today)!
                case "Últimos 15 días":
                    self.selectedDateFilterIndex = 1
                    startDate = Calendar.current.date(byAdding: .day, value: -15, to: today)!
                case "Últimos 30 días":
                    self.selectedDateFilterIndex = 2
                    startDate = Calendar.current.date(byAdding: .day, value: -30, to: today)!
                default:
                    startDate = Calendar.current.date(byAdding: .day, value: -7, to: today)!
                }
                
                self.filterChipsView.setDateFilter(item.title)
                // UI only - no actual filtering
                
                self.activeDropdown?.dismiss()
                self.activeDropdown = nil
                self.activeFilterType = nil
            }
        }
        dropdown.onDismiss = { [weak self] in
            self?.activeDropdown = nil
            self?.activeFilterType = nil
        }
        dropdown.show(from: anchorView, in: view)
        activeDropdown = dropdown
        activeFilterType = "fecha"
    }
    
    private func showTypePicker(anchorView: UIView) {
        // If same filter is tapped again, close the dropdown
        if activeFilterType == "tipo" && activeDropdown != nil {
            activeDropdown?.dismiss()
            activeDropdown = nil
            activeFilterType = nil
            return
        }
        
        // Dismiss any existing dropdown
        activeDropdown?.dismiss()
        activeDropdown = nil
        activeFilterType = nil
        
        let dropdown = DropdownMenuView.typeFilterMenu()
        dropdown.onItemSelected = { [weak self] index, item in
            guard let self = self else { return }
            
            // Update chip - show nil for "Todos" to reset
            if item.title == "Todos" {
                self.filterChipsView.setTypeFilter(nil)
            } else {
                self.filterChipsView.setTypeFilter(item.title)
            }
            
            // UI only - no actual filtering
            self.activeDropdown?.dismiss()
            self.activeDropdown = nil
            self.activeFilterType = nil
        }
        dropdown.onDismiss = { [weak self] in
            self?.activeDropdown = nil
            self?.activeFilterType = nil
        }
        dropdown.show(from: anchorView, in: view)
        activeDropdown = dropdown
        activeFilterType = "tipo"
    }
    
    private func showAmountRangePicker(anchorView: UIView) {
        // If same filter is tapped again, close the dropdown
        if activeFilterType == "monto" && activeDropdown != nil {
            activeDropdown?.dismiss()
            activeDropdown = nil
            activeFilterType = nil
            return
        }
        
        // Dismiss any existing dropdown
        activeDropdown?.dismiss()
        activeDropdown = nil
        activeFilterType = nil
        
        let dropdown = DropdownMenuView.amountFilterMenu()
        dropdown.onItemSelected = { [weak self] index, item in
            guard let self = self else { return }
            
            // If "Personalizado" is selected, dismiss dropdown and show amount range picker
            if item.title == "Personalizado" {
                self.activeDropdown?.dismiss()
                self.activeDropdown = nil
                self.activeFilterType = nil
                
                // Present amount range picker immediately (same as working copy)
                self.presentAmountRangePicker()
            } else if item.title == "Todos" {
                self.filterChipsView.setAmountFilter(nil)
                // UI only - no actual filtering
                self.activeDropdown?.dismiss()
                self.activeDropdown = nil
                self.activeFilterType = nil
            }
        }
        dropdown.onDismiss = { [weak self] in
            self?.activeDropdown = nil
            self?.activeFilterType = nil
        }
        dropdown.show(from: anchorView, in: view)
        activeDropdown = dropdown
        activeFilterType = "monto"
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
        
        // Apply type filter (Ingresos = positive amounts, Egresos = negative amounts)
        if let type = selectedType {
            filtered = filtered.filter { transaction in
                switch type.lowercased() {
                case "ingresos":
                    return transaction.amount > 0
                case "egresos":
                    return transaction.amount < 0
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
    
    @objc private func exportTapped() {
        // Haptic feedback
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
        
        // Dismiss any existing dropdown
        activeDropdown?.dismiss()
        activeDropdown = nil
        
        // Show export options dropdown
        let dropdown = DropdownMenuView.exportMenu()
        dropdown.onItemSelected = { [weak self] index, item in
            guard let self = self else { return }
            
            self.activeDropdown?.dismiss()
            self.activeDropdown = nil
            
            switch item.title {
            case "Compartir PDF":
                self.showSharePDFModal()
            case "Compartir Excel":
                self.shareExcel()
            default:
                break
            }
        }
        dropdown.onDismiss = { [weak self] in
            self?.activeDropdown = nil
        }
        dropdown.show(from: exportButton, in: view, alignment: .trailing, direction: .up)
        activeDropdown = dropdown
    }
    
    // MARK: - Export Helpers
    
    private func showSharePDFModal() {
        // Hide export button
        hideExportButtonForExport()
        
        // Small delay to ensure dropdown is fully dismissed
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [weak self] in
            guard let self = self else { return }
            
            let sharePDFVC = SharePDFViewController()
            sharePDFVC.modalPresentationStyle = .overFullScreen
            sharePDFVC.modalTransitionStyle = .crossDissolve
            
            // Configure with current date range from filter
            sharePDFVC.dateRange = self.getCurrentDateRangeString()
            sharePDFVC.userEmail = "dan_rdgz@hotmail.com" // In real app, get from user profile
            
            sharePDFVC.onSendEmail = { [weak self] email in
                // Generate PDF and send via email
                self?.generateAndSendPDF(to: email)
                self?.showExportButtonAfterExport()
            }
            
            sharePDFVC.onUpdateData = { [weak self] in
                // Navigate to update user data
                print("Navigate to update data screen")
                self?.showExportButtonAfterExport()
            }
            
            // Handle dismiss without action
            sharePDFVC.onDismissWithoutAction = { [weak self] in
                self?.showExportButtonAfterExport()
            }
            
            self.present(sharePDFVC, animated: false)
        }
    }
    
    private func shareExcel() {
        // Hide export button immediately
        hideExportButtonForExport()
        
        // Small delay to ensure dropdown is fully dismissed
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { [weak self] in
            guard let self = self else { return }
            
            // Use pre-generated file or create new one
            let fileName = self.generateExcelFileName()
            let tempDirectory = FileManager.default.temporaryDirectory
            let fileURL = tempDirectory.appendingPathComponent(fileName)
            
            // Ensure file exists (regenerate if needed)
            if !FileManager.default.fileExists(atPath: fileURL.path) {
                let csvContent = self.generateCSVContent()
                try? csvContent.write(to: fileURL, atomically: true, encoding: .utf8)
            }
            
            // Show share sheet
            let activityVC = UIActivityViewController(
                activityItems: [fileURL],
                applicationActivities: nil
            )
            
            // Exclude some activity types to speed up loading
            activityVC.excludedActivityTypes = [
                .addToReadingList,
                .assignToContact,
                .openInIBooks
            ]
            
            // For iPad - position at bottom of screen
            if let popover = activityVC.popoverPresentationController {
                popover.sourceView = self.view
                popover.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.maxY, width: 0, height: 0)
                popover.permittedArrowDirections = []
            }
            
            // Restore export button when share sheet is dismissed
            activityVC.completionWithItemsHandler = { [weak self] _, _, _, _ in
                self?.showExportButtonAfterExport()
            }
            
            self.present(activityVC, animated: true)
        }
    }
    
    private func hideExportButtonForExport() {
        UIView.animate(withDuration: 0.2) {
            self.exportButton.alpha = 0
        } completion: { _ in
            self.exportButton.isHidden = true
        }
    }
    
    private func showExportButtonAfterExport() {
        let offsetY = scrollView.contentOffset.y
        let hasScrolledDown = offsetY > 10
        
        if hasScrolledDown {
            exportButton.isHidden = false
            UIView.animate(withDuration: 0.25) {
                self.exportButton.alpha = 1
            }
        }
    }
    
    private func getCurrentDateRangeString() -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "es_MX")
        formatter.dateFormat = "MMMM yyyy"
        
        let calendar = Calendar.current
        let now = Date()
        let oneMonthAgo = calendar.date(byAdding: .month, value: -1, to: now) ?? now
        
        let startMonth = formatter.string(from: oneMonthAgo).capitalized
        let endMonth = formatter.string(from: now).capitalized
        
        return "\(startMonth) - \(endMonth)"
    }
    
    private func generateExcelFileName() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd_MM_yyyy"
        let dateString = formatter.string(from: Date())
        return "Estado de cuenta-\(dateString).csv"
    }
    
    private func generateCSVContent() -> String {
        var csv = "Fecha,Descripción,Monto,Saldo\n"
        
        for section in filteredTransactions {
            for transaction in section.transactions {
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "dd/MM/yyyy"
                let dateStr = dateFormatter.string(from: transaction.date)
                
                let description = transaction.description.replacingOccurrences(of: ",", with: ";")
                let amount = String(format: "%.2f", transaction.amount)
                let balance = String(format: "%.2f", transaction.balance)
                
                csv += "\(dateStr),\(description),\(amount),\(balance)\n"
            }
        }
        
        return csv
    }
    
    private func generateAndSendPDF(to email: String) {
        // In a real app, this would generate a PDF and send it via backend API
        print("Generating PDF and sending to: \(email)")
        
        // Show success feedback
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
    }
    
    // MARK: - Scroll Handling
    
    private func updateFilterChipsVisibility(show: Bool) {
        guard filtersVisible != show else { return }
        filtersVisible = show
        
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut) {
            if show {
                // Show filters
                self.filterChipsView.alpha = 1
                self.filterChipsView.isHidden = false
                self.scrollViewTopToFiltersConstraint?.isActive = true
                self.scrollViewTopToSearchConstraint?.isActive = false
            } else {
                // Hide filters
                self.filterChipsView.alpha = 0
                self.scrollViewTopToFiltersConstraint?.isActive = false
                self.scrollViewTopToSearchConstraint?.isActive = true
            }
            self.view.layoutIfNeeded()
        } completion: { _ in
            if !show {
                self.filterChipsView.isHidden = true
            }
        }
    }
    
    private func updateExportButtonVisibility(show: Bool) {
        UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseInOut) {
            if show {
                self.exportButton.isHidden = false
                self.exportButton.alpha = 1
                self.exportButton.transform = .identity
            } else {
                self.exportButton.alpha = 0
                self.exportButton.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
            }
        } completion: { _ in
            if !show {
                self.exportButton.isHidden = true
            }
        }
    }
}

// MARK: - UIScrollViewDelegate

extension SearchViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y
        
        // Show/hide filter chips based on scroll position
        let hasScrolledDown = offsetY > 10
        updateFilterChipsVisibility(show: !hasScrolledDown)
        
        // Show export button when scrolling down
        updateExportButtonVisibility(show: hasScrolledDown)
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
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yy"
        
        let dateText = "\(formatter.string(from: startDate)) - \(formatter.string(from: endDate))"
        filterChipsView.setDateFilter(dateText)
        // UI only - no actual filtering
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
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 2
        
        var amountText = ""
        if let min = minAmount, let max = maxAmount {
            let minStr = formatter.string(from: NSNumber(value: min)) ?? "$\(min)"
            let maxStr = formatter.string(from: NSNumber(value: max)) ?? "$\(max)"
            amountText = "\(minStr)- \(maxStr)"
        } else if let min = minAmount {
            let minStr = formatter.string(from: NSNumber(value: min)) ?? "$\(min)"
            amountText = "> \(minStr)"
        } else if let max = maxAmount {
            let maxStr = formatter.string(from: NSNumber(value: max)) ?? "$\(max)"
            amountText = "< \(maxStr)"
        }
        
        if !amountText.isEmpty {
            filterChipsView.setAmountFilter(amountText)
        }
        // UI only - no actual filtering
    }
    
    func amountRangePickerDidCancel(_ picker: AmountRangePickerViewController) {
        // Nothing to do
    }
}

// MARK: - AllFiltersDelegate

extension SearchViewController: AllFiltersDelegate {
    func allFiltersDidApply(_ filters: AllFiltersViewController.FilterState) {
        // Update UI only - no actual filtering
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yy"
        let dateText = "\(formatter.string(from: filters.startDate)) - \(formatter.string(from: filters.endDate))"
        filterChipsView.setDateFilter(dateText)
        
        // Update type chip
        if filters.transactionType != "Todos" {
            filterChipsView.setTypeFilter(filters.transactionType)
        }
        
        // Update amount chip
        if let min = filters.minAmount, let max = filters.maxAmount {
            filterChipsView.setAmountFilter(String(format: "$%.2f - $%.2f", min, max))
        }
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
