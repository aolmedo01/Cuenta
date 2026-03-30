import UIKit

final class SearchBarView: UIView {
    
    // MARK: - UI Components
    private let containerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .white
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
        return textField
    }()
    
    let filterButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage(systemName: "line.3.horizontal.decrease")?
            .withConfiguration(UIImage.SymbolConfiguration(pointSize: 18, weight: .medium)), for: .normal)
        button.tintColor = .accentBlue
        button.backgroundColor = .white
        button.layer.cornerRadius = 24
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
        
        addSubview(containerView)
        containerView.addSubview(searchIcon)
        containerView.addSubview(textField)
        addSubview(filterButton)
        
        NSLayoutConstraint.activate([
            // Container
            containerView.leadingAnchor.constraint(equalTo: leadingAnchor),
            containerView.topAnchor.constraint(equalTo: topAnchor),
            containerView.bottomAnchor.constraint(equalTo: bottomAnchor),
            containerView.trailingAnchor.constraint(equalTo: filterButton.leadingAnchor, constant: -8),
            containerView.heightAnchor.constraint(equalToConstant: 48),
            
            // Search Icon
            searchIcon.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            searchIcon.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            searchIcon.widthAnchor.constraint(equalToConstant: 24),
            searchIcon.heightAnchor.constraint(equalToConstant: 24),
            
            // Text Field
            textField.leadingAnchor.constraint(equalTo: searchIcon.trailingAnchor, constant: 12),
            textField.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            textField.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            
            // Filter Button
            filterButton.trailingAnchor.constraint(equalTo: trailingAnchor),
            filterButton.centerYAnchor.constraint(equalTo: centerYAnchor),
            filterButton.widthAnchor.constraint(equalToConstant: 48),
            filterButton.heightAnchor.constraint(equalToConstant: 48)
        ])
    }
}
