module.exports = (grunt) ->
	# Load Grunt tasks declared in the package.json file
	require('matchdep').filterDev('grunt-*').forEach(grunt.loadNpmTasks)

	# Project configuration
	grunt.initConfig
		pkg: @file.readJSON 'package.json'

		# Install dependencies
		bower:
			install: {}

		# CoffeeScript complication
		coffee:
			core:
				expand: true
				src: ['*.coffee']
				dest: 'dist'
				cwd: 'src'
				ext: '.js'
			gruntfile:
				files: 'Gruntfile.coffee'

		# Remove tmp directory once builds are complete
		clean: ['build', 'dist']

		watch:
			coffee:
				files: [ '**/*.coffee' ]
				tasks: ['build']
			options:
				spawn: false

	# Local tasks
	@registerTask 'build', ['clean', 'coffee']
	@registerTask 'dist', ['build', 'uglify']
#  @registerTask 'test', ['coffeelint', 'build', 'qunit']
#  @registerTask 'crossbrowser', ['test', 'connect', 'saucelabs-qunit']

	@registerTask 'default', ['build']
 