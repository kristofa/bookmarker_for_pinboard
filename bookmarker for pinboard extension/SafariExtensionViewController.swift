import SafariServices

class SafariExtensionViewController: SFSafariExtensionViewController {
    
    static let shared: SafariExtensionViewController = {
        let shared = SafariExtensionViewController()
        shared.preferredContentSize = NSSize(width:320, height:240)
        return shared
    }()

    let pinboardApi = PinboardApi()
    let apiTokenAccess = CommonKeychainAccess()
    
    @IBOutlet weak var addToPinboardPopup: NSView!
    @IBOutlet var statusTextView: NSTextView!
    @IBOutlet weak var descriptionTextField: NSTextField!
    @IBOutlet weak var urlTextField: NSTextField!
    @IBOutlet weak var titleTextField: NSTextField!
    @IBOutlet var tagsTextView: NSTextView!
    @IBOutlet weak var readLaterCheckbox: NSButton!
    @IBOutlet weak var privateCheckbox: NSButton!
    
    @IBAction func urlTextFieldAction(_ sender: Any) {
        saveBookMark()
    }
    
    @IBAction func titleTextFieldAction(_ sender: Any) {
        saveBookMark()
    }
    
    @IBAction func tagsTextFieldAction(_ sender: Any) {
        saveBookMark()
    }
    
    @IBAction func descriptionTextFieldAction(_ sender: Any) {
        saveBookMark()
    }
    
    @IBAction func bookmarkButtonPressed(_ sender: Any) {
        saveBookMark()
    }
    
    private func saveBookMark() -> Void {
        var apiTokenFromKeychain: String
        let response = apiTokenAccess.getApiToken()
        
        switch(response) {
            case .Error(let message):
                self.updateStatusTextFieldFailure(message: message)
                return
            case .Success(let token):
                NSLog("Getting API token from keychain successful")
                apiTokenFromKeychain = token
        }
        
        let pinboardUrl = PinboardUrl(url: urlTextField.stringValue, title: titleTextField.stringValue, description: descriptionTextField.stringValue, isPrivate: buttonStateToBool(value: privateCheckbox.state), readLater: buttonStateToBool(value: readLaterCheckbox.state), tags: tagsTextView.string, date: "")
        
        pinboardApi.add(apiToken: apiTokenFromKeychain, pinboardUrl: pinboardUrl) {
            (url, response) in
            switch response {
            case .Succes:
                NSLog("Pinboard Request successful")
                self.updateStatusTextFieldSuccess(message: "URL successfully submitted to Pinboard.")
                self.dismissPopover()
            case .Error(let value):
                NSLog("Pinboard Request failed. Error: \(value)")
                self.updateStatusTextFieldFailure(message: value)
            }
        }
    }
    
    
    private func buttonStateToBool(value: NSControl.StateValue) -> Bool {
        return value == NSControl.StateValue.on ? true : false
    }
    
    public func updateStatusTextFieldSuccess(message: String) -> Void {
        updateTextAndColorOfStatusField(value: message, color: NSColor.systemGray)
    }
    
    public func updateStatusTextFieldFailure(message: String) -> Void {
        updateTextAndColorOfStatusField(value: message, color: NSColor.systemRed)
    }
    
    private func updateTextAndColorOfStatusField(value: String, color: NSColor) -> Void {
        DispatchQueue.main.async {
            self.statusTextView.textColor = color
            self.statusTextView.string = value
        }
    }
    
  
}
