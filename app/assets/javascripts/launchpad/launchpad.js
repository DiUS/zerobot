$(document).ready(function () {

    $('#create-another-link').live('click', function () {
        $.removeCookie('project_data');
        $.removeCookie('project_id');
        $.removeCookie('project_token');
        window.refresh();
    });

    var getSuccess = function(response) {
        if (response.status === 'running') {
            $('#loading-image').remove();
            $('#please-wait').remove();
            $('#waiting .page-container h1').text('Your environment is ready for action');
            $('#waiting .page-container').append('<h2><a href="' + response.output.value + '" target="_blank">' + response.output.value + '</a></h2>');
            $('#waiting .page-container').append('<p>Link broken? You may have to wait a few moments while your Zerobot domain is being registered.</p>');
            $('#waiting .page-container').append('<p>Done with this environment? <a id="create-another-link" href="">Create another</a></p>');
            return;
        } else if (response.status === 'ROLLBACK_COMPLETE' || response.status === 'CREATE_FAILED') {
            $('#loading-image').remove();
            $('#please-wait').remove();
            $('#waiting .page-container h1').text('Your environment failed to be created');
            $('#waiting .page-container').append('<p>There was an issue creating your environment.</p>');
            $('#waiting .page-container').append('<p>Please ensure that the AWS credentials you have provided are correct.</p>');
            $('#waiting .page-container').append('<p>If you believe the AWS credentials given are correct, please log into the <a target="_blank" href="https://console.aws.amazon.com/cloudformation/home">AWS Management Console</a> to investigate further.</p>');
            $('#waiting .page-container').append('<p>When you are confident that you can attempt to create your environments again, <a id="create-another-link" href="">click here</a>.</p>');
        } else {
          setTimeout(function () {
            $.ajax({
              type: 'GET',
              url: '/projects/' + response.id,
              contentType: "application/json",
              success: getSuccess
            });
         }, 30000);
        }
    };

    var inifiniteCheck = function (projectId) {
        $.ajax({
            type: 'GET',
            url: '/projects/' + projectId,
            contentType: "application/json",
            success:  getSuccess
        });
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
            id: '#correspondence',
            validation: function () {
                return true;
            },
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
                github_project: $('#application-name option:selected').attr('data-name'),
                accept_correspondence: $('#accept-correspondence:checked').val()? true : false
            }};

            $.cookie('project_data', JSON.stringify(data), {expires: 365});

            var postSuccess = function(response) {
                $.cookie('project_id', response.id, {expires: 365});
                inifiniteCheck(response.id);
            };

            var postError = function(xhr, responseText) {
                $('#loading-image').remove();
                $('#please-wait').remove();
                $('#waiting .page-container h1').text('Your environment failed to be created');
                $('#waiting .page-container').append('<p>There was an issue creating your environment.</p>');
                $('#waiting .page-container').append('<p>' + xhr.responseText + '</p>');
                $('#waiting .page-container').append('<p>When you are confident that you can attempt to create your environments again, <a id="create-another-link" href="">click here</a>.</p>');
            };

            $('#please-wait').append('<div id="loading-image"><img src="/assets/ajax-loading.gif" alt="Loading..." /></div>');

            $.ajax({
                type: 'POST',
                url: '/projects',
                contentType: "application/json",
                data: JSON.stringify(data),
                success: postSuccess ,
                error: postError
            });
        }
    });
});
