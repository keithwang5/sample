//
//  ReceiveIncomingLinksHandler.swift
//  Bonfire
//
//  Created by Keith Wang on 4/27/20.
//  Copyright © 2020 Bonfire. All rights reserved.
//

import UIKit
import Firebase
import FirebaseFirestore
import FirebaseAuth
import GoogleSignIn
import OneSignal
import IHDesignableButton
import Intents
import AVKit
import AVFoundation
import UserNotifications


class ReceiveIncomingLinksHandler {
    
    func application(_ application: UIApplication, continue userActivity: NSUserActivity,
                     restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
        
        // Handle incoming Firebase dynamic link
        if let incomingURL = userActivity.webpageURL {
            print("Incoming URL is \(incomingURL)")
            
            let linkHandled = DynamicLinks.dynamicLinks().handleUniversalLink(incomingURL)
            { (dynamicLink, error) in
                guard error == nil else {
                    print("Found an error! \(error!.localizedDescription)")
                    return
                }
                if let dynamicLink = dynamicLink {
                    self.handleIncomingDynamicLink(dynamicLink)
                }
            }
            
            if linkHandled {
                return true
            } else {
                return false
            }
        }
        
        return true
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        let user: GIDGoogleUser? = GIDSignIn.sharedInstance().currentUser

        if user != nil {
            // return GIDSignIn.sharedInstance().handle(url)
        }
        
        print("Yay, I have received a URL through a custom scheme! - \(url.absoluteString)")
        
        if let dynamicLink = DynamicLinks.dynamicLinks().dynamicLink(fromCustomSchemeURL: url) {
            self.handleIncomingDynamicLink(dynamicLink)

            return true
        } else {
            return GIDSignIn.sharedInstance().handle(url)
        }
    }
    
    // MARK: - Helper Methods
    
    // Firebase Dynamic Links handling
    func handleIncomingDynamicLink(_ dynamicLink: DynamicLink) {
        guard let url = dynamicLink.url else {
            print("Hmm, cannot receive any dynamic link...")
            return
        }
        
        let alert = UIAlertController(title: "Deep link handled", message: nil, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        window?.rootViewController?.present(alert, animated: true, completion: nil)
        
        
        guard (dynamicLink.matchType == .unique || dynamicLink.matchType == .default) else {
            // Not a strong enough match, do nothing in this case
            print("Not a strong enough match to continue")
            let alert = UIAlertController(title: "Weak match", message: nil, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            window?.rootViewController?.present(alert, animated: true, completion: nil)
            return
        }
        
        // Parse the link parameter
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
            let queryItems = components.queryItems else { return }
        
        if components.path == uniqueLink.path {
            // Direct to success page and link both parties into a tribe
            if let userIDQueryItem = queryItems.first(where: {$0.name == "id" }) {
                let userID = userIDQueryItem.value
                
                let alert = UIAlertController(title: "Sender ID retrieved", message: nil, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                window?.rootViewController?.present(alert, animated: true, completion: nil)
                
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                if let vc = storyboard.instantiateViewController(withIdentifier: "InviteSuccessViewController") as? InviteSuccessViewController,
                    let tabBarController = self.window?.rootViewController as? UITabBarController,
                    let navController = tabBarController.selectedViewController as? UINavigationController {
                    vc.userID = userID
                    navController.pushViewController(vc, animated: true)
                }
                
                print("The parsed user id is \(userID ?? "Bonfirer")")
            }
        } else {
            let alert = UIAlertController(title: "No component path", message: nil, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            window?.rootViewController?.present(alert, animated: true, completion: nil)
        }
    }
    
}


