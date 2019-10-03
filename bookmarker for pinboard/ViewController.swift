import Cocoa
import SafariServices.SFSafariApplication

class ViewController: NSViewController {

    @IBOutlet var appNameLabel: NSTextField!
    
    @IBOutlet weak var readLaterButton: NSPopUpButton!
   
    @IBOutlet weak var privateButton: NSPopUpButton!
    
    @IBOutlet weak var apiTokenSetTextFieldCell: NSTextFieldCell!
    
    @IBOutlet weak var apiTokenTextField: CutCopyPasteTextField!
    
    @IBOutlet weak var apiTokenButton: NSButtonCell!
    
    @IBOutlet weak var apiTokenHelpButton: NSButtonCell!
    
    let apiTokenAccess = KeychainApiTokenAccess()
    let userDefaults = CommonUserDefaults()
 
    @IBAction func apiTokenHelpButtonAction(_ sender: NSButtonCell) {
        guard let url = URL(string: "https://pinboard.in/settings/password") else { return }
        NSWorkspace.shared.open(url)
    }
    
    @IBAction func apiTokenButtonAction(_ sender: NSButtonCell) {
        let apiToken = apiTokenTextField.stringValue
        
        if (validApiToken(apiToken: apiToken)) {
            let response = apiTokenAccess.createOrUpdateToken(apiToken: apiToken)
        
            switch (response) {
                case .Success : updateApiTokenSetTextFieldValueSuccess(message: "API token updated.")
                case .ErrorCreatingOrUpdatingApiToken(let osStatus) : updateApiTokenSetTextFieldValueFailure(message: "Error updating Keychain. OSStatus: \(osStatus). Try setting API token again.")
                case .ErrorCreatingSecAccess(let osStatus) : updateApiTokenSetTextFieldValueFailure(message: "Error creating keychain access info. OSStatus: \(osStatus). Try setting API token again.")
                case .ErrorCreatingTrustedApplicationsFailed(let osStatus1, let osStatus2) : updateApiTokenSetTextFieldValueFailure(message: "Error creating trusted applications for keychain. OSStatuses: \(osStatus1), \(osStatus2).")
            }
        
            // Clear field so token isn't visible anymore.
            DispatchQueue.main.async {
                self.apiTokenTextField.stringValue = ""
            }
        }
        else {
            updateApiTokenSetTextFieldValueFailure(message: "Invalid API token format. Expecting username:TOKEN")
        }
    }
    
    
    @IBAction func readLaterButtonAction(_ sender: NSPopUpButton) {
        if let item = sender.selectedItem {
            userDefaults.setReadLater(value: item.title)
        }
    }
    
    @IBAction func privateButtonAction(_ sender: NSPopUpButton) {
        if let item = sender.selectedItem {
            userDefaults.setPrivate(value: item.title)
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let apiTokenResponse = apiTokenAccess.getApiToken()
        
        switch (apiTokenResponse) {
            case .Success(_) :
                updateApiTokenSetTextFieldValueSuccess(message: "API token set.")
            case .Error(let message) :
                updateApiTokenSetTextFieldValueFailure(message: message)
        }
        
        if let readLater = userDefaults.getReadLater() {
            DispatchQueue.main.async {
                self.readLaterButton.selectItem(withTitle: readLater)
            }
        } else {
            let value = userDefaults.setReadLaterDefaultValue()
            DispatchQueue.main.async {
                self.readLaterButton.selectItem(withTitle: value)
            }
        }
        
        if let isPrivate = userDefaults.getPrivate() {
            DispatchQueue.main.async {
                self.privateButton.selectItem(withTitle: isPrivate)
            }
        } else {
            let value = userDefaults.setPrivateDefaultValue()
            DispatchQueue.main.async {
                self.privateButton.selectItem(withTitle: value)
            }
        }
    }
    
    @IBAction func openSafariExtensionPreferences(_ sender: AnyObject?) {
        SFSafariApplication.showPreferencesForExtension(withIdentifier: "kristofa.pinboard.in-bookmarker.safariappextension") { error in
            if let _ = error {
                // Insert code to inform the user that something went wrong.

            }
        }
    }
    
    private func updateApiTokenSetTextFieldValueSuccess(message: String) -> Void {
        updateTextAndColorOfApiTokenSetField(value: message, color: NSColor.systemGreen)
    }
    
    private func updateApiTokenSetTextFieldValueFailure(message: String) -> Void {
        updateTextAndColorOfApiTokenSetField(value: message, color: NSColor.systemRed)
    }
    
    private func updateTextAndColorOfApiTokenSetField(value: String, color: NSColor) -> Void {
        DispatchQueue.main.async {
            self.apiTokenSetTextFieldCell.textColor = color
            self.apiTokenSetTextFieldCell.stringValue = value
        }
    }
    
    private func validApiToken(apiToken: String) -> Bool {
        do {
            let regex = try NSRegularExpression(pattern: "[^\\s]{2,}:[A-Za-z0-9]{5,}")
            let results = regex.matches(in: apiToken,
                                        range: NSRange(apiToken.startIndex..., in: apiToken))
            let matches = results.map {
                String(apiToken[Range($0.range, in: apiToken)!])
            }
            return (matches.count == 1)
            
        } catch let error {
            NSLog("invalid regex: \(error.localizedDescription)")
            return false
        }
    }
    
}
