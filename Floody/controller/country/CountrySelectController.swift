import UIKit

class CountrySelectController: UIViewController {
    @IBOutlet weak var btnAtras: UIButton!
    @IBOutlet weak var imgFlag: UIImageView!
    @IBOutlet weak var lblCountryName: UILabel!
    
    var countryName: String?
    var flagURL: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        lblCountryName.text = countryName
        
        if let flagURL = flagURL, let url = URL(string: flagURL) {
            URLSession.shared.dataTask(with: url) { data, _, _ in
                if let data = data {
                    DispatchQueue.main.async {
                        self.imgFlag.image = UIImage(data: data)
                    }
                }
            }.resume()
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        btnAtras.layer.cornerRadius = btnAtras.frame.height / 2
        btnAtras.layer.masksToBounds = true
    }
    
    //Volver a la lista de paises
    @IBAction func btnAtrasTapped(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    
    @IBAction func btnSiguienteTapped(_ sender: UIButton) {
        guard let country = countryName else { return }

            // Guardar región seleccionada
            UserDefaults.standard.set(country, forKey: "selectedCountry")

            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let tabBar = storyboard.instantiateViewController(withIdentifier: "MainTabBarController")

            tabBar.modalPresentationStyle = .fullScreen
            self.present(tabBar, animated: true)
    }
}
