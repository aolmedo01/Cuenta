import UIKit

final class CircleIconButton: UIButton {
    
    // MARK: - Properties
    private let iconSize: CGFloat = 20
    
    // MARK: - Initialization
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    convenience init(systemName: String, size: CGFloat = 44) {
        self.init(frame: .zero)
        setImage(UIImage(systemName: systemName)?
            .withConfiguration(UIImage.SymbolConfiguration(pointSize: 17, weight: .medium))
            .withRenderingMode(.alwaysTemplate), for: .normal)
        
        NSLayoutConstraint.activate([
            widthAnchor.constraint(equalToConstant: size),
            heightAnchor.constraint(equalToConstant: size)
        ])
    }
    
    // MARK: - Setup
    private func setupView() {
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = .iconButtonBackground
        tintColor = UIColor(red: 0.251, green: 0.251, blue: 0.251, alpha: 1) // #404040
        layer.cornerRadius = 22
        clipsToBounds = true
        
        // Shadow
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.04
        layer.shadowOffset = CGSize(width: 0, height: 2)
        layer.shadowRadius = 10
        layer.masksToBounds = false
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        layer.cornerRadius = bounds.height / 2
    }
}
