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
    let sharedUserDefaults = UserDefaults(suiteName: "pinboard.in_bookmarker")!
    
    @IBOutlet weak var statusTextField: NSTextField!
    @IBOutlet weak var descriptionTextField: NSTextField!
    @IBOutlet weak var urlTextField: NSTextField!
    @IBOutlet weak var titleTextField: NSTextField!
    @IBOutlet weak var tagsTextField: NSTextField!
    @IBOutlet weak var readLaterCheckbox: NSButton!
    @IBOutlet weak var privateCheckbox: NSButton!
    
    @IBAction func bookmarkButtonPressed(_ sender: Any) {
        
        NSLog("Bookmark button pressed")
        
        if let apiToken = sharedUserDefaults.string(forKey: "apiToken") {
        
            let pinboardUrl = PinboardUrl(url: urlTextField.stringValue, title: titleTextField.stringValue, description: descriptionTextField.stringValue, isPrivate: buttonStateToBool(value: privateCheckbox.state), readLater: buttonStateToBool(value: readLaterCheckbox.state), tags: tagsTextField.stringValue)
        
            pinboardApi.submit(apiToken: apiToken, pinboardUrl: pinboardUrl) {
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
        } else {
            self.updateStatusTextField(value: "pinboard.in API token not configured.")
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
