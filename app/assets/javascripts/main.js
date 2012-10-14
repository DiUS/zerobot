require.config({
    baseUrl: 'assets',
    paths: {
        jquery: 'libs/jquery-1.7.2',
        underscore: 'libs/underscore',
        backbone: 'libs/backbone',
        'underscore.string': 'libs/underscore.string',
        text: 'libs/text',
        templates: 'templates'
    },

    shim: {
        "backbone": {
            deps: ["underscore", "jquery"],
            exports: "Backbone"
        },

        'underscore': {
            exports: '_'
        },

        'underscore.string': {
              deps: ["underscore"],
              exports: '_.string'
        },

        'libs/bootstrap': ["jquery"],

        'libs/jquery.cookie': ["jquery"],

        'libs/jquery.countdown': ["jquery"],

        'libs/jquery.githubRepoWidget': ["jquery"],

        'libs/base': ['backbone']
    }
});

require([
    'underscore',
    'underscore.string'], function(_, _string) {
        _.mixin(_string.exports());
});

require([
  'jquery',
  'backbone',
  'routers/app-router',
  'libs/base',
  'libs/bootstrap',
  'libs/haml',
  'libs/jquery.cookie',
  'libs/jquery.countdown',
  'libs/jquery.githubRepoWidget',
  'libs/moment'
], function($, Backbone, AppRouter) {
    $(function() {
        router = new AppRouter();
        Backbone.history.start();
    });
});