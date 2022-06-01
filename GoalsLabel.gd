extends Label

var Goals = {}

func _ready():
	redraw()

func redraw():
	if len(Goals):
		show()
		text=""
		for goal in Goals.values():
			text += "- "+ Goals[goal] +"\n"
		text.erase(text.length() - 1, 1)
	else:
		hide()
		
func remove(key):
	Goals.erase(key)
	redraw()
	
func add(key, text):
	Goals[key]=text
	redraw()
	
