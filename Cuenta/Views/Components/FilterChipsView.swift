import UIKit

final class FilterChipButton: UIButton {
    
    private var hasChevron: Bool = true
    private var isFilterSelected: Bool = false
    private var baseTitle: String = ""
    
    // MARK: - Initialization
    init(title: String, showChevron: Bool = true) {
        self.hasChevron = showChevron
        self.baseTitle = title
        super.init(frame: .zero)
        setupView(title: title, showChevron: showChevron)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    // MARK: - Setup
    private func setupView(title: String, showChevron: Bool) {
        translatesAutoresizingMaskIntoConstraints = false
        
        // Background: #FCFCFD, Border: 1px #A9B0BF, Border-radius: 42px
        backgroundColor = UIColor(red: 0.988, green: 0.988, blue: 0.992, alpha: 1)
        layer.borderWidth = 1
        layer.borderColor = UIColor(red: 0.663, green: 0.69, blue: 0.749, alpha: 1).cgColor
        layer.cornerRadius = 16.5
        clipsToBounds = true
        
        // Set title first
        setTitle(title, for: .normal)
        setTitleColor(UIColor(red: 0.318, green: 0.353, blue: 0.451, alpha: 1), for: .normal)
        titleLabel?.font = UIFont.systemFont(ofSize: 11, weight: .regular)
        
        if showChevron {
            // Chevron icon
            let chevronConfig = UIImage.SymbolConfiguration(pointSize: 8, weight: .medium)
            let chevron = UIImage(systemName: "chevron.down", withConfiguration: chevronConfig)
            setImage(chevron, for: .normal)
            tintColor = UIColor(red: 0.663, green: 0.69, blue: 0.749, alpha: 1)
            
            // Image on right side
            semanticContentAttribute = .forceRightToLeft
            
            // Spacing
            imageEdgeInsets = UIEdgeInsets(top: 0, left: 4, bottom: 0, right: -4)
            titleEdgeInsets = UIEdgeInsets(top: 0, left: -4, bottom: 0, right: 4)
            contentEdgeInsets = UIEdgeInsets(top: 8, left: 12, bottom: 8, right: 16)
        } else {
            // "Todos los filtros" - no border, no background
            backgroundColor = .clear
            layer.borderWidth = 0
            contentEdgeInsets = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
        }
        
        // Height: 33px
        heightAnchor.constraint(equalToConstant: 33).isActive = true
    }
    
    // MARK: - Filter Selection
    func setFilterValue(_ value: String?) {
        if let value = value, !value.isEmpty {
            isFilterSelected = true
            setTitle("\(baseTitle): \(value)", for: .normal)
            
            // Keep same style as unselected - background: #FCFCFD, border: #A9B0BF, text: #515A73
            backgroundColor = UIColor(red: 0.988, green: 0.988, blue: 0.992, alpha: 1)
            layer.borderColor = UIColor(red: 0.663, green: 0.69, blue: 0.749, alpha: 1).cgColor
            setTitleColor(UIColor(red: 0.318, green: 0.353, blue: 0.451, alpha: 1), for: .normal)
            tintColor = UIColor(red: 0.663, green: 0.69, blue: 0.749, alpha: 1)
            
            // Change chevron to X for clearing
            if hasChevron {
                let xConfig = UIImage.SymbolConfiguration(pointSize: 8, weight: .medium)
                let xImage = UIImage(systemName: "xmark", withConfiguration: xConfig)
                setImage(xImage, for: .normal)
            }
        } else {
            clearFilter()
        }
        invalidateIntrinsicContentSize()
    }
    
    func clearFilter() {
        isFilterSelected = false
        setTitle(baseTitle, for: .normal)
        
        // Reset to default style
        backgroundColor = UIColor(red: 0.988, green: 0.988, blue: 0.992, alpha: 1)
        layer.borderColor = UIColor(red: 0.663, green: 0.69, blue: 0.749, alpha: 1).cgColor
        setTitleColor(UIColor(red: 0.318, green: 0.353, blue: 0.451, alpha: 1), for: .normal)
        tintColor = UIColor(red: 0.663, green: 0.69, blue: 0.749, alpha: 1)
        
        // Restore chevron
        if hasChevron {
            let chevronConfig = UIImage.SymbolConfiguration(pointSize: 8, weight: .medium)
            let chevron = UIImage(systemName: "chevron.down", withConfiguration: chevronConfig)
            setImage(chevron, for: .normal)
        }
        invalidateIntrinsicContentSize()
    }
    
    var isFilterActive: Bool {
        return isFilterSelected
    }
    
    override var intrinsicContentSize: CGSize {
        let size = super.intrinsicContentSize
        return CGSize(width: size.width + (hasChevron ? 8 : 0), height: 33)
    }
    
    // MARK: - Touch Feedback
    override var isHighlighted: Bool {
        didSet {
            UIView.animate(withDuration: 0.1) {
                self.alpha = self.isHighlighted ? 0.7 : 1.0
                self.transform = self.isHighlighted ? CGAffineTransform(scaleX: 0.97, y: 0.97) : .identity
            }
        }
    }
}

// MARK: - Filter Chips Container
final class FilterChipsView: UIView {
    
    // MARK: - Properties
    var onFilterSelected: ((String, UIView) -> Void)?
    var onFilterCleared: ((String) -> Void)?
    var onResetAllFilters: (() -> Void)?
    
    // MARK: - UI Components
    private let scrollView: UIScrollView = {
        let scroll = UIScrollView()
        scroll.translatesAutoresizingMaskIntoConstraints = false
        scroll.showsHorizontalScrollIndicator = false
        scroll.showsVerticalScrollIndicator = false
        scroll.alwaysBounceHorizontal = true
        return scroll
    }()
    
    private let stackView: UIStackView = {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .horizontal
        stack.spacing = 8
        stack.alignment = .center
        stack.distribution = .fill
        return stack
    }()
    
    private lazy var fechaButton: FilterChipButton = {
        let button = FilterChipButton(title: "Fecha")
        button.addTarget(self, action: #selector(filterTapped(_:)), for: .touchUpInside)
        button.accessibilityIdentifier = "fecha"
        return button
    }()
    
    private lazy var tipoButton: FilterChipButton = {
        let button = FilterChipButton(title: "Tipo")
        button.addTarget(self, action: #selector(filterTapped(_:)), for: .touchUpInside)
        button.accessibilityIdentifier = "tipo"
        return button
    }()
    
    private lazy var montoButton: FilterChipButton = {
        let button = FilterChipButton(title: "Monto")
        button.addTarget(self, action: #selector(filterTapped(_:)), for: .touchUpInside)
        button.accessibilityIdentifier = "monto"
        return button
    }()
    
    private lazy var todosButton: FilterChipButton = {
        let button = FilterChipButton(title: "Todos los filtros", showChevron: false)
        button.addTarget(self, action: #selector(filterTapped(_:)), for: .touchUpInside)
        button.accessibilityIdentifier = "todos"
        return button
    }()
    
    private let separatorView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor(red: 0.663, green: 0.69, blue: 0.749, alpha: 1)
        view.isHidden = true
        return view
    }()
    
    private lazy var resetButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Restablecer", for: .normal)
        button.setTitleColor(UIColor(red: 0.318, green: 0.353, blue: 0.451, alpha: 1), for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 11, weight: .regular)
        button.addTarget(self, action: #selector(resetTapped), for: .touchUpInside)
        button.isHidden = true
        return button
    }()
    
    // MARK: - Initialization
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    // MARK: - Setup
    private func setupView() {
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = .clear
        
        addSubview(scrollView)
        scrollView.addSubview(stackView)
        
        stackView.addArrangedSubview(fechaButton)
        stackView.addArrangedSubview(tipoButton)
        stackView.addArrangedSubview(montoButton)
        stackView.addArrangedSubview(todosButton)
        stackView.addArrangedSubview(separatorView)
        stackView.addArrangedSubview(resetButton)
        
        NSLayoutConstraint.activate([
            heightAnchor.constraint(equalToConstant: 65),
            
            scrollView.leadingAnchor.constraint(equalTo: leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: trailingAnchor),
            scrollView.topAnchor.constraint(equalTo: topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            stackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 16),
            stackView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -16),
            stackView.centerYAnchor.constraint(equalTo: scrollView.centerYAnchor),
            stackView.heightAnchor.constraint(equalToConstant: 33),
            
            separatorView.widthAnchor.constraint(equalToConstant: 1),
            separatorView.heightAnchor.constraint(equalToConstant: 20)
        ])
    }
    
    // MARK: - Private Methods
    private func updateResetButtonVisibility() {
        let hasActiveFilters = fechaButton.isFilterActive || tipoButton.isFilterActive || montoButton.isFilterActive
        
        UIView.animate(withDuration: 0.2) {
            self.separatorView.isHidden = !hasActiveFilters
            self.resetButton.isHidden = !hasActiveFilters
            self.separatorView.alpha = hasActiveFilters ? 1 : 0
            self.resetButton.alpha = hasActiveFilters ? 1 : 0
        }
    }
    
    // MARK: - Public Methods
    func setDateFilter(_ value: String?) {
        fechaButton.setFilterValue(value)
        updateResetButtonVisibility()
    }
    
    func setTypeFilter(_ value: String?) {
        tipoButton.setFilterValue(value)
        updateResetButtonVisibility()
    }
    
    func setAmountFilter(_ value: String?) {
        montoButton.setFilterValue(value)
        updateResetButtonVisibility()
    }
    
    func clearAllFilters() {
        fechaButton.clearFilter()
        tipoButton.clearFilter()
        montoButton.clearFilter()
        updateResetButtonVisibility()
    }
    
    // MARK: - Actions
    @objc private func filterTapped(_ sender: FilterChipButton) {
        let filterType = sender.accessibilityIdentifier ?? ""
        
        // If filter is active and user taps, clear it
        if sender.isFilterActive {
            sender.clearFilter()
            updateResetButtonVisibility()
            onFilterCleared?(filterType)
        } else {
            onFilterSelected?(filterType, sender)
        }
    }
    
    @objc private func resetTapped() {
        clearAllFilters()
        onResetAllFilters?()
        
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
    }
    
    // MARK: - Animation
    func show(animated: Bool = true) {
        if animated {
            alpha = 0
            isHidden = false
            UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseOut) {
                self.alpha = 1
            }
        } else {
            isHidden = false
            alpha = 1
        }
    }
    
    func hide(animated: Bool = true) {
        if animated {
            UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseIn) {
                self.alpha = 0
            } completion: { _ in
                self.isHidden = true
            }
        } else {
            isHidden = true
            alpha = 0
        }
    }
}
