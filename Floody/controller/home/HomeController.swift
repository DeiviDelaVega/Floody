import UIKit
import AVFoundation

class HomeController: UIViewController {

    @IBOutlet weak var cameraPreviewView: UIView!
    @IBOutlet weak var scannedCountLabel: UILabel!

    private let scanner = BarcodeScannerService()

    private var scannedCount: Int = 0 {
        didSet {
            scannedCountLabel.text = "\(scannedCount)"
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        scannedCount = 0

        #if targetEnvironment(simulator)
        startSimulatorMode()
        #else
        startCameraMode()
        #endif
    }

    // MARK: - Simulator Mode
    private func startSimulatorMode() {
        let fakeCode = "5449000054227"
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
        ProductService.shared.fetchProduct(code: code) { product in
            guard let product = product else {
                print("Product not found")
                return
            }

            DispatchQueue.main.async {
                print("Name:", product.name)
                print("Brand:", product.brand)
                print("Calories:", product.calories)
            }
        }
    }
}
