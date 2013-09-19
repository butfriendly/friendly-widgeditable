Signal = signals.Signal

class Widgeditable
	constructor: (@el, @parent) ->
		@id = @el.id
		@id or= do @uniqueId
		@el.id = @id

		# Read store URL
		@_storeUrl = @el.getAttribute('data-store')
		if @_storeUrl?
			if !/^(http|https):\/\//i.test @_storeUrl
				throw "Invalid store URL #{ storeUrl }"
#			console.log "Found store #{ storeUrl } at \"#{ @id }\""

		# Initially the element and editable are the same
		@editable = @el

		# Initialize storables
		@_storables = []

		# Setup events
		@e =
			activate: new Signal
			deactivate: new Signal
			save: new Signal
			destroy: new Signal
		@_setupSignalHandler if @parent? then @parent.e else @e

		# By default we propagate all events and aren't a root
		@_propagate = true
		@_isRoot = false
		@_isActive = false

		if !@parent?
			# We don't have any parent, so we are root obviously
#			console.log "\"#{ @id }\" is root"

			@_propagate = false
			@_isRoot = true
		else
			# console.log "Attached \"#{ @id }\" to parent \"#{ @parent.id }\""

			# We don't have any storeUrl, so we want be stored
			# by our parent widgeditable
			@parent.registerStorable @ if !storeUrl?

		# Execute init function if any
		@init?()

		return

	_setupSignalHandler: (e) ->
		# You MUST NOT use underscore bind otherwise JS-Signals 
		# does not bind multiple handler
		e.save.add(@_saveHandler, @)
		e.activate.add(@_activateHandler, @)
		e.deactivate.add(@_deactivateHandler, @)
		return

	registerStorable: (storable) ->
#		console.log "Registered storable \"#{ storable.id }\" on \"#{ @id }\""
		@_storables.push storable

		# Listen for destroy signals in the storable
		storable.e.destroy.add =>
			# Remove the destroyed item from storables
			@_storables.splice(@_storables.indexOf(storable), 1)
			return

		return

	data: ->
		data =
			id: @id
			type: @constructor.name

	_processStorables: ->
		# console.log "Processing \"#{ @id }\""
		data = do @data
		if @_storables.length
			data.storables = [] if !data.storables?
			for storable in @_storables
				# console.log "Processing #{ storable.id }"
				data.storables.push(storable._processStorables())
		return data

	_save: ->
		if @_storeUrl?
			# Store at URL
			#console.log "Save \"#{ @id }\" at storeUrl #{ @_storeUrl }"

			if !@_storables.length
				throw "No storables found"

			data = do @_processStorables

			# @todo: Store data
			console.log data
		return

	_saveHandler: ->
		# console.log "Executed _saveHandler on \"#{ @id }\""

		# De-Activate editing
		do @deactivate

		# Call pre-actication hook
		@preSave?()

		# Propagate save
		if @propagate
			@e.save.dispatch()

		do @_save

		# Call pre-actication hook
		@postSave?()

		return
 
	_deactivate: () ->
		@editable.contentEditable = false

	_deactivateHandler: ->
		# console.log "Executed _deactivateHandler on ##{ @id }"

		@preDeactivate?()

		# Propagate edit
		if @_propagate
			@e.deactivate.dispatch()

		do @_deactivate

		@postDeactivate?()
		return

	_activate: (shouldBeEditable) ->
		# Activate editing for everything then the root widget
		@editable.contentEditable = true if !@_isRoot and shouldBeEditable
		return

	_activateHandler: ->
		# console.log "Executed _activateHandler on ##{ @id }"

		shouldBeEditable = true

		# Call pre-actication hook if any
		shouldBeEditable = false if @preActivate?() == false

		# Propagate edit
		if @_propagate
			@e.activate.dispatch()

		@_activate shouldBeEditable

		# Call post-actication hook
		@postActivate?()

		return

	activate: ->
		return if @_isActive
		@_isActive = true
		# console.log "Called activate on ##{ @id }"
		do @e.activate.dispatch
		return

	deactivate: ->
		return if !@_isActive
		@_isActive = false
		# console.log "Called deactivate on ##{ @id }"
		do @e.deactivate.dispatch
		return

	save: ->
		# console.log "Called save on ##{ @id }"
		do @e.save.dispatch
		return

	@search = (el, parent, clazz = 'widgeditable') ->
		if 1 == el.nodeType and $(el).hasClass(clazz)
			# console.log "#{ el.nodeName }##{ el.id }.#{ el.className }"    
			widget = Widgeditable.fromElement(el, parent)

		parent = widget if widget?

		for node in el.childNodes
			Widgeditable.search(node, parent)

		return widget

	@fromElement: (el, parent) ->
		nodeName = el.nodeName.toUpperCase()
		if nodeName of this.widgeditables
			Clazz = this.widgeditables[nodeName]
		else
			Clazz = this
		widget = new Clazz(el, parent)
		return widget

	@widgeditables = {}

	@registerWidgeditable: (nodeName, Widgeditable) ->
		this.widgeditables[nodeName.toUpperCase()] = Widgeditable
		return @

	uniqueId: (length=8) ->
		id = ""
		id += Math.random().toString(36).substr(2) while id.length < length
		id.substr 0, length
