import Cocoa
import SafariServices.SFSafariApplication

class ViewController: NSViewController {

    @IBOutlet var appNameLabel: NSTextField!
    
    @IBOutlet weak var readLaterButton: NSPopUpButton!
   
    @IBOutlet weak var privateButton: NSPopUpButton!
    
    @IBOutlet weak var apiTokenSetTextFieldCell: NSTextFieldCell!
    
    @IBOutlet weak var apiTokenTextField: CutCopyPasteTextField!
    
    @IBOutlet weak var apiTokenButton: NSButtonCell!
    
    
    let sharedUserDefaults = UserDefaults(suiteName: "bookmarker_for_pinboard")!
    let apiTokenAccess = KeychainApiTokenAccess()
 
    @IBAction func apiTokenButtonAction(_ sender: NSButtonCell) {
        let apiToken = apiTokenTextField.stringValue
        let response = apiTokenAccess.createOrUpdateToken(apiToken: apiToken)
        
        switch (response) {
            case .Success : updateApiTokenSetTextFieldValueSuccess(message: "API token set.")
            case .ErrorCreatingOrUpdatingApiToken(let osStatus) : updateApiTokenSetTextFieldValueFailure(message: "Error when updating API token in keychain. OSStatus: \(osStatus). Try setting API token again.")
            case .ErrorCreatingSecAccess(let osStatus) : updateApiTokenSetTextFieldValueFailure(message: "Error creating keychain item access information. OSStatus: \(osStatus). Try setting API token again.")
            case .ErrorCreatingTrustedApplicationsFailed(let osStatus1, let osStatus2) : updateApiTokenSetTextFieldValueFailure(message: "Error creating trusted applications for keychain. OSStatuses: \(osStatus1), \(osStatus2).")
        }
        
        // Clear field so token isn't visible anymore.
        DispatchQueue.main.async {
            self.apiTokenTextField.stringValue = ""
        }
    }
    
    
    @IBAction func readLaterButtonAction(_ sender: NSPopUpButton) {
        if let item = sender.selectedItem {
            sharedUserDefaults.set(item.title, forKey: "readLater")
        }
    }
    
    @IBAction func privateButtonAction(_ sender: NSPopUpButton) {
        if let item = sender.selectedItem {
            sharedUserDefaults.set(item.title, forKey: "private")
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let apiTokenResponse = apiTokenAccess.getApiToken()
        
        switch (apiTokenResponse) {
            case .Success(_) :
                updateApiTokenSetTextFieldValueSuccess(message: "API token set.")
            case .ErrorApiTokenItemNotFound :
                updateApiTokenSetTextFieldValueFailure(message: "API token not set.")
            case .ErrorUnexpectedApiTokenData :
                updateApiTokenSetTextFieldValueFailure(message: "API token data is invalid. Update API token.")
            case .ErrorUnknown(let osStatus) :
                updateApiTokenSetTextFieldValueFailure(message: "Unknown error when getting API token. OSStatus \(osStatus). Update API token.")
        }
        
        if let readLater = sharedUserDefaults.string(forKey: "readLater") {
            DispatchQueue.main.async {
                self.readLaterButton.selectItem(withTitle: readLater)
            }
        } else {
            sharedUserDefaults.set("No", forKey: "readLater")
            DispatchQueue.main.async {
                self.readLaterButton.selectItem(withTitle: "No")
            }
        }
        
        if let isPrivate = sharedUserDefaults.string(forKey: "private") {
            DispatchQueue.main.async {
                self.privateButton.selectItem(withTitle: isPrivate)
            }
        } else {
            sharedUserDefaults.set("No", forKey: "private")
            DispatchQueue.main.async {
                self.privateButton.selectItem(withTitle: "No")
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
    
}
