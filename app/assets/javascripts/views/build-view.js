define([
    'backbone',
    'models/last-failed',
    'text!templates/build.html.haml',
    'libs/bootstrap'
], function (Backbone, LastFailed, template) {

    return Backbone.SuperView.extend({

        className: 'build',

        template: template,

        renderSpinner: function () {
            if (this.model.get('color').indexOf('anim') !== -1) {
                this.$('.loading').removeClass('off');
            } else {
                this.$('.loading').addClass('off');
            }
        },

        update: function (model) {
            this.model = model;
            if (this.$('.build-' + this.model.get('color')).length === 0) {
                this.$('.build-button')
                    .removeClass('build-blue build-blue_anime build-red build-red_anime build-grey build-grey_anime')
                    .addClass('build-' + model.get('color'));
            }

            if (this.model.isCurrentlyFailing()) {
                var lastFailed = new LastFailed({displayName: this.model.get('displayName')});

                lastFailed.on('change', function () {
                    var theBreaker = lastFailed.theBreaker();
                    if (theBreaker === '') {
                        var message = 'Not sure who did it';
                    } else {
                        var message = 'Chase down: ' + theBreaker;    
                    }
                    
                    this.$('.build-' + this.model.get('color') + ' a').attr({
                        'data-title': 'Broken Build',
                        'data-content': message
                    }).popover({
                        trigger: 'hover'
                    });
                }, this);

                lastFailed.fetch();
            } else {
                this.$('.build-' + this.model.get('color') + ' a').removeAttr('data-title').removeAttr('data-content');
            }

            this.renderSpinner();
        }
    });
});