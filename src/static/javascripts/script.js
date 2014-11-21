$(function() {
  var job_profession_group = $("select#ammattiryhma").asEventStream("change")
    .map('.target.value.toLowerCase');

  var area = $("select#alue").asEventStream("change")
    .map('.target.value.toLowerCase');

  var job_type = $("input.job-type").asEventStream("change")
    .map(function(event) {
      //'.target.value.toLowerCase'
      if ($(event.target).is(':checked')) {
        return event.target.value;
      } else {
        return '';
      }
    });

  var employer_suitable_for_specialization = $("input#koulutusterveyskeskus").asEventStream("change")
    .map(function(event) {
      if ($(event.target).is(':checked')) {
        return event.target.value;
      } else {
        return '';
      }
    });

  Bacon.combineTemplate({
    job_profession_group: job_profession_group.toProperty(null),
    area: area.toProperty(null),
    job_type: job_type.toProperty(),
    employer_suitable_for_specialization: employer_suitable_for_specialization.toProperty(null)
  }).onValue(function(value) {

    var selector = _.collect(value, function(value, key) {
      if (_.isEmpty(value)) {
        key = key.replace(/_/g, '-');

        var areaMatch = /^area$/;
        if (areaMatch.test(key)) {
          key = 'area-domain';
        }

        return ['[', [['data', key].join('-')].join(""), ']'].join('')
      } else {
        var domainMatch = /^domain\-/,
            districtsMatch = /^district\-/;

        key = key.replace(/_/g, '-');

        if (domainMatch.test(value)) {
          key = 'area-domain';
          value = value.replace('domain-', '');
        } else if (districtsMatch.test(value)) {
          key = 'area-district';
          value = value.replace('district-', '');
        }

        return ['[', [['data', key].join('-'), ['"',value,'"'].join('')].join("="), ']'].join('');
      }
    }).join('');

    $('li.result').hide();
    $('li.result').filter(selector).show();
  });
});

$(document).ready(function ()
{
  // Sub-menu enhancer
  $('#nav li:last-child').addClass('submenu');
  $('<a href="#" id="menutoggler"><i class="fa fa-bars"></i></a>').insertBefore('#sub-nav');
  $('#menutoggler').click(function() {
    $('#sub-nav').toggle();
    return false;
  });
  $(document).click(function() {
      $('#sub-nav').hide();
  });
  $('#sub-nav').click(function(e) {
      e.stopPropagation();
  });

  // Pop-up opener
  function popUp(winurl) {
	  window.open(winurl,'popup','width=660,height=550,scrollbars=1');
	}

	// Google Analytics event tracking for links excluding AddThis
	var gaLink = function()
	{
		var filetypes = /\.doc$|\.odt$|\.rtf$/i;
		$('a').not('.addthis_toolbox a').on('click', function(event)
		{
			var url = '';
			if ($(this).attr('href').match(/^mailto\:/i)) {
				url = $(this).attr('href').replace(/^mailto\:/i, "");
        ga('send', 'event', 'Links', 'Mailto', url);
			}
			else if ($(this).attr('href').match(/^tel\:/i)) {
				url = $(this).attr('href').replace(/^tel\:/i, "");
        ga('send', 'event', 'Links', 'Tel', url);
			}
			else if ($(this).hasClass('popup')) {
        event.preventDefault();
				url = $(this).attr('href').replace(/^http\:\/\/(www\.)*/i, "");
        ga('send', 'event', 'Links', 'Outgoing', url, {'hitCallback': popUp($(this).attr('href'))});
			}
			else if (location.host != this.host.replace(/\:80$/i, "") && $(!$(this).hasClass('popup'))) {
        event.preventDefault();
				url = $(this).attr('href').replace(/^http\:\/\/(www\.)*/i, "");
				var self = this;
        ga('send', 'event', 'Links', 'Outgoing', url, {'hitCallback': function(){window.location.href = $(self).attr('href');}});
			}
			else if ($(this).attr('href').match(/.+(\/rss\/).+/)) {
        url = $(this).attr('href').replace(/^http\:\/\/(www\.)*/i, "");
        ga('send', 'event', 'Links', 'RSS', url);
			}
			else if ($(this).attr('href').match(filetypes)) {
				var host = location.host.replace(/\./, "\\."), pattern = new RegExp('^(http\:\/\/)*(www\.)*(' + 'tkrekry.fi' + ')*\/', 'i');
				url = $(this).attr('href').replace(pattern, "");
        ga('send', 'event', 'Links', 'Downloads', url);
			}
		});
  }();

  // Google Analytics event tracking for printing: http://www.blastam.com/blog/index.php/2013/07/tracking-print-page-action-google-analytics/
  var gaPrint = function()
  {
    var afterPrint = function()
    {
      ga('send', 'event', 'Print', 'Intent', document.location.pathname);
    };
    if (window.matchMedia)
    {
      var mediaQueryList = window.matchMedia('print');
      mediaQueryList.addListener(function(mql)
      {
        if (!mql.matches)
        afterPrint();
      });
    }
    window.onafterprint = afterPrint;
  }();

  // AddThis used asynchronously
  function someButtons()
  {
    var addthis_config = {
      pubid: 'ra-533aa884077c525f',
      data_ga_property: 'UA-6571240-1',
      data_ga_social : true
    };

    function loadAddThis()
    {
      $('footer > div').append('<div class="addthis_toolbox addthis_default_style addthis_32x32_style"><a class="addthis_button_facebook"></a><a class="addthis_button_google_plusone_share"></a><a class="addthis_button_twitter"></a><a class="addthis_button_linkedin"></a><a class="addthis_button_email"></a></div>');
      addthis.init();
    }
    loadAddThis();
    addthis.toolbox('.addthis_toolbox');
  }
  someButtons();
});
