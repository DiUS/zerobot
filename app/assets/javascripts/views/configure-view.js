define([
    'backbone',
    'collections/available',
    'collections/instances',
    'collections/cloudformation',
    'views/widget-view',
    'views/environment-view',
    'text!templates/environments.html.haml'
], function (Backbone, AvailableCollection, InstancesCollection, CloudFormationCollection, WidgetView, EnvironmentView, template) {
    return Backbone.SuperView.extend({

        className: 'environments',

        events: {
            'click #refresh-environments': 'refreshEnvironments'
        },

        regions: {
            'us-east-1': 'US East (Virginia)',
            'us-west-1': 'US West (North California)',
            'us-west-2': 'US West (Oregon)',
            'eu-west-1': 'EU West (Ireland)',
            'ap-southeast-1': 'Asia Pacific (Singapore)',
            'ap-southeast-2': 'Asia Pacific (Sydney)',
            'ap-northeast-1': 'Asia Pacific (Tokyo)',
            'sa-east-1': 'South Amercia (Sao Paulo)'
        },

        views: [],

        initialize: function () {
            this.views = [];
            this.availableCollection = new AvailableCollection();
            this.collection = new InstancesCollection();
            this.stasks = new CloudFormationCollection()

            this.bindTo(this.availableCollection, 'reset', function () {
                this.$('.message').remove();
                this.renderAvailableEnvironments();
                var view = this;
                setTimeout( function () {
                    view.collection.fetch();
                }, 100);
            });

            this.bindTo(this.collection, 'reset', function () {
                this.renderEnvironments();
            });
        },

        refreshEnvironments: function () {
            location.reload();
            return false;
        },

        postRender: function () {
            var view = new WidgetView({
                 heading: 'Environments - ' + this.regions[awsRegion],
                 contentId: 'environments-widget'
            }).render();
            view.appendTemplate(template);
            view.$('.widget-content').addClass('row');
            view.$('.widget-header h3').append('<div class="widget-toolbar"><a id="refresh-environments" class="btn configure-newrelic-btn" href="#"><i class="icon-refresh"/></a></div>');
            this.renderEnvironments();
            this.$el.html(view.el);
        },

        renderAvailableEnvironments: function () {
            this.availableCollection.each(function (availableEnvironment) {
                this.renderAvailableEnvironment(availableEnvironment);
            }, this);
        },

        renderEnvironments: function () {

            this.collection.each(function (environment) {
                this.bindEnvironment(environment);
            }, this);

            _(this.views).each(function (view) {
                if (view.model.has('name')) { // needs to be created?
                    view.renderCreateEnvironment().fadeIn();
                } else {
                    view.renderEnvironment().fadeIn();
                }
            }, this);
        },

        renderAvailableEnvironment: function (availableEnvironment) {
            var view = new EnvironmentView({model: availableEnvironment}).render();
            this.$('.widget-content .content').append(view.el);
            this.views.push(view);
        },

        bindEnvironment: function (environment) {
            if (environment.get('status') === 'terminated') {
                return;
            }

            var view = _(this.views).find(function (environmentView) {
                if (environmentView.model.has('name')) {
                    return environmentView.model.get('name') === this.envNameFrom(environment.get('tags')['dupondius:environment']);
                } else {
                    return this.envNameFrom(environmentView.model.get('tags')['dupondius:environment']) === this.envNameFrom(environment.get('tags')['dupondius:environment']);
                }
            }, this);

            if (view === undefined) {
                return; // foreign instance that we dont care about
            }

            if (view.model.has('name')) {
                view.availableModel = view.model;
                view.model = environment;
                view.getStack();
            }

            if (view.instancesCollection === undefined) {
                view.instancesCollection = new InstancesCollection();
            }

            view.instancesCollection.push(environment);
        },

        envNameFrom: function (name) {
            var returned = name;
            if (_(name).startsWith('dev')) {
                returned = name.replace(/(dev)-.*/, '$1');
            }

            return returned;
        },

        destroy: function () {
            _(this.views).each(function (view) {
                view.destroy();
            }, this);
            Backbone.SuperView.prototype.destroy.call(this);
        }
    });
});
