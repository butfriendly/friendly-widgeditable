
class ListItemWidgeditable extends Widgeditable
	@removeButtonTemplate = _.template(
		'<button type="button" class="btn btn-xs btn-default actn-remove">
			<span class="glyphicon glyphicon-remove"></span> 
		</button>')

	init: ->
		self = @

		$item = $(@el)

		# Render the button
		buttonHtml = ListItemWidgeditable.removeButtonTemplate
			buttonLabel: "Remove"

		@_controls = $("<div class=\"widgeditable-controls\">#{ buttonHtml }</div>").hide()

		$item.hide()
		     .wrapInner('<div class="editable"></div>')
		     .append(@_controls)
		     .show()

		@editable = $('.editable', @el).get(0)

		@_button = $item.find 'button.actn-remove'
		@_button.click (e) ->
			$(e.target).parents('li').first().remove()

			# Tell others about or end-of-life, so they can say good-bye
			do self.e.destroy.dispatch
			return false

		return

	postActivate: ->
		do @_controls.show
		do @_button.show
		return

	postDeactivate: ->
		do @_controls.hide
		do @_button.hide
		return

	data: ->
		data = super()
		_.extend data,
			text: $('.editable', @el).html()
		return data

