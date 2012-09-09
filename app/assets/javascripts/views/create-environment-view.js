define([
    'views/modal-view',
    'models/stack',
    'models/stack-template',
    'text!templates/create-environment-form-field.html.haml',
    'text!templates/create-environment-form.html.haml'
], function (ModalView, Stack, StackTemplate, formFieldTemplate, template) {
    return ModalView.extend({
        template: template,

        events: {
            'click .cancel': 'hide',
            'click .confirm': 'confirm'
        },

        initialize: function (options) {
            ModalView.prototype.initialize.call(this);

            this.model = new Stack({random: this.random});
            this.bindTo(this.model, 'change', function () {
                this.populateForm();
            });

            this.stackTemplate = new StackTemplate();
            this.bindTo(this.stackTemplate, 'change', function () {
                this.renderFormFromTemplate();
            });
            this.stackTemplate.fetch();
        },

        renderFormFromTemplate: function () {
            _(this.stackTemplate.get('parameters')).each(function (parameter) {
                var formField = haml.compileHaml({source: formFieldTemplate})(parameter);
                this.$('.form-horizontal').append(formField);
            }, this);

            if (this.model.isNew()) {
                this.fadeIn();
                this.$('#EnvironmentName').val(this.options.name);
            }
        },

        fadeIn: function () {
            this.$('#loading-fields-' + this.random).fadeOut();
            this.$('.form-horizontal').css('visibility', 'visible').fadeIn();
        },

        populateForm: function () {
            _(this.model.get('parameters')).each(function (value, key) {
                this.$('#' + key).val(value);
            }, this);  

            this.fadeIn();
        },

        confirm: function () {
            var attrs = {};
            _(this.stackTemplate.get('parameters')).each(function (parameter) {
                attrs[parameter.parameter_key] = this.$('#'+ parameter.parameter_key).val();
            }, this);

            this.model.save(attrs);
            return false;
        }
    });
});