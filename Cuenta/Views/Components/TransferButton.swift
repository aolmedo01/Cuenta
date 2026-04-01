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
        
        // Dark navy background
        backgroundColor = UIColor(red: 0.106, green: 0.106, blue: 0.227, alpha: 1.0) // #1B1B3A
        layer.cornerRadius = 25
        
        // Icon - up/down arrows
        let iconImage = UIImage(systemName: "arrow.up.arrow.down")?
            .withConfiguration(UIImage.SymbolConfiguration(pointSize: 15, weight: .semibold))
            .withRenderingMode(.alwaysTemplate)
        setImage(iconImage, for: .normal)
        tintColor = .white
        
        // Title
        setTitle("Transferir", for: .normal)
        setTitleColor(.white, for: .normal)
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
