import UIKit

class CountryListController: UIViewController, UITableViewDelegate, UITableViewDataSource{
    @IBOutlet weak var tvPais: UITableView!
    
    private var countries: [Country] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tvPais.delegate = self
        tvPais.dataSource = self
        tvPais.showsVerticalScrollIndicator = false
        
        loadCachedCountries()
        loadCountriesFromAPI()
    }
    
    private func loadCachedCountries() {
        let cached = CountryCache.shared.load()
        if !cached.isEmpty {
            self.countries = cached
            self.tvPais.reloadData()
        }
    }
    
    private func loadCountriesFromAPI() {
        OpenFoodFactsCountriesAPI.shared.fetchCountries { apiCountries in
            
            let filtered = apiCountries.compactMap { name -> Country? in
                guard Country.allowedCountries.contains(name),
                      let flagURL = FlagsService.shared.flagURL(for: name) else { return nil }
                return Country(name: name, flagURL: flagURL)
            }
            
            DispatchQueue.main.async {
                self.countries = filtered
                CountryCache.shared.save(filtered)
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
        cell.configure(with: country)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let country = countries[indexPath.row]
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let vc = storyboard.instantiateViewController(withIdentifier: "CountrySelectController") as? CountrySelectController {
            vc.countryName = country.translatedName
            vc.flagURL = country.flagURL
            self.present(vc, animated: true)
        }
    }
}
