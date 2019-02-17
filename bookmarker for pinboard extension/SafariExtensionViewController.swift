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
        
        var apiTokenFromKeychain: String
        let response = apiTokenAccess.getApiToken()
        
        switch(response) {
            case .ErrorApiTokenItemNotFound:
                let message = "Can't find API token in keychain. Set it using application."
                self.updateStatusTextFieldFailure(message: message)
                return
            case .ErrorUnexpectedApiTokenData:
                let message = "Invalid data for API key in keychain. Manually remove it from keychain."
                self.updateStatusTextFieldFailure(message: message)
                return
            case .ErrorUnknown(let status):
                let message = "Unknown error when getting API key from keychain. OSStatus: \(status)"
                self.updateStatusTextFieldFailure(message: message )
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
                        self.updateStatusTextFieldSuccess(message: "URL successfully submitted to Pinboard.")
                    case .Error(let value):
                        NSLog("Pinboard Request failed. Error: \(value)")
                        self.updateStatusTextFieldFailure(message: "URL submission failed. Message: \(value).")
                }
        }
        
    }
    
    private func buttonStateToBool(value: NSControl.StateValue) -> Bool {
        return value == NSControl.StateValue.on ? true : false
    }
    
    private func updateStatusTextFieldSuccess(message: String) -> Void {
        updateTextAndColorOfStatusField(value: message, color: NSColor.systemGreen)
    }
    
    private func updateStatusTextFieldFailure(message: String) -> Void {
        updateTextAndColorOfStatusField(value: message, color: NSColor.systemRed)
    }
    
    private func updateTextAndColorOfStatusField(value: String, color: NSColor) -> Void {
        DispatchQueue.main.async {
            self.statusTextField.textColor = color
            self.statusTextField.stringValue = value
        }
    }
    
  
}
