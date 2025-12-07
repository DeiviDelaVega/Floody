import UIKit
import FirebaseCore
import FirebaseAuth
import GoogleSignIn
import MSAL

class LoginController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func goToCountryList() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "CountryListController")

        vc.modalPresentationStyle = .fullScreen
        self.present(vc, animated: true)
    }

    func signInWithGoogle() {
        // Obtiene ClientID de Fb
        guard let clientID = FirebaseApp.app()?.options.clientID else { return }

        let config = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.configuration = config

        // Popup de google
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first,
              let rootViewController = window.rootViewController else {
               
            print("No se encontró rootViewController")
            return
           }

        // Muestra Ventana de Google para elegir la cuenta
        GIDSignIn.sharedInstance.signIn(withPresenting: rootViewController) { result, error in
            if let error = error {
                print("Error Google SignIn:", error.localizedDescription)
                return
            }

            // Obtiene token
            guard let user = result?.user,
                  let idToken = user.idToken?.tokenString else {
                print("Error obteniendo token de Google")
                return
               }

            // Crea credencial x medio del Token de Fb
            let credential = GoogleAuthProvider.credential(withIDToken: idToken,
                                                           accessToken: user.accessToken.tokenString)

            // Inicia sesion
            Auth.auth().signIn(with: credential) { authResult, error in
                if let error = error {
                    print("Error Firebase Auth:", error.localizedDescription)
                    return
                }
                print("Usuario logueado:", authResult?.user.email ?? "sin email")
                self.goToCountryList()
            }
        }
    }
    
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
            }
        } catch {
            print("ERROR EN CONFIGURACIÓN: \(error)")
        }
    }
    

    @IBAction func btnGoogleSignIn(_ sender: GoogleButton) {
        signInWithGoogle()
    }
    
    
    @IBAction func btnOutlookSignIn(_ sender: UIButton) {
        signInWithOutlook()
    }
    
}


