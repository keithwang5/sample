//
//  InviteSuccessViewController.swift
//  Bonfire
//
//  Created by Keith Wang on 11/15/19.
//  Copyright © 2019 Bonfire. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore
import GoogleSignIn

class InviteSuccessViewController: UIViewController {
    
    var vc = SignUpOptionsViewController()
    
    let db = Firestore.firestore()
    let id = Auth.auth().currentUser?.uid
    var ref: CollectionReference? {
        return db.collection("tribes").document(userID!).collection("members")
    }
    
    let user: GIDGoogleUser = GIDSignIn.sharedInstance()!.currentUser
    var userID: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        UserDefaults.standard.set(true, forKey: "friend")
        
        // 1. Add recipient uid to tribe leader's collection in Firestore
        if id != nil {
            ref?.document(id!).setData([
                "name": user.profile.name!,
                "image": user.profile.imageURL(withDimension: 200).absoluteString,
                "my_tribe": true,
                "shared": false
            ]) { err in
                if let err = err {
                    print("Error writing document: \(err)")
                } else {
                    print("Added new tribe member")
                }
            }
            
            db.collection("users").document(userID!).getDocument { (document, err) in
                if let err = err {
                    print("Error writing document: \(err)")
                } else {
                    if let document = document, document.exists {
                        let data = document.data()
                        let name = data?["name"]
                        let image = data?["image"]
                        
                        // 2. Add inviter's uid to recipient's joined_tribe collection of tribe ids
                        // 3. Create tribe id for the recipient
                        self.db.collection("users").document(self.id!).collection("joined_tribes").document(self.userID).setData([
                            "name": name!,
                            "image": image!
                        ]) { err in
                            if let err = err {
                                print("Error writing document: \(err)")
                            } else {
                                print("Added other tribe ids to my collection")
                            }
                        }
                    }
                }
            }
        }
    }
    
    @IBAction func nextButtonTapped(sender: UIButton) {
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "BonfireViewController") as! BonfireViewController
        
        present(vc, animated: true, completion: nil)
    }
}
