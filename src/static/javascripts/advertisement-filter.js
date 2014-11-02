$(function() {

    var job_profession_group = $("select#ammattiryhma").asEventStream("change")
        .map('.target.value.toLowerCase');

    var area = $("select#alue").asEventStream("change")
        .map('.target.value.toLowerCase');

    var append_selected_type = function(seed, changed) {
        return _.uniq((changed[0] ? seed.concat(changed[1]) : _.without(seed, changed[1])));
    };

    var job_type_seed = ["lyhyt-sijaisuus", "pitka-sijaisuus", "vakituinen", "paivystys", "amanuenssi"];

    var job_type = $("input.job-type").asEventStream("change")
        .map(function(event) {
            return [$(event.target).is(':checked'), event.target.value];
        })
        .scan(job_type_seed, append_selected_type);


    var employer_suitable_for_specialization = $("input#koulutusterveyskeskus").asEventStream("change")
        .map(function(event) {
            console.log("EVENT: ", event);
            if ($(event.target).is(':checked')) {
                return event.target.value;
            } else {
                return '';
            }
        });

    Bacon.combineTemplate({
        job_profession_group: job_profession_group.toProperty(null),
        area: area.toProperty(null),
        employer_suitable_for_specialization: employer_suitable_for_specialization.toProperty(null),
        job_type: job_type,
    }).onValue(function(value) {
        var selector = _.uniq(_.compact(_.collect(value, function(value, key) {
            if (value) {
                key = key.replace(/_/gi, '-');
                if (_.isArray(value)) {
                    return _.map(value, function(element) {
                        return [key, element].join('-');
                    });
                } else {
                    return [key, value].join('-');
                }
            }
        })));

        var pre_filter = selector.pop();
        selector = selector.length == 0 ? ['result'] : selector;
        var query_filter = _.map(pre_filter, function(pre_elem) {
            return ['li', selector.join('.'), pre_elem].join('.');
        }).join(' ,');
        $('li.result').hide();
        var selected_elements = $(query_filter);
        selected_elements.show();
        $('span.number-of-advertisement').text( " - "+selected_elements.length);
    });
});
