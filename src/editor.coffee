Signal = signals.Signal

class Widgeditable
	propagate: true
	isRoot: false

	constructor: (@el, @parent) ->
		# Read store URL
		store = @el.getAttribute('data-store')
		if store?
			console.log "Found store #{ store } at ##{ @el.id }"

		# Setup events
		@e =
			edit: new Signal
			save: new Signal

		if @parent?
			console.log "Attached ##{ @el.id } to parent ##{ @parent.el.id }"
			# You MUST NOT use underscore bind otherwise JS-Signals 
			# does not bind multiple handler
			@parent.e.save.add(_.bind(@_saveHandler, @))
			@parent.e.edit.add(_.bind(@_editHandler, @))

		if !@parent?
			@propagate = false
			@isRoot = true
			# Root element save-handler
			console.log "Attached ##{ @el.id } to root ##{ @el.id }"
			@e.save.add(@_saveHandler, @)
			@e.edit.add(@_editHandler, @)

		@el.className = "editable"

		# Execute init function if any
		@init?()

		return

	_saveHandler: ->
		# Call pre-actication hook
		@preSave?()

		# Propagate save
		if @propagate
			@e.save.dispatch()

		# De-Activate editing
		@el.contentEditable = false

		console.log "Executed saveHandler on ##{ @el.id }"

		# Call pre-actication hook
		@postSave?()

		return
 
	_editHandler: ->
		# Call pre-actication hook
		@preActivateEdit?()

		# Propagate edit
		if @propagate
			@e.edit.dispatch()

		# Activate editing for everything then the root widget
		@el.contentEditable = true if !@isRoot

		console.log "Executed editHandler on ##{ @el.id }"

		# Call post-actication hook
		@postActivateEdit?()

		return

	# Toggle editing mode
	edit: ->
		# Ignore call as long as we are editing
		return if @isEditing
		@isEditing = !@isEditing

		console.log "Called edit on ##{ @el.id }"
		@e.edit.dispatch()
		return

	save: ->
		console.log "Called save on ##{ @el.id }"
		@isEditing = !@isEditing
		@e.save.dispatch()
		return

	@search = (el, parent, clazz = 'widgeditable') ->
		if 1 == el.nodeType and el.className.indexOf(clazz) != -1
			# console.log "#{ el.nodeName }##{ el.id }.#{ el.className }"    
			widget = Widgeditable.fromElement(el, parent)

		parent = widget if widget?

		for node in el.childNodes
			Widgeditable.search(node, parent)

		return widget

	@fromElement: (el, parent) ->
		# todo: Enable widgets to register themself for a tag
		nodeName = el.nodeName.toUpperCase()
		if "UL" == nodeName
			widget = new ListWidgeditable(el, parent)
		else if "LI" == nodeName
			widget = new ListItemWidgeditable(el, parent)
		else if "IMG" == nodeName
			widget = new ImageUploadWidgeditable(el, parent)
		else
			widget = new Widgeditable(el, parent)
		widget


class ListItemWidgeditable extends Widgeditable


class ListWidgeditable extends Widgeditable
	init: ->
		self = @

		# Remove editable class
		@el.className = ""

		# Attach a widget to the lists parent for every list-item
		$('> li', @el).each ->
			Widgeditable.fromElement @, self.parent
			return

		$list = $(@el)
		@_button = $("<button>Add item</button>").hide()
		@_button.click (e) ->
			# Clone first item and empty it
			newItem = $(':first-child', self.el).clone()
				.empty()
				.removeAttr('id')

			# Attach widget to new item
			Widgeditable.fromElement newItem.get(0), self.parent

			# Insert fresh node after last list-item
			$('li:last', self.el).after(newItem)

			return
		$list.append(@_button)

		return

	postActivateEdit: ->
		# Show "Add item" button
		do @_button.show

		# We do not want to edit the list itself
		@el.contentEditable = false

		return


class ImageUploadWidgeditable extends Widgeditable
	init: ->
		self = @
		# Check for the various File API support.
		if window.File and window.FileReader and window.FileList and window.Blob
			$(@el).wrap('<div class="image-wrap"></div>')
			# Great success! All the File APIs are supported.
		else
			alert('The File APIs are not fully supported in this browser.')

	postActivateEdit: ->
		if @dialog?
			@dialog.show()
			return

		$image = $(@el)

		# Prepare styling of the dialog
		styles = $image.position()
		$.extend styles,
			position: 'absolute'
			overflow: 'hidden'
			width: $image.width() - 2
			height: $image.height() - 2
			padding: $image.css 'padding'
			margin: $image.css 'margin'
			backgroundColor: 'rgba(255,215,0, 0.9)'
			border: '1px solid #FFC125'
			zIndex: 10

		# Create the dialog
		dialogId = "image-upload-widgeditable"
		@dialog = $dialog = $ "<div class=\"#{ dialogId }\">
			<input type=\"file\" id=\"files\" name=\"files[]\" multiple=\"multiple\" style=\"display:none\" />
			<ul class=\"file-list\"></ul>
			<button>Browse</button></div>"
		$dialog.hide().css styles

		$fileList = $dialog.find('.file-list')
		$fileInput = $dialog.find('input[type="file"]')

		$dialog.find('button').click (e) ->
			$fileInput.click()
			return

		$fileInput.bind 'change', (evt) ->
			files = evt.target.files
			output = []
			for file in files
				# console.log(file)
				output.push("<li>#{ file.name } (#{ file.type || 'n/a' })<button>Remove</button></li>")
			$fileList.html(output.join(''))
			return

		$image.parent().append($dialog.show())
		return

	preSave: ->
		@dialog.hide()
		return

# Create a master widget which contains all other widgets
master = Widgeditable.search(document.getElementById('wrap'))

$ ->
	$('button#save').click ->
		master.save()
	$('button#edit').click ->
		master.edit()
