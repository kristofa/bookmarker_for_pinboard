import SafariServices

class SafariExtensionHandler: SFSafariExtensionHandler {
    
    let sharedUserDefaults = UserDefaults(suiteName: "bookmarker_for_pinboard")!
    
    override func messageReceived(withName messageName: String, from page: SFSafariPage, userInfo: [String : Any]?) {
        // This method will be called when a content script provided by your extension calls safari.extension.dispatchMessage("message").
        page.getPropertiesWithCompletionHandler { properties in
            NSLog("The extension received a message (\(messageName)) from a script injected into (\(String(describing: properties?.url))) with userInfo (\(userInfo ?? [:]))")
        }
    }
    
    override func toolbarItemClicked(in window: SFSafariWindow) {
        // This method will be called when your toolbar item is clicked.
    }
    
    override func validateToolbarItem(in window: SFSafariWindow, validationHandler: @escaping ((Bool, String) -> Void)) {
        // This is called when Safari's state changed in some way that would require the extension's toolbar item to be validated again.
        validationHandler(true, "")
    }
    
    override func popoverViewController() -> SFSafariExtensionViewController {
        return SafariExtensionViewController.shared
    }
    
    override func popoverWillShow(in window: SFSafariWindow) {
        
        window.getActiveTab {
            activeTab in activeTab?.getActivePage {
                activePage in activePage?.getPropertiesWithCompletionHandler {
                    pageProperties in
                    if let title = pageProperties?.title, let url = pageProperties?.url {
                        DispatchQueue.main.async {
                            SafariExtensionViewController.shared.urlTextField.stringValue = url.absoluteString
                            SafariExtensionViewController.shared.titleTextField.stringValue = title
                            SafariExtensionViewController.shared.descriptionTextField.stringValue = ""
                            SafariExtensionViewController.shared.tagsTextField.stringValue = ""
                            SafariExtensionViewController.shared.statusTextField.stringValue = ""
                        }
                    } else {
                        DispatchQueue.main.async {
                            SafariExtensionViewController.shared.urlTextField.stringValue = ""
                            SafariExtensionViewController.shared.titleTextField.stringValue = ""
                            SafariExtensionViewController.shared.descriptionTextField.stringValue = ""
                            SafariExtensionViewController.shared.tagsTextField.stringValue = ""
                            SafariExtensionViewController.shared.statusTextField.stringValue = ""
                        }
                    }
                }
            }
        }
        
        DispatchQueue.main.async {
            SafariExtensionViewController.shared.readLaterCheckbox.state = NSControl.StateValue.off
            if let readLater = self.sharedUserDefaults.string(forKey: "readLater") {
                if (readLater == "Yes") {
                    SafariExtensionViewController.shared.readLaterCheckbox.state = NSControl.StateValue.on
                }
            }
        
            SafariExtensionViewController.shared.privateCheckbox.state = NSControl.StateValue.off
            if let isPrivate = self.sharedUserDefaults.string(forKey: "private") {
                if (isPrivate == "Yes") {
                    SafariExtensionViewController.shared.privateCheckbox.state = NSControl.StateValue.on
                }
            }
        }
        
    }
    
//    override func popoverDidClose(in window: SFSafariWindow) {
//        
//    }

}