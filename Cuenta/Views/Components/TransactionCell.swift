import UIKit

final class TransactionCell: UIView {
    
    // MARK: - Properties
    private var isExpanded = false
    var isCurrentlyExpanded: Bool { isExpanded }
    
    private var transaction: Transaction?
    var onExpansionChanged: ((Bool) -> Void)?
    var onShareTapped: ((Transaction) -> Void)?
    
    private var collapsedHeight: CGFloat = 64
    private var expandedHeight: CGFloat = 280
    
    private var heightConstraint: NSLayoutConstraint?
    private var detailViewHeightConstraint: NSLayoutConstraint?
    
    // Highlight layer for wave animation
    private let highlightLayer: CAGradientLayer = {
        let layer = CAGradientLayer()
        layer.colors = [
            UIColor(red: 0.047, green: 0.306, blue: 0.796, alpha: 0.15).cgColor,
            UIColor(red: 0.047, green: 0.306, blue: 0.796, alpha: 0.05).cgColor,
            UIColor.clear.cgColor
        ]
        layer.locations = [0, 0.5, 1]
        layer.startPoint = CGPoint(x: 0.5, y: 0)
        layer.endPoint = CGPoint(x: 0.5, y: 1)
        layer.opacity = 0
        return layer
    }()
    
    // MARK: - UI Components
    private let containerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor(red: 0.988, green: 0.988, blue: 0.992, alpha: 1) // #FCFCFD
        view.layer.cornerRadius = 24
        return view
    }()
    
    private let iconContainer: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor(red: 0.961, green: 0.965, blue: 0.973, alpha: 1) // #F5F6F8
        view.layer.cornerRadius = 18
        return view
    }()
    
    private let iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = UIColor(red: 0.047, green: 0.067, blue: 0.114, alpha: 1) // #0C111D
        return imageView
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .manrope(size: 17, weight: .semibold)
        label.textColor = UIColor(red: 0.122, green: 0.161, blue: 0.239, alpha: 1) // #1F293D
        return label
    }()
    
    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .manrope(size: 15, weight: .regular)
        label.textColor = UIColor(red: 0.424, green: 0.455, blue: 0.553, alpha: 1) // #6C748D
        return label
    }()
    
    private let statusBadge: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor(red: 0.906, green: 0.937, blue: 1.0, alpha: 1) // #E7EFFF
        view.layer.cornerRadius = 14
        view.isHidden = true
        return view
    }()
    
    private let statusClockIcon: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(systemName: "clock")?
            .withConfiguration(UIImage.SymbolConfiguration(pointSize: 14, weight: .medium))
        imageView.tintColor = UIColor(red: 0.035, green: 0.231, blue: 0.596, alpha: 1) // #093B98
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private let statusLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .manrope(size: 15, weight: .regular)
        label.textColor = UIColor(red: 0.035, green: 0.231, blue: 0.596, alpha: 1) // #093B98
        label.textAlignment = .center
        return label
    }()
    
    private let statusTimeLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .manrope(size: 15, weight: .bold)
        label.textColor = UIColor(red: 0.035, green: 0.231, blue: 0.596, alpha: 1) // #093B98
        label.textAlignment = .center
        return label
    }()
    
    private let amountLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .manrope(size: 15, weight: .regular)
        label.textAlignment = .right
        return label
    }()
    
    private let balanceLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .manrope(size: 12, weight: .regular)
        label.textColor = UIColor(red: 0.541, green: 0.576, blue: 0.659, alpha: 1) // #8A93A8
        label.textAlignment = .right
        return label
    }()
    
    // Extra labels for electricity (CNEL) type
    private let subtitle2Label: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .manrope(size: 15, weight: .regular)
        label.textColor = UIColor(red: 0.424, green: 0.455, blue: 0.553, alpha: 1) // #6C748D
        label.isHidden = true
        return label
    }()
    
    private let subtitle3Label: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .manrope(size: 15, weight: .regular)
        label.textColor = UIColor(red: 0.424, green: 0.455, blue: 0.553, alpha: 1) // #6C748D
        label.isHidden = true
        return label
    }()
    
    private let extraBalance1Label: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .manrope(size: 12, weight: .regular)
        label.textColor = UIColor(red: 0.541, green: 0.576, blue: 0.659, alpha: 1) // #8A93A8
        label.textAlignment = .right
        label.isHidden = true
        return label
    }()
    
    private let extraBalance2Label: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .manrope(size: 12, weight: .regular)
        label.textColor = UIColor(red: 0.541, green: 0.576, blue: 0.659, alpha: 1) // #8A93A8
        label.textAlignment = .right
        label.isHidden = true
        return label
    }()
    
    private var isElectricityType = false
    
    private let labelsStack: UIStackView = {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.spacing = 0
        stack.alignment = .leading
        stack.distribution = .fillEqually
        return stack
    }()
    
    private let amountStack: UIStackView = {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.spacing = 0
        stack.alignment = .trailing
        stack.distribution = .fillEqually
        return stack
    }()
    
    // MARK: - Expandable Detail View
    private let detailContainerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor(red: 0.988, green: 0.988, blue: 0.992, alpha: 1)
        view.clipsToBounds = true
        view.alpha = 0
        return view
    }()
    
    private let separatorLine: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor(red: 0.933, green: 0.941, blue: 0.957, alpha: 1) // #EEF0F4
        return view
    }()
    
    private let detailStackView: UIStackView = {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.spacing = 16
        stack.alignment = .fill
        return stack
    }()
    
    // Detail rows - Standard
    private let fechaRow = TransactionDetailRow(label: "Fecha")
    private let tipoRow = TransactionDetailRow(label: "Tipo")
    private let referenciaRow = TransactionDetailRow(label: "Referencia")
    
    // Detail rows - Withdrawal specific
    private let enviadoARow = TransactionDetailRow(label: "Enviado a")
    private let celularRow = TransactionDetailRow(label: "Celular")
    private let tiempoRestanteRow = TransactionDetailRow(label: "Tiempo restante")
    
    private let progressBarContainer: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor(red: 0.878, green: 0.878, blue: 0.878, alpha: 1) // Light gray
        view.layer.cornerRadius = 4
        return view
    }()
    
    private let progressBarFill: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .accentBlue
        view.layer.cornerRadius = 4
        return view
    }()
    
    private var progressWidthConstraint: NSLayoutConstraint?
    
    // Warning text shown in collapsed state for cardless withdrawals
    private let collapsedWarningLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Si el tiempo expira, el dinero regresará a tu cuenta."
        label.font = .manrope(size: 11, weight: .regular)
        label.textColor = UIColor(red: 0.541, green: 0.576, blue: 0.659, alpha: 1) // #8A93A8
        label.isHidden = true
        return label
    }()
    
    private let footerMessageLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "El dinero volverá a tu cuenta si expira el tiempo"
        label.font = .manrope(size: 12, weight: .regular)
        label.textColor = UIColor(red: 0.424, green: 0.455, blue: 0.553, alpha: 1) // #6C748D
        label.textAlignment = .center
        label.isHidden = true
        return label
    }()
    
    private let reportButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Reportar este consumo", for: .normal)
        button.titleLabel?.font = .manrope(size: 11, weight: .regular)
        button.setTitleColor(UIColor(red: 0.047, green: 0.306, blue: 0.796, alpha: 1), for: .normal) // #0C4ECB
        button.contentHorizontalAlignment = .left
        return button
    }()
    
    private let compartirButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Compartir", for: .normal)
        button.titleLabel?.font = .manrope(size: 17, weight: .regular)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = UIColor(red: 0.086, green: 0.059, blue: 0.255, alpha: 1) // #160F41
        button.layer.cornerRadius = 17
        return button
    }()
    
    // Track if this is a withdrawal transaction
    private var isWithdrawalPending = false
    
    // MARK: - Initialization
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
        setupTapGesture()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
        setupTapGesture()
    }
    
    // MARK: - Setup
    private func setupView() {
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = .clear
        
        addSubview(containerView)
        
        labelsStack.addArrangedSubview(titleLabel)
        labelsStack.addArrangedSubview(subtitleLabel)
        labelsStack.addArrangedSubview(statusBadge)
        labelsStack.addArrangedSubview(collapsedWarningLabel)
        labelsStack.addArrangedSubview(subtitle2Label)
        labelsStack.addArrangedSubview(subtitle3Label)
        statusBadge.addSubview(statusClockIcon)
        statusBadge.addSubview(statusLabel)
        statusBadge.addSubview(statusTimeLabel)
        
        amountStack.addArrangedSubview(amountLabel)
        amountStack.addArrangedSubview(balanceLabel)
        amountStack.addArrangedSubview(extraBalance1Label)
        amountStack.addArrangedSubview(extraBalance2Label)
        
        containerView.addSubview(iconContainer)
        iconContainer.addSubview(iconImageView)
        containerView.addSubview(labelsStack)
        containerView.addSubview(amountStack)
        
        // Detail view setup
        containerView.addSubview(detailContainerView)
        detailContainerView.addSubview(separatorLine)
        detailContainerView.addSubview(detailStackView)
        
        // Standard detail rows (will be hidden for withdrawal)
        detailStackView.addArrangedSubview(fechaRow)
        detailStackView.addArrangedSubview(tipoRow)
        detailStackView.addArrangedSubview(referenciaRow)
        detailStackView.addArrangedSubview(reportButton)
        
        // Withdrawal specific rows (will be hidden for standard transactions)
        detailStackView.addArrangedSubview(enviadoARow)
        detailStackView.addArrangedSubview(celularRow)
        detailStackView.addArrangedSubview(tiempoRestanteRow)
        
        // Progress bar
        detailContainerView.addSubview(progressBarContainer)
        progressBarContainer.addSubview(progressBarFill)
        progressWidthConstraint = progressBarFill.widthAnchor.constraint(equalTo: progressBarContainer.widthAnchor, multiplier: 0.7)
        
        // Footer message
        containerView.addSubview(footerMessageLabel)
        
        containerView.addSubview(compartirButton)
        compartirButton.alpha = 0
        
        heightConstraint = heightAnchor.constraint(equalToConstant: collapsedHeight)
        detailViewHeightConstraint = detailContainerView.heightAnchor.constraint(equalToConstant: 0)
        
        NSLayoutConstraint.activate([
            // Container View
            containerView.topAnchor.constraint(equalTo: topAnchor),
            containerView.leadingAnchor.constraint(equalTo: leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: trailingAnchor),
            containerView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -8),
            
            // Status Badge - "Por retirar 23 h" style
            statusBadge.heightAnchor.constraint(equalToConstant: 28),
            statusClockIcon.leadingAnchor.constraint(equalTo: statusBadge.leadingAnchor, constant: 10),
            statusClockIcon.centerYAnchor.constraint(equalTo: statusBadge.centerYAnchor),
            statusClockIcon.widthAnchor.constraint(equalToConstant: 16),
            statusClockIcon.heightAnchor.constraint(equalToConstant: 16),
            statusLabel.leadingAnchor.constraint(equalTo: statusClockIcon.trailingAnchor, constant: 4),
            statusLabel.centerYAnchor.constraint(equalTo: statusBadge.centerYAnchor),
            statusTimeLabel.leadingAnchor.constraint(equalTo: statusLabel.trailingAnchor, constant: 2),
            statusTimeLabel.trailingAnchor.constraint(equalTo: statusBadge.trailingAnchor, constant: -10),
            statusTimeLabel.centerYAnchor.constraint(equalTo: statusBadge.centerYAnchor),
            
            // Icon Container
            iconContainer.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            iconContainer.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 14),
            iconContainer.widthAnchor.constraint(equalToConstant: 36),
            iconContainer.heightAnchor.constraint(equalToConstant: 36),
            
            // Icon Image
            iconImageView.centerXAnchor.constraint(equalTo: iconContainer.centerXAnchor),
            iconImageView.centerYAnchor.constraint(equalTo: iconContainer.centerYAnchor),
            iconImageView.widthAnchor.constraint(equalToConstant: 18),
            iconImageView.heightAnchor.constraint(equalToConstant: 18),
            
            // Labels Stack
            labelsStack.leadingAnchor.constraint(equalTo: iconContainer.trailingAnchor, constant: 16),
            labelsStack.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 12),
            labelsStack.trailingAnchor.constraint(lessThanOrEqualTo: amountStack.leadingAnchor, constant: -24),
            
            // Amount Stack
            amountStack.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            amountStack.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 12),
            
            // Detail Container
            detailContainerView.topAnchor.constraint(equalTo: labelsStack.bottomAnchor, constant: 12),
            detailContainerView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            detailContainerView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            detailViewHeightConstraint!,
            
            // Separator
            separatorLine.topAnchor.constraint(equalTo: detailContainerView.topAnchor),
            separatorLine.leadingAnchor.constraint(equalTo: detailContainerView.leadingAnchor, constant: 68),
            separatorLine.trailingAnchor.constraint(equalTo: detailContainerView.trailingAnchor, constant: -16),
            separatorLine.heightAnchor.constraint(equalToConstant: 1),
            
            // Detail Stack
            detailStackView.topAnchor.constraint(equalTo: separatorLine.bottomAnchor, constant: 16),
            detailStackView.leadingAnchor.constraint(equalTo: detailContainerView.leadingAnchor, constant: 16),
            detailStackView.trailingAnchor.constraint(equalTo: detailContainerView.trailingAnchor, constant: -16),
            
            // Progress Bar Container
            progressBarContainer.topAnchor.constraint(equalTo: detailStackView.bottomAnchor, constant: 16),
            progressBarContainer.leadingAnchor.constraint(equalTo: detailContainerView.leadingAnchor, constant: 16),
            progressBarContainer.trailingAnchor.constraint(equalTo: detailContainerView.trailingAnchor, constant: -16),
            progressBarContainer.heightAnchor.constraint(equalToConstant: 8),
            
            // Progress Bar Fill
            progressBarFill.leadingAnchor.constraint(equalTo: progressBarContainer.leadingAnchor),
            progressBarFill.topAnchor.constraint(equalTo: progressBarContainer.topAnchor),
            progressBarFill.bottomAnchor.constraint(equalTo: progressBarContainer.bottomAnchor),
            progressWidthConstraint!,
            
            // Footer Message
            footerMessageLabel.topAnchor.constraint(equalTo: progressBarContainer.bottomAnchor, constant: 20),
            footerMessageLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            footerMessageLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            
            // Compartir Button
            compartirButton.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            compartirButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            compartirButton.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -16),
            compartirButton.heightAnchor.constraint(equalToConstant: 34),
            
            // Height
            heightConstraint!
        ])
        
        // Initially hide withdrawal-specific rows and progress bar
        enviadoARow.isHidden = true
        celularRow.isHidden = true
        tiempoRestanteRow.isHidden = true
        progressBarContainer.isHidden = true
    }
    
    private func setupTapGesture() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        containerView.addGestureRecognizer(tap)
        containerView.isUserInteractionEnabled = true
        
        // Share button action
        compartirButton.addTarget(self, action: #selector(handleShareTapped), for: .touchUpInside)
    }
    
    // MARK: - Actions
    @objc private func handleTap() {
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
        toggleExpansion()
    }
    
    @objc private func handleShareTapped() {
        guard let transaction = transaction else { return }
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
        onShareTapped?(transaction)
    }
    
    func toggleExpansion(animated: Bool = true) {
        isExpanded.toggle()
        
        // Different heights for withdrawal vs standard transactions
        let withdrawalExpandedHeight: CGFloat = 277
        let standardExpandedHeight: CGFloat = expandedHeight
        let targetExpandedHeight = isWithdrawalPending ? withdrawalExpandedHeight : standardExpandedHeight
        
        let newHeight = isExpanded ? targetExpandedHeight : collapsedHeight
        let detailHeight: CGFloat = isExpanded ? (isWithdrawalPending ? 160 : 140) : 0
        
        if animated {
            if isExpanded {
                // Expanding: add wave highlight effect
                playExpandAnimation(newHeight: newHeight, detailHeight: detailHeight)
            } else {
                // Collapsing: simple animation
                playCollapseAnimation(newHeight: newHeight, detailHeight: detailHeight)
            }
        } else {
            heightConstraint?.constant = newHeight
            detailViewHeightConstraint?.constant = detailHeight
            detailContainerView.alpha = isExpanded ? 1 : 0
            compartirButton.alpha = (isExpanded && !isWithdrawalPending) ? 1 : 0
            footerMessageLabel.alpha = (isExpanded && isWithdrawalPending) ? 1 : 0
            progressBarContainer.alpha = (isExpanded && isWithdrawalPending) ? 1 : 0
            containerView.transform = .identity
        }
        
        onExpansionChanged?(isExpanded)
    }
    
    private func playExpandAnimation(newHeight: CGFloat, detailHeight: CGFloat) {
        // Setup highlight layer
        highlightLayer.frame = containerView.bounds
        highlightLayer.cornerRadius = 24
        containerView.layer.insertSublayer(highlightLayer, at: 0)
        
        // Initial scale down slightly
        containerView.transform = CGAffineTransform(scaleX: 0.98, y: 0.98)
        
        // Animate highlight fade in
        let fadeIn = CABasicAnimation(keyPath: "opacity")
        fadeIn.fromValue = 0
        fadeIn.toValue = 1
        fadeIn.duration = 0.15
        fadeIn.fillMode = .forwards
        fadeIn.isRemovedOnCompletion = false
        highlightLayer.add(fadeIn, forKey: "fadeIn")
        
        // Main expansion animation with spring
        UIView.animate(withDuration: 0.4, delay: 0, usingSpringWithDamping: 0.75, initialSpringVelocity: 0.8, options: [.curveEaseOut]) {
            self.heightConstraint?.constant = newHeight
            self.detailViewHeightConstraint?.constant = detailHeight
            self.containerView.transform = .identity
            self.superview?.layoutIfNeeded()
        }
        
        // Fade in content with slight delay
        UIView.animate(withDuration: 0.25, delay: 0.1, options: [.curveEaseOut]) {
            self.detailContainerView.alpha = 1
            self.compartirButton.alpha = self.isWithdrawalPending ? 0 : 1
            self.footerMessageLabel.alpha = self.isWithdrawalPending ? 1 : 0
            self.progressBarContainer.alpha = self.isWithdrawalPending ? 1 : 0
        }
        
        // Animate highlight fade out
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            let fadeOut = CABasicAnimation(keyPath: "opacity")
            fadeOut.fromValue = 1
            fadeOut.toValue = 0
            fadeOut.duration = 0.3
            fadeOut.fillMode = .forwards
            fadeOut.isRemovedOnCompletion = false
            self.highlightLayer.add(fadeOut, forKey: "fadeOut")
        }
    }
    
    private func playCollapseAnimation(newHeight: CGFloat, detailHeight: CGFloat) {
        // Remove any existing highlight
        highlightLayer.removeAllAnimations()
        highlightLayer.opacity = 0
        
        // Fade out content first
        UIView.animate(withDuration: 0.15, delay: 0, options: [.curveEaseIn]) {
            self.detailContainerView.alpha = 0
            self.compartirButton.alpha = 0
            self.footerMessageLabel.alpha = 0
            self.progressBarContainer.alpha = 0
        }
        
        // Collapse with spring
        UIView.animate(withDuration: 0.3, delay: 0.05, usingSpringWithDamping: 0.85, initialSpringVelocity: 0.5, options: [.curveEaseOut]) {
            self.heightConstraint?.constant = newHeight
            self.detailViewHeightConstraint?.constant = detailHeight
            self.superview?.layoutIfNeeded()
        }
    }
    
    func collapse(animated: Bool = true) {
        guard isExpanded else { return }
        
        // Clean up highlight layer
        highlightLayer.removeAllAnimations()
        highlightLayer.opacity = 0
        
        toggleExpansion(animated: animated)
    }
    
    func expand(animated: Bool = true) {
        guard !isExpanded else { return }
        toggleExpansion(animated: animated)
    }
    
    // Quick collapse for auto-mode (minimal animation)
    func collapseQuick() {
        guard isExpanded else { return }
        isExpanded = false
        
        // Clean up
        highlightLayer.removeAllAnimations()
        highlightLayer.opacity = 0
        
        // Fast collapse
        UIView.animate(withDuration: 0.15, delay: 0, options: [.curveEaseOut]) {
            self.heightConstraint?.constant = self.collapsedHeight
            self.detailViewHeightConstraint?.constant = 0
            self.detailContainerView.alpha = 0
            self.compartirButton.alpha = 0
            self.footerMessageLabel.alpha = 0
            self.progressBarContainer.alpha = 0
            self.superview?.layoutIfNeeded()
        }
        
        onExpansionChanged?(isExpanded)
    }
    
    // MARK: - Configuration
    func configure(with transaction: Transaction) {
        self.transaction = transaction
        
        titleLabel.text = transaction.name
        subtitleLabel.text = transaction.description
        amountLabel.text = transaction.formattedAmount
        balanceLabel.text = transaction.formattedBalance
        
        // Amount color - electricity and withdrawal types use dark color, others use positive/negative
        if transaction.type == .electricity || (transaction.type == .withdrawal && transaction.status == .toWithdraw) {
            amountLabel.textColor = UIColor(red: 0.129, green: 0.157, blue: 0.227, alpha: 1) // #21283A
        } else {
            amountLabel.textColor = transaction.isPositive ? .amountPositive : .amountNegative
        }
        
        // Status badge
        switch transaction.status {
        case .toWithdraw:
            statusBadge.isHidden = false
            collapsedWarningLabel.isHidden = false
            balanceLabel.isHidden = true // No balance shown for pending withdrawals
            statusLabel.text = "Por retirar"
            // Extract hours from timeRemaining (e.g., "23h 15m" -> "23 h")
            if let timeRemaining = transaction.timeRemaining {
                let hours = timeRemaining.components(separatedBy: "h").first ?? "23"
                statusTimeLabel.text = "\(hours.trimmingCharacters(in: .whitespaces)) h"
            } else {
                statusTimeLabel.text = "23 h"
            }
            subtitleLabel.isHidden = true
            // Adjust height for withdrawal with warning (104px per CSS)
            collapsedHeight = 104
            if !isExpanded {
                heightConstraint?.constant = collapsedHeight
            }
        case .pending:
            statusBadge.isHidden = false
            collapsedWarningLabel.isHidden = true
            balanceLabel.isHidden = false
            statusLabel.text = "Pendiente"
            statusTimeLabel.text = ""
            subtitleLabel.isHidden = true
        case .completed:
            statusBadge.isHidden = true
            collapsedWarningLabel.isHidden = true
            balanceLabel.isHidden = false
            subtitleLabel.isHidden = false
        }
        
        // Icon based on type
        let iconName: String
        switch transaction.type {
        case .transfer:
            iconName = "arrow.left.arrow.right"
        case .withdrawal:
            iconName = "dollarsign.square" // banking-online icon
        case .deposit:
            iconName = "arrow.down"
        case .payment:
            iconName = "drop"
        case .goal:
            iconName = "arrow.turn.up.left"
        case .cardPurchase:
            iconName = "creditcard"
        case .salary:
            iconName = "arrow.down"
        case .electricity:
            iconName = "lightbulb"
        }
        
        iconImageView.image = UIImage(systemName: iconName)?
            .withConfiguration(UIImage.SymbolConfiguration(pointSize: 16, weight: .medium))
        
        // Configure detail rows
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "es_ES")
        dateFormatter.dateFormat = "EEEE d 'de' MMMM, HH:mm"
        let dateString = dateFormatter.string(from: transaction.date).capitalized
        fechaRow.setValue(dateString)
        
        // Type description
        let typeDescription: String
        switch transaction.type {
        case .transfer:
            typeDescription = transaction.isPositive ? "Transferencia recibida" : "Transferencia enviada"
        case .withdrawal:
            typeDescription = "Retiro en cajero"
        case .deposit:
            typeDescription = "Transferencia desde Banco Pichincha"
        case .payment:
            typeDescription = "Pago de servicio"
        case .goal:
            typeDescription = transaction.isPositive ? "Retiro de meta" : "Ahorro a meta"
        case .cardPurchase:
            typeDescription = "Compra con tarjeta"
        case .salary:
            typeDescription = "Depósito de nómina"
        case .electricity:
            typeDescription = "Pago de servicio luz"
        }
        tipoRow.setValue(typeDescription)
        
        // Reference number (mock)
        let referenceNumber = String(format: "%015d", Int.random(in: 100000...999999999))
        referenciaRow.setValue(referenceNumber)
        
        // Check if this is electricity type (CNEL) - special compact expanded view
        isElectricityType = transaction.type == .electricity
        
        if isElectricityType {
            // Show extra info in collapsed state
            subtitle2Label.isHidden = false
            subtitle3Label.isHidden = false
            extraBalance1Label.isHidden = false
            extraBalance2Label.isHidden = false
            
            // Set extra info - service breakdown
            subtitleLabel.text = "Servicio de luz"
            subtitle2Label.text = "Comisión interbancaria"
            subtitle3Label.text = "15% iva"
            
            // Format amounts
            let serviceAmt = transaction.serviceAmount ?? 120.00
            let commissionAmt = transaction.commission ?? 0.18
            let taxAmt = transaction.tax ?? 0.03
            
            balanceLabel.text = String(format: "-$%.2f", serviceAmt)
            extraBalance1Label.text = String(format: "-$%.2f", commissionAmt)
            extraBalance2Label.text = String(format: "-$%.2f", taxAmt)
            
            // Adjust height for electricity type
            collapsedHeight = 103
            heightConstraint?.constant = collapsedHeight
        } else {
            // Hide extra labels for non-electricity transactions
            subtitle2Label.isHidden = true
            subtitle3Label.isHidden = true
            extraBalance1Label.isHidden = true
            extraBalance2Label.isHidden = true
            
            // Reset to normal height (64px per CSS specs)
            collapsedHeight = 64
            if !isExpanded {
                heightConstraint?.constant = collapsedHeight
            }
        }
        
        // Check if this is a cardless withdrawal (Retiro sin tarjeta)
        isWithdrawalPending = transaction.type == .withdrawal && transaction.status == .toWithdraw
        
        if isWithdrawalPending {
            // Hide standard rows (only tipo and referencia)
            tipoRow.isHidden = true
            referenciaRow.isHidden = true
            reportButton.isHidden = true
            compartirButton.isHidden = true
            
            // Show withdrawal-specific rows including fecha
            fechaRow.isHidden = false
            enviadoARow.isHidden = false
            celularRow.isHidden = false
            tiempoRestanteRow.isHidden = false
            progressBarContainer.isHidden = false
            footerMessageLabel.isHidden = false
            
            // Configure withdrawal data
            enviadoARow.setValue(transaction.recipientName ?? "Destinatario")
            celularRow.setValue(transaction.recipientPhone ?? "099 999 9999")
            tiempoRestanteRow.setValue(transaction.timeRemaining ?? "35 min")
            
            // Update progress (mock: 70% remaining)
            let progress = transaction.progressRemaining ?? 0.7
            progressWidthConstraint?.isActive = false
            progressWidthConstraint = progressBarFill.widthAnchor.constraint(equalTo: progressBarContainer.widthAnchor, multiplier: progress)
            progressWidthConstraint?.isActive = true
        } else {
            // Show standard rows
            fechaRow.isHidden = false
            tipoRow.isHidden = false
            referenciaRow.isHidden = false
            reportButton.isHidden = false
            compartirButton.isHidden = false
            
            // Hide withdrawal-specific rows
            enviadoARow.isHidden = true
            celularRow.isHidden = true
            tiempoRestanteRow.isHidden = true
            progressBarContainer.isHidden = true
            footerMessageLabel.isHidden = true
        }
    }
}

// MARK: - Transaction Detail Row
final class TransactionDetailRow: UIView {
    
    private let labelView: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .manrope(size: 12, weight: .regular)
        label.textColor = UIColor(red: 0.541, green: 0.576, blue: 0.659, alpha: 1) // #8A93A8
        return label
    }()
    
    private let valueLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .manrope(size: 12, weight: .medium)
        label.textColor = UIColor(red: 0.318, green: 0.353, blue: 0.451, alpha: 1) // #515A73
        label.textAlignment = .right
        return label
    }()
    
    init(label: String) {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        labelView.text = label
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        addSubview(labelView)
        addSubview(valueLabel)
        
        NSLayoutConstraint.activate([
            heightAnchor.constraint(equalToConstant: 16),
            
            labelView.leadingAnchor.constraint(equalTo: leadingAnchor),
            labelView.centerYAnchor.constraint(equalTo: centerYAnchor),
            
            valueLabel.trailingAnchor.constraint(equalTo: trailingAnchor),
            valueLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            valueLabel.leadingAnchor.constraint(greaterThanOrEqualTo: labelView.trailingAnchor, constant: 16)
        ])
    }
    
    func setValue(_ value: String) {
        valueLabel.text = value
    }
}
