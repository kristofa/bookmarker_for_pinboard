import SafariServices

class SafariExtensionViewController: SFSafariExtensionViewController, NSTextFieldDelegate {
    
    static let shared: SafariExtensionViewController = {
        let shared = SafariExtensionViewController()
        shared.preferredContentSize = NSSize(width:320, height:240)
        return shared
    }()

    let pinboardApi = PinboardApi()
    let apiTokenAccess = CommonKeychainAccess()
    var tags: [PinboardWeightedTag]?
    
    // enter, tab, esc and arrow keys
    let keysToIgnore = [36, 48, 53, 123, 124, 125, 126]
    
    @IBOutlet weak var addToPinboardPopup: NSView!
    @IBOutlet var statusTextView: NSTextView!
    @IBOutlet weak var descriptionTextField: NSTextField!
    @IBOutlet weak var urlTextField: NSTextField!
    @IBOutlet weak var titleTextField: NSTextField!
    @IBOutlet weak var tagsTextField: NSTextField!
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
    
    override func viewDidLoad() {
        tagsTextField.delegate = self
        
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
        
        pinboardApi.getTags(apiToken: apiTokenFromKeychain) {
            (response) in
            
            switch (response) {
                case .Success(let tags):
                    self.tags = tags.sorted().reversed()
                case .Error(let error):
                    self.updateStatusTextFieldFailure(message: error)
            }
        }
    }
    
    override func keyUp(with event: NSEvent) {
        if (addToPinboardPopup.window?.firstResponder?.isEqual(tagsTextField.currentEditor()) ?? false) {
            if (!keysToIgnore.contains(Int(event.keyCode))) {
                tagsTextField.currentEditor()?.complete(nil)
            }
        }
        super.keyUp(with: event)
    }
    
    func control(_ control: NSControl, textView: NSTextView, completions words: [String],
                forPartialWordRange charRange: NSRange, indexOfSelectedItem index: UnsafeMutablePointer<Int>) -> [String] {
    
        let range = Range(charRange, in: textView.string)!
        let substring = textView.string[range]
        
        index.initialize(to: -1)
        if (tags != nil) {
            let filtered = self.tags!.filter { tag in return tag.tagName.starts(with: substring) }
            return filtered.map { tag in return tag.tagName}
        } else
        {
            return []
        }
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
        
        let pinboardUrl = PinboardUrl(url: urlTextField.stringValue, title: titleTextField.stringValue, description: descriptionTextField.stringValue, isPrivate: buttonStateToBool(value: privateCheckbox.state), readLater: buttonStateToBool(value: readLaterCheckbox.state), tags: tagsTextField.stringValue, date: "")
        
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
