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
            this._initHighlighter();
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
                console.log(e);
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
                console.log(e);
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
        }
    };

    window.EReader = EReader;

})(jQuery, rangy);
