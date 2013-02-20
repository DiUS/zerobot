define([
    'backbone',
    'models/stack'
], function (Backbone, Stack) {
    return Backbone.Collection.extend({

        model: Stack,

        url: 'aws/stacks'

    });
});