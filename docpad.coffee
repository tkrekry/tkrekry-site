process.setMaxListeners(0)
path = require('path')
_ = require('lodash')

moment = require('moment-timezone')
moment.locale('fi')

# DocPad Configuration
docpadConfig = {

  # =================================
  # Paths Configuration

  # Root Path
  # The root path of our our project
  rootPath: process.cwd()  # default

  # Plugins Paths
  # An array of paths which to load multiple plugins from
  pluginsPaths: [  # default
    'plugins',
    'node_modules'
  ]

  databaseCache: false

  watchOptions: preferredMethods: ['watchFile','watch']

  # Regenerate Delay
  # The time (in milliseconds) to wait after a source file has
  # changed before using it to regenerate. Updating over the
  # network (e.g. via FTP) can cause a page to be partially
  # rendered as the page is regenerated *before* the source file
  # has completed updating: in this case increase this value.
  regenerateDelay: 10    # default

  # Out Path
  # Where should we put our generated website files?
  # If it is a relative path, it will have the resolved `rootPath` prepended to it
  outPath: 'out'  # default

  # Src Path
  # Where can we find our source website files?
  # If it is a relative path, it will have the resolved `rootPath` prepended to it
  srcPath: 'src'  # default

  # Documents Paths
  # An array of paths which contents will be treated as documents
  # If it is a relative path, it will have the resolved `srcPath` prepended to it
  documentsPaths: [  # default
    'documents'
  ]

  # Files Paths
  # An array of paths which contents will be treated as files
  # If it is a relative path, it will have the resolved `srcPath` prepended to it
  filesPaths: [  # default
    'static'
  ]

  # Layouts Paths
  # An array of paths which contents will be treated as layouts
  # If it is a relative path, it will have the resolved `srcPath` prepended to it
  layoutsPaths: [  # default
    'layouts'
  ]

  # =================================
  # Server Configuration

  # Port
  # Use to change the port that DocPad listens to
  # By default we will detect the appropriate port number for our environment
  # if no environment port number is detected we will use 9778 as the port number
  # Checked environment variables are:
  # - PORT - Heroku, Nodejitsu, Custom
  # - VCAP_APP_PORT - AppFog
  # - VMC_APP_PORT - CloudFoundry
  port: process.env.PORT || 8888  # default

  # Max Age
  # The default caching time limit that is sent with the response to the client
  # Can be set to `false` to disable caching
  maxAge: false

  # =================================
  # Logging Configuration

  # Log Level
  # Up to which level of logging should we output
  logLevel: (if ('-d' in process.argv) then 7 else 6)  # default

  # Logger
  #  The caterpillar instance that we want to use
  # If not set, we will create our own
  logger: null  # default

  # Catch Exceptions
  # Whether or not DocPad should catch uncaught exceptions
  catchExceptions: false  # default

  # Report Errors
  # Whether or not we should report errors back to the DocPad Team
  reportErrors: process.argv.join('').indexOf('test') is -1  # default (don't enable if we are running inside a test)

  # Report Statistics
  # Whether or not we should report statistics back to the DocPad Team
  reportStatistics: process.argv.join('').indexOf('test') is -1  # default (don't enable if we are running inside a test)

  # Airbrake Token
  # The airbrake token we should use for reporting errors
  # By default, uses the DocPad Team's token
  airbrakeToken: null  # default

  # MixPanel Token
  # The mixpanel token we should use for reporting statistics
  # By default, uses the DocPad Team's token
  mixpanelToken: null  # default

  # =================================
  # Other Configuration

  # Render Passes
  # How many times should we render documents that reference other documents?
  renderPasses: 1  # default

  # Helper Url
  # Used for subscribing to newsletter, account information, and statistics etc
  helperUrl: 'https://docpad.org/helper/'  # default

  # Collections
  # A hash of functions that create collections
  collections: {

  }

  # Regenerate Every
  # Performs a regenerate every x milliseconds, useful for always having the latest data
  regenerateEvery: 2 * 60 * 1000  # default

  # =================================
  # Template Configuration

  # Template Data
  # Use to define your own template data and helpers that will be accessible to your templates
  # Complete listing of default values can be found here: http://docpad.org/docs/template-data
  templateData:  # example
    formatDate: (date, format='LLLL') -> return moment(date).tz('Europe/Helsinki').format(format)
    locale:
      fi:
        _name: "Suomi"
        _param: "fi_FI"
        nav:
         home: "Etusivu"
        meta:
         description: "Meta kuvaus suomeksi"
      sv:
        _name: "Ruotsi"
        _param: "sv_FI"
        nav:
          home: "Hemma"
        meta:
          description: "Meta på svenska"

    # Specify some site properties
    site:
      # The production url of our website
      url: (process.env.SITE_URL||"http://www.tkrekry.fi")

      # The production admin url
      admin_url: process.env.ADMIN_URL||"http://admin.beta.tkrekry.fi"

      # The default title of our website
      title: "TKrekry"

      # The website description (for SEO)
      description: """
      """

      # The website keywords (for SEO) separated by commas
      keywords: """
      """

      getUrl: (document) ->
        return @site.url + (document.url or document.get?('url'))

      domains: [
        {
          name: "Tampereen yliopistollisen sairaalan erityisvastuualue",
          short_name: "Tays ERVA"
          id: "tays-erva"
        }
        {
          name: "Helsingin ja Uudenmaan sairaanhoitopiirin erityisvastuualue",
          short_name: "HYKS ERVA"
          id: "hyks-erva"
        }
        {
          name: "Kuopion yliopistollisen sairaalan erityisvastuualue",
          short_name: "Kys ERVA"
          id: "kys-erva"
        }
        {
          name: "Oulun yliopistollisen sairaalan erityisvastuualue",
          short_name: "Oys ERVA"
          id: "oys-erva"
        }
        {
          name: "Turun yliopistollisen sairaalan erityisvastuualue",
          short_name: "Tyks ERVA"
          id: "tyks-erva"
        }
      ]

      districts: [
        {
          domain_id: "hyks-erva",
          name: "Etelä-Karjalan sosiaali- ja terveyspiiri",
          short_name: "EKSOTE",
          id: "etela-karjalan-sosiaali-ja-terveyspiiri"
        }
        {
          domain_id: "tays-erva",
          name: "Etelä-Pohjanmaan sairaanhoitopiiri",
          short_name: "EPSHP",
          id: "etela-pohjanmaan-sairaanhoitopiiri"
        }
        {
          domain_id: "kys-erva",
          name: "Etelä-Savon sairaanhoitopiiri",
          short_name: "ESSHP",
          id: "etela-savon-sairaanhoitopiiri"
        }
        {
          domain_id: "hyks-erva",
          name: "Helsingin ja Uudenmaan sairaanhoitopiiri",
          short_name: "HUS",
          id: "helsingin-ja-uudenmaan-sairaanhoitopiiri"
        }
        {
          domain_id: "kys-erva",
          name: "Itä-Savon sairaanhoitopiiri",
          short_name: "ISSHP",
          id: "ita-savon-sairaanhoitopiiri"
        }
        {
          domain_id: "oys-erva",
          name: "Kainuun sairaanhoitopiiri",
          short_name: "Kainuun sairaanhoitopiiri",
          id: "kainuun-sairaanhoitopiiri"
        }
        {
          domain_id: "tays-erva",
          name: "Kanta-Hämeen sairaanhoitopiiri",
          short_name: "KHSHP",
          id: "kanta-hameen-sairaanhoitopiiri"
        }
        {
          domain_id: "oys-erva",
          name: "Keski-Pohjanmaan erikoissairaanhoito- ja peruspalvelukuntayhtymä",
          short_name: "Keski-Pohjanmaan erikoissairaanhoito- ja peruspalv",
          id: "keski-pohjanmaan-erikoissairaanhoito-ja-peruspalvelukuntayhtyma"
        }
        {
          domain_id: "kys-erva",
          name: "Keski-Suomen sairaanhoitopiiri",
          short_name: "KSSHP",
          id: "keski-suomen-sairaanhoitopiiri"
        }
        {
          domain_id: "hyks-erva",
          name: "Kymenlaakson sairaanhoitopiiri",
          short_name: "KYMSHP",
          id: "kymenlaakson-sairaanhoitopiiri"
        }
        {
          domain_id: "oys-erva",
          name: "Länsi-Pohjan sairaanhoitopiiri",
          short_name: "Länsi-Pohjan sairaanhoitopiiri",
          id: "lansi-pohjan-sairaanhoitopiiri"
        }
        {
          domain_id: "oys-erva",
          name: "Lapin sairaanhoitopiiri",
          short_name: "Lapin sairaanhoitopiiri",
          id: "lapin-sairaanhoitopiiri"
        }
        {
          domain_id: "tays-erva",
          name: "Pirkanmaan sairaanhoitopiiri",
          short_name: "PSHP",
          id: "pirkanmaan-sairaanhoitopiiri"
        }
        {
          domain_id: "tays-erva",
          name: "Päijät-Hämeen sairaanhoitopiiiri",
          short_name: "PHSHP",
          id: "paijat-hameen-sairaanhoitopiiiri"
        }
        {
          domain_id: "kys-erva",
          name: "Pohjois-Karjalan sairaanhoito- ja sosiaalipalvelujen kuntayhtymä",
          short_name: "PKSSK",
          id: "pohjois-karjalan-sairaanhoito-ja-sosiaalipalvelujen-kuntayhtyma"
        }
        {
          domain_id: "oys-erva",
          name: "Pohjois-Pohjanmaan sairaanhoitopiiri",
          short_name: "Pohjois-Pohjanmaan sairaanhoitopiiri",
          id: "pohjois-pohjanmaan-sairaanhoitopiiri"
        }
        {
          domain_id: "kys-erva",
          name: "Pohjois-Savon sairaanhoitopiiri",
          short_name: "PSSHP",
          id: "pohjois-savon-sairaanhoitopiiri"
        }
        {
          domain_id: "tyks-erva",
          name: "Satakunnan sairaanhoitopiiri",
          short_name: "Satakunnan sairaanhoitopiiri",
          id: "satakunnan-sairaanhoitopiiri"
        }
        {
          domain_id: "tyks-erva",
          name: "Vaasan sairaanhoitopiiri",
          short_name: "VSHP",
          id: "vaasan-sairaanhoitopiiri"
        }
        {
          domain_id: "tyks-erva",
          name: "Varsinais-Suomen sairaanhoitopiiri",
          short_name: "Varsinais-Suomen sairaanhoitopiiri",
          id: "varsinais-suomen-sairaanhoitopiiri"
        }
      ]

    # -----------------------------
    # Helper Functions

    getDomains: ()->
      @site.domains

    getDistrictsForDomain: (domain_id)->
      _.select(@site.districts, {domain_id: domain_id})

    # Get the prepared site/document title
    # Often we would like to specify particular formatting to our page's title
    # we can apply that formatting here
    getPreparedTitle: ->
      # if we have a document title, then we should use that and suffix the site's title onto it
      if @document.title
        "#{@site.title} - #{@document.title}"
      # if our document does not have it's own title, then we should just use the site's title
      else
        @site.title

    # Get the prepared site/document description
    getPreparedDescription: ->
        # if we have a document description, then we should use that, otherwise use the site's description
        @document.description or @site.description

    # Get the prepared site/document keywords
    getPreparedKeywords: ->
      # Merge the document keywords with the site keywords
      @site.keywords.concat(@document.keywords or []).join(', ')


  # =================================
  # Plugin Configuration

  # Skip Unsupported Plugins
  # Set to `false` to load all plugins whether or not they are compatible with our DocPad version or not
  skipUnsupportedPlugins: false  # default

  # Enable Unlisted Plugins
  # Set to false to only enable plugins that have been explicity set to `true` inside `enabledPlugins`
  enabledUnlistedPlugins: true  # default

  enabledPlugins:
    rss: true
    tkrekry: true
    sunny: true
    sitemap: true

  plugins:
    rss:
      default:
        collection: 'advertisements_fi'
        url: '/rss.xml'

    moment:
      formats: [
        {raw: 'created_at', format: 'MMMM Do YYYY', formatted: 'humanDate'}
        {raw: 'date', format: 'YYYY-MM-DD', formatted: 'computerDate'}
      ]

    sitemap:
      cachetime: 600
      changefreq: 'hourly'
      priority: 0.5
      filePath: 'sitemap.xml'

    tkrekry:
      apiUrl: process.env.API_URL || "http://admin.beta.tkrekry.fi"
      extension: '.html.jade'
      injectDocumentHelperEmployer:
        fi: (document) ->
          document.setMeta({
            layout: 'fi',
            lang: 'fi',
            data: """
                != partial('health_center_fi', document.tkrekry)
                """
          })
        sv: (document) ->
          document.setMeta({
            layout: 'sv',
            lang: 'sv',
            data: """
                != partial('health_center_sv', document.tkrekry)
                """
          })
      injectDocumentHelperAdvertisement:
        fi: (document) ->
          document.setMeta({
            layout: 'fi',
            lang: 'fi',
            data: """
                != partial('advertisement_fi', document.tkrekry)
                """
          })
        sv: (document) ->
          document.setMeta({
            layout: 'sv',
            lang: 'sv',
            data: """
                != partial('advertisement_sv', document.tkrekry)
                """
          })

    sunny:
      configFromEnv: true
      onlyIfProduction: true
      envPrefixes: ["DOCPAD_SUNNY_"]

  # =================================
  # Event Configuration

  # Events
  # Allows us to bind listeners to the events that DocPad emits
  # Complete event listing can be found here: http://docpad.org/docs/events
  events:  # example
    # Server Extend
    # Used to add our own custom routes to the server before the docpad routes are added
    serverExtend: (opts) ->
      # Extract the server from the options
      {server} = opts
      docpad = @docpad

  # =================================
  # Environment Configuration

  # Environment
  # Which environment we should load up
  # If not set, we will default the `NODE_ENV` environment variable, if that isn't set, we will default to `development`
  env: 'development'  # default

  # Environments
  # Allows us to set custom configuration for specific environments
  environments:  # default
    development:  # default
      # Always refresh from server
      maxAge: false  # default

      # Only do these if we are running standalone via the `docpad` executable
      checkVersion: process.argv.length >= 2 and /docpad$/.test(process.argv[1])  # default
      welcome: process.argv.length >= 2 and /docpad$/.test(process.argv[1])  # default
      prompts: process.argv.length >= 2 and /docpad$/.test(process.argv[1])  # default

      # Listen to port 9005 on the development environment
      port: process.env.PORT || 9005  # example

    production:
      maxAge: 60  # default
      port: process.env.PORT || 9005  # example
}

# Export the DocPad Configuration
module.exports = docpadConfig