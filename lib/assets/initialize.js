// initialize 
var editor = document.getElementById("editor");
editor.innerHTML = "<p><br></p>";

// block delete input to keep default content
editor.addEventListener("keydown", event => {
    var key = event.key || event.keyCode;
    if ((key === 8 || key === 46) && editor.innerHTML === '<p><br></p>') {
        event.preventDefault();
    }
});

// clean intput on paste so layout is not messed up
editor.addEventListener('paste', event => {
    event.preventDefault();
    var text = event.clipboardData.getData("text/plain");
    console.log(text);
    document.execCommand("insertHTML", false, text);
}, false);

// focus callback
editor.addEventListener('focus', (event) => {
    console.log("Editor focused");
    window.flutter_inappwebview.callHandler("onFocus");
});

document.getElementById("body").addEventListener('scroll', (event) => {
    console.log("Scroll!");
    event.preventDefault();
});

// blur callback
editor.addEventListener('blur', (event) => {
    console.log("Editor unfocused");
    window.flutter_inappwebview.callHandler("onBlur");
});

// onChange callback
editor.addEventListener("input", (event) => {
    var content = editor.innerHTML;
    var height = editor.scrollHeight;
    if (content != '<p><br></p>') {
        placeholder.remove();
    }
    else {
        document.getElementById("editor-container").prepend(placeholder);
    }
    console.log("Text:" + editor.innerHTML);
    console.log("Flexible height:" + height);
    window.flutter_inappwebview.callHandler("onChange", content, height);
}, false);