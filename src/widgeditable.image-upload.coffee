
class ImageUploadWidgeditable extends Widgeditable
	@uploadDialogTemplate = _.template(
		'<div class="<%= dialogId %>">
			<input type="file" id="files" name="files[]" style="display:none" />
			<ul class="file-list"></ul>
			<button type="button" class="btn btn-default">
				<span class=".glyphicon .glyphicon-picture"></span> <%= buttonLabel %>
			</button>
		</div>')

	@fileListItemTemplate = _.template(
		'<li>
			<span class="filename"><%= fileName %></span> <span class="filetype">(<%= fileType %>)</span>
			<button type=\"button\" class=\"btn btn-sm btn-default action-remove\">
				<span class=\"glyphicon glyphicon-remove\"></span> <%= buttonLabel %>
			</button>
		</li>')

	init: ->
		self = @
		# Check for the various File API support.
		if window.File and window.FileReader and window.FileList and window.Blob
			# Great success! All the File APIs are supported.
			$(@el).wrap('<div class="image-wrap"></div>')
		else
			alert 'The File APIs are not fully supported in this browser.'

	postActivate: ->
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
		dialogHtml = ImageUploadWidgeditable.uploadDialogTemplate
			dialogId: "image-upload-widgeditable"
			buttonLabel: "Browse"
		@dialog = $dialog = $ dialogHtml
		$dialog.hide().css styles

		$fileList = $dialog.find('.file-list')
		$fileList.on 'click', 'button.action-remove', (e) ->
			# @todo: Remove/stop upload
			$(e.target).parents('li').first().remove()
#			console.log e
			return false

		$fileInput = $dialog.find('input[type="file"]')

		$dialog.find('button').click (e) ->
			$fileInput.click()
			return

		$fileInput.bind 'change', (evt) ->
			files = evt.target.files
			output = []
			for file in files
				# console.log(file)
				# @todo: Upload handling
				itemHtml = ImageUploadWidgeditable.fileListItemTemplate
					fileName: file.name
					fileType: file.type or= 'n/a'
					buttonLabel: "Remove"
				output.push(itemHtml)
			$fileList.html(output.join(''))
			return

		$image.parent().append($dialog.show())
		return

	preActivate: ->
		# The image itself should not be editable
		return false

	postDeactivate: ->
		@dialog.hide()
		return

	data: ->
		data = super()
		_.extend data,
			'image-url': 'http://127.0.0.1/bla.gif'
		return data
