module.exports = (grunt) ->
	# Load Grunt tasks declared in the package.json file
	require('matchdep').filterDev('grunt-*').forEach(grunt.loadNpmTasks)

	# Project configuration
	grunt.initConfig
		pkg: @file.readJSON 'package.json'

		# Install dependencies
		bower:
			install:
				options:
#					targetDir: './components'
					layout: 'byComponent'
					cleanTargetDir: true
					cleanBowerDir: false
					install: true
					verbose: true

		# CoffeeScript complication
		coffee:
			build:
				options:
					bare: true
					sourceMap: true
				expand: true
				src: [ '*.coffee', '*.*.coffee' ]
				dest: 'build'
				cwd: 'src'
				ext: '.js'
			gruntfile:
				files: 'Gruntfile.coffee'

		# Remove tmp directory once builds are complete
		clean: ['build', 'dist']

		uglify:
			dist:
				files:
					'dist/widgeditable.min.js': ['build/widgeditable.concat.js']

		jsonlint: {
			json: {
				src: [ '*.json' ]
			}
		}

		watch:
			json:
				files: [ '<%= jsonlint.json.src %>' ]
				tasks: ['jsonlint']
			coffee:
				files: [ '**/*.coffee' ]
				tasks: ['build']
			options:
				spawn: false
				livereload: true

		connect:
			options:
				port: 9012
				hostname: "0.0.0.0"
				base: './'
			dev:
				options:
					middleware: (connect, options) ->
						[
							do require('connect-livereload'),

							# Serve statics
							connect.static(options.base),

							# Directory listing
							connect.directory(options.base)
						]

	# Local tasks
	@registerTask 'build', ['jsonlint', 'clean', 'coffee']
	@registerTask 'dist', ['build', 'uglify']
	@registerTask 'dev', ['build', 'connect', 'watch']

	@registerTask 'default', ['dist']
 