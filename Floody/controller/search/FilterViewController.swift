//
//  FilterViewController.swift
//  Floody
//
//  Created by David Barbaran on 30/11/25.
//

import UIKit

class FilterViewController: UIViewController {
    
    
    @IBOutlet weak var radioAlimentoBtn: UIButton!
    @IBOutlet weak var radioAnimalesBtn: UIButton!
    
    var selectedTipo : TipoFiltro = .alimentos
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        view.backgroundColor = UIColor.black.withAlphaComponent(0.4)
    }
  
    private func setupUI() {
        radioAlimentoBtn.tintColor = UIColor(named: "lightGreen")
        radioAnimalesBtn.tintColor = UIColor(named: "lightGreen")
        updateRadioUI()
    }
    
    @IBAction func radioAlimentTapped(_ sender: UIButton) {
        selectedTipo = .alimentos
        updateRadioUI()
    }
    
    
    @IBAction func radioAnimalsTapped(_ sender: UIButton) {
        selectedTipo = .animales
        updateRadioUI()
    }
    
    private func updateRadioUI() {
            let selectedImage = UIImage(systemName: "largecircle.fill.circle")
            let unselectedImage = UIImage(systemName: "circle")

            switch selectedTipo {
            case .alimentos:
                radioAlimentoBtn.setImage(selectedImage, for: .normal)
                radioAnimalesBtn.setImage(unselectedImage, for: .normal)
            case .animales:
                radioAlimentoBtn.setImage(unselectedImage, for: .normal)
                radioAnimalesBtn.setImage(selectedImage, for: .normal)
            }
        }
    
    @IBAction func cerrarFiltro(_ sender: UIButton) {
        dismiss(animated: true)
    }
}
