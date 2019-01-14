import Cocoa
import SafariServices.SFSafariApplication

class ViewController: NSViewController {

    @IBOutlet var appNameLabel: NSTextField!
    
    @IBOutlet weak var readLaterButton: NSPopUpButton!
   
    @IBOutlet weak var privateButton: NSPopUpButton!
    
    @IBOutlet weak var apiTokenSetTextFieldCell: NSTextFieldCell!
    
    @IBOutlet weak var apiTokenTextField: NSTextFieldCell!
    
    @IBOutlet weak var apiTokenButton: NSButtonCell!
    
    
    let sharedUserDefaults = UserDefaults(suiteName: "pinboard.in_bookmarker")!
    let apiTokenAccess = KeychainApiTokenAccess()
    
 
    @IBAction func apiTokenButtonAction(_ sender: NSButtonCell) {
        let apiToken = apiTokenTextField.stringValue
        let response = apiTokenAccess.createOrUpdateToken(apiToken: apiToken)
        
        switch (response) {
            case .Success : updateTextAndColorOfApiTokenSetField(value: "Yes", color: NSColor.systemGreen)
        case .ErrorCreatingOrUpdatingApiToken(_) : updateTextAndColorOfApiTokenSetField(value: "No", color: NSColor.red)
        case .ErrorCreatingSecAccess(_) : updateTextAndColorOfApiTokenSetField(value: "No", color: NSColor.red)
        case .ErrorCreatingTrustedApplicationsFailed(_, _) : updateTextAndColorOfApiTokenSetField(value: "No", color: NSColor.red)
        }
        
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
        
        self.appNameLabel.stringValue = "pinboard.in bookmarker";
        
        let apiTokenResponse = apiTokenAccess.getApiToken()
        
        switch (apiTokenResponse) {
            case .Success(_) :
                updateTextAndColorOfApiTokenSetField(value: "Yes", color: NSColor.systemGreen)
            default:
                updateTextAndColorOfApiTokenSetField(value: "No", color: NSColor.red)
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
        SFSafariApplication.showPreferencesForExtension(withIdentifier: "kristofa.pinboard.in-bookmarker") { error in
            if let _ = error {
                // Insert code to inform the user that something went wrong.

            }
        }
    }
    
    private func updateTextAndColorOfApiTokenSetField(value: String, color: NSColor) -> Void {
        DispatchQueue.main.async {
            self.apiTokenSetTextFieldCell.textColor = color
            self.apiTokenSetTextFieldCell.stringValue = value
        }
    }
    
}
