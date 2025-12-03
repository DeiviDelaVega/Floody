import UIKit

class CountryListController: UIViewController, UITableViewDelegate, UITableViewDataSource{
    @IBOutlet weak var tvPais: UITableView!
    
    var countries: [Country] = []
    
    let allowedCountries = [
        "Peru",
        "United States",
        "Spain",
        "France",
        "Canada",
        "Japan",
        "China",
        "Brazil",
        "Mexico",
        "Italy"
    ]
    
    let countryTranslations: [String: String] = [
        "Peru": "Perú",
        "United States": "Estados Unidos",
        "Spain": "España",
        "France": "Francia",
        "Canada": "Canadá",
        "Japan": "Japón",
        "China": "China",
        "Brazil": "Brasil",
        "Mexico": "México",
        "Italy": "Italia"
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tvPais.delegate = self
        tvPais.dataSource = self
        tvPais.showsVerticalScrollIndicator = false
        
        loadCountries()
    }
    
    func loadCountries() {
        OpenFoodFactsCountriesAPI.shared.fetchCountries { apiCountries in
            
            var filtered: [Country] = []
            
            for name in apiCountries {
                if self.allowedCountries.contains(name),
                   let flag = FlagsService.shared.flagURL(for: name) {
                    
                    filtered.append(Country(name: name, flagURL: flag))
                }
            }
            
            DispatchQueue.main.async {
                self.countries = filtered
                self.tvPais.reloadData()
            }
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return countries.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "countryCell", for: indexPath) as! CountryCell
        
        let country = countries[indexPath.row]
        
        let translated = countryTranslations[country.name] ?? country.name
        cell.lblCountry.text = translated
        
        if let url = URL(string: country.flagURL) {
            URLSession.shared.dataTask(with: url) { data, _, _ in
                if let data = data {
                    DispatchQueue.main.async {
                        cell.imgFlag.image = UIImage(data: data)
                    }
                }
            }.resume()
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 85.0
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedCountry = countries[indexPath.row]
        let translatedName = countryTranslations[selectedCountry.name] ?? selectedCountry.name

        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "CountrySelectController") as! CountrySelectController

        vc.countryName = translatedName
        vc.flagURL = selectedCountry.flagURL

        self.present(vc, animated: true, completion: nil)
    }
}
