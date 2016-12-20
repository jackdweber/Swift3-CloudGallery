//
//  AppState.swift
//  CloudGallery
//
//  Created by Jack Weber on 12/12/16.
//  Copyright © 2016 Jack Weber. All rights reserved.
//

import UIKit

class AppState: NSObject {
    static let sharedInstance = AppState()
    
    var signedIn = false
    var displayName: String?
    var photoURL: URL?
}
