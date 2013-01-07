$(document).ready(function () {

    $('#create-another-link').live('click', function () {
        $.removeCookie('project_data');
        $.removeCookie('project_id');
        $.removeCookie('project_token');
        window.refresh();
    });

    var getSuccess = function(response) {
        if (response.status === 'CREATE_COMPLETE') {
            $('#loading-image').remove();
            $('#please-wait').remove();
            $('#waiting .page-container h1').text('Your environment is ready for action');
            $('#waiting .page-container').append('<h2><a href="' + response.output.value + '" target="_blank">' + response.output.value + '</a></h2>');
            $('#waiting .page-container').append('<p>Done with this environment? <a id="create-another-link" href="">Create another</a></p>');
            return;
        } else {
          setTimeout(function () {
            $.ajax({
              type: 'GET',
              url: '/projects/' + response.id,
              contentType: "application/json",
              success: getSuccess
            });
         }, 50000);
        }
    };

    var inifiniteCheck = function (projectId) {
        $.ajax({
            type: 'GET',
            url: '/projects/' + projectId,
            contentType: "application/json",
            success:  getSuccess
        });

        $('#please-wait').append('<div id="loading-image"><img src="/assets/ajax-loading.gif" alt="Loading..." /></div>');
    };

    if ($.cookie('project_id') !== null) {
        // show to last step
        $('#page1').addClass('hidden');
        $('#waiting').removeClass('hidden');
        inifiniteCheck($.cookie('project_id'));

        var data = JSON.parse($.cookie('project_data'));

        return;
    }

    $.scrollingWizard({
        steps: [{
            id: '#page1',
            validation: function () {
                var text = $('#application-name option:selected').text();

                if (text === '') {
                    return null;
                }

                $('b.url').html(text);

                $('#summary-application-name').text(text);

                $.cookie('project_token', $('#application-token').val(), {path: '/', expires: 365});
                return text;
            },
            focus: function () {
                $('#application-name').focus();
            }
        },
        {
            id: '#aws-details',
            validation: function () {

                var accessKey = $('#aws-access-key-id').val();
                var secretKey = $('#aws-secret-access-key').val();
                var privateKey = $('#aws-private-key').val();

                if (accessKey === '' || secretKey === '' || privateKey === '') {
                  return null;
                }
                $('#summary-aws-account').text(accessKey + ' ' + secretKey + ' ' + privateKey);
                return true;
            }
        },
        {
            id: '#summary',
            validation: function () {
                return true;
            },
            finish: true
        },{
            id: '#waiting',
            validation: function () {
                return true;
            }
        },{
            id: '#region',
            validation: function () {
                $('#summary-aws-region').text($('#aws-region').val());
                return $('#aws-region').val();
            }
        }],
        finished: function () {
            if ($.cookie('project_id') !== null) {
                return;
            }

            var applicationName = $('#application-name option:selected').text();
            var applicationUrl = $('#application-name option:selected').val();
            var data = {project: {
                name: applicationName,
                url: applicationUrl,
                token: $('#application-token').val(),
                github_account: $('#github-account').val(),
                github_project: applicationName,
                region: $('#aws-region').val(),
                aws_access_key: $("#aws-access-key-id").val(),
                aws_secret_access_key: $("#aws-secret-access-key").val(),
                aws_key_name: $("#aws-private-key").val()
            }};

            $.cookie('project_data', JSON.stringify(data), {expires: 365});

            var postSuccess = function(response) {
                $.cookie('project_id', response.id, {expires: 365});
                inifiniteCheck(response.id);
            };

            $.ajax({
                type: 'POST',
                url: '/projects',
                contentType: "application/json",
                data: JSON.stringify(data),
               success: postSuccess
            });
        }
    });
});
