/**
 * EReader
 * author: jerryni
 * date: 2015-05-21
 */
;
(function($, rangy) {

    var EReader,
        highlighter;

    EReader = {
        init: function() {
            this.bindElments();
            this.bindEvents();
            this._initHighlighter();

            this.log('EReader init finished...');
        },

        bindEvents: function() {
            var _this = this;
            $(document).on('selectionchange', function(e) {
                _this.log("callback://");
             });
        },

        bindElments: function() {
            this.$content = $('#content');
            this.$header = $('#header');
            this.$footer = $('#footer');
        },

        _initHighlighter: function() {
            rangy.init();

            highlighter = rangy.createHighlighter();

            highlighter.addClassApplier(rangy.createClassApplier(MY_GLOBAL.HILITE_CLASS_NAME, {
                ignoreWhiteSpace: true,
                tagNames: ["span", "a"]
            }));
        },

        addHilite: function() {
            try {
                highlighter.highlightSelection(MY_GLOBAL.HILITE_CLASS_NAME);

            } catch (e) {
                this.log(e);
            }
            return this;
        },

        isHilite: function() {

            var $el = $(document.getSelection().baseNode.parentElement);
            return $el.hasClass(MY_GLOBAL.HILITE_CLASS_NAME);
        },

        removeHilite: function() {

            try {
                highlighter.unhighlightSelection();
            } catch (e) {
                this.log(e);
            }
            return this;
        },

        setTopTitle: function(txt) {
            this.$header.html(txt);
            return this;
        },

        setHTML: function(html) {
            this.$content.html(html);

            return this;
        },

        getHTML: function() {
            //这边手动加入evernote需要的evernote DOCTYPE
            var originHtml = this.$content.html(),
                index,
                html = '<!DOCTYPE en-note SYSTEM "http://xml.evernote.com/pub/enml2.dtd">',
                result;

            index = originHtml.indexOf('?>') + 2;
            result = originHtml.slice(0, index) + html + originHtml.slice(index);

            return result;
        },

        // This will show up in the XCode console as we are able to push this into an NSLog.
        log: function(log) {
          var iframe = document.createElement("IFRAME");
          iframe.setAttribute("src", "ios-log:#iOS#" + log);
          document.documentElement.appendChild(iframe);
          iframe.parentNode.removeChild(iframe);
          iframe = null;
        }
    };

    window.EReader = EReader;

})(jQuery, rangy);
