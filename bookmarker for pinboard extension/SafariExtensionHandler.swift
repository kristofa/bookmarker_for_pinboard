import SafariServices

class SafariExtensionHandler: SFSafariExtensionHandler {
    
    let sharedUserDefaults = CommonUserDefaults()
    
    override func messageReceived(withName messageName: String, from page: SFSafariPage, userInfo: [String : Any]?) {
        // This method will be called when a content script provided by your extension calls safari.extension.dispatchMessage("message").
        switch (messageName) {
            case "selectedText" :
                if let selectedText = userInfo?["text"] {
                    DispatchQueue.main.async {
                        SafariExtensionViewController.shared.descriptionTextField.stringValue = selectedText as! String
                    }
                }
                else {
                    DispatchQueue.main.async {
                        SafariExtensionViewController.shared.descriptionTextField.stringValue = ""
                    }
                }
            case "openPopover" :
                page.getContainingTab { (tab) in
                    tab.getContainingWindow(completionHandler: { (window) in
                        window?.getToolbarItem(completionHandler: { (toolbaritem) in
                            toolbaritem?.showPopover()
                        })
                    })
                }
            default :
                NSLog("Received unsupported message: \(messageName)")
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
        
        clearStatusMessage()
        clearAllUrlProperties()
    SafariExtensionViewController.shared.addToPinboardPopup.window?.makeFirstResponder(SafariExtensionViewController.shared.tagsTextField)
        
        window.getActiveTab {
            activeTab in activeTab?.getActivePage {
                activePage in activePage?.getPropertiesWithCompletionHandler {
                    pageProperties in
                    
                    if let apiToken = self.getApiToken(), let url = pageProperties?.url, let title = pageProperties?.title  {
                        SafariExtensionViewController.shared.pinboardApi.get(apiToken: apiToken, inputUrl: url.absoluteString) {
                            
                            (url, existingEntries) in
                            switch (existingEntries) {
                                case .Succes(let pinboardUrls):
                                    if (pinboardUrls.isEmpty) {
                                        // Trigger getting selected page text so  description field can get populated
                                        activePage?.dispatchMessageToScript(withName: "getSelectedText", userInfo: nil)
                                        self.setUrlPropertiesExceptDescription(urlValue: url, titleValue: title)
                                    self.setDefaultValuesForReadLaterAndPrivateCheckboxes()
                                    } else {
                                        let firstUrl = pinboardUrls[0]
                                        self.setUrlProperties(urlValue: url, titleValue: firstUrl.title, descriptionValue: firstUrl.description, tagsValue: firstUrl.tags, isPrivate: firstUrl.isPrivate, readLater: firstUrl.readLater)
                                       
                                        if (firstUrl.description.isEmpty) {
                                           activePage?.dispatchMessageToScript(withName: "getSelectedText", userInfo: nil)
                                        }
                                        SafariExtensionViewController.shared.updateStatusTextFieldSuccess(message: "Already added earlier. Initially added: \(firstUrl.date)")
                                    }
                                case .Error(let message):
                                    self.clearAllUrlProperties(); SafariExtensionViewController.shared.updateStatusTextFieldFailure(message: message)
                                    
                            }
                        }
                    } else {
                        self.clearAllUrlProperties()
                    }
                }
            }
        }
        
       
    }
    
    private func getApiToken() -> Optional<String> {
        let apiTokenResponse = SafariExtensionViewController.shared.apiTokenAccess.getApiToken()
        switch(apiTokenResponse) {
            case .Error(let message):
            
            SafariExtensionViewController.shared.updateStatusTextFieldFailure(message: message)
                return Optional.none
            case .Success(let token):
                return Optional.some(token)
        }
    }
    
    private func setDefaultValuesForReadLaterAndPrivateCheckboxes() {
        DispatchQueue.main.async {
                   SafariExtensionViewController.shared.readLaterCheckbox.state = NSControl.StateValue.off
                   if let readLater = self.sharedUserDefaults.getReadLater() {
                       if (readLater == "Yes") {
                           SafariExtensionViewController.shared.readLaterCheckbox.state = NSControl.StateValue.on
                       }
                   }
               
                   SafariExtensionViewController.shared.privateCheckbox.state = NSControl.StateValue.off
                   if let isPrivate = self.sharedUserDefaults.getPrivate() {
                       if (isPrivate == "Yes") {
                           SafariExtensionViewController.shared.privateCheckbox.state = NSControl.StateValue.on
                       }
                   }
        }
    }
    
    private func setUrlPropertiesExceptDescription(urlValue: String, titleValue: String) {
        setUrlPropertiesExceptDescription(urlValue: urlValue, titleValue: titleValue, tagsValue: "")
    }
    
    private func setUrlPropertiesExceptDescription(urlValue: String, titleValue: String, tagsValue: String) {
            DispatchQueue.main.async {
                SafariExtensionViewController.shared.urlTextField.stringValue = urlValue
                SafariExtensionViewController.shared.titleTextField.stringValue = titleValue
                SafariExtensionViewController.shared.tagsTextField.stringValue = tagsValue
            }
    }
    
    private func setUrlProperties(urlValue: String, titleValue: String, descriptionValue: String, tagsValue: String, isPrivate: Bool, readLater: Bool) {
            DispatchQueue.main.async {
                SafariExtensionViewController.shared.urlTextField.stringValue = urlValue
                SafariExtensionViewController.shared.titleTextField.stringValue = titleValue
                SafariExtensionViewController.shared.descriptionTextField.stringValue = descriptionValue
                SafariExtensionViewController.shared.tagsTextField.stringValue = tagsValue
                
                if (isPrivate) {
                    SafariExtensionViewController.shared.privateCheckbox.state = NSControl.StateValue.on
                } else {
                    SafariExtensionViewController.shared.privateCheckbox.state = NSControl.StateValue.off
                }
                
                if (readLater) {
                    SafariExtensionViewController.shared.readLaterCheckbox.state = NSControl.StateValue.on
                } else {
                    SafariExtensionViewController.shared.readLaterCheckbox.state = NSControl.StateValue.off
                }
            }
    }
    
    private func clearAllUrlProperties() {
        DispatchQueue.main.async {
            SafariExtensionViewController.shared.urlTextField.stringValue = ""
            SafariExtensionViewController.shared.titleTextField.stringValue = ""
            SafariExtensionViewController.shared.descriptionTextField.stringValue = ""
            SafariExtensionViewController.shared.tagsTextField.stringValue = ""
        }
    }
    
    private func clearStatusMessage() {
        DispatchQueue.main.async {
            SafariExtensionViewController.shared.statusTextView.string = ""
        }
    }
    
//    override func popoverDidClose(in window: SFSafariWindow) {
//        
//    }

}
