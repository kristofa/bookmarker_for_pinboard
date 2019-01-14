import Cocoa
import SafariServices.SFSafariApplication

class ViewController: NSViewController, NSTextFieldDelegate {

    @IBOutlet var appNameLabel: NSTextField!
    
    @IBOutlet weak var apiTokenTextField: NSSecureTextField!
    
    @IBOutlet weak var readLaterButton: NSPopUpButton!
   
    @IBOutlet weak var privateButton: NSPopUpButton!
    
    let sharedUserDefaults = UserDefaults(suiteName: "pinboard.in_bookmarker")!
    let apiTokenAccess = KeychainApiTokenAccess()
    
    func controlTextDidChange(_ obj: Notification) {
        
        let apiToken = apiTokenTextField.stringValue
        apiTokenAccess.createOrUpdateToken(apiToken: apiToken)
   
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
        self.apiTokenTextField.delegate = self
        
        let apiTokenResponse = apiTokenAccess.getApiToken()
        
        switch (apiTokenResponse) {
            case .Success(let token) :
                DispatchQueue.main.async {
                    self.apiTokenTextField.stringValue = token
                }
            default:
                DispatchQueue.main.async {
                    self.apiTokenTextField.stringValue = ""
                }
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
    
}
