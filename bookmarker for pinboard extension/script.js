if (window.top === window) {
    // The parent frame is the top-level frame, not an iframe.
    // All non-iframe code goes before the closing brace.
    
    var selectedText = ""
    var numberConsecutiveEmptySelections = 0
    
    var handleMessage = function (event) {
        //console.log("(bookmarker for pinboard) Got message from extension %s.", event.name);
        switch(event.name) {
            case "getSelectedText" :
                safari.extension.dispatchMessage("selectedText", {"text": selectedText} );
        }
    }
    
    document.addEventListener("DOMContentLoaded", function(event) {
                                safari.self.addEventListener("message", handleMessage);
                              });
    
    document.addEventListener("selectionchange", () => {
                                // This implementation with 'numberConsecutiveEmptySelections' is implemented
                                // to work around and ignore the deselect of text when we press the toolbar button.
                                // We store the selected text in the 'selectedText' variable but only empty it if we got
                                // two or more consecutive empty selections. This means following sequences work :
                                // a. 1. User selects text.  2. selection is lost when user presses toolbar button (outside of our control)
                                // b. 1. User deselects text. 2. selection is lost when user presses toolbar button (outside of our control)
                              
                                // In a. the user selected text will appear in the Description field as expected.
                                // In b. the Description field will be empty as expected.
                              
                                newSelection = window.getSelection().toString()
                                if (newSelection == "") {
                                    numberConsecutiveEmptySelections++
                                    if (numberConsecutiveEmptySelections >= 2) {
                                        selectedText = ""
                                    }
                                } else {
                                    selectedText = newSelection
                                    numberConsecutiveEmptySelections = 0
                                }
                                //console.log(selectedText);
                              });
}
