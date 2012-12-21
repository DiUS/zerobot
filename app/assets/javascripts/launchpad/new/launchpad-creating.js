(function () {
    var getProject = function (id, callback) {
        var xhr = new XMLHttpRequest();
        xhr.open('GET', '/projects/' + id, true);
        xhr.setRequestHeader('Content-type', 'application/json');

        xhr.onreadystatechange = function () {
            if (xhr.readyState === 4) {
                if (xhr.status === 200) {
                    callback(JSON.parse(xhr.responseText));
                } else {
                    document.querySelector('.complete').innerHTML = 'There was an issue, please refresh your browser';
                }
            }
        };

        xhr.send();
    };

    var infiniteChecking = function (id) {
        getProject(id, function (response) {
            if (response.status === 'CREATE_COMPLETE') {
                document.querySelector('.complete').innerHTML = 'done!!';
                return;
            }

            setTimeout(function () {
                infiniteChecking(id);
            }, 30000);
        });
    };

    window.onload = function () {
        infiniteChecking(projectId); // projectId is global
    };
})();