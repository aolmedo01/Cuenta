import UIKit

final class TransferButton: UIButton {
    
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
        
        backgroundColor = .buttonBackground
        layer.cornerRadius = 25
        
        // Icon
        let iconImage = UIImage(systemName: "arrow.left.arrow.right")?
            .withConfiguration(UIImage.SymbolConfiguration(pointSize: 15, weight: .semibold))
            .withRenderingMode(.alwaysTemplate)
        setImage(iconImage, for: .normal)
        tintColor = .textNavy
        
        // Title
        setTitle("Transferir", for: .normal)
        setTitleColor(.textDark, for: .normal)
        titleLabel?.font = .buttonLabel
        
        // Layout
        semanticContentAttribute = .forceLeftToRight
        imageEdgeInsets = UIEdgeInsets(top: 0, left: -4, bottom: 0, right: 4)
        contentEdgeInsets = UIEdgeInsets(top: 13, left: 20, bottom: 13, right: 20)
        
        NSLayoutConstraint.activate([
            heightAnchor.constraint(equalToConstant: 48)
        ])
    }
}
