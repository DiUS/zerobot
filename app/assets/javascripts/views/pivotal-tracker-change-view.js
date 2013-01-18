define([
    'views/modal-view',
    'text!templates/pivotal-tracker-change.html.haml'
], function (ModalView, template) {
    return ModalView.extend({
        template: template,

        events: {
            'click .change': 'change',
            'click .cancel': 'hide'
        },

        initialize: function (options) {
            options.model.on('destroy', function () {
                this.hide();
            }, this);
        },

        change: function () {
            this.options.model.destroy();
            return false;
        }
    });
});