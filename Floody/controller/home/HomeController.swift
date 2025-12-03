import UIKit
import AVFoundation

class HomeController: UIViewController {

    @IBOutlet weak var cameraPreviewView: UIView!
    @IBOutlet weak var scannedCountLabel: UILabel!

    private let scanner = BarcodeScannerService()
    
    private var selectedCountry: String = "Estados Unidos" // default

    private var scannedCount: Int = 0 {
        didSet {
            scannedCountLabel.text = "\(scannedCount)"
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        scannedCount = 0
        
        if let savedCountry = UserDefaults.standard.string(forKey: "selectedCountry") {
            selectedCountry = savedCountry
        }

        print("Región activa:", selectedCountry)

        #if targetEnvironment(simulator)
        startSimulatorMode()
        #else
        startCameraMode()
        #endif
    }

    // MARK: - Simulator Mode
    private func startSimulatorMode() {
        let fakeCode = "7751271021975"
        scannedCount += 1
        loadProduct(code: fakeCode)
    }

    // MARK: - Camera Mode
    private func startCameraMode() {
        scanner.start(in: cameraPreviewView) { [weak self] code in
            guard let self = self else { return }

            self.scannedCount += 1
            self.loadProduct(code: code)
        }
    }

    // MARK: - Product Loader
    private func loadProduct(code: String) {
        ProductService.shared.fetchProduct(
            code: code,
            country: selectedCountry
        ) { product in
            guard let product = product else {
                print("Product not found")
                return
            }

            DispatchQueue.main.async {
                print("Country:", self.selectedCountry)
                print("Name:", product.name)
                print("Brand:", product.brand)
                print("Calories:", product.calories)
            }
        }
    }

}
