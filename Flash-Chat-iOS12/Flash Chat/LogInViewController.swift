//  This is the view controller where users login

import UIKit
import Firebase
import SVProgressHUD

class LogInViewController: UIViewController {

    //Textfields pre-linked with IBOutlets
    @IBOutlet var emailTextfield: UITextField!
    @IBOutlet var passwordTextfield: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

   
    @IBAction func logInPressed(_ sender: AnyObject) {
        // triggers a loading pop-up
        SVProgressHUD.show()
        // Logs in user
        Auth.auth().signIn(withEmail: emailTextfield.text!, password: passwordTextfield.text!) { (user, error) in
            // if no problem, print success, else print error type
            if error != nil {
                print(error!)
            } else{
                print("Log in Successful!")
                // get rid of the progressHUD
                SVProgressHUD.dismiss()
            }
            self.performSegue(withIdentifier: "goToChat", sender: self)
        }
    }
}  
