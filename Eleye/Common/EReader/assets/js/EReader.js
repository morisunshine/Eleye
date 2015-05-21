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

        bindEvents: function () {
            $(window).on('touchend', function(e) {
                 if (!this.isDragging) {
                    window.location = "EReader-callback/"   ;    
                 }
             });

            $(window).on('touchstart', function(e) {
                 this.isDragging = false;
            });

            $(window).on('touchmove', function(e) {
                 this.isDragging = true;
                 // zss_editor.updateScrollOffset = true;
                 // zss_editor.setScrollPosition();
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
            return $el.hasClass(MY_GLOBAL.HILITE_COLOR);
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
            return this.$content.html();
        },

        // This will show up in the XCode console as we are able to push this into an NSLog.
        log: function(msg) {
            window.location = 'debug://'+msg;
        }
    };

    window.EReader = EReader;

})(jQuery, rangy);
