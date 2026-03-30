import UIKit

final class SharePDFViewController: UIViewController {
    
    // MARK: - Properties
    var dateRange: String = "Febrero 2026 - Marzo 2026"
    var userEmail: String = "dan_rdgz@hotmail.com"
    var onSendEmail: ((String) -> Void)?
    var onUpdateData: (() -> Void)?
    var onDismissWithoutAction: (() -> Void)?
    
    // MARK: - UI Components
    private let containerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .white
        view.layer.cornerRadius = 32
        view.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        return view
    }()
    
    private let handleView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor(red: 0.85, green: 0.85, blue: 0.85, alpha: 1)
        view.layer.cornerRadius = 2.5
        return view
    }()
    
    private lazy var closeButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = UIColor(red: 0.93, green: 0.93, blue: 0.93, alpha: 1)
        button.layer.cornerRadius = 20
        button.setImage(UIImage(systemName: "xmark")?
            .withConfiguration(UIImage.SymbolConfiguration(pointSize: 14, weight: .semibold)), for: .normal)
        button.tintColor = UIColor(red: 0.4, green: 0.4, blue: 0.4, alpha: 1)
        button.addTarget(self, action: #selector(closeTapped), for: .touchUpInside)
        return button
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Estados de cuenta"
        label.font = .manrope(size: 18, weight: .semibold)
        label.textColor = .textPrimary
        label.textAlignment = .center
        return label
    }()
    
    private let dateRangeLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .manrope(size: 14, weight: .regular)
        label.textColor = .textSecondary
        label.textAlignment = .center
        return label
    }()
    
    private let emailContainer: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor(red: 0.965, green: 0.969, blue: 0.976, alpha: 1)
        view.layer.cornerRadius = 16
        return view
    }()
    
    private let emailTitleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Correo electrónico de destino"
        label.font = .manrope(size: 14, weight: .medium)
        label.textColor = .textPrimary
        return label
    }()
    
    private let emailLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .manrope(size: 15, weight: .regular)
        label.textColor = .textSecondary
        return label
    }()
    
    private let disclaimerLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "*El PDF llegará a tu correo, si el correo no es correcto, actualiza tus datos."
        label.font = .manrope(size: 13, weight: .regular)
        label.textColor = .textSecondary
        label.numberOfLines = 0
        return label
    }()
    
    private lazy var sendButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = UIColor(red: 0.086, green: 0.059, blue: 0.255, alpha: 1) // #160F41
        button.layer.cornerRadius = 28
        button.setTitle("Enviar por correo", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = .manrope(size: 17, weight: .semibold)
        button.addTarget(self, action: #selector(sendTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var updateDataButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Actualizar datos", for: .normal)
        button.setTitleColor(UIColor(red: 0.086, green: 0.059, blue: 0.255, alpha: 1), for: .normal)
        button.titleLabel?.font = .manrope(size: 15, weight: .medium)
        
        // Underline
        let attributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.manrope(size: 15, weight: .medium),
            .foregroundColor: UIColor(red: 0.086, green: 0.059, blue: 0.255, alpha: 1),
            .underlineStyle: NSUnderlineStyle.single.rawValue
        ]
        button.setAttributedTitle(NSAttributedString(string: "Actualizar datos", attributes: attributes), for: .normal)
        button.addTarget(self, action: #selector(updateDataTapped), for: .touchUpInside)
        return button
    }()
    
    private let dimmingView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor.black.withAlphaComponent(0.4)
        view.alpha = 0
        return view
    }()
    
    private var containerBottomConstraint: NSLayoutConstraint?
    private let containerHeight: CGFloat = 380
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        updateContent()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        animateIn()
    }
    
    // MARK: - Setup
    private func setupUI() {
        view.backgroundColor = .clear
        
        view.addSubview(dimmingView)
        view.addSubview(containerView)
        
        containerView.addSubview(handleView)
        containerView.addSubview(closeButton)
        containerView.addSubview(titleLabel)
        containerView.addSubview(dateRangeLabel)
        containerView.addSubview(emailContainer)
        emailContainer.addSubview(emailTitleLabel)
        emailContainer.addSubview(emailLabel)
        containerView.addSubview(disclaimerLabel)
        containerView.addSubview(sendButton)
        containerView.addSubview(updateDataButton)
        
        containerBottomConstraint = containerView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: containerHeight)
        
        NSLayoutConstraint.activate([
            dimmingView.topAnchor.constraint(equalTo: view.topAnchor),
            dimmingView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            dimmingView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            dimmingView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            containerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            containerBottomConstraint!,
            containerView.heightAnchor.constraint(equalToConstant: containerHeight),
            
            handleView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 12),
            handleView.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            handleView.widthAnchor.constraint(equalToConstant: 40),
            handleView.heightAnchor.constraint(equalToConstant: 5),
            
            closeButton.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 20),
            closeButton.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 20),
            closeButton.widthAnchor.constraint(equalToConstant: 40),
            closeButton.heightAnchor.constraint(equalToConstant: 40),
            
            titleLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 28),
            titleLabel.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            
            dateRangeLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            dateRangeLabel.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            
            emailContainer.topAnchor.constraint(equalTo: dateRangeLabel.bottomAnchor, constant: 24),
            emailContainer.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 20),
            emailContainer.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -20),
            emailContainer.heightAnchor.constraint(equalToConstant: 72),
            
            emailTitleLabel.topAnchor.constraint(equalTo: emailContainer.topAnchor, constant: 14),
            emailTitleLabel.leadingAnchor.constraint(equalTo: emailContainer.leadingAnchor, constant: 16),
            emailTitleLabel.trailingAnchor.constraint(equalTo: emailContainer.trailingAnchor, constant: -16),
            
            emailLabel.topAnchor.constraint(equalTo: emailTitleLabel.bottomAnchor, constant: 4),
            emailLabel.leadingAnchor.constraint(equalTo: emailContainer.leadingAnchor, constant: 16),
            emailLabel.trailingAnchor.constraint(equalTo: emailContainer.trailingAnchor, constant: -16),
            
            disclaimerLabel.topAnchor.constraint(equalTo: emailContainer.bottomAnchor, constant: 20),
            disclaimerLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 20),
            disclaimerLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -20),
            
            sendButton.topAnchor.constraint(equalTo: disclaimerLabel.bottomAnchor, constant: 20),
            sendButton.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 20),
            sendButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -20),
            sendButton.heightAnchor.constraint(equalToConstant: 56),
            
            updateDataButton.topAnchor.constraint(equalTo: sendButton.bottomAnchor, constant: 12),
            updateDataButton.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            updateDataButton.heightAnchor.constraint(equalToConstant: 32)
        ])
        
        // Add tap gesture to dimming view
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(closeTapped))
        dimmingView.addGestureRecognizer(tapGesture)
        
        // Add pan gesture for drag to dismiss
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
        containerView.addGestureRecognizer(panGesture)
    }
    
    private func updateContent() {
        dateRangeLabel.text = dateRange
        emailLabel.text = userEmail
    }
    
    // MARK: - Animations
    private func animateIn() {
        containerBottomConstraint?.constant = 0
        
        UIView.animate(withDuration: 0.35, delay: 0, usingSpringWithDamping: 0.85, initialSpringVelocity: 0.5) {
            self.view.layoutIfNeeded()
            self.dimmingView.alpha = 1
        }
    }
    
    private func animateOut(completion: (() -> Void)? = nil) {
        containerBottomConstraint?.constant = containerHeight
        
        UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseIn) {
            self.view.layoutIfNeeded()
            self.dimmingView.alpha = 0
        } completion: { _ in
            self.dismiss(animated: false, completion: completion)
        }
    }
    
    // MARK: - Actions
    @objc private func closeTapped() {
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
        animateOut { [weak self] in
            self?.onDismissWithoutAction?()
        }
    }
    
    @objc private func sendTapped() {
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
        
        animateOut { [weak self] in
            guard let self = self else { return }
            self.onSendEmail?(self.userEmail)
        }
    }
    
    @objc private func updateDataTapped() {
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
        
        animateOut { [weak self] in
            self?.onUpdateData?()
        }
    }
    
    @objc private func handlePan(_ gesture: UIPanGestureRecognizer) {
        let translation = gesture.translation(in: view)
        let velocity = gesture.velocity(in: view)
        
        switch gesture.state {
        case .changed:
            // Only allow dragging down
            if translation.y > 0 {
                containerBottomConstraint?.constant = translation.y
                let progress = min(translation.y / containerHeight, 1.0)
                dimmingView.alpha = 1 - progress
            }
        case .ended:
            // Dismiss if dragged past threshold or velocity is high enough
            if translation.y > containerHeight * 0.3 || velocity.y > 500 {
                animateOut { [weak self] in
                    self?.onDismissWithoutAction?()
                }
            } else {
                // Snap back
                containerBottomConstraint?.constant = 0
                UIView.animate(withDuration: 0.25, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.5) {
                    self.view.layoutIfNeeded()
                    self.dimmingView.alpha = 1
                }
            }
        default:
            break
        }
    }
}
