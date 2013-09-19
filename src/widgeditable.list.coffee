class ListWidgeditable extends Widgeditable
	@addItemButtonTemplate = _.template(
		'<button type="button" class="btn btn-sm btn-default actn-add">
			<span class="glyphicon glyphicon-plus"></span> <%= buttonLabel %>
		</button>')

	init: ->
		self = @

		# Remove editable class
		@el.className = "widgeditable-list"

		# Create a widget for every _existing_ list-item
		$('> li', @el).each ->
			Widgeditable.fromElement @, self
			return

		$list = $(@el)

		# Render button's template
		buttonHtml = ListWidgeditable.addItemButtonTemplate
			buttonLabel: "Add item"

		@_button = $(buttonHtml).hide()
		@_button.click (e) ->
			# Duplicate the template
			newItem = $.clone(self._newListItemTemplate, true, true)

			# Attach widget to the new item
			widgeditable = Widgeditable.fromElement newItem, self

			# We need to activate it by hand, because activation 
			# was already triggered - should be better
			do widgeditable._activateHandler

			# Insert fresh node after last list-item
			$lastItem = $('li:last', self.el);
			if $lastItem.length > 0
				$lastItem.after(newItem)
			else
				$(self.el).append(newItem)

			return

		# Append the button to the end of the list
		$list.after(@_button)

		return

	preActivate: ->
		# Save the first item as template if we don't have any
		@._newListItemTemplate ?= $('li:first-child', self.el)
			.clone(true, true)
			.html('NEW ENTRY')
			.removeAttr('id')
			.get(0)

		# The list itself should not be editable
		return false

	postActivate: ->
		# Show "Add item" button
		do @_button.show
		return

	postDeactivate: ->
		do @_button.hide
		return
