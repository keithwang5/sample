//
//  UniqueLink.swift
//  Bonfire
//
//  Created by Keith Wang on 11/8/19.
//  Copyright © 2019 Bonfire. All rights reserved.
//

import Foundation

struct UniqueLink {
    
    let scheme: String
    let host: String
    let path: String
    let prefix: String
    let myAppStoreID: String
    let title: String
    let descriptionText: String
    let imageURL: NSURL
    let promoText: String
    
    init() {
        self.scheme = "https"
        self.host = "bonfireapp.page.link"
        self.path = "/my"
        self.prefix = "https://bonfireapp.page.link"
        self.myAppStoreID = "1480186539"
        self.title = "Bonfire"
        self.descriptionText = "Collaborate with your tribe, improve your mental health"
        self.imageURL = NSURL(string: "https://imgur.com/9xOw4Tb")!
        self.promoText = ""
    }
    
}
