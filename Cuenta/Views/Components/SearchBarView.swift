import UIKit

final class SearchBarView: UIView {
    
    // MARK: - UI Components
    
    // Search container outer ring (liquid glass effect)
    private let searchOuterRing: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor.white.withAlphaComponent(0.6)
        view.layer.cornerRadius = 28
        return view
    }()
    
    private let containerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .clear
        view.layer.cornerRadius = 24
        view.clipsToBounds = true
        return view
    }()
    
    private let blurView: UIVisualEffectView = {
        let blur = UIBlurEffect(style: .systemThinMaterial)
        let view = UIVisualEffectView(effect: blur)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 24
        view.clipsToBounds = true
        return view
    }()
    
    private let glassOverlay: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor(red: 0.973, green: 0.973, blue: 0.973, alpha: 0.95) // #f8f8f8
        view.layer.cornerRadius = 24
        return view
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
    
    // Filter button outer ring (liquid glass effect)
    private let filterOuterRing: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor.white.withAlphaComponent(0.6)
        view.layer.cornerRadius = 28
        return view
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
        let blur = UIBlurEffect(style: .systemThinMaterial)
        let view = UIVisualEffectView(effect: blur)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 24
        view.clipsToBounds = true
        return view
    }()
    
    let filterOverlay: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor(red: 0.973, green: 0.973, blue: 0.973, alpha: 0.95) // #f8f8f8
        view.layer.cornerRadius = 24
        return view
    }()
    
    // Blue circle for active state (same size as filter container)
    private let activeBlueCircle: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .accentBlue
        view.layer.cornerRadius = 24
        view.alpha = 0
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
    
    private var isFilterActive: Bool = false
    
    // Highlight layers for glass effect
    private var searchHighlightLayer: CAShapeLayer?
    private var filterHighlightLayer: CAShapeLayer?
    
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
        
        // Search container with liquid glass effect
        addSubview(searchOuterRing)
        addSubview(containerView)
        containerView.addSubview(blurView)
        containerView.addSubview(glassOverlay)
        containerView.addSubview(searchIcon)
        containerView.addSubview(textField)
        
        // Filter button with liquid glass effect
        addSubview(filterOuterRing)
        addSubview(filterContainerView)
        filterContainerView.addSubview(filterBlurView)
        filterContainerView.addSubview(filterOverlay)
        filterContainerView.addSubview(activeBlueCircle)
        filterContainerView.addSubview(filterButton)
        
        // Add shadow to outer rings for depth
        searchOuterRing.layer.shadowColor = UIColor.black.cgColor
        searchOuterRing.layer.shadowOpacity = 0.06
        searchOuterRing.layer.shadowOffset = CGSize(width: 0, height: 4)
        searchOuterRing.layer.shadowRadius = 12
        
        filterOuterRing.layer.shadowColor = UIColor.black.cgColor
        filterOuterRing.layer.shadowOpacity = 0.06
        filterOuterRing.layer.shadowOffset = CGSize(width: 0, height: 4)
        filterOuterRing.layer.shadowRadius = 12
        
        NSLayoutConstraint.activate([
            // Search Outer Ring (liquid glass effect)
            searchOuterRing.leadingAnchor.constraint(equalTo: leadingAnchor, constant: -4),
            searchOuterRing.topAnchor.constraint(equalTo: topAnchor, constant: -4),
            searchOuterRing.bottomAnchor.constraint(equalTo: bottomAnchor, constant: 4),
            searchOuterRing.trailingAnchor.constraint(equalTo: filterOuterRing.leadingAnchor, constant: -8),
            
            // Container
            containerView.leadingAnchor.constraint(equalTo: leadingAnchor),
            containerView.topAnchor.constraint(equalTo: topAnchor),
            containerView.bottomAnchor.constraint(equalTo: bottomAnchor),
            containerView.trailingAnchor.constraint(equalTo: filterContainerView.leadingAnchor, constant: -16),
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
            
            // Filter Outer Ring (liquid glass effect)
            filterOuterRing.trailingAnchor.constraint(equalTo: trailingAnchor, constant: 4),
            filterOuterRing.centerYAnchor.constraint(equalTo: centerYAnchor),
            filterOuterRing.widthAnchor.constraint(equalToConstant: 56),
            filterOuterRing.heightAnchor.constraint(equalToConstant: 56),
            
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
            
            // Active Blue Circle (same size as container)
            activeBlueCircle.topAnchor.constraint(equalTo: filterContainerView.topAnchor),
            activeBlueCircle.leadingAnchor.constraint(equalTo: filterContainerView.leadingAnchor),
            activeBlueCircle.trailingAnchor.constraint(equalTo: filterContainerView.trailingAnchor),
            activeBlueCircle.bottomAnchor.constraint(equalTo: filterContainerView.bottomAnchor),
            
            // Filter Button
            filterButton.topAnchor.constraint(equalTo: filterContainerView.topAnchor),
            filterButton.leadingAnchor.constraint(equalTo: filterContainerView.leadingAnchor),
            filterButton.trailingAnchor.constraint(equalTo: filterContainerView.trailingAnchor),
            filterButton.bottomAnchor.constraint(equalTo: filterContainerView.bottomAnchor)
        ])
    }
    
    // MARK: - Filter Active State
    func setFilterActive(_ active: Bool, animated: Bool = true) {
        guard isFilterActive != active else { return }
        isFilterActive = active
        
        if animated {
            UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.5) {
                self.updateFilterAppearance()
            }
        } else {
            updateFilterAppearance()
        }
    }
    
    private func updateFilterAppearance() {
        if isFilterActive {
            // Show active state - blue circle, white icon
            activeBlueCircle.alpha = 1
            filterOverlay.alpha = 0
            filterButton.tintColor = .white
        } else {
            // Show inactive state - glass overlay, blue icon
            activeBlueCircle.alpha = 0
            filterOverlay.alpha = 1
            filterButton.tintColor = .accentBlue
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        // Update shadow paths for better performance
        searchOuterRing.layer.shadowPath = UIBezierPath(roundedRect: searchOuterRing.bounds, cornerRadius: 28).cgPath
        filterOuterRing.layer.shadowPath = UIBezierPath(roundedRect: filterOuterRing.bounds, cornerRadius: 28).cgPath
        
        // Add highlight border on top-left for search container
        addHighlightBorder(to: glassOverlay, cornerRadius: 24, existingLayer: &searchHighlightLayer)
        
        // Add highlight border on top-left for filter overlay
        addHighlightBorder(to: filterOverlay, cornerRadius: 24, existingLayer: &filterHighlightLayer)
    }
    
    private func addHighlightBorder(to view: UIView, cornerRadius: CGFloat, existingLayer: inout CAShapeLayer?) {
        existingLayer?.removeFromSuperlayer()
        
        let bounds = view.bounds
        guard bounds.width > 0 && bounds.height > 0 else { return }
        
        // Create path for top-left highlight (from bottom-left, up, across top, down right side partially)
        let path = UIBezierPath()
        
        // Start from bottom-left
        path.move(to: CGPoint(x: 0, y: bounds.height - cornerRadius))
        
        // Line up the left side
        path.addLine(to: CGPoint(x: 0, y: cornerRadius))
        
        // Top-left corner arc
        path.addArc(
            withCenter: CGPoint(x: cornerRadius, y: cornerRadius),
            radius: cornerRadius,
            startAngle: .pi,
            endAngle: -.pi / 2,
            clockwise: true
        )
        
        // Line across the top
        path.addLine(to: CGPoint(x: bounds.width - cornerRadius, y: 0))
        
        // Top-right corner arc (partial)
        path.addArc(
            withCenter: CGPoint(x: bounds.width - cornerRadius, y: cornerRadius),
            radius: cornerRadius,
            startAngle: -.pi / 2,
            endAngle: 0,
            clockwise: true
        )
        
        let highlightLayer = CAShapeLayer()
        highlightLayer.path = path.cgPath
        highlightLayer.strokeColor = UIColor.white.cgColor
        highlightLayer.fillColor = UIColor.clear.cgColor
        highlightLayer.lineWidth = 2.5
        highlightLayer.lineCap = .round
        
        view.layer.addSublayer(highlightLayer)
        existingLayer = highlightLayer
    }
}
