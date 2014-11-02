module.exports = (BasePlugin) ->
  RSS = require 'rss'
  pathUtil = require 'path'
  safefs = require 'safefs'

  class RssPlugin extends BasePlugin
    name: 'rss'

    config:
      priority: 10

    writeAfter: (opts, next) ->
      docpad = @docpad
      templateData = docpad.getTemplateData()
      docpadConfig = docpad.getConfig()
      feedPath = pathUtil.resolve(docpadConfig.outPath, 'feed/rss.xml')

      feed = new RSS
        title: "TKrekry - Lääkärien ja hammaslääkärien työpaikkailmoitukset"
        description: "Lääkärien ja hammaslääkärien avoimet työpaikat terveyskeskuksissa"
        site_url: "http://www.tkrekry.fi"
        feed_url: "http://www.tkrekry.fi/feed/rss.xml"
        author: "TKrekry"

      docpad.getCollection('advertisements_fi').sortCollection(date:1).forEach (document) ->
        document = document.toJSON()

        feed.item
          title: document.title
          author: document.author
          description: document.contentRenderedWithoutLayouts
          url: "http://www.tkrekry.fi" + document.url
          date: document.date.toISOString()

      safefs.writeFile feedPath, feed.xml(true), (err) ->
        # bail on error? Should really do something here
        return next?(err) if err

        # log
        docpad.log 'info', "Wrote the RSS Advertisements xml file to: #{feedPath}"

        # Done, let DocPad proceed
        return next()

      @
