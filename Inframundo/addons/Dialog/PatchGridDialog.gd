extends DefaultDialog

func set_image(img, patchs):
	var node = find_node("Main")
	node.set_image(img, patchs)
