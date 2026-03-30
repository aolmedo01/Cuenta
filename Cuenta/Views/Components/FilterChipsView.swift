import UIKit

final class FilterChipButton: UIButton {
    
    private var hasChevron: Bool = true
    
    // MARK: - Initialization
    init(title: String, showChevron: Bool = true) {
        self.hasChevron = showChevron
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
    
    // MARK: - UI Components
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
        
        addSubview(stackView)
        
        stackView.addArrangedSubview(fechaButton)
        stackView.addArrangedSubview(tipoButton)
        stackView.addArrangedSubview(montoButton)
        stackView.addArrangedSubview(todosButton)
        
        // Same padding as searchContainer: 16px horizontal, height 65px with 16px vertical padding
        NSLayoutConstraint.activate([
            heightAnchor.constraint(equalToConstant: 65),
            
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            stackView.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor, constant: -16),
            stackView.centerYAnchor.constraint(equalTo: centerYAnchor),
            stackView.heightAnchor.constraint(equalToConstant: 33)
        ])
    }
    
    // MARK: - Actions
    @objc private func filterTapped(_ sender: FilterChipButton) {
        let filterType = sender.accessibilityIdentifier ?? ""
        onFilterSelected?(filterType, sender)
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
