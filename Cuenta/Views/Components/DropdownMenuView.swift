import UIKit

// MARK: - Dropdown Menu Item
struct DropdownMenuItem {
    let title: String
    var isSelected: Bool
    let isSeparator: Bool
    
    init(title: String, isSelected: Bool = false, isSeparator: Bool = false) {
        self.title = title
        self.isSelected = isSelected
        self.isSeparator = isSeparator
    }
    
    static func separator() -> DropdownMenuItem {
        return DropdownMenuItem(title: "", isSeparator: true)
    }
}

// MARK: - Dropdown Menu View
final class DropdownMenuView: UIView {
    
    // MARK: - Properties
    var items: [DropdownMenuItem] = [] {
        didSet {
            rebuildMenu()
        }
    }
    
    var onItemSelected: ((Int, DropdownMenuItem) -> Void)?
    var onDismiss: (() -> Void)?
    
    var menuWidth: CGFloat = 238 {
        didSet {
            widthConstraint?.constant = menuWidth
        }
    }
    
    private var widthConstraint: NSLayoutConstraint?
    
    // MARK: - UI Components
    private let containerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 34
        view.clipsToBounds = true
        return view
    }()
    
    private let blurView: UIVisualEffectView = {
        let blur = UIBlurEffect(style: .systemUltraThinMaterial)
        let view = UIVisualEffectView(effect: blur)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 34
        view.clipsToBounds = true
        return view
    }()
    
    private let glassOverlay: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        // background: rgba(245, 245, 245, 0.6) blended with color-dodge
        view.backgroundColor = UIColor(red: 0.96, green: 0.96, blue: 0.96, alpha: 0.85)
        view.layer.cornerRadius = 34
        return view
    }()
    
    private let stackView: UIStackView = {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.spacing = 0
        stack.alignment = .fill
        return stack
    }()
    
    private let backgroundOverlay: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .clear
        return view
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
        
        // Shadow
        containerView.layer.shadowColor = UIColor.black.cgColor
        containerView.layer.shadowOpacity = 0.08
        containerView.layer.shadowOffset = CGSize(width: 0, height: 4)
        containerView.layer.shadowRadius = 20
        containerView.layer.masksToBounds = false
        
        addSubview(containerView)
        containerView.addSubview(blurView)
        containerView.addSubview(glassOverlay)
        containerView.addSubview(stackView)
        
        widthConstraint = containerView.widthAnchor.constraint(equalToConstant: menuWidth)
        
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: topAnchor),
            containerView.leadingAnchor.constraint(equalTo: leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: trailingAnchor),
            containerView.bottomAnchor.constraint(equalTo: bottomAnchor),
            widthConstraint!,
            
            blurView.topAnchor.constraint(equalTo: containerView.topAnchor),
            blurView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            blurView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            blurView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
            
            glassOverlay.topAnchor.constraint(equalTo: containerView.topAnchor),
            glassOverlay.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            glassOverlay.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            glassOverlay.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
            
            stackView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 10),
            stackView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            stackView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            stackView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -10)
        ])
    }
    
    private func rebuildMenu() {
        stackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        for (index, item) in items.enumerated() {
            if item.isSeparator {
                let separator = createSeparator()
                stackView.addArrangedSubview(separator)
            } else {
                let itemView = createMenuItem(item: item, index: index)
                stackView.addArrangedSubview(itemView)
            }
        }
    }
    
    private func createMenuItem(item: DropdownMenuItem, index: Int) -> UIView {
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false
        container.tag = index
        
        // Checkmark
        let checkmark = UILabel()
        checkmark.translatesAutoresizingMaskIntoConstraints = false
        checkmark.text = "✓"
        checkmark.font = .systemFont(ofSize: 17, weight: .semibold)
        checkmark.textColor = UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 1)
        checkmark.isHidden = !item.isSelected
        
        // Label
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = item.title
        label.font = .systemFont(ofSize: 17, weight: .regular)
        label.textColor = UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 1)
        
        container.addSubview(checkmark)
        container.addSubview(label)
        
        // Tap gesture
        let tap = UITapGestureRecognizer(target: self, action: #selector(itemTapped(_:)))
        container.addGestureRecognizer(tap)
        container.isUserInteractionEnabled = true
        
        NSLayoutConstraint.activate([
            container.heightAnchor.constraint(equalToConstant: 40),
            
            checkmark.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 8),
            checkmark.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            checkmark.widthAnchor.constraint(equalToConstant: 24),
            
            label.leadingAnchor.constraint(equalTo: checkmark.trailingAnchor, constant: 4),
            label.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -8),
            label.centerYAnchor.constraint(equalTo: container.centerYAnchor)
        ])
        
        return container
    }
    
    private func createSeparator() -> UIView {
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false
        
        let line = UIView()
        line.translatesAutoresizingMaskIntoConstraints = false
        line.backgroundColor = UIColor(red: 0.9, green: 0.9, blue: 0.9, alpha: 1)
        
        container.addSubview(line)
        
        NSLayoutConstraint.activate([
            container.heightAnchor.constraint(equalToConstant: 21),
            
            line.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 8),
            line.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -8),
            line.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            line.heightAnchor.constraint(equalToConstant: 1)
        ])
        
        return container
    }
    
    // MARK: - Actions
    @objc private func itemTapped(_ gesture: UITapGestureRecognizer) {
        guard let view = gesture.view else { return }
        let index = view.tag
        
        // Haptic feedback
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
        
        // Update selection
        for i in 0..<items.count {
            if !items[i].isSeparator {
                items[i].isSelected = (i == index)
            }
        }
        
        // Callback - NO auto-dismiss, user must tap outside or tap filter button again
        onItemSelected?(index, items[index])
    }
    
    @objc private func backgroundTapped() {
        dismiss()
    }
    enum DropdownAlignment {
        case leading
        case trailing
        case center
    }
    
    enum DropdownDirection {
        case down
        case up
    }
    
    // MARK: - Show/Hide
    func show(from anchorView: UIView, in parentView: UIView, alignment: DropdownAlignment = .leading, direction: DropdownDirection = .down) {
        // Add background overlay first to capture taps outside
        parentView.addSubview(backgroundOverlay)
        NSLayoutConstraint.activate([
            backgroundOverlay.topAnchor.constraint(equalTo: parentView.topAnchor),
            backgroundOverlay.leadingAnchor.constraint(equalTo: parentView.leadingAnchor),
            backgroundOverlay.trailingAnchor.constraint(equalTo: parentView.trailingAnchor),
            backgroundOverlay.bottomAnchor.constraint(equalTo: parentView.bottomAnchor)
        ])
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(backgroundTapped))
        backgroundOverlay.addGestureRecognizer(tapGesture)
        
        // Add dropdown on top of overlay
        parentView.addSubview(self)
        
        // Position relative to anchor
        let anchorFrame = anchorView.convert(anchorView.bounds, to: parentView)
        
        var constraints: [NSLayoutConstraint] = []
        
        // Vertical positioning
        switch direction {
        case .down:
            constraints.append(topAnchor.constraint(equalTo: parentView.topAnchor, constant: anchorFrame.maxY + 8))
        case .up:
            constraints.append(bottomAnchor.constraint(equalTo: parentView.topAnchor, constant: anchorFrame.minY - 8))
        }
        
        // Horizontal positioning
        switch alignment {
        case .leading:
            constraints.append(leadingAnchor.constraint(equalTo: parentView.leadingAnchor, constant: anchorFrame.minX))
        case .trailing:
            constraints.append(trailingAnchor.constraint(equalTo: parentView.trailingAnchor, constant: -(parentView.bounds.width - anchorFrame.maxX)))
        case .center:
            constraints.append(centerXAnchor.constraint(equalTo: parentView.leadingAnchor, constant: anchorFrame.midX))
        }
        
        NSLayoutConstraint.activate(constraints)
        
        // Animate in
        alpha = 0
        let translateY: CGFloat = direction == .up ? 10 : -10
        transform = CGAffineTransform(scaleX: 0.95, y: 0.95).translatedBy(x: 0, y: translateY)
        
        UIView.animate(withDuration: 0.25, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.5) {
            self.alpha = 1
            self.transform = .identity
        }
    }
    
    func dismiss() {
        dismiss(completion: nil)
    }
    
    func dismiss(completion: (() -> Void)?) {
        UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseIn) {
            self.alpha = 0
            self.transform = CGAffineTransform(scaleX: 0.95, y: 0.95).translatedBy(x: 0, y: -10)
        } completion: { _ in
            self.backgroundOverlay.removeFromSuperview()
            self.removeFromSuperview()
            self.onDismiss?()
            completion?()
        }
    }
}

// MARK: - Filter Dropdown Configurations
extension DropdownMenuView {
    
    static func dateFilterMenu(selectedIndex: Int = 0) -> DropdownMenuView {
        let menu = DropdownMenuView()
        menu.items = [
            DropdownMenuItem(title: "Últimos 7 días", isSelected: selectedIndex == 0),
            DropdownMenuItem(title: "Últimos 15 días", isSelected: selectedIndex == 1),
            DropdownMenuItem(title: "Últimos 30 días", isSelected: selectedIndex == 2),
            .separator(),
            DropdownMenuItem(title: "Personalizado", isSelected: selectedIndex == 4)
        ]
        return menu
    }
    
    static func typeFilterMenu(selectedIndex: Int = 0) -> DropdownMenuView {
        let menu = DropdownMenuView()
        menu.menuWidth = 238
        menu.items = [
            DropdownMenuItem(title: "Todos", isSelected: selectedIndex == 0),
            DropdownMenuItem(title: "Ingresos", isSelected: selectedIndex == 1),
            DropdownMenuItem(title: "Egresos", isSelected: selectedIndex == 2)
        ]
        return menu
    }
    
    static func amountFilterMenu(selectedIndex: Int = 0) -> DropdownMenuView {
        let menu = DropdownMenuView()
        menu.menuWidth = 197
        menu.items = [
            DropdownMenuItem(title: "Todos", isSelected: selectedIndex == 0),
            DropdownMenuItem(title: "Personalizado", isSelected: selectedIndex == 1)
        ]
        return menu
    }
    
    static func moreOptionsMenu() -> DropdownMenuView {
        let menu = DropdownMenuView()
        menu.menuWidth = 238
        menu.items = [
            DropdownMenuItem(title: "Documentos", isSelected: false),
            DropdownMenuItem(title: "Configurar cuenta", isSelected: false)
        ]
        return menu
    }
    
    static func exportMenu() -> DropdownMenuView {
        let menu = DropdownMenuView()
        menu.menuWidth = 200
        menu.items = [
            DropdownMenuItem(title: "Compartir PDF", isSelected: false),
            DropdownMenuItem(title: "Compartir Excel", isSelected: false)
        ]
        return menu
    }
    
    static func downloadFormatMenu() -> DropdownMenuView {
        let menu = DropdownMenuView()
        menu.menuWidth = 160
        menu.items = [
            DropdownMenuItem(title: "PDF", isSelected: false),
            DropdownMenuItem(title: "Excel", isSelected: false)
        ]
        return menu
    }
    
    // Legacy method kept for reference but not used
    static func _amountFilterMenuExtended(selectedIndex: Int = -1) -> DropdownMenuView {
        let menu = DropdownMenuView()
        menu.items = [
            DropdownMenuItem(title: "Personalizado", isSelected: selectedIndex == 5)
        ]
        return menu
    }
}
