Widgeditable.registerWidgeditable('ul', ListWidgeditable)
            .registerWidgeditable('li', ListItemWidgeditable)
            .registerWidgeditable('img', ImageUploadWidgeditable)

# Create a master widget which contains all other widgets
widgeditable = Widgeditable.search(document.getElementById('wrap'))

$ ->
	$saveButton = $('button#save').prop('disabled', true);
	$activateButton = $('button#activate');
	$deactivateButton = $('button#deactivate').prop('disabled', true);

	$saveButton.click ->
		$deactivateButton.prop('disabled', true);
		$activateButton.prop('disabled', false);
		$saveButton.prop('disabled', true);
		widgeditable.save()

	$activateButton.click ->
		$deactivateButton.prop('disabled', false);
		$activateButton.prop('disabled', true);
		$saveButton.prop('disabled', false);
		widgeditable.activate()

	$deactivateButton.click ->
		$deactivateButton.prop('disabled', true);
		$activateButton.prop('disabled', false);
		$saveButton.prop('disabled', true);
		widgeditable.deactivate()
