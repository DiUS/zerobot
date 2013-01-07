define([
    'backbone',
    'models/iteration',
    'views/widget-view',
    'views/pivotal-tracker-help-view',
    'views/pivotal-tracker-change-view',
    'text!templates/configure-pivotal.html.haml'
], function (Backbone, Iteration, WidgetView, PivotalTrackerHelpView, PivotalTrackerChangeView, configurePivotalTemplate) {
    return Backbone.SuperView.extend({

        id: 'stories',

        events: {
            'click button.btn': 'configurePivotalTracker',
            'click #reset-pivotal-tracker': 'changePivotalTracker',
            'click .help': 'help'
        },

        initialize: function (options) {
            this.model = new Iteration();
            this.model.on('change', function () {
                this.render();
            }, this);
        },

        postRender: function () {
            if (this.model.has('stories')) {
                this.renderBurnDownChart();
            } else {
                this.renderConfigurePivotalTracker();
            }
        },

        renderBurnDownChart: function () {
            var view = new WidgetView({
                 heading: 'Burn Down Chart - ',
                 contentId: 'burn-down-widget'
            }).render();
            this.$el.html(view.el);
            this.renderLineGraph(view);
            this.$('.widget-header h3').append(this.make('a', {'href': 'https://www.pivotaltracker.com/projects/' + this.model.get('stories')[0].project_id, 'target': '_blank'}, 'Pivotal Tracker'));
            this.$('.widget-header h3').append('<div class="widget-toolbar"><a id="reset-pivotal-tracker" class="btn configure-newrelic-btn" href="#" rel="tooltip" title="Configuration"><i class="icon-cog"/></a></div>');
        },

        renderConfigurePivotalTracker: function () {
            var view = new WidgetView({
               heading: 'Pivotal Tracker',
               contentId: 'configure-pivotal-tracker-widget'
            }).render();

            if (this.model.has('not_configured')) {
                view.appendTemplate(configurePivotalTemplate);
            }

            this.$el.html(view.el);
        },

        changePivotalTracker: function () {
            var view = new PivotalTrackerChangeView({model: this.model}).render();
            view.$el.removeClass('loading');
            this.$el.append(view.el);
            view.show();

            view.model.on('destroy', function () {
                window.location.reload();
            }, this);
            return false;
        },

        help: function () {
            var view = new PivotalTrackerHelpView().render();
            this.$el.append(view.el);
            view.show();
            return false;
        },

        configurePivotalTracker: function () {
            var token = this.$('#pivotal-tracker-token').val();
            var projectId = this.$('#pivotal-tracker-project').val();

            this.model.on('error', function (model, errors) {
                _(errors).each(function (error) {
                    this.$('#' + error.name).addClass('error');
                    this.$('#' + error.name + ' .help-inline').text(error.message);
                }, this);
            }, this);

            this.$('.control-group').removeClass('error');
            this.$('.help-inline').empty();

            this.model.save({
                not_configured: undefined,
                token: token,
                project_id: projectId
            });

            return false;
        },

        renderLineGraph: function (view) {
            view.empty();
            renderLineGraph({
                elementId: view.options.contentId,
                labels: this.model.burnDownDates(),
                values: this.model.burnDownValues(),
                width: Math.min(this.$el.width(), 900),
                height: 250
            });
        }
    });
});