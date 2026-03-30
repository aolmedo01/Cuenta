import UIKit

final class CuentaViewController: UIViewController {
    
    // MARK: - Properties
    private var account = Account(
        accountNumber: "12788373662",
        accountType: "AHO",
        balance: 1482000.00
    )
    
    private var transactionSections: [TransactionSection] = []
    private var isCompactHeaderVisible = false
    private var scrollThreshold: CGFloat = 160 // Threshold when header + transfer button pass
    
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
    
    // MARK: - Sticky Compact Header
    private let stickyHeaderView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .appBackground
        view.alpha = 0
        return view
    }()
    
    private lazy var stickyBackButton: CircleIconButton = {
        let button = CircleIconButton(systemName: "chevron.left")
        button.addTarget(self, action: #selector(backTapped), for: .touchUpInside)
        return button
    }()
    
    private let stickyBalanceLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 22, weight: .bold)
        label.textColor = .textPrimary
        return label
    }()
    
    private let stickyAccountLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        label.textColor = .textSecondary
        return label
    }()
    
    private lazy var stickyCardButton: CircleIconButton = {
        let button = CircleIconButton(systemName: "creditcard")
        button.addTarget(self, action: #selector(cardTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var stickyMoreButton: CircleIconButton = {
        let button = CircleIconButton(systemName: "ellipsis")
        button.addTarget(self, action: #selector(stickyMoreTapped), for: .touchUpInside)
        return button
    }()
    
    // Sticky header filter chips - same component as main filter
    private let stickyFilterChipsView: FilterChipsView = {
        let view = FilterChipsView()
        view.isHidden = true
        view.alpha = 0
        return view
    }()
    
    private var stickyHeightConstraint: NSLayoutConstraint?
    
    // MARK: - Floating Action Buttons
    private lazy var scrollToTopButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = .white
        button.layer.cornerRadius = 28
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOpacity = 0.15
        button.layer.shadowOffset = CGSize(width: 0, height: 4)
        button.layer.shadowRadius = 12
        button.setImage(UIImage(systemName: "arrow.up")?
            .withConfiguration(UIImage.SymbolConfiguration(pointSize: 18, weight: .medium)), for: .normal)
        button.tintColor = UIColor(red: 0.122, green: 0.161, blue: 0.239, alpha: 1) // #1F293D
        button.alpha = 0
        button.isHidden = true
        button.addTarget(self, action: #selector(scrollToTopTapped), for: .touchUpInside)
        return button
    }()
    
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
        button.tintColor = .accentBlue
        button.alpha = 0
        button.isHidden = true
        button.addTarget(self, action: #selector(exportTapped), for: .touchUpInside)
        return button
    }()
    
    private var hasDateFilter: Bool = false
    
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
        stack.spacing = 24
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
        
        scrollView.delegate = self
        
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        contentView.addSubview(mainStackView)
        
        setupHeader()
        setupTransferButton()
        setupSearchBar()
        setupTransactions()
        setupHistory()
        setupStickyHeader()
        setupFloatingButtons()
        
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
    
    private func setupFloatingButtons() {
        view.addSubview(scrollToTopButton)
        view.addSubview(exportButton)
        
        NSLayoutConstraint.activate([
            // Scroll to top button (left)
            scrollToTopButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            scrollToTopButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -24),
            scrollToTopButton.widthAnchor.constraint(equalToConstant: 56),
            scrollToTopButton.heightAnchor.constraint(equalToConstant: 56),
            
            // Export button (right)
            exportButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            exportButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -24),
            exportButton.widthAnchor.constraint(equalToConstant: 56),
            exportButton.heightAnchor.constraint(equalToConstant: 56)
        ])
    }
    
    private func updateFloatingButtons(scrolledToBottom: Bool) {
        let showScrollToTop = scrolledToBottom
        let showExport = scrolledToBottom && hasDateFilter
        
        UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseInOut) {
            // Scroll to top button
            if showScrollToTop {
                self.scrollToTopButton.isHidden = false
                self.scrollToTopButton.alpha = 1
                self.scrollToTopButton.transform = .identity
            } else {
                self.scrollToTopButton.alpha = 0
                self.scrollToTopButton.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
            }
            
            // Export button
            if showExport {
                self.exportButton.isHidden = false
                self.exportButton.alpha = 1
                self.exportButton.transform = .identity
            } else {
                self.exportButton.alpha = 0
                self.exportButton.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
            }
        } completion: { _ in
            if !showScrollToTop {
                self.scrollToTopButton.isHidden = true
            }
            if !showExport {
                self.exportButton.isHidden = true
            }
        }
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
        
        // Handle filter cleared
        filterChipsView.onFilterCleared = { [weak self] filterType in
            guard let self = self else { return }
            print("Filter cleared: \(filterType)")
            
            // Sync with sticky filter chips
            switch filterType {
            case "fecha":
                self.stickyFilterChipsView.setDateFilter(nil)
                self.hasDateFilter = false
            case "tipo":
                self.stickyFilterChipsView.setTypeFilter(nil)
            case "monto":
                self.stickyFilterChipsView.setAmountFilter(nil)
            default:
                break
            }
        }
        
        // Handle reset all filters
        filterChipsView.onResetAllFilters = { [weak self] in
            guard let self = self else { return }
            print("All filters reset")
            self.stickyFilterChipsView.clearAllFilters()
            self.hasDateFilter = false
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
            historyStackView.bottomAnchor.constraint(equalTo: historyContainer.bottomAnchor, constant: -32)
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
    
    private func setupStickyHeader() {
        view.addSubview(stickyHeaderView)
        
        let infoStack = UIStackView()
        infoStack.translatesAutoresizingMaskIntoConstraints = false
        infoStack.axis = .vertical
        infoStack.spacing = 2
        infoStack.alignment = .leading
        
        infoStack.addArrangedSubview(stickyBalanceLabel)
        infoStack.addArrangedSubview(stickyAccountLabel)
        
        stickyHeaderView.addSubview(stickyBackButton)
        stickyHeaderView.addSubview(infoStack)
        stickyHeaderView.addSubview(stickyCardButton)
        stickyHeaderView.addSubview(stickyMoreButton)
        
        // Add FilterChipsView to sticky header
        stickyHeaderView.addSubview(stickyFilterChipsView)
        
        // Setup sticky filter chips callbacks
        stickyFilterChipsView.onFilterSelected = { [weak self] filterType, anchorView in
            self?.handleFilterSelection(filterType, anchorView: anchorView)
        }
        
        stickyFilterChipsView.onFilterCleared = { [weak self] filterType in
            guard let self = self else { return }
            // Sync with main filterChipsView
            switch filterType {
            case "fecha":
                self.filterChipsView.setDateFilter(nil)
                self.hasDateFilter = false
            case "tipo":
                self.filterChipsView.setTypeFilter(nil)
            case "monto":
                self.filterChipsView.setAmountFilter(nil)
            default:
                break
            }
        }
        
        stickyFilterChipsView.onResetAllFilters = { [weak self] in
            self?.filterChipsView.clearAllFilters()
            self?.hasDateFilter = false
        }
        
        // Update sticky header content
        stickyBalanceLabel.text = account.formattedBalance
        stickyAccountLabel.text = "\(account.accountType) \(account.accountNumber)"
        
        stickyHeightConstraint = stickyHeaderView.heightAnchor.constraint(equalToConstant: 64)
        
        NSLayoutConstraint.activate([
            stickyHeaderView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            stickyHeaderView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            stickyHeaderView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            stickyHeightConstraint!,
            
            stickyBackButton.leadingAnchor.constraint(equalTo: stickyHeaderView.leadingAnchor, constant: 16),
            stickyBackButton.topAnchor.constraint(equalTo: stickyHeaderView.topAnchor, constant: 12),
            
            infoStack.leadingAnchor.constraint(equalTo: stickyBackButton.trailingAnchor, constant: 12),
            infoStack.centerYAnchor.constraint(equalTo: stickyBackButton.centerYAnchor),
            
            stickyMoreButton.trailingAnchor.constraint(equalTo: stickyHeaderView.trailingAnchor, constant: -16),
            stickyMoreButton.centerYAnchor.constraint(equalTo: stickyBackButton.centerYAnchor),
            
            stickyCardButton.trailingAnchor.constraint(equalTo: stickyMoreButton.leadingAnchor, constant: -10),
            stickyCardButton.centerYAnchor.constraint(equalTo: stickyBackButton.centerYAnchor),
            
            // Filter chips view
            stickyFilterChipsView.topAnchor.constraint(equalTo: stickyBackButton.bottomAnchor, constant: 8),
            stickyFilterChipsView.leadingAnchor.constraint(equalTo: stickyHeaderView.leadingAnchor),
            stickyFilterChipsView.trailingAnchor.constraint(equalTo: stickyHeaderView.trailingAnchor)
        ])
    }
    
    private func updateStickyHeaderFilters() {
        // Only update if sticky header is visible
        guard isCompactHeaderVisible else { return }
        
        let shouldShowFilters = isFilterVisible
        
        UIView.animate(withDuration: 0.2) {
            // Show/hide sticky filter chips
            if shouldShowFilters {
                self.stickyFilterChipsView.isHidden = false
                self.stickyFilterChipsView.alpha = 1
                self.stickyHeightConstraint?.constant = 130
                self.scrollView.contentInset.top = 130
            } else {
                self.stickyFilterChipsView.isHidden = true
                self.stickyFilterChipsView.alpha = 0
                self.stickyHeightConstraint?.constant = 80
                self.scrollView.contentInset.top = 80
            }
            self.view.layoutIfNeeded()
        }
    }
    
    private func updateCompactHeader(show: Bool) {
        guard show != isCompactHeaderVisible else { return }
        isCompactHeaderVisible = show
        
        UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseInOut) {
            self.stickyHeaderView.alpha = show ? 1 : 0
            self.headerView.alpha = show ? 0 : 1
            
            // Show filter chips in sticky header if filters are active and sticky header is visible
            if show && self.isFilterVisible {
                self.stickyFilterChipsView.isHidden = false
                self.stickyFilterChipsView.alpha = 1
                self.stickyHeightConstraint?.constant = 130
                self.scrollView.contentInset.top = 130
            } else if show {
                self.stickyFilterChipsView.isHidden = true
                self.stickyFilterChipsView.alpha = 0
                self.stickyHeightConstraint?.constant = 80
                self.scrollView.contentInset.top = 80
            } else {
                self.scrollView.contentInset.top = 0
            }
        }
    }
    
    // MARK: - Data
    private func setupData() {
        // Sample transactions
        let today = Date()
        let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: today)!
        let twoDaysAgo = Calendar.current.date(byAdding: .day, value: -2, to: today)!
        
        let todayTransactions: [Transaction] = [
            Transaction(id: UUID(), name: "Jessica Alfonso", description: "Movimiento interno", amount: 1600.00, balance: 1640.00, date: today, type: .transfer),
            Transaction(id: UUID(), name: "Retiro sin tarjeta", description: "Por retirar", amount: -40.00, balance: 40.00, date: today, type: .withdrawal, status: .toWithdraw),
            Transaction(id: UUID(), name: "CNEL", description: "Pago de servicio luz", amount: -120.00, balance: 80.00, date: today, type: .electricity),
            Transaction(id: UUID(), name: "Carla Lecaro", description: "Mercado frutas", amount: -60.00, balance: 200.00, date: today, type: .payment)
        ]
        
        let yesterdayTransactions: [Transaction] = [
            Transaction(id: UUID(), name: "Isabela Jacome", description: "Alquiler", amount: 60.00, balance: 260.00, date: yesterday, type: .deposit),
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
        // Dismiss filter dropdown if open
        activeDropdown?.dismiss()
        activeDropdown = nil
        activeFilterType = nil
        
        let dropdown = DropdownMenuView.moreOptionsMenu()
        dropdown.onItemSelected = { [weak self] index, item in
            guard let self = self else { return }
            print("More option selected: \(item.title)")
            
            self.activeDropdown?.dismiss()
            self.activeDropdown = nil
            
            switch item.title {
            case "Documentos":
                self.navigateToDocuments()
            case "Configurar cuenta":
                self.navigateToAccountSettings()
            default:
                break
            }
        }
        dropdown.onDismiss = { [weak self] in
            self?.activeDropdown = nil
        }
        dropdown.show(from: moreButton, in: view, alignment: .trailing)
        activeDropdown = dropdown
    }
    
    @objc private func stickyMoreTapped() {
        activeDropdown?.dismiss()
        activeDropdown = nil
        activeFilterType = nil
        
        let dropdown = DropdownMenuView.moreOptionsMenu()
        dropdown.onItemSelected = { [weak self] index, item in
            guard let self = self else { return }
            print("More option selected: \(item.title)")
            
            self.activeDropdown?.dismiss()
            self.activeDropdown = nil
            
            switch item.title {
            case "Documentos":
                self.navigateToDocuments()
            case "Configurar cuenta":
                self.navigateToAccountSettings()
            default:
                break
            }
        }
        dropdown.onDismiss = { [weak self] in
            self?.activeDropdown = nil
        }
        dropdown.show(from: stickyMoreButton, in: view, alignment: .trailing)
        activeDropdown = dropdown
    }
    
    private func navigateToDocuments() {
        let documentsVC = DocumentsViewController()
        navigationController?.pushViewController(documentsVC, animated: true)
    }
    
    private func navigateToAccountSettings() {
        let settingsVC = AccountSettingsViewController()
        navigationController?.pushViewController(settingsVC, animated: true)
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
    
    @objc private func scrollToTopTapped() {
        // Haptic feedback
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
        
        // Scroll to top with animation
        scrollView.setContentOffset(.zero, animated: true)
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
        // Hide floating buttons
        hideFloatingButtonsForExport()
        
        let sharePDFVC = SharePDFViewController()
        sharePDFVC.modalPresentationStyle = .overFullScreen
        sharePDFVC.modalTransitionStyle = .crossDissolve
        
        // Configure with current date range from filter
        sharePDFVC.dateRange = getCurrentDateRangeString()
        sharePDFVC.userEmail = "dan_rdgz@hotmail.com" // In real app, get from user profile
        
        sharePDFVC.onSendEmail = { [weak self] email in
            // Generate PDF and send via email
            self?.generateAndSendPDF(to: email)
            self?.showFloatingButtonsAfterExport()
        }
        
        sharePDFVC.onUpdateData = { [weak self] in
            // Navigate to update user data
            print("Navigate to update data screen")
            self?.showFloatingButtonsAfterExport()
        }
        
        // Handle dismiss without action
        sharePDFVC.onDismissWithoutAction = { [weak self] in
            self?.showFloatingButtonsAfterExport()
        }
        
        present(sharePDFVC, animated: false)
    }
    
    private func shareExcel() {
        // Hide floating buttons immediately
        hideFloatingButtonsForExport()
        
        // Generate file in background to avoid UI delay
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self = self else { return }
            
            // Generate Excel file (CSV format for compatibility)
            let fileName = self.generateExcelFileName()
            let csvContent = self.generateCSVContent()
            
            // Create temporary file
            let tempDirectory = FileManager.default.temporaryDirectory
            let fileURL = tempDirectory.appendingPathComponent(fileName)
            
            do {
                try csvContent.write(to: fileURL, atomically: true, encoding: .utf8)
                
                DispatchQueue.main.async {
                    // Show share sheet
                    let activityVC = UIActivityViewController(
                        activityItems: [fileURL],
                        applicationActivities: nil
                    )
                    
                    // For iPad
                    if let popover = activityVC.popoverPresentationController {
                        popover.sourceView = self.exportButton
                        popover.sourceRect = self.exportButton.bounds
                    }
                    
                    // Restore floating buttons when share sheet is dismissed
                    activityVC.completionWithItemsHandler = { [weak self] _, _, _, _ in
                        self?.showFloatingButtonsAfterExport()
                    }
                    
                    self.present(activityVC, animated: true)
                }
            } catch {
                print("Error creating Excel file: \(error)")
                DispatchQueue.main.async {
                    self.showFloatingButtonsAfterExport()
                }
            }
        }
    }
    
    private func hideFloatingButtonsForExport() {
        UIView.animate(withDuration: 0.2) {
            self.scrollToTopButton.alpha = 0
            self.exportButton.alpha = 0
        } completion: { _ in
            self.scrollToTopButton.isHidden = true
            self.exportButton.isHidden = true
        }
    }
    
    private func showFloatingButtonsAfterExport() {
        // Only show if conditions are still met
        let contentHeight = scrollView.contentSize.height
        let scrollViewHeight = scrollView.bounds.height
        let offsetY = scrollView.contentOffset.y
        let scrolledToBottom = offsetY > contentHeight - scrollViewHeight - 100
        
        if scrolledToBottom {
            scrollToTopButton.isHidden = false
            UIView.animate(withDuration: 0.25) {
                self.scrollToTopButton.alpha = 1
            }
            
            if hasDateFilter {
                exportButton.isHidden = false
                UIView.animate(withDuration: 0.25) {
                    self.exportButton.alpha = 1
                }
            }
        }
    }
    
    private func getCurrentDateRangeString() -> String {
        // Get date range from filter chips if set
        // For now, return a default range
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
        
        for section in transactionSections {
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
    
    @objc private func filterButtonTapped() {
        isFilterVisible.toggle()
        
        // Haptic feedback
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
        
        // Update filter button appearance with liquid glass effect
        searchBarView.setFilterActive(isFilterVisible)
        
        // Show/hide filter chips
        if isFilterVisible {
            filterChipsView.show()
        } else {
            filterChipsView.hide()
        }
        
        // Update sticky header filters visibility
        updateStickyHeaderFilters()
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
            } else {
                // Update chip with selected value and dismiss
                self.filterChipsView.setDateFilter(item.title)
                self.stickyFilterChipsView.setDateFilter(item.title)
                self.hasDateFilter = true
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
    }
    
    private func showTypeFilterDropdown(from anchorView: UIView) {
        let dropdown = DropdownMenuView.typeFilterMenu()
        dropdown.onItemSelected = { [weak self] index, item in
            guard let self = self else { return }
            print("Type filter selected: \(item.title)")
            
            // Update chip - show nil for "Todos" to reset
            if item.title == "Todos" {
                self.filterChipsView.setTypeFilter(nil)
                self.stickyFilterChipsView.setTypeFilter(nil)
            } else {
                self.filterChipsView.setTypeFilter(item.title)
                self.stickyFilterChipsView.setTypeFilter(item.title)
            }
            
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
            } else if item.title == "Todos" {
                self.filterChipsView.setAmountFilter(nil)
                self.stickyFilterChipsView.setAmountFilter(nil)
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
        formatter.dateFormat = "d MMM"
        
        let dateText = "\(formatter.string(from: startDate)) - \(formatter.string(from: endDate))"
        filterChipsView.setDateFilter(dateText)
        stickyFilterChipsView.setDateFilter(dateText)
        hasDateFilter = true
        
        print("Date range selected: \(dateText)")
        // TODO: Apply date filter to transactions
    }
    
    func dateRangePickerDidCancel(_ picker: DateRangePickerViewController) {
        print("Date range picker cancelled")
    }
}

// MARK: - AmountRangePickerDelegate
extension CuentaViewController: AmountRangePickerDelegate {
    func amountRangePicker(_ picker: AmountRangePickerViewController, didSelectMinAmount minAmount: Double?, maxAmount: Double?) {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = Locale(identifier: "en_US")
        formatter.maximumFractionDigits = 0
        
        var amountText = ""
        if let min = minAmount, let max = maxAmount {
            let minStr = formatter.string(from: NSNumber(value: min)) ?? "$\(Int(min))"
            let maxStr = formatter.string(from: NSNumber(value: max)) ?? "$\(Int(max))"
            amountText = "\(minStr)- \(maxStr)"
        } else if let min = minAmount {
            let minStr = formatter.string(from: NSNumber(value: min)) ?? "$\(Int(min))"
            amountText = "> \(minStr)"
        } else if let max = maxAmount {
            let maxStr = formatter.string(from: NSNumber(value: max)) ?? "$\(Int(max))"
            amountText = "< \(maxStr)"
        }
        
        if !amountText.isEmpty {
            filterChipsView.setAmountFilter(amountText)
            stickyFilterChipsView.setAmountFilter(amountText)
        }
        
        print("Amount range: \(amountText)")
        // TODO: Apply amount filter to transactions
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
        stickyFilterChipsView.clearAllFilters()
        filterChipsView.clearAllFilters()
        hasDateFilter = false
        print("Filters reset")
    }
}

// MARK: - UIScrollViewDelegate
extension CuentaViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y
        updateCompactHeader(show: offsetY > scrollThreshold)
        
        // Show floating buttons when user scrolls down (any amount > 10px)
        let hasScrolledDown = offsetY > 10
        updateFloatingButtons(scrolledToBottom: hasScrolledDown)
    }
}
