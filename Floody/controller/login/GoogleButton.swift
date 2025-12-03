import UIKit

class GoogleButton: UIButton{
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder:NSCoder)
    {
        super.init(coder: coder)
        setup()
    }
    
    private func setup() {
        var config = UIButton.Configuration.plain()
               config.title = "Continuar con Google"

               config.baseForegroundColor = .blue
               config.background.backgroundColor = .white

               config.image = UIImage(systemName: "g.circle.fill")
               config.imagePadding = 10
               config.imagePlacement = .leading

               config.cornerStyle = .capsule

               config.contentInsets = NSDirectionalEdgeInsets(top: 12, leading: 20, bottom: 12, trailing: 20)

               self.configuration = config

               // Sombra suave tipo Material
               layer.shadowColor = UIColor.black.cgColor
               layer.shadowOpacity = 0.12
               layer.shadowOffset = CGSize(width: 0, height: 2)
               layer.shadowRadius = 4
           }
}
