//
//  ViewController.swift
//  toDoFirebase
//
//  Created by Dimz on 12.05.17.
//  Copyright © 2017 Dmitriy Zyablikov. All rights reserved.
//

import UIKit
import Firebase

class LoginViewController: UIViewController {

    @IBOutlet weak var warning: UILabel!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    var ref: FIRDatabaseReference!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ref = FIRDatabase.database().reference(withPath: "users")

        NotificationCenter.default.addObserver(self, selector: #selector(kbDidShow), name: NSNotification.Name.UIKeyboardDidShow, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(kbDidHide), name: NSNotification.Name.UIKeyboardDidHide, object: nil)
        
        warning.alpha = 0
        
        FIRAuth.auth()?.addStateDidChangeListener({ (auth, user) in
            
            if user == nil { return }
            
            self.performSegue(withIdentifier: "tasksSegue", sender: nil)
            return
        })
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        emailTextField.text = ""
        passwordTextField.text = ""
        
    }
    
    
    func kbDidShow(notification: Notification) {
        
        guard let userInfo = notification.userInfo else { return }
        
        let kbFrameSize = (userInfo[UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        
        (self.view as! UIScrollView).contentSize = CGSize(width: self.view.bounds.width, height: self.view.bounds.height + kbFrameSize.height)
       
        //UIScrollView не должен заходить за клавиатуру
        //ограничение перемещения накладываем на scrollIndicatorInsets с помощью UIEdgeInsetsMake
        (self.view as! UIScrollView).scrollIndicatorInsets = UIEdgeInsetsMake(0, 0, kbFrameSize.height, 0)
        
    }
    
    func kbDidHide(notification: Notification) {
        
        (self.view as! UIScrollView).contentSize = CGSize(width: self.view.bounds.width, height: self.view.bounds.height)
        
    }
    
    func displayWarningLabel(withText text: String) {
        
        warning.text = text
        
        UIView.animate(withDuration: 3, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: [.curveEaseInOut], animations: {
            
            self.warning.alpha = 1
            
        }) { (complete) in
            
            UIView.animate(withDuration: 1.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: [.curveEaseInOut], animations: {
                
                self.warning.alpha = 0
            })
            
        }
        
    }
    
    
    @IBAction func loginTapped(_ sender: UIButton) {
        
        guard let email = emailTextField.text, let password = passwordTextField.text, email != "", password != "" else {
        
            displayWarningLabel(withText: "Info is not correct")
            return
        }
        
        FIRAuth.auth()?.signIn(withEmail: email, password: password, completion: { (user, erorr) in
            
            if erorr != nil {
                self.displayWarningLabel(withText: "Erorr occured")
                return
            }
            
            if user != nil {
                self.performSegue(withIdentifier: "tasksSegue", sender: nil)
                return
            }
            
            self.displayWarningLabel(withText: "User is not found")
        })
        
        
    }
    
    @IBAction func registerTapped(_ sender: UIButton) {
        
        guard let email = emailTextField.text, let password = passwordTextField.text, email != "", password != "" else {
            
            displayWarningLabel(withText: "Info is not correct")
            return
        }
        
        FIRAuth.auth()?.createUser(withEmail: email, password: password, completion: { (user, erorr) in
            
            guard erorr == nil, user != nil else {
                
                self.displayWarningLabel(withText: "User is not created")
                
                print(erorr?.localizedDescription ?? "")
                return
            }
            
            let userRef = self.ref?.child((user?.uid)!)
            userRef?.setValue(["email" : user?.email])
        
            
        })
        
        
    }
    


}

