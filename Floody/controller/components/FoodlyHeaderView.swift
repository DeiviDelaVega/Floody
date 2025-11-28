import UIKit

class FoodlyHeaderView: UIView {

    private let logoImageView = UIImageView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }

    private func setupUI() {
        // Fondo verde
        backgroundColor = UIColor(red: 167/255, green: 214/255, blue: 90/255, alpha: 1)

        // Logo
        logoImageView.image = UIImage(named: "logoFoodly")
        logoImageView.contentMode = .scaleAspectFit
        logoImageView.translatesAutoresizingMaskIntoConstraints = false

        addSubview(logoImageView)

        NSLayoutConstraint.activate([
            logoImageView.centerXAnchor.constraint(equalTo: centerXAnchor),
            logoImageView.centerYAnchor.constraint(equalTo: safeAreaLayoutGuide.centerYAnchor),
            logoImageView.widthAnchor.constraint(equalToConstant: 140),
            logoImageView.heightAnchor.constraint(equalToConstant: 40)
        ])
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        layer.cornerRadius = 30
        layer.maskedCorners = [
            .layerMinXMaxYCorner,
            .layerMaxXMaxYCorner
        ]
        layer.masksToBounds = true
    }
}

