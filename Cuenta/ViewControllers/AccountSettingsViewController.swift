import UIKit

final class AccountSettingsViewController: UIViewController {
    
    // MARK: - Data
    private var accountName: String = "AHO"
    private var accountNumber: String = "12788373662"
    
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
        stack.spacing = 0
        stack.alignment = .fill
        return stack
    }()
    
    // Toolbar
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
    
    private let titleStackView: UIStackView = {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.spacing = 2
        stack.alignment = .center
        return stack
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Configurar cuenta"
        label.font = UIFont.systemFont(ofSize: 17, weight: .semibold)
        label.textColor = .textPrimary
        label.textAlignment = .center
        return label
    }()
    
    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .manrope(size: 12, weight: .regular)
        label.textColor = UIColor(red: 0.318, green: 0.353, blue: 0.451, alpha: 1)
        label.textAlignment = .center
        return label
    }()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    // MARK: - Setup UI
    private func setupUI() {
        view.backgroundColor = UIColor(red: 0.961, green: 0.965, blue: 0.973, alpha: 1)
        
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        contentView.addSubview(mainStackView)
        
        setupToolbar()
        setupProfileSection()
        setupAccountNameSection()
        setupAccessSection()
        
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
    
    private func setupToolbar() {
        mainStackView.addArrangedSubview(toolbarView)
        toolbarView.addSubview(backButton)
        
        titleStackView.addArrangedSubview(titleLabel)
        titleStackView.addArrangedSubview(subtitleLabel)
        toolbarView.addSubview(titleStackView)
        
        subtitleLabel.text = "AHO \(accountNumber)"
        
        NSLayoutConstraint.activate([
            toolbarView.heightAnchor.constraint(equalToConstant: 54),
            
            backButton.leadingAnchor.constraint(equalTo: toolbarView.leadingAnchor, constant: 16),
            backButton.centerYAnchor.constraint(equalTo: toolbarView.centerYAnchor),
            
            titleStackView.centerXAnchor.constraint(equalTo: toolbarView.centerXAnchor),
            titleStackView.centerYAnchor.constraint(equalTo: toolbarView.centerYAnchor)
        ])
    }
    
    private func setupProfileSection() {
        let profileContainer = UIView()
        profileContainer.translatesAutoresizingMaskIntoConstraints = false
        
        let circleView = UIView()
        circleView.translatesAutoresizingMaskIntoConstraints = false
        circleView.backgroundColor = UIColor(red: 0.85, green: 0.0, blue: 0.56, alpha: 1)
        circleView.layer.cornerRadius = 70
        circleView.clipsToBounds = true
        
        let chanchitoImageView = UIImageView()
        chanchitoImageView.translatesAutoresizingMaskIntoConstraints = false
        chanchitoImageView.image = UIImage(named: "ChanchitoFeliz")
        chanchitoImageView.contentMode = .scaleAspectFit
        
        circleView.addSubview(chanchitoImageView)
        profileContainer.addSubview(circleView)
        
        let editButton = UIButton(type: .system)
        editButton.translatesAutoresizingMaskIntoConstraints = false
        editButton.setTitle("Editar", for: .normal)
        editButton.setTitleColor(.textPrimary, for: .normal)
        editButton.titleLabel?.font = .manrope(size: 15, weight: .medium)
        editButton.addTarget(self, action: #selector(editProfileTapped), for: .touchUpInside)
        
        profileContainer.addSubview(editButton)
        
        NSLayoutConstraint.activate([
            profileContainer.heightAnchor.constraint(equalToConstant: 200),
            
            circleView.centerXAnchor.constraint(equalTo: profileContainer.centerXAnchor),
            circleView.topAnchor.constraint(equalTo: profileContainer.topAnchor, constant: 20),
            circleView.widthAnchor.constraint(equalToConstant: 140),
            circleView.heightAnchor.constraint(equalToConstant: 140),
            
            chanchitoImageView.centerXAnchor.constraint(equalTo: circleView.centerXAnchor),
            chanchitoImageView.centerYAnchor.constraint(equalTo: circleView.centerYAnchor),
            chanchitoImageView.widthAnchor.constraint(equalToConstant: 80),
            chanchitoImageView.heightAnchor.constraint(equalToConstant: 80),
            
            editButton.centerXAnchor.constraint(equalTo: profileContainer.centerXAnchor),
            editButton.topAnchor.constraint(equalTo: circleView.bottomAnchor, constant: 12)
        ])
        
        mainStackView.addArrangedSubview(profileContainer)
    }
    
    private func setupAccountNameSection() {
        let headerView = createSectionHeader(title: "Nombre de la cuenta")
        mainStackView.addArrangedSubview(headerView)
        
        let containerStack = UIStackView()
        containerStack.translatesAutoresizingMaskIntoConstraints = false
        containerStack.axis = .vertical
        containerStack.spacing = 8
        containerStack.layoutMargins = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        containerStack.isLayoutMarginsRelativeArrangement = true
        
        let nameRow = createAccountNameRow()
        containerStack.addArrangedSubview(nameRow)
        
        mainStackView.addArrangedSubview(containerStack)
        
        let descriptionLabel = UILabel()
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        descriptionLabel.text = "En pagos y transferencias, se mostrará el nombre de tu cuenta en lugar del número, para que puedas identificarla fácilmente."
        descriptionLabel.font = .manrope(size: 12, weight: .regular)
        descriptionLabel.textColor = UIColor(red: 0.318, green: 0.353, blue: 0.451, alpha: 1)
        descriptionLabel.numberOfLines = 0
        
        let descContainer = UIView()
        descContainer.translatesAutoresizingMaskIntoConstraints = false
        descContainer.addSubview(descriptionLabel)
        
        NSLayoutConstraint.activate([
            descriptionLabel.topAnchor.constraint(equalTo: descContainer.topAnchor, constant: 8),
            descriptionLabel.leadingAnchor.constraint(equalTo: descContainer.leadingAnchor, constant: 16),
            descriptionLabel.trailingAnchor.constraint(equalTo: descContainer.trailingAnchor, constant: -16),
            descriptionLabel.bottomAnchor.constraint(equalTo: descContainer.bottomAnchor, constant: -8)
        ])
        
        mainStackView.addArrangedSubview(descContainer)
    }
    
    private func setupAccessSection() {
        let headerView = createSectionHeader(title: "Dar acceso a mi cuenta")
        mainStackView.addArrangedSubview(headerView)
        
        let containerStack = UIStackView()
        containerStack.translatesAutoresizingMaskIntoConstraints = false
        containerStack.axis = .vertical
        containerStack.spacing = 8
        containerStack.layoutMargins = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        containerStack.isLayoutMarginsRelativeArrangement = true
        
        let inviteRow = createInviteRow()
        containerStack.addArrangedSubview(inviteRow)
        
        mainStackView.addArrangedSubview(containerStack)
        
        let descriptionView = createDescriptionText(
            text: "Invita a alguien de confianza para ayudarte con tu cuenta. Actuará como ",
            linkText: "Firma autorizada"
        )
        mainStackView.addArrangedSubview(descriptionView)
    }
    
    // MARK: - Factory Methods
    private func createSectionHeader(title: String) -> UIView {
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false
        
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = title
        label.font = .manrope(size: 15, weight: .semibold)
        label.textColor = .accentBlue
        
        container.addSubview(label)
        
        NSLayoutConstraint.activate([
            container.heightAnchor.constraint(equalToConstant: 44),
            label.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 16),
            label.centerYAnchor.constraint(equalTo: container.centerYAnchor)
        ])
        
        return container
    }
    
    private func createInviteRow() -> UIView {
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false
        container.backgroundColor = UIColor(red: 0.988, green: 0.988, blue: 0.992, alpha: 1)
        container.layer.cornerRadius = 24
        
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Agregar a una persona"
        label.font = UIFont.systemFont(ofSize: 17, weight: .regular)
        label.textColor = .black
        
        let chevron = UIImageView()
        chevron.translatesAutoresizingMaskIntoConstraints = false
        chevron.image = UIImage(systemName: "chevron.right")?
            .withConfiguration(UIImage.SymbolConfiguration(pointSize: 14, weight: .semibold))
        chevron.tintColor = UIColor(red: 0.129, green: 0.157, blue: 0.227, alpha: 1)
        
        container.addSubview(label)
        container.addSubview(chevron)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(inviteRowTapped))
        container.addGestureRecognizer(tap)
        container.isUserInteractionEnabled = true
        
        NSLayoutConstraint.activate([
            container.heightAnchor.constraint(equalToConstant: 52),
            label.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 16),
            label.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            chevron.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -16),
            chevron.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            chevron.widthAnchor.constraint(equalToConstant: 16),
            chevron.heightAnchor.constraint(equalToConstant: 16)
        ])
        
        return container
    }
    
    private func createDescriptionText(text: String, linkText: String) -> UIView {
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false
        
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        
        let fullText = text + linkText + "."
        let attributedString = NSMutableAttributedString(string: fullText)
        
        attributedString.addAttributes([
            .font: UIFont.manrope(size: 12, weight: .regular),
            .foregroundColor: UIColor(red: 0.318, green: 0.353, blue: 0.451, alpha: 1)
        ], range: NSRange(location: 0, length: fullText.count))
        
        if let linkRange = fullText.range(of: linkText) {
            let nsRange = NSRange(linkRange, in: fullText)
            attributedString.addAttributes([
                .foregroundColor: UIColor.accentBlue,
                .underlineStyle: NSUnderlineStyle.single.rawValue
            ], range: nsRange)
        }
        
        label.attributedText = attributedString
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(firmAutorizadaTapped))
        label.isUserInteractionEnabled = true
        label.addGestureRecognizer(tap)
        
        container.addSubview(label)
        
        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: container.topAnchor, constant: 8),
            label.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 16),
            label.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -16),
            label.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -16)
        ])
        
        return container
    }
    
    private func createAccountNameRow() -> UIView {
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false
        container.backgroundColor = UIColor(red: 0.988, green: 0.988, blue: 0.992, alpha: 1)
        container.layer.cornerRadius = 24
        
        let nameLabel = UILabel()
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.text = accountName
        nameLabel.font = UIFont.systemFont(ofSize: 17, weight: .regular)
        nameLabel.textColor = .black
        
        container.addSubview(nameLabel)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(accountNameRowTapped))
        container.addGestureRecognizer(tap)
        container.isUserInteractionEnabled = true
        
        NSLayoutConstraint.activate([
            container.heightAnchor.constraint(equalToConstant: 52),
            nameLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 16),
            nameLabel.centerYAnchor.constraint(equalTo: container.centerYAnchor)
        ])
        
        return container
    }
    
    // MARK: - Actions
    @objc private func backTapped() {
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
        navigationController?.popViewController(animated: true)
    }
    
    @objc private func editProfileTapped() {
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
        print("Edit profile tapped")
    }
    
    @objc private func inviteRowTapped() {
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
        print("Invite person tapped")
    }
    
    @objc private func firmAutorizadaTapped() {
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
        print("Firma autorizada link tapped")
    }
    
    @objc private func accountNameRowTapped() {
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
        print("Account name row tapped")
    }
}
