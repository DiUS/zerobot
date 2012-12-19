(function () {
    var querySelectorAll = function (selector) {
        return Array.prototype.slice.call(document.querySelectorAll(selector), 0);
    };

    var clearHelp = function () {
        var helpPopovers = querySelectorAll('.input-help small');
        helpPopovers.forEach(function (helpPopover) {
            helpPopover.classList.remove('show');
        });
    };

    var handleHelpIconClick = function (event) {
        clearHelp();
        if (event.target.classList.contains('icon-question-sign')) {
            event.preventDefault();
            event.target.parentElement.querySelector('small').classList.add('show');
        }
    };

    document.ontouchstart = handleHelpIconClick;
    document.onclick = handleHelpIconClick;
})();