import UIKit

final class SearchBarView: UIView {
    
    // MARK: - UI Components
    private let containerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .clear
        view.layer.cornerRadius = 24
        view.clipsToBounds = true
        return view
    }()
    
    private let blurView: UIVisualEffectView = {
        let blur = UIBlurEffect(style: .systemUltraThinMaterial)
        let view = UIVisualEffectView(effect: blur)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 24
        view.clipsToBounds = true
        return view
    }()
    
    private let glassOverlay: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor(red: 0.969, green: 0.969, blue: 0.969, alpha: 0.85) // #F7F7F7
        view.layer.cornerRadius = 24
        return view
    }()
    
    private let innerShadowLayer: CALayer = {
        let layer = CALayer()
        layer.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.004).cgColor
        return layer
    }()
    
    private let searchIcon: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(systemName: "magnifyingglass")?
            .withConfiguration(UIImage.SymbolConfiguration(pointSize: 20, weight: .regular))
        imageView.tintColor = .textSecondary
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    let textField: UITextField = {
        let textField = UITextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.placeholder = "Buscar nombre o comercio"
        textField.font = .searchPlaceholder
        textField.textColor = .textPrimary
        textField.borderStyle = .none
        textField.backgroundColor = .clear
        return textField
    }()
    
    private let filterContainerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .clear
        view.layer.cornerRadius = 24
        view.clipsToBounds = true
        return view
    }()
    
    private let filterBlurView: UIVisualEffectView = {
        let blur = UIBlurEffect(style: .systemUltraThinMaterial)
        let view = UIVisualEffectView(effect: blur)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 24
        view.clipsToBounds = true
        return view
    }()
    
    let filterOverlay: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor(red: 0.969, green: 0.969, blue: 0.969, alpha: 0.85)
        view.layer.cornerRadius = 24
        return view
    }()
    
    let filterButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage(systemName: "line.3.horizontal.decrease")?
            .withConfiguration(UIImage.SymbolConfiguration(pointSize: 18, weight: .medium)), for: .normal)
        button.tintColor = .accentBlue
        button.backgroundColor = .clear
        button.layer.cornerRadius = 24
        button.clipsToBounds = true
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
        
        // Search container with glass effect
        addSubview(containerView)
        containerView.addSubview(blurView)
        containerView.addSubview(glassOverlay)
        containerView.addSubview(searchIcon)
        containerView.addSubview(textField)
        
        // Filter button with glass effect
        addSubview(filterContainerView)
        filterContainerView.addSubview(filterBlurView)
        filterContainerView.addSubview(filterOverlay)
        filterContainerView.addSubview(filterButton)
        
        // Add subtle shadow to containers
        containerView.layer.shadowColor = UIColor.black.cgColor
        containerView.layer.shadowOpacity = 0.04
        containerView.layer.shadowOffset = CGSize(width: 0, height: 2)
        containerView.layer.shadowRadius = 10
        containerView.layer.masksToBounds = false
        
        filterContainerView.layer.shadowColor = UIColor.black.cgColor
        filterContainerView.layer.shadowOpacity = 0.04
        filterContainerView.layer.shadowOffset = CGSize(width: 0, height: 2)
        filterContainerView.layer.shadowRadius = 10
        filterContainerView.layer.masksToBounds = false
        
        NSLayoutConstraint.activate([
            // Container
            containerView.leadingAnchor.constraint(equalTo: leadingAnchor),
            containerView.topAnchor.constraint(equalTo: topAnchor),
            containerView.bottomAnchor.constraint(equalTo: bottomAnchor),
            containerView.trailingAnchor.constraint(equalTo: filterContainerView.leadingAnchor, constant: -8),
            containerView.heightAnchor.constraint(equalToConstant: 48),
            
            // Blur View
            blurView.topAnchor.constraint(equalTo: containerView.topAnchor),
            blurView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            blurView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            blurView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
            
            // Glass Overlay
            glassOverlay.topAnchor.constraint(equalTo: containerView.topAnchor),
            glassOverlay.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            glassOverlay.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            glassOverlay.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
            
            // Search Icon
            searchIcon.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            searchIcon.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            searchIcon.widthAnchor.constraint(equalToConstant: 24),
            searchIcon.heightAnchor.constraint(equalToConstant: 24),
            
            // Text Field
            textField.leadingAnchor.constraint(equalTo: searchIcon.trailingAnchor, constant: 12),
            textField.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            textField.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            
            // Filter Container
            filterContainerView.trailingAnchor.constraint(equalTo: trailingAnchor),
            filterContainerView.centerYAnchor.constraint(equalTo: centerYAnchor),
            filterContainerView.widthAnchor.constraint(equalToConstant: 48),
            filterContainerView.heightAnchor.constraint(equalToConstant: 48),
            
            // Filter Blur
            filterBlurView.topAnchor.constraint(equalTo: filterContainerView.topAnchor),
            filterBlurView.leadingAnchor.constraint(equalTo: filterContainerView.leadingAnchor),
            filterBlurView.trailingAnchor.constraint(equalTo: filterContainerView.trailingAnchor),
            filterBlurView.bottomAnchor.constraint(equalTo: filterContainerView.bottomAnchor),
            
            // Filter Overlay
            filterOverlay.topAnchor.constraint(equalTo: filterContainerView.topAnchor),
            filterOverlay.leadingAnchor.constraint(equalTo: filterContainerView.leadingAnchor),
            filterOverlay.trailingAnchor.constraint(equalTo: filterContainerView.trailingAnchor),
            filterOverlay.bottomAnchor.constraint(equalTo: filterContainerView.bottomAnchor),
            
            // Filter Button
            filterButton.topAnchor.constraint(equalTo: filterContainerView.topAnchor),
            filterButton.leadingAnchor.constraint(equalTo: filterContainerView.leadingAnchor),
            filterButton.trailingAnchor.constraint(equalTo: filterContainerView.trailingAnchor),
            filterButton.bottomAnchor.constraint(equalTo: filterContainerView.bottomAnchor)
        ])
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        // Update shadow paths for better performance
        containerView.layer.shadowPath = UIBezierPath(roundedRect: containerView.bounds, cornerRadius: 24).cgPath
        filterContainerView.layer.shadowPath = UIBezierPath(roundedRect: filterContainerView.bounds, cornerRadius: 24).cgPath
    }
}
