$(function() {
    $.expr[":"].contains = $.expr.createPseudo(function(arg) {
        return function(elem) {
            return $(elem).text().toUpperCase().indexOf(arg.toUpperCase()) >= 0;
        };
    });

    $("input#search")
        .asEventStream("keyup")
        .map('.target.value.toLowerCase').onValue(function(value) {
            $("ul#employer-list li h2:not(:contains(" + value + "))").parent().parent().hide();
            $("ul#employer-list li h2:contains(" + value + ")").parent().parent().show();
        });
});
