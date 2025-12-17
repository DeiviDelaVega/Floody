import UIKit
import FirebaseCore
import FirebaseAuth
import GoogleSignIn
import MSAL

class LoginController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        validarFlujoInicial()
    }

    // MARK: Validar si ya hay un pais seleccionado
    func validarFlujoInicial() {
        guard let user = Auth.auth().currentUser else {
            print("Usuario nuevo = mostrar login")
            return
        }

        let uid = user.uid
        let selectedCountry = UserDefaults.standard.string(forKey: "selectedCountry_\(uid)")

        if selectedCountry != nil {
            goToMain()
        } else {
            goToCountryList()
        }
        print("DEBUG selectedCountry:", UserDefaults.standard.dictionaryRepresentation())

    }
    
    // MARK: Ir a la LISTA DE PAÍSES
    func goToCountryList() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "CountryListController")
        vc.modalPresentationStyle = .fullScreen
        self.present(vc, animated: true)
    }
    
    // MARK: Ir al MAIN despues de elegir pais
    func goToMain() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let tabBar = storyboard.instantiateViewController(withIdentifier: "MainTabBarController")
        tabBar.modalPresentationStyle = .fullScreen
        self.present(tabBar, animated: true)
    }
    
    // MARK: GOOGLE SIGN IN
    func signInWithGoogle() {
        guard let clientID = FirebaseApp.app()?.options.clientID else { return }

        let config = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.configuration = config

        GIDSignIn.sharedInstance.signIn(withPresenting: self) { result, error in
            if let error = error {
                print("Google error:", error.localizedDescription)
                return
            }

            guard let user = result?.user,
                  let idToken = user.idToken?.tokenString else {
                print("Token error")
                return
            }

            let credential = GoogleAuthProvider.credential(
                withIDToken: idToken,
                accessToken: user.accessToken.tokenString
            )

            Auth.auth().signIn(with: credential) { authResult, error in
                if let error = error {
                    print("Firebase error:", error.localizedDescription)
                    return
                }

                guard let user = authResult?.user else { return }
                    let uid = user.uid

                    let selectedCountry = UserDefaults.standard
                        .string(forKey: "selectedCountry_\(uid)")
                
                print("Login OK:", authResult?.user.email ?? "")

                DispatchQueue.main.async {
                    self.validarFlujoInicial()
                }
            }
        }
    }

    /*
    func signInWithOutlook() {
        
        // Id de la cuenta de Axure
        let clientId = "TU_CLIENT_ID" // CAMBIAR AL REGISTRAR LA APP
        let redirectUri = "msal\(clientId)://auth"
        let authority = "https://login.microsoftonline.com/common"
        
        do {
            let config = try MSALPublicClientApplicationConfig(clientId: clientId,
                                                               redirectUri: redirectUri,
                                                               authority: MSALAuthority(url: URL(string: authority)!))
            
            let app = try MSALPublicClientApplication(configuration: config)
            
            // Parametros para el token
            let parameters = MSALInteractiveTokenParameters(scopes: ["User.Read"], webviewParameters: MSALWebviewParameters(authPresentationViewController: self))
            
            // Login
            app.acquireToken(with: parameters) { (result, error) in
                
                if let error = error {
                    print("Error: \(error)")
                    return
                }
                
                // token + datos del user
                guard let result = result else { return }
                
                print("ACCESS TOKEN:")
                print(result.accessToken)
                
                print("Cuenta:")
                print(result.account.username)
                
                if UserDefaults.standard.string(forKey: "selectedCountry") == nil {
                    self.goToCountryList()
                } else {
                    self.goToMain()
                }
            }
        } catch {
            print("ERROR EN CONFIGURACIÓN: \(error)")
        }
    }*/
    
    @IBAction func btnGoogleSignIn(_ sender: GoogleButton) {
        signInWithGoogle()
    }
    
    @IBAction func btnOutlookSignIn(_ sender: UIButton) {
        //signInWithOutlook()
    }
}
