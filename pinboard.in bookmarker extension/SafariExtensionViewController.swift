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

    let pinboardApi = PinboardApi()
    let apiTokenAccess = CommonKeychainAccess()
    let sharedUserDefaults = UserDefaults(suiteName: "pinboard.in_bookmarker")!
    
    @IBOutlet weak var statusTextField: NSTextField!
    @IBOutlet weak var descriptionTextField: NSTextField!
    @IBOutlet weak var urlTextField: NSTextField!
    @IBOutlet weak var titleTextField: NSTextField!
    @IBOutlet weak var tagsTextField: NSTextField!
    @IBOutlet weak var readLaterCheckbox: NSButton!
    @IBOutlet weak var privateCheckbox: NSButton!
    
    @IBAction func bookmarkButtonPressed(_ sender: Any) {
        
        NSLog("----- Bookmark button pressed -----")
        
        var apiTokenFromKeychain: String
        let response = apiTokenAccess.getApiToken()
        
        switch(response) {
            case .ErrorApiTokenItemNotFound:
                let message = "Can't find API key in keychain. Set it using application."
                NSLog(message)
                self.updateStatusTextField(value: message)
                return
            case .ErrorUnexpectedApiTokenData:
                let message = "Invalid data for API key in keychain. Manually remove it from keychain."
                NSLog(message)
                self.updateStatusTextField(value: message)
                return
            case .ErrorUnknown(let status):
                let message = "Unknown error when getting API key from keychain. OSStatus: \(status)"
                NSLog(message)
                self.updateStatusTextField(value: message )
                return
            case .Success(let token):
                NSLog("Getting API token from keychain successful")
                apiTokenFromKeychain = token
        }
        
        let pinboardUrl = PinboardUrl(url: urlTextField.stringValue, title: titleTextField.stringValue, description: descriptionTextField.stringValue, isPrivate: buttonStateToBool(value: privateCheckbox.state), readLater: buttonStateToBool(value: readLaterCheckbox.state), tags: tagsTextField.stringValue)
        
        pinboardApi.submit(apiToken: apiTokenFromKeychain, pinboardUrl: pinboardUrl) {
            (url, response) in
                switch response {
                    case .Succes:
                        NSLog("Pinboard Request successful")
                        self.updateStatusTextField(value: "URL successfully submitted to Pinboard.")
                    case .Error(let value):
                        NSLog("Pinboard Request failed. Error: \(value)")
                        self.updateStatusTextField(value: "URL submission failed. Message: \(value).")
                }
        }
        
    }
    
    private func buttonStateToBool(value: NSControl.StateValue) -> Bool {
        return value == NSControl.StateValue.on ? true : false
    }
    
    private func updateStatusTextField(value: String) -> Void {
        DispatchQueue.main.async {
            self.statusTextField.stringValue = value
        }
    }
    
  
}
