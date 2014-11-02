process.setMaxListeners(0)

{TaskGroup} = require('taskgroup')
{EventEmitter} = require('events')
eachr = require('eachr')
_  = require('lodash')
slug = require('slug')
async = require('async')

# Export
module.exports = (BasePlugin) ->
	# Define
	class TkrekryPlugin extends BasePlugin
		# Name
		name: 'tkrekry'

		# Config
		config:
			priority: 900
			apiUrl: "http://admin.beta.tkrekry.fi"
			injectDocumentHelperAdvertisement: null
			injectDocumentHelperEmployer: null
			relativeDirPathAdvertisements:
				"fi":
					"avoimet-tyopaikat"
				"sv":
					"sv/lediga-jobb"

			relativeDirPathEmployers:
				"fi":
					"terveyskeskukset"
				"sv":
					"sv/halsovardscentralen"


		# =============================
		# Events

		# Extend Collections
		# Create our live collection for our tags
		extendCollections: ->
			# Prepare
			config = @getConfig()
			docpad = @docpad

			# Create the collection
			advertisementsCollectionFi = docpad.getFiles({relativeDirPath: $startsWith: config.relativeDirPathAdvertisements.fi}, [title:1])
			advertisementsCollectionSv = docpad.getFiles({relativeDirPath: $startsWith: config.relativeDirPathAdvertisements.sv}, [title:1])

			employersCollectionFi = docpad.getFiles({relativeDirPath: $startsWith: config.relativeDirPathEmployers.fi}, [name:1])
			employersCollectionSv = docpad.getFiles({relativeDirPath: $startsWith: config.relativeDirPathEmployers.sv}, [name:1])

			# Set the collection
			docpad.setCollection("advertisements_fi", advertisementsCollectionFi)
			docpad.setCollection("advertisements_sv", advertisementsCollectionSv)

			docpad.setCollection("employers_fi", employersCollectionFi)
			docpad.setCollection("employers_sv", employersCollectionSv)

			# Chain
			@

		# Fetch our Tumblr Posts
		# next(err,tumblrPosts)
		fetchTkrekryAdvertisementsData: (opts={},next) ->
			# Prepare
			config = @getConfig()
			feedr = @feedr ?= new (require('feedr').Feedr)

			# Prepare
			tkrekryAdvertisementsUrl = "#{config.apiUrl}/api/advertisements/published"
			tkrekryAdvertisements = []

			# Fetch the first feed which is the initial page
			feedr.readFeed tkrekryAdvertisementsUrl, { parse:'json' }, (err, feedData) ->
				# Check
				return next(err) if err

				return next(null, feedData, 1)

			# Chain
			@

		fetchTkrekryEmployersData: (opts={},next) ->
			# Prepare
			config = @getConfig()
			feedr = @feedr ?= new (require('feedr').Feedr)

			# Prepare
			tkrekryEmployersUrl = "#{config.apiUrl}/api/employers"
			tkrekryEmployers = []

			# Fetch the first feed which is the initial page
			feedr.readFeed tkrekryEmployersUrl, { parse:'json' }, (err,feedData) ->
				# Check
				return next(err) if err

				return next(null,feedData, 1)

			# Chain
			@


		# next(err, document)
		createTkrekryAdvertisementPage: (advertisement, lang = 'fi', next) ->
			# Prepare
			plugin = @
			docpad = @docpad
			config = @getConfig()

			#docpad.log('info', "Loading advertisement", advertisement)

			# Extract
			advertisementId = advertisement._id
			advertisementMtime = new Date(advertisement.updated_at)
			advertisementDate = new Date(advertisement.created_at)

			# Fetch
			document = docpad.getFile({tkrekryId: advertisementId, lang: lang})
			documentTime = document?.get('mtime') or null

			if documentTime and documentTime.toString() is advertisementMtime.toString()
			 	# Skip
				return next(null, null)

			# Prepare
			#

			if lang == 'fi'
				counterLanguage = 'sv'
			else
				counterLanguage = 'fi'

			title = (lg)->
				switch lg
					when 'fi'
						"Avoimet työpaikat - Työpaikkailmoitus: #{(advertisement.title).replace(/<(?:.|\n)*?>/gm, '')}, #{advertisement.employer.name}, #{(advertisement.office && advertisement.office.locality)}"
					else
						"Lediga jobb - Platsannons: #{(advertisement.title).replace(/<(?:.|\n)*?>/gm, '')}, #{advertisement.employer.name}, #{(advertisement.office && advertisement.office.locality)}"

			keywords = (lg)->
				switch lg
					when 'fi'
						"avoimet työpaikat, työpaikkailmoitus, #{advertisement.title}, #{advertisement.employer.name}, #{(advertisement.office && advertisement.office.locality)}"
					else
						"lediga jobb, platsannons, #{advertisement.title}, #{advertisement.employer.name}, #{(advertisement.office && advertisement.office.locality)}"


			urlSlug = slug([advertisement.title, advertisement?.office?.locality, advertisement?.job_profession_group.id, advertisement?.job_type.id, advertisement?.job_duration.id, advertisementId].join(' ')).toLowerCase()
			documentAttributes =
				data: JSON.stringify(advertisement, null, '\t')
				meta:
					lang: lang
					published: advertisement.published
					tkrekryId: advertisementId
					tkrekry: advertisement
					date: advertisementDate
					pageUrl: [advertisementId, advertisement.title].join('-')
					mtime: advertisementMtime
					title: title(lang)
					description: title(lang)
					keywords: keywords(lang)
					slug: "#{config.relativeDirPathAdvertisements[lang]}/#{urlSlug}.html"
					counterPart: "/#{config.relativeDirPathAdvertisements[counterLanguage]}/#{urlSlug}.html"
					relativePath: "#{config.relativeDirPathAdvertisements[lang]}/#{urlSlug}#{config.extension}"

			# Existing document
			if document?
				document.set(documentAttributes)

			# New Document
			else
				# Create document from opts
				document = docpad.createDocument(documentAttributes)

			# Inject document helper
			config.injectDocumentHelperAdvertisement[lang]?.call(plugin, document)

			# Load the document
			document.action 'load', (err) ->
				# Check
				return next(err, document)  if err

				# Add it to the database (with b/c compat)
				docpad.addModel?(document) or docpad.getDatabase().add(document)

				# Complete
				return next(null, document)

			# Return the document
			return document

		createTkrekryEmployerPages: (employer, lang = 'fi', next) ->
			# Prepare
			plugin = @
			docpad = @docpad
			config = @getConfig()

			# docpad.log('info', "Loading employer", employer)

			# Extract
			employerId = employer._id
			employerMtime = new Date(employer.updated_at)
			employerDate = new Date(employer.created_at)

			# Fetch
			document = docpad.getFile({tkrekryId: employerId, lang: lang})
			documentTime = document?.get('mtime') or null

			# Compare
			if documentTime and documentTime.toString() is employerMtime.toString()
			 	# Skip
				return next(null, null)

			# Prepare
			#

			if lang == 'fi'
				counterLanguage = 'sv'
			else
				counterLanguage = 'fi'

			title = (lg)->
				switch lg
					when 'fi'
						"#{(employer.name).replace(/<(?:.|\n)*?>/gm, '')} - Rekrytoinnista vastaavat yhteyshenkilöt, koulutusvalmiudet, esittely ja toimipisteet"
					else
						"#{(employer.name).replace(/<(?:.|\n)*?>/gm, '')} - Kontaktpersoner för rekrytering, utbildningsberedskap, presentation och verksamhetsställen"

			keywords = (lg)->
				switch lg
					when 'fi'
						"#{(employer.name).replace(/<(?:.|\n)*?>/gm, '')} "
					else
						"#{(employer.name).replace(/<(?:.|\n)*?>/gm, '')} "

			urlSlug = slug([employer.name, employerId].join(' ')).toLowerCase()
			documentAttributes =
				data: JSON.stringify(employer, null, '\t')
				meta:
					lang: lang
					tkrekryId: employerId
					tkrekry: employer
					title: title(lang)
					description: title(lang)
					keywords: keywords(lang)
					date: employerDate
					pageUrl: [employerId, employer.name].join('-')
					mtime: employerMtime
					counterPart: "/#{config.relativeDirPathEmployers[counterLanguage]}/#{urlSlug}.html"
					slug: "#{config.relativeDirPathEmployers[lang]}/#{urlSlug}.html"
					relativePath: "#{config.relativeDirPathEmployers[lang]}/#{urlSlug}#{config.extension}"

			# Existing document
			if document?
				document.set(documentAttributes)

			# New Document
			else
				# Create document from opts
				document = docpad.createDocument(documentAttributes)

			# Inject document helper
			config.injectDocumentHelperEmployer[lang]?.call(plugin, document)

			# Load the document
			document.action 'load', (err) ->
				# Check
				return next(err, document)  if err

				# Add it to the database (with b/c compat)
				docpad.addModel?(document) or docpad.getDatabase().add(document)

				# Complete
				return next(null, document)

			# Return the document
			return document


		# =============================
		# Events

		# Populate Collections
		# Import Tumblr Data into the Database
		populateCollections: (opts,next) ->
			# Prepare
			plugin = @
			docpad = @docpad
			counter = 0
			loaded = new EventEmitter()
			self = @

			tasks = new TaskGroup(concurrency: 0).once 'complete', (err, results) ->
				docpad.log 'info', 'TKRekry collections added.'
				return next(err) if err
				# Complete
				return next()

			async.series([
				(callback)->
					self.fetchTkrekryAdvertisementsData null, (err, advertisements) ->
						# Check
						return next(err)  if err

						# Inject our posts
						eachr advertisements, (advertisement, i) ->
							tasks.addTask (complete) ->
								plugin.createTkrekryAdvertisementPage advertisement, 'fi', (err, document) ->
									# Check
									if err
										docpad.log("error", "Error while creating page", err)
										return complete(err) if err

									return complete()

							tasks.addTask (complete) ->
								plugin.createTkrekryAdvertisementPage advertisement, 'sv', (err, document) ->
									# Check
									if err
										docpad.log("error", "Error while creating page", err)
										return complete(err) if err

									return complete()

						callback(null, true)

				,(callback)->
					self.fetchTkrekryEmployersData null, (err, employers) ->
						# Check
						return next(err)  if err

						# Inject our posts
						eachr employers, (employer, i) ->
							tasks.addTask (complete) ->
								plugin.createTkrekryEmployerPages employer, 'fi', (err, document) ->
									# Check
									if err
										docpad.log("error", "Eroor while creating page", err)
										return complete(err) if err

									return complete()

							tasks.addTask (complete) ->
								plugin.createTkrekryEmployerPages employer, 'sv', (err, document) ->
									# Check
									if err
										docpad.log("error", "Eroor while creating page", err)
										return complete(err) if err

									return complete()

						callback(null, true)
				],
				(er, results)->
					tasks.run()
				)

			@


