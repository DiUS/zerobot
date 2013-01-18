define([
    'views/modal-view',
    'collections/instances',
    'views/instance-view',
    'text!templates/instances.html.haml'
], function (ModalView, InstancesCollection, InstanceView, template) {
    return ModalView.extend({
        template: template,

        events: {
            'click .cancel': 'hide'
        },

        serialize : function() {
            return {
                random: this.random
            };
        },

        postRender: function () {
            this.$el.removeClass('loading');
            this.collection.each(function (instance) {
                if (instance.status !== 'terminated') {
                    var view = new InstanceView({model: instance}).render();
                    this.$('.table').append(view.el);
                }
            }, this);
        }
    });
});