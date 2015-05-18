// @koala-prepend 'assets/vender/jquery.js',
// @koala-prepend 'assets/vender/rangy-core.js',
// @koala-prepend 'assets/vender/rangy-classapplier.js',
// @koala-prepend 'assets/vender/rangy-highlighter.js',
// @koala-prepend 'assets/js/ZSSRichTextEditor.js'

$(function () {
    try {
        zss_editor.init();
        
    } catch(e) {
        alert(e);
    }
});