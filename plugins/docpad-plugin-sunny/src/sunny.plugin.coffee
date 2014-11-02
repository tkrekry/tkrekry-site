# Inspired https://github.com/bobobo1618/docpad-plugin-sunny
process.setMaxListeners(0)

if (process.env.REDISTOGO_URL)
    rtg   = require('url').parse(process.env.REDISTOGO_URL)
    redis_client = require('redis').createClient(rtg.port, rtg.hostname)
    redis_client.auth(rtg.auth.split(':')[1])
else
    redis_client = require('redis').createClient()

fs     = require 'fs'
crypto = require 'crypto'
pathUtil = require 'path'
redis  = require 'redis'
sunny  = require 'sunny'
mime   = require 'mime'
http   = require 'http'
util   = require 'util'
_      = require 'lodash'
async  = require 'async'
fs     = require 'fs'

Uploader = (docpad)->
    docpad: docpad,
    connected: false,
    container: null,
    redis: redis_client

    process: (processDoneCallback)->
        self = @
        docpadConfig = @docpad.getConfig()
        queue = async.queue(self.writeFile.bind(self), 1)
        queue.drain = processDoneCallback
        queue.empty = ()->
            console.log("Queue empty")

        generateFile = (fileName, path)->
            return {
                get: (attr)->
                    switch attr
                        when "content" then fs.readFileSync(path)
                        when "headers" then {}

                attributes: {
                    relativeOutPath: fileName
                }
            }

        feedPath = pathUtil.resolve(docpadConfig.outPath, 'feed/rss.xml')
        siteMapPath = pathUtil.resolve(docpadConfig.outPath, 'sitemap.xml')

        feedFile = generateFile('feed/rss.xml', feedPath)
        siteMapFile = generateFile('sitemap.xml', siteMapPath)

        queue.push self.prepareFile(feedFile), (err)->
            if (err)
                console.log("error while preparing rss feed", err)

        queue.push self.prepareFile(siteMapFile), (err)->
            if (err)
                console.log("error while preparing sitemap", err)

        self.docpad.getFiles(write: true).forEach (file)->
            queue.push self.prepareFile(file), (err)->
                if (err)
                    console.log "Error so push pack to queue"

        @

    prepareFile: (file)->
        data = file.get('contentRendered') || file.get('content') || (file.getData && file.getData()) || file.getContent() || ""

        if !data
            return null

        path = file.attributes.relativeOutPath
        length = data.length
        type = mime.lookup path
        headers = _.merge("Content-Length": length, "Content-Type": type, file.get('headers'))
        md5 = crypto.createHash('md5')
        md5.update(data)

        { mtime: file.get('date'), path: path, headers: { headers: headers, cloudHeaders: { 'acl': 'public-read' } }, data: data, check_sum: md5.digest('hex') }

    writeFile: (target, callback)->
        self = @
        if !target
            callback null, null

        self.redis.get target.path, (err, reply)->
            try
                if err
                    console.log("error if", err)
                    callback err
                    return

                if (reply && target.check_sum == reply)
                    # console.log("Found from cache '", target.path, "''", reply, "'")
                    callback(null, reply)
                    return

                else
                    writeStream = self.container.putBlob target.path, target.headers
                    writeStream.on 'error', (err)->
                        console.log "Error uploading #{path} to #{self.container.name}"
                        callback err

                    writeStream.on 'end', (results, meta)->
                        # console.log("Uploaded '", target.path, "' with check sum: '", target.check_sum, "'")
                        self.redis.set target.path, target.check_sum, (err, reply)->
                            #console.log("Wrote cache key for '", target.path ,"' with '", target.check_sum, "'")
                            callback null, results
                            self

                    writeStream.write target.data
                    writeStream.end()

            catch ex
                console.log("Sunny upload exception", ex)

            @

    connect: (callback)->
        sunnyConfig = {
            provider: process.env["DOCPAD_SUNNY_PROVIDER"], # Cloud provider: (aws|google)
            account: process.env["DOCPAD_SUNNY_ACCOUNT"],
            secretKey: process.env["DOCPAD_SUNNY_SECRETKEY"],
            ssl: process.env["DOCPAD_SUNNY_SSL"]
            authUrl: process.env["DOCPAD_SUNNY_AUTHURL"]
        }
        sunnyContainer = process.env["DOCPAD_SUNNY_CONTAINER"]
        sunnyACL = process.env["DOCPAD_SUNNY_ACL"]

        # Parse the environment variable for ssl.
        sunnyConfig.ssl = ((typeof(sunnyConfig.ssl) is 'string') and (sunnyConfig.ssl.toLowerCase() is 'true'))

        connection = sunny.Configuration.fromObj(sunnyConfig).connection
        # Prepare a request to the provider for the container. Checks to make sure the container exists.
        containerReq = connection.getContainer sunnyContainer, {validate: true}

        containerReq.on 'error', (err)->
            console.log "Received error trying to connect to provider: \n #{err}"

        containerReq.on 'end', (results, meta)->
            if results # not sure exactly how, but the 'end' can get called more than once with null params on the second call
                callback(null, results.container)


        containerReq.end()
        @

module.exports = (BasePlugin) ->
    class docpadSunnyPlugin extends BasePlugin
        name: "sunny"

        config:
            priority: 0.01
            uploader: null
            defaultACL: 'public-read'
            onlyIfProduction: true
            configFromEnv: true
            envPrefixes: ["DOCPAD_SUNNY_"]
            cloudConfigs: [
                # {
                #    sunny:{
                #        provider: undefined
                #        account: undefined
                #        secretKey: undefined
                #        ssl: undefined
                #        authUrl: undefined
                #    },
                #    container: undefined,
                #    acl: undefined
                #    retryLimit: undefined
                # }
            ]

        docpadReady: (opts, next)->
            self = @
            self.config.docpad = @docpad
            console.log("Sunny generation: do? ", process.env.NODE_ENV, (process.env.NODE_ENV is "production"))

            if (process.env.DOCPAD_ENV is "production")
                self.config.uploader = new Uploader(self.config.docpad)
                self.config.uploader.connect (err, container)->
                    if (err)
                        next(err)
                        return

                    self.config.uploader.container = container
                    next()
            else
                next()

            @

        writeAfter: (opts, next)->
          console.log("Sunny generation: do? ", process.env.NODE_ENV, (process.env.NODE_ENV is "production"))
          if (process.env.DOCPAD_ENV is "production")
            if @config.configFromEnv
                console.log "Sunny plugin getting config from environment..."
                @config.uploader.process ()->
                    console.log("All files uploaded")
                    next?()


