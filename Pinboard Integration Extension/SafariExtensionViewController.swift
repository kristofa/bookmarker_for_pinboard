//
//  SafariExtensionViewController.swift
//  Pinboard Integration Extension
//
//  Created by Kristof Adriaenssens on 30/12/2018.
//  Copyright © 2018 Kristof Adriaenssens. All rights reserved.
//

import SafariServices

class SafariExtensionViewController: SFSafariExtensionViewController {
    
    static let shared: SafariExtensionViewController = {
        let shared = SafariExtensionViewController()
        shared.preferredContentSize = NSSize(width:320, height:240)
        return shared
    }()

}
