if (window.top === window) {
    // The parent frame is the top-level frame, not an iframe.
    // All non-iframe code goes before the closing brace.
    
    var handleMessage = function (event) {
        console.log("(bookmarker for pinboard) Get message from extension %s.",event.name);
        switch(event.name) {
            case "getSelectedText" :
                safari.extension.dispatchMessage("selectedText", {"text": window.getSelection().toString()} );
        }
    }
    
    document.addEventListener("DOMContentLoaded", function(event) {
                              safari.self.addEventListener("message", handleMessage);
                              });
}
