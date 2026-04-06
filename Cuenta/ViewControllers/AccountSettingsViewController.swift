import UIKit

final class AccountSettingsViewController: UIViewController {
    private enum Layout {
        static let horizontalInset: CGFloat = 24
    }
    
    private enum Palette {
        static let title = UIColor(red: 0.18, green: 0.19, blue: 0.23, alpha: 1)
        static let subtitle = UIColor(red: 0.55, green: 0.55, blue: 0.57, alpha: 1)
        static let sectionTitle = UIColor(red: 0.31, green: 0.36, blue: 0.49, alpha: 1)
        static let bodyText = UIColor(red: 0.35, green: 0.40, blue: 0.51, alpha: 1)
        static let rowText = UIColor(red: 0.17, green: 0.21, blue: 0.30, alpha: 1)
    }
    
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
        view.backgroundColor = .clear
        return view
    }()
    
    private lazy var backButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage(systemName: "chevron.left"), for: .normal)
        button.tintColor = UIColor(red: 0.251, green: 0.251, blue: 0.251, alpha: 1)
        button.backgroundColor = UIColor(white: 0.95, alpha: 1)
        button.layer.cornerRadius = 22
        button.layer.masksToBounds = true
        button.addTarget(self, action: #selector(backTapped), for: .touchUpInside)
        return button
    }()
    
    private let titleStackView: UIStackView = {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.spacing = 0
        stack.alignment = .center
        return stack
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Configurar cuenta"
        label.font = .manrope(size: 15, weight: .semibold)
        label.textColor = Palette.title
        label.textAlignment = .center
        label.setContentHuggingPriority(.required, for: .vertical)
        return label
    }()

    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .manrope(size: 12, weight: .medium)
        label.textColor = Palette.subtitle
        label.textAlignment = .center
        label.setContentHuggingPriority(.required, for: .vertical)
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
        toolbarView.addSubview(titleStackView)

        titleStackView.addArrangedSubview(titleLabel)
        titleStackView.addArrangedSubview(subtitleLabel)

        subtitleLabel.text = "AHO \(accountNumber)"

        NSLayoutConstraint.activate([
            toolbarView.heightAnchor.constraint(equalToConstant: 72),
            toolbarView.leadingAnchor.constraint(equalTo: mainStackView.leadingAnchor),
            toolbarView.trailingAnchor.constraint(equalTo: mainStackView.trailingAnchor),

            backButton.leadingAnchor.constraint(equalTo: toolbarView.leadingAnchor, constant: Layout.horizontalInset),
            backButton.centerYAnchor.constraint(equalTo: toolbarView.centerYAnchor),
            backButton.widthAnchor.constraint(equalToConstant: 44),
            backButton.heightAnchor.constraint(equalToConstant: 44),

            titleStackView.centerXAnchor.constraint(equalTo: toolbarView.centerXAnchor),
            titleStackView.centerYAnchor.constraint(equalTo: toolbarView.centerYAnchor),
            titleStackView.widthAnchor.constraint(lessThanOrEqualToConstant: 250),
        ])
        
        mainStackView.setCustomSpacing(24, after: toolbarView)
    }
    
    private func setupProfileSection() {
        let profileContainer = UIView()
        profileContainer.translatesAutoresizingMaskIntoConstraints = false
        
        let circleView = UIView()
        circleView.translatesAutoresizingMaskIntoConstraints = false
        circleView.backgroundColor = UIColor(red: 0.85, green: 0.0, blue: 0.56, alpha: 1)
        circleView.layer.cornerRadius = 112
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
        editButton.setTitleColor(Palette.rowText, for: .normal)
        editButton.titleLabel?.font = .manrope(size: 15, weight: .medium)
        editButton.addTarget(self, action: #selector(editProfileTapped), for: .touchUpInside)
        
        profileContainer.addSubview(editButton)
        
        NSLayoutConstraint.activate([
            profileContainer.heightAnchor.constraint(equalToConstant: 250),
            
            circleView.centerXAnchor.constraint(equalTo: profileContainer.centerXAnchor),
            circleView.topAnchor.constraint(equalTo: profileContainer.topAnchor, constant: 8),
            circleView.widthAnchor.constraint(equalToConstant: 224),
            circleView.heightAnchor.constraint(equalToConstant: 224),
            
            chanchitoImageView.centerXAnchor.constraint(equalTo: circleView.centerXAnchor),
            chanchitoImageView.centerYAnchor.constraint(equalTo: circleView.centerYAnchor),
            chanchitoImageView.widthAnchor.constraint(equalToConstant: 118),
            chanchitoImageView.heightAnchor.constraint(equalToConstant: 118),
            
            editButton.centerXAnchor.constraint(equalTo: profileContainer.centerXAnchor),
            editButton.topAnchor.constraint(equalTo: circleView.bottomAnchor, constant: 12)
        ])
        
        mainStackView.addArrangedSubview(profileContainer)
        mainStackView.setCustomSpacing(12, after: profileContainer)
    }
    
    private func setupAccountNameSection() {
        let headerView = createSectionHeader(title: "Nombre de la cuenta")
        mainStackView.addArrangedSubview(headerView)
        
        let containerStack = UIStackView()
        containerStack.translatesAutoresizingMaskIntoConstraints = false
        containerStack.axis = .vertical
        containerStack.spacing = 8
        containerStack.layoutMargins = UIEdgeInsets(top: 0, left: Layout.horizontalInset, bottom: 0, right: Layout.horizontalInset)
        containerStack.isLayoutMarginsRelativeArrangement = true
        
        let nameRow = createAccountNameRow()
        containerStack.addArrangedSubview(nameRow)
        
        mainStackView.addArrangedSubview(containerStack)
        
        let descriptionLabel = UILabel()
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        descriptionLabel.text = "En pagos y transferencias, se mostrará el nombre de tu cuenta en lugar del número, para que puedas identificarla fácilmente."
        descriptionLabel.font = .manrope(size: 12, weight: .regular)
        descriptionLabel.textColor = Palette.bodyText
        descriptionLabel.numberOfLines = 0
        
        let descContainer = UIView()
        descContainer.translatesAutoresizingMaskIntoConstraints = false
        descContainer.addSubview(descriptionLabel)
        
        NSLayoutConstraint.activate([
            descriptionLabel.topAnchor.constraint(equalTo: descContainer.topAnchor, constant: 10),
            descriptionLabel.leadingAnchor.constraint(equalTo: descContainer.leadingAnchor, constant: Layout.horizontalInset),
            descriptionLabel.trailingAnchor.constraint(equalTo: descContainer.trailingAnchor, constant: -Layout.horizontalInset),
            descriptionLabel.bottomAnchor.constraint(equalTo: descContainer.bottomAnchor, constant: -12)
        ])
        
        mainStackView.addArrangedSubview(descContainer)
        mainStackView.setCustomSpacing(26, after: descContainer)
    }
    
    private func setupAccessSection() {
        let headerView = createSectionHeader(title: "Dar acceso a mi cuenta")
        mainStackView.addArrangedSubview(headerView)
        
        let containerStack = UIStackView()
        containerStack.translatesAutoresizingMaskIntoConstraints = false
        containerStack.axis = .vertical
        containerStack.spacing = 8
        containerStack.layoutMargins = UIEdgeInsets(top: 0, left: Layout.horizontalInset, bottom: 0, right: Layout.horizontalInset)
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
        label.textColor = Palette.sectionTitle
        
        container.addSubview(label)
        
        NSLayoutConstraint.activate([
            container.heightAnchor.constraint(equalToConstant: 44),
            label.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: Layout.horizontalInset),
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
        label.font = .manrope(size: 17, weight: .regular)
        label.textColor = Palette.rowText
        
        let chevron = UIImageView()
        chevron.translatesAutoresizingMaskIntoConstraints = false
        chevron.image = UIImage(systemName: "chevron.right")?
            .withConfiguration(UIImage.SymbolConfiguration(pointSize: 14, weight: .semibold))
        chevron.tintColor = Palette.rowText
        
        container.addSubview(label)
        container.addSubview(chevron)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(inviteRowTapped))
        container.addGestureRecognizer(tap)
        container.isUserInteractionEnabled = true
        
        NSLayoutConstraint.activate([
            container.heightAnchor.constraint(equalToConstant: 52),
            label.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 20),
            label.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            chevron.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -20),
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
            .foregroundColor: Palette.bodyText
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
            label.topAnchor.constraint(equalTo: container.topAnchor, constant: 10),
            label.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: Layout.horizontalInset),
            label.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -Layout.horizontalInset),
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
        nameLabel.font = .manrope(size: 17, weight: .regular)
        nameLabel.textColor = Palette.rowText
        
        container.addSubview(nameLabel)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(accountNameRowTapped))
        container.addGestureRecognizer(tap)
        container.isUserInteractionEnabled = true
        
        NSLayoutConstraint.activate([
            container.heightAnchor.constraint(equalToConstant: 52),
            nameLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 20),
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
