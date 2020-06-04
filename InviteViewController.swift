//
//  InviteViewController.swift
//  Bonfire
//
//  Created by Keith Wang on 11/7/19.
//  Copyright © 2019 Bonfire. All rights reserved.
//

import UIKit
import FirebaseDynamicLinks
import FirebaseAuth

class InviteViewController: UIViewController {
    
    @IBOutlet var linkLabel: UILabel!
    @IBOutlet var shareButton: UIButton! {
        didSet {
            shareButton.layer.cornerRadius = 25.0
            shareButton.layer.masksToBounds = true
        }
    }
    
    private var uniqueID = Auth.auth().currentUser?.uid
    var dynamicLink = UniqueLink()
    var shareLinkButtonPressed = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        createDynamicLink()
    }
    
    @IBAction func shareLinkButtonTapped() {
        shareLinkButtonPressed = true
       
        createDynamicLink()
    }
    
    // MARK:- Helper Methods
    
    // Create link
    func createDynamicLink() {
        guard let id = self.uniqueID else { return }
        
        var components = URLComponents()
        components.scheme = dynamicLink.scheme
        components.host = dynamicLink.host
        components.path = dynamicLink.path
        
        let uniqueIDQueryItem = URLQueryItem(name: "id", value: id)
        components.queryItems = [uniqueIDQueryItem]
        
        guard let linkParameter = components.url else {return}
        print("This is my share link parameter \(linkParameter.absoluteString)")
        
        // To generate the big dynamic link
        guard let shareLink = DynamicLinkComponents(link: linkParameter, domainURIPrefix: dynamicLink.prefix) else {
            print("Error creating Firebase Dynamic Link")
            return
        }
        
        // Create dynamic link parameters
        if let myBundleID = Bundle.main.bundleIdentifier {
            shareLink.iOSParameters = DynamicLinkIOSParameters(bundleID: myBundleID)
        }
        
        shareLink.iOSParameters?.appStoreID = dynamicLink.myAppStoreID
        shareLink.socialMetaTagParameters = DynamicLinkSocialMetaTagParameters()
        shareLink.socialMetaTagParameters?.title = dynamicLink.title
        shareLink.socialMetaTagParameters?.descriptionText = dynamicLink.descriptionText
        shareLink.socialMetaTagParameters?.imageURL = dynamicLink.imageURL as URL
        
        guard let longDynamicLink = shareLink.url else { return }
        print("The long URL is: \(longDynamicLink.absoluteString)")
        
        // Shorten dynamic link
        shareLink.shorten { (url, warnings, error) in
            if let error = error {
                print("Error! \(error)")
                return
            }
            
            if let warnings = warnings {
                for warnings in warnings {
                    print("Warnings! \(warnings)")
                }
            }
            
            // This is where the "magic link" gets shortened and generated
            guard let url = url else { return }
            print("Here is the shortened \(url.absoluteString)")
            
            // Print link onto text field
            self.linkLabel.text = "\(url.absoluteString)"
            
            // If share link button is tapped, bring up share activity view
            if self.shareLinkButtonPressed == true {
                self.shareController(url: url)
            }
        }
    }
    
    func shareController(url: URL) {
        let promoText = dynamicLink.promoText
        let controller = UIActivityViewController(activityItems: [promoText, url],
        applicationActivities: nil)
        present(controller, animated: true)
    }
    
}
