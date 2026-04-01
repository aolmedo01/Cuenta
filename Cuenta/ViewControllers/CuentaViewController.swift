import UIKit

final class CuentaViewController: UIViewController {
    private let headerBaseHeight: CGFloat = 232
    
    // MARK: - Properties
    private var account = Account(
        accountNumber: "6497640900",
        accountType: "AHO",
        balance: 1482000.00
    )
    
    private var transactionSections: [TransactionSection] = []
    private var isCompactHeaderVisible = false
    private var scrollThreshold: CGFloat = 220 // Threshold when header content passes
    
    // MARK: - UI Components
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.showsVerticalScrollIndicator = false
        scrollView.alwaysBounceVertical = true
        scrollView.clipsToBounds = false
        return scrollView
    }()
    
    private let contentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.clipsToBounds = false
        // Match header gradient bottom color to hide any gap
        view.backgroundColor = UIColor(red: 0.74, green: 0.0, blue: 0.56, alpha: 1)
        return view
    }()
    
    private let mainStackView: UIStackView = {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.spacing = 0
        stack.alignment = .fill
        stack.clipsToBounds = false
        return stack
    }()
    
    // MARK: - Header Components
    private let headerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .clear
        view.clipsToBounds = false
        return view
    }()
    
    private let headerCardView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        // Sin bordes redondeados - borde recto
        view.clipsToBounds = true
        return view
    }()
    
    private let headerGradientLayer = CAGradientLayer()
    private let headerGlowLayer = CAGradientLayer()
    private var headerViewHeightConstraint: NSLayoutConstraint?
    private var headerCardHeightConstraint: NSLayoutConstraint?
    private var headerCardTopConstraint: NSLayoutConstraint?
    private var toolbarTopConstraint: NSLayoutConstraint?
    
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
        label.textColor = .white
        label.numberOfLines = 1
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.8
        return label
    }()
    
    private let accountInfoStack: UIStackView = {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.spacing = 2
        stack.alignment = .leading
        return stack
    }()
    
    private let accountTypeLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .manrope(size: 12, weight: .regular)
        label.textColor = UIColor.white.withAlphaComponent(0.92)
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
        label.font = .manrope(size: 12, weight: .regular)
        label.textColor = UIColor.white.withAlphaComponent(0.92)
        return label
    }()
    
    private let accountIconContainer: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .clear
        return view
    }()
    
    private let accountIconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(named: "AccountIcon")
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private let accountCoinView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor(red: 1.0, green: 0.863, blue: 0.0, alpha: 1)
        view.layer.cornerRadius = 8
        return view
    }()
    
    private let accountCoinLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "$"
        label.font = .manrope(size: 10, weight: .bold)
        label.textColor = UIColor(red: 0.537, green: 0.365, blue: 0.0, alpha: 1)
        label.textAlignment = .center
        return label
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
    
    // MARK: - Search
    private let searchBarView = SearchBarView()
    
    // MARK: - Filter Chips
    private let filterChipsView: FilterChipsView = {
        let view = FilterChipsView()
        view.isHidden = true
        view.alpha = 0
        return view
    }()
    
    // MARK: - Segmented Control (Manual/Automático)
    private let segmentedControlView: SegmentedControlView = {
        let view = SegmentedControlView()
        return view
    }()
    
    private let segmentedControlContainer: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let todayHeaderLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Hoy"
        label.font = .manrope(size: 15, weight: .bold)
        label.textColor = UIColor(red: 0.235, green: 0.235, blue: 0.263, alpha: 0.6) // rgba(60, 60, 67, 0.6)
        return label
    }()
    
    private let stickySegmentedControlView: SegmentedControlView = {
        let view = SegmentedControlView()
        return view
    }()
    
    // Expansion mode: Manual (user taps) vs Automático (auto expand)
    private var isManualMode = true
    private var currentlyExpandedCell: TransactionCell?
    private var allTransactionCells: [TransactionCell] = []
    private var lastScrollOffset: CGFloat = 0
    
    // Throttle for wave effect - minimum time between expansions
    private var lastExpansionTime: Date = .distantPast
    private let expansionCooldown: TimeInterval = 0.5 // seconds between expansions
    
    private var isFilterVisible = false
    private var activeDropdown: DropdownMenuView?
    private var activeFilterType: String?
    
    // MARK: - Movements Container
    private let movementsContainerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor(red: 0.74, green: 0.0, blue: 0.56, alpha: 1)
        return view
    }()
    
    private let movementsContentBackgroundView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor(red: 0.961, green: 0.965, blue: 0.973, alpha: 1) // #F5F6F8
        view.layer.cornerRadius = 28
        view.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        return view
    }()
    
    private let movementsTopDividerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .clear
        return view
    }()
    
    private let movementsTopShadowView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .clear
        view.isUserInteractionEnabled = false
        return view
    }()
    
    private let movementsTopShadowLayer: CAGradientLayer = {
        let layer = CAGradientLayer()
        layer.colors = [
            UIColor.clear.cgColor,
            UIColor.clear.cgColor
        ]
        layer.startPoint = CGPoint(x: 0.5, y: 0.0)
        layer.endPoint = CGPoint(x: 0.5, y: 1.0)
        return layer
    }()
    
    private let movementsStackView: UIStackView = {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.spacing = 0
        stack.alignment = .fill
        return stack
    }()
    
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
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let topInset = view.safeAreaInsets.top
        toolbarTopConstraint?.constant = topInset + 16
        headerCardTopConstraint?.constant = -topInset
        headerCardHeightConstraint?.constant = headerBaseHeight + topInset
        headerViewHeightConstraint?.constant = headerBaseHeight + topInset
        headerGradientLayer.frame = headerCardView.bounds
        headerGlowLayer.frame = headerCardView.bounds
        movementsTopShadowLayer.frame = movementsTopShadowView.bounds
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
        setupMovementsContainer()
        setupStickyHeader()
        setupFloatingButtons()
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
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
        view.addSubview(transferButton)
        
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
            exportButton.heightAnchor.constraint(equalToConstant: 56),
            
            // Transfer button (bottom right, always visible)
            transferButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            transferButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16)
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
        
        headerView.addSubview(headerCardView)
        headerCardView.addSubview(toolbarView)
        toolbarView.addSubview(backButton)
        toolbarView.addSubview(cardButton)
        toolbarView.addSubview(moreButton)
        
        headerCardView.addSubview(accountInfoStack)
        accountInfoStack.addArrangedSubview(accountTypeLabel)
        accountInfoStack.addArrangedSubview(accountNumberContainer)
        accountNumberContainer.addSubview(accountNumberLabel)
        
        headerCardView.addSubview(accountIconContainer)
        accountIconContainer.addSubview(accountIconImageView)
        // accountCoinView not needed - SVG already includes coin
        
        headerCardView.addSubview(balanceLabel)
        
        backButton.applyStyle(.lightOnDark)
        cardButton.applyStyle(.lightOnDark)
        moreButton.applyStyle(.lightOnDark)
        
        headerGradientLayer.colors = [
            UIColor(red: 0.85, green: 0.0, blue: 0.45, alpha: 1).cgColor,
            UIColor(red: 0.74, green: 0.0, blue: 0.56, alpha: 1).cgColor
        ]
        headerGradientLayer.startPoint = CGPoint(x: 0.15, y: 0.0)
        headerGradientLayer.endPoint = CGPoint(x: 0.85, y: 1.0)
        
        headerGlowLayer.colors = [
            UIColor.white.withAlphaComponent(0.22).cgColor,
            UIColor.clear.cgColor
        ]
        headerGlowLayer.startPoint = CGPoint(x: 0.5, y: 0.0)
        headerGlowLayer.endPoint = CGPoint(x: 0.5, y: 0.45)
        
        if headerGradientLayer.superlayer == nil {
            headerCardView.layer.insertSublayer(headerGradientLayer, at: 0)
        }
        if headerGlowLayer.superlayer == nil {
            headerCardView.layer.insertSublayer(headerGlowLayer, above: headerGradientLayer)
        }
        
        headerViewHeightConstraint = headerView.heightAnchor.constraint(equalToConstant: headerBaseHeight)
        headerCardHeightConstraint = headerCardView.heightAnchor.constraint(equalToConstant: headerBaseHeight)
        headerCardTopConstraint = headerCardView.topAnchor.constraint(equalTo: headerView.topAnchor, constant: 0)
        toolbarTopConstraint = toolbarView.topAnchor.constraint(equalTo: headerCardView.topAnchor, constant: 50)
        
        NSLayoutConstraint.activate([
            headerViewHeightConstraint!,
            
            headerCardTopConstraint!,
            headerCardView.leadingAnchor.constraint(equalTo: headerView.leadingAnchor),
            headerCardView.trailingAnchor.constraint(equalTo: headerView.trailingAnchor),
            headerCardHeightConstraint!,
            
            // Toolbar
            toolbarTopConstraint!,
            toolbarView.leadingAnchor.constraint(equalTo: headerCardView.leadingAnchor, constant: 24),
            toolbarView.trailingAnchor.constraint(equalTo: headerCardView.trailingAnchor, constant: -24),
            toolbarView.heightAnchor.constraint(equalToConstant: 48),
            
            // Back Button
            backButton.leadingAnchor.constraint(equalTo: toolbarView.leadingAnchor),
            backButton.centerYAnchor.constraint(equalTo: toolbarView.centerYAnchor),
            
            // More Button
            moreButton.trailingAnchor.constraint(equalTo: toolbarView.trailingAnchor),
            moreButton.centerYAnchor.constraint(equalTo: toolbarView.centerYAnchor),
            
            // Card Button
            cardButton.trailingAnchor.constraint(equalTo: moreButton.leadingAnchor, constant: -10),
            cardButton.centerYAnchor.constraint(equalTo: toolbarView.centerYAnchor),
            
            accountInfoStack.topAnchor.constraint(equalTo: toolbarView.bottomAnchor, constant: 34),
            accountInfoStack.leadingAnchor.constraint(equalTo: headerCardView.leadingAnchor, constant: 24),
            accountInfoStack.trailingAnchor.constraint(lessThanOrEqualTo: accountIconContainer.leadingAnchor, constant: -16),
            
            accountNumberContainer.leadingAnchor.constraint(equalTo: accountInfoStack.leadingAnchor),
            accountNumberContainer.heightAnchor.constraint(equalToConstant: 18),
            
            accountNumberLabel.leadingAnchor.constraint(equalTo: accountNumberContainer.leadingAnchor),
            accountNumberLabel.centerYAnchor.constraint(equalTo: accountNumberContainer.centerYAnchor),
            accountNumberLabel.trailingAnchor.constraint(equalTo: accountNumberContainer.trailingAnchor),
            
            accountIconContainer.trailingAnchor.constraint(equalTo: headerCardView.trailingAnchor, constant: -24),
            accountIconContainer.topAnchor.constraint(equalTo: toolbarView.bottomAnchor, constant: 32),
            accountIconContainer.widthAnchor.constraint(equalToConstant: 48),
            accountIconContainer.heightAnchor.constraint(equalToConstant: 48),
            
            accountIconImageView.centerXAnchor.constraint(equalTo: accountIconContainer.centerXAnchor),
            accountIconImageView.centerYAnchor.constraint(equalTo: accountIconContainer.centerYAnchor),
            accountIconImageView.widthAnchor.constraint(equalToConstant: 48),
            accountIconImageView.heightAnchor.constraint(equalToConstant: 48),
            
            balanceLabel.leadingAnchor.constraint(equalTo: headerCardView.leadingAnchor, constant: 24),
            balanceLabel.trailingAnchor.constraint(equalTo: headerCardView.trailingAnchor, constant: -24),
            balanceLabel.bottomAnchor.constraint(equalTo: headerCardView.bottomAnchor, constant: -40)
        ])
    }
    
    private func setupMovementsContainer() {
        // Add movements container to main stack
        mainStackView.addArrangedSubview(movementsContainerView)
        // Slight overlap so the white content sheet sits attached to the magenta header
        mainStackView.setCustomSpacing(-44, after: headerView)
        movementsContainerView.addSubview(movementsContentBackgroundView)
        movementsContainerView.addSubview(movementsTopShadowView)
        movementsContainerView.addSubview(movementsTopDividerView)
        movementsContainerView.addSubview(movementsStackView)
        
        if movementsTopShadowLayer.superlayer == nil {
            movementsTopShadowView.layer.addSublayer(movementsTopShadowLayer)
        }
        
        // Ensure movements container is above header
        movementsContainerView.layer.zPosition = 10
        
        // Configure search bar
        searchBarView.textField.placeholder = "Buscar movimiento"
        searchBarView.filterButton.addTarget(self, action: #selector(filterButtonTapped), for: .touchUpInside)
        searchBarView.onSearchBarTapped = { [weak self] in
            self?.openSearchScreen()
        }
        
        // Add search bar container at the top of movements stack
        let searchBarContainer = UIView()
        searchBarContainer.translatesAutoresizingMaskIntoConstraints = false
        searchBarContainer.addSubview(searchBarView)
        movementsStackView.addArrangedSubview(searchBarContainer)
        
        NSLayoutConstraint.activate([
            movementsContentBackgroundView.topAnchor.constraint(equalTo: movementsContainerView.topAnchor, constant: -6),
            movementsContentBackgroundView.leadingAnchor.constraint(equalTo: movementsContainerView.leadingAnchor),
            movementsContentBackgroundView.trailingAnchor.constraint(equalTo: movementsContainerView.trailingAnchor),
            movementsContentBackgroundView.bottomAnchor.constraint(equalTo: movementsContainerView.bottomAnchor),
            
            movementsTopShadowView.topAnchor.constraint(equalTo: movementsContentBackgroundView.topAnchor, constant: 6),
            movementsTopShadowView.leadingAnchor.constraint(equalTo: movementsContainerView.leadingAnchor),
            movementsTopShadowView.trailingAnchor.constraint(equalTo: movementsContainerView.trailingAnchor),
            movementsTopShadowView.heightAnchor.constraint(equalToConstant: 24),
            
            movementsTopDividerView.topAnchor.constraint(equalTo: movementsContentBackgroundView.topAnchor),
            movementsTopDividerView.leadingAnchor.constraint(equalTo: movementsContainerView.leadingAnchor),
            movementsTopDividerView.trailingAnchor.constraint(equalTo: movementsContainerView.trailingAnchor),
            movementsTopDividerView.heightAnchor.constraint(equalToConstant: 0),
            
            searchBarContainer.heightAnchor.constraint(equalToConstant: 64),
            searchBarView.leadingAnchor.constraint(equalTo: searchBarContainer.leadingAnchor),
            searchBarView.trailingAnchor.constraint(equalTo: searchBarContainer.trailingAnchor, constant: -4),
            searchBarView.centerYAnchor.constraint(equalTo: searchBarContainer.centerYAnchor),
            searchBarView.heightAnchor.constraint(equalToConstant: 56)
        ])
        
        // Add filter chips
        movementsStackView.addArrangedSubview(filterChipsView)
        
        // Add "Hoy" header with segmented control (Manual/Automático) in the same row
        movementsStackView.addArrangedSubview(segmentedControlContainer)
        segmentedControlContainer.addSubview(todayHeaderLabel)
        segmentedControlContainer.addSubview(segmentedControlView)
        
        NSLayoutConstraint.activate([
            segmentedControlContainer.heightAnchor.constraint(equalToConstant: 50),
            
            // "Hoy" label on the left
            todayHeaderLabel.leadingAnchor.constraint(equalTo: segmentedControlContainer.leadingAnchor, constant: 16),
            todayHeaderLabel.centerYAnchor.constraint(equalTo: segmentedControlContainer.centerYAnchor),
            
            // Segmented control on the right
            segmentedControlView.trailingAnchor.constraint(equalTo: segmentedControlContainer.trailingAnchor),
            segmentedControlView.centerYAnchor.constraint(equalTo: segmentedControlContainer.centerYAnchor)
        ])
        
        segmentedControlView.onSegmentChanged = { [weak self] segment in
            guard let self = self else { return }
            print("Segment changed to: \(segment == .manual ? "Manual" : "Automático")")
            self.isManualMode = (segment == .manual)
            self.stickySegmentedControlView.selectedSegment = segment
            
            self.currentlyExpandedCell?.collapse()
            self.currentlyExpandedCell = nil
        }
        
        // Handle filter callbacks
        filterChipsView.onFilterSelected = { [weak self] filterType, anchorView in
            self?.handleFilterSelection(filterType, anchorView: anchorView)
        }
        
        filterChipsView.onFilterCleared = { [weak self] filterType in
            guard let self = self else { return }
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
        
        filterChipsView.onResetAllFilters = { [weak self] in
            guard let self = self else { return }
            self.stickyFilterChipsView.clearAllFilters()
            self.hasDateFilter = false
        }
        
        // Add transactions stack
        movementsStackView.addArrangedSubview(transactionsStackView)
        
        // Add history
        let historyContainer = UIView()
        historyContainer.translatesAutoresizingMaskIntoConstraints = false
        historyContainer.addSubview(historyStackView)
        movementsStackView.addArrangedSubview(historyContainer)
        
        NSLayoutConstraint.activate([
            historyStackView.topAnchor.constraint(equalTo: historyContainer.topAnchor, constant: 16),
            historyStackView.leadingAnchor.constraint(equalTo: historyContainer.leadingAnchor),
            historyStackView.trailingAnchor.constraint(equalTo: historyContainer.trailingAnchor),
            historyStackView.bottomAnchor.constraint(equalTo: historyContainer.bottomAnchor, constant: -32)
        ])
        
        // Configure history sections
        let monthsSection = HistorySectionView()
        monthsSection.configure(title: "Movimientos 2025", items: ["Febrero", "Enero"])
        historyStackView.addArrangedSubview(monthsSection)
        
        let yearsSection = HistorySectionView()
        yearsSection.configure(title: "Movimientos por año", items: ["2025", "2024"])
        historyStackView.addArrangedSubview(yearsSection)
        
        // Constraints for movements container
        NSLayoutConstraint.activate([
            movementsStackView.topAnchor.constraint(equalTo: movementsContentBackgroundView.topAnchor, constant: 16),
            movementsStackView.leadingAnchor.constraint(equalTo: movementsContentBackgroundView.leadingAnchor, constant: 16),
            movementsStackView.trailingAnchor.constraint(equalTo: movementsContentBackgroundView.trailingAnchor, constant: -16),
            movementsStackView.bottomAnchor.constraint(equalTo: movementsContentBackgroundView.bottomAnchor, constant: -32)
        ])
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
        
        // Add segmented control to sticky header
        stickyHeaderView.addSubview(stickySegmentedControlView)
        
        stickySegmentedControlView.onSegmentChanged = { [weak self] segment in
            guard let self = self else { return }
            print("Sticky segment changed to: \(segment == .manual ? "Manual" : "Automático")")
            self.isManualMode = (segment == .manual)
            self.segmentedControlView.selectedSegment = segment
            
            // Collapse current cell when switching modes
            self.currentlyExpandedCell?.collapse()
            self.currentlyExpandedCell = nil
        }
        
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
        
        stickyHeightConstraint = stickyHeaderView.heightAnchor.constraint(equalToConstant: 100)
        
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
            stickyFilterChipsView.trailingAnchor.constraint(equalTo: stickyHeaderView.trailingAnchor),
            
            // Segmented control - positioned at bottom right of sticky header
            stickySegmentedControlView.bottomAnchor.constraint(equalTo: stickyHeaderView.bottomAnchor, constant: -8),
            stickySegmentedControlView.trailingAnchor.constraint(equalTo: stickyHeaderView.trailingAnchor, constant: -12)
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
                self.stickyHeightConstraint?.constant = 170
                self.scrollView.contentInset.top = 170
            } else {
                self.stickyFilterChipsView.isHidden = true
                self.stickyFilterChipsView.alpha = 0
                self.stickyHeightConstraint?.constant = 100
                self.scrollView.contentInset.top = 100
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
            
            // Hide/show segmented controls to avoid both being visible
            self.segmentedControlView.alpha = show ? 0 : 1
            self.stickySegmentedControlView.alpha = show ? 1 : 0
            
            // Show filter chips in sticky header if filters are active and sticky header is visible
            if show && self.isFilterVisible {
                self.stickyFilterChipsView.isHidden = false
                self.stickyFilterChipsView.alpha = 1
                self.stickyHeightConstraint?.constant = 170
                self.scrollView.contentInset.top = 170
            } else if show {
                self.stickyFilterChipsView.isHidden = true
                self.stickyFilterChipsView.alpha = 0
                self.stickyHeightConstraint?.constant = 100
                self.scrollView.contentInset.top = 100
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
            Transaction(id: UUID(), name: "Retiro sin tarjeta", description: "Por retirar", amount: -50.00, balance: 260.00, date: today, type: .withdrawal, status: .toWithdraw, recipientName: "María Guadalupe López Martillo", recipientPhone: "096XXXX193", timeRemaining: "23h 15m", progressRemaining: 0.7),
            Transaction(id: UUID(), name: "CNEL", description: "Pago de servicio luz", amount: -120.21, balance: 80.00, date: today, type: .electricity, serviceAmount: 120.00, commission: 0.18, tax: 0.03),
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
        balanceLabel.attributedText = makeHeaderBalanceText(account.formattedBalance)
        accountTypeLabel.attributedText = makeHeaderMetaText(displayAccountType)
        accountNumberLabel.attributedText = makeHeaderMetaText(account.accountNumber)
        
        // Clear existing transactions
        transactionsStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        allTransactionCells.removeAll()
        
        // Add transaction sections
        for (index, section) in transactionSections.enumerated() {
            let sectionContainer = UIView()
            sectionContainer.translatesAutoresizingMaskIntoConstraints = false
            
            let sectionStack = UIStackView()
            sectionStack.translatesAutoresizingMaskIntoConstraints = false
            sectionStack.axis = .vertical
            sectionStack.spacing = 16
            
            // Section header (skip for first section "Hoy" as it's in the segmented control row)
            if index > 0 {
                let header = SectionHeaderView(title: section.title)
                sectionStack.addArrangedSubview(header)
            }
            
            // Transaction cells
            for transaction in section.transactions {
                let cell = TransactionCell()
                cell.configure(with: transaction)
                
                // Handle expansion
                cell.onExpansionChanged = { [weak self, weak cell] isExpanded in
                    guard let self = self, let cell = cell else { return }
                    
                    if isExpanded {
                        // Collapse previously expanded cell
                        if let previousCell = self.currentlyExpandedCell, previousCell !== cell {
                            previousCell.collapse()
                        }
                        self.currentlyExpandedCell = cell
                    } else {
                        if self.currentlyExpandedCell === cell {
                            self.currentlyExpandedCell = nil
                        }
                    }
                }
                
                // Handle share button tap
                cell.onShareTapped = { [weak self] transaction in
                    self?.showTransactionReceipt(for: transaction)
                }
                
                allTransactionCells.append(cell)
                sectionStack.addArrangedSubview(cell)
            }
            
            sectionContainer.addSubview(sectionStack)
            
            NSLayoutConstraint.activate([
                sectionStack.topAnchor.constraint(equalTo: sectionContainer.topAnchor),
                sectionStack.leadingAnchor.constraint(equalTo: sectionContainer.leadingAnchor),
                sectionStack.trailingAnchor.constraint(equalTo: sectionContainer.trailingAnchor),
                sectionStack.bottomAnchor.constraint(equalTo: sectionContainer.bottomAnchor)
            ])
            
            transactionsStackView.addArrangedSubview(sectionContainer)
        }
    }
    
    private var displayAccountType: String {
        switch account.accountType.uppercased() {
        case "AHO":
            return "CUENTA DE AHORROS"
        default:
            return account.accountType.uppercased()
        }
    }
    
    private func makeHeaderMetaText(_ text: String) -> NSAttributedString {
        NSAttributedString(
            string: text.uppercased(),
            attributes: [
                .font: UIFont.manrope(size: 12, weight: .regular),
                .foregroundColor: UIColor.white.withAlphaComponent(0.92),
                .kern: 3.0
            ]
        )
    }
    
    private func makeHeaderBalanceText(_ text: String) -> NSAttributedString {
        NSAttributedString(
            string: text,
            attributes: [
                .font: UIFont.manrope(size: 35, weight: .regular),
                .foregroundColor: UIColor.white,
                .kern: -2.5
            ]
        )
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
    
    private func openSearchScreen() {
        let searchVC = SearchViewController()
        searchVC.modalPresentationStyle = .fullScreen
        present(searchVC, animated: true)
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
    // MARK: - Transaction Receipt
    private func showTransactionReceipt(for transaction: Transaction) {
        let receiptVC = TransactionReceiptViewController(transaction: transaction)
        present(receiptVC, animated: true)
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
        
        // Auto-expand mode: immediately expand the cell in the focus zone
        if !isManualMode {
            expandCellInFocusZone(in: scrollView)
        }
        
        lastScrollOffset = offsetY
    }
    
    private func expandCellInFocusZone(in scrollView: UIScrollView) {
        // Check cooldown - don't expand too fast
        let now = Date()
        guard now.timeIntervalSince(lastExpansionTime) >= expansionCooldown else {
            return
        }
        
        // Focus zone: upper-middle area of the screen (30-50% from top)
        let focusZoneTop = scrollView.contentOffset.y + scrollView.bounds.height * 0.25
        let focusZoneBottom = scrollView.contentOffset.y + scrollView.bounds.height * 0.55
        
        // Find the cell whose top is within the focus zone
        for cell in allTransactionCells {
            guard let cellFrame = cell.superview?.convert(cell.frame, to: scrollView) else { continue }
            
            let cellTop = cellFrame.minY
            
            // Check if cell's top edge is within the focus zone
            if cellTop >= focusZoneTop && cellTop <= focusZoneBottom {
                // Only act if this is a different cell than the currently expanded one
                if currentlyExpandedCell !== cell {
                    // Quick collapse the previous cell (fast animation for wave effect)
                    currentlyExpandedCell?.collapseQuick()
                    
                    // Expand the new cell with wave animation
                    cell.expand(animated: true)
                    currentlyExpandedCell = cell
                    
                    // Update last expansion time
                    lastExpansionTime = now
                }
                break // Only process one cell per scroll event
            }
        }
    }
}
