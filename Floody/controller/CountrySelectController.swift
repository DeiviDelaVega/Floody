//
//  CountrySelectController.swift
//  Floody
//
//  Created by David Barbaran on 27/11/25.
//

import UIKit

class CountrySelectController: UIViewController {
    
    @IBOutlet weak var btnAtras: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        btnAtras.layer.cornerRadius = btnAtras.frame.height / 2
        btnAtras.layer.masksToBounds = true
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
