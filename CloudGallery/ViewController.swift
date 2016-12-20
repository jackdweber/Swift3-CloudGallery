//
//  ViewController.swift
//  CloudGallery
//
//  Created by Jack Weber on 12/12/16.
//  Copyright © 2016 Jack Weber. All rights reserved.
//

import UIKit
import FirebaseAuth

class ViewController: UIViewController {
    
    //Outlets to the story board
    @IBOutlet var emailTextField: UITextField!
    @IBOutlet var passTextField: UITextField!
    
    @IBAction func logAction(_ sender: Any) {
        //If the user has an accout, try to sign in, if not sign him up.
        if emailTextField.text != "" && passTextField.text != ""{
            let email = emailTextField.text
            let pass = passTextField.text
            
            FIRAuth.auth()?.signIn(withEmail: email!, password: pass!, completion: { (user, error) in
                if error != nil{
                    print(error?.localizedDescription ?? "Error")
                    FIRAuth.auth()?.createUser(withEmail: email!, password: pass!, completion: { (newuser, error2) in
                        if error2 != nil{
                            print(error?.localizedDescription ?? "Error")
                        }
                        else{
                            self.signedIn(newuser)
                        }
                    })
                }
                else{
                    self.signedIn(user)
                }
            })
        }

    }
    
    //Child Functions
    
    func signedIn(_ user: FIRUser?) {
        //Save the user info into the appState class
        AppState.sharedInstance.displayName = user?.displayName ?? user?.email
        AppState.sharedInstance.photoURL = user?.photoURL
        AppState.sharedInstance.signedIn = true
        performSegue(withIdentifier: "logInSegue", sender: nil)
    }
    
    //Override Functions

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        //Check for user after view appears to give it time to load up.
        if let user = FIRAuth.auth()?.currentUser{
            signedIn(user)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

