extends RichTextLabel

signal exit

const HELP_COMMAND = "help"		# Display all help commands
const DIR_COMMAND = "ls"		# Display all files and folders in current working directory
const CHANGE_DIRECTORY_COMMAND = "cd"	# Change working directory
const QUIT_COMMAND = "exit"		# Quit application
const CLEAR_COMMAND = "clear"		# Clear terminal windows

var current_context : Context
var past_commands = [""]

class Context:
	var user_name = "JAE-N2"
	var device_name = "KM-X0"
	var working_directory : Folder
	var root_directory : Folder
	var date = get_date_srtr()
	
	func get_date_srtr():
		var time = OS.get_datetime()
		return "XXXXX-{month}-{day}".format({"month":"%02d" % time["month"], "day":"%02d" % time["day"]})
	
class Folder:
	var folder_path : String
	var parent_directory : Folder
	var child_directories = []
	var child_files = []
	
	func _init(path, parent):
		folder_path = path
		parent_directory = parent
		pass
	
	func _to_string():
		return folder_path
		
class Document:
	var document_name : String
	var parent_directory : Folder
	var content : String
	var size_kb = 10
	
	func _init(name, parent):
		document_name = name
		parent_directory = parent
		pass
	
	func set_content(new_content : String):
		content = new_content
		size_kb = stepify((float(content.length()) * 8) / 1024, 0.01)
	
	func _to_string():
		return document_name
	

func _ready():
	# Initalise context, folders & files
	current_context = Context.new()
	
	current_context.root_directory = Folder.new("", null)
	current_context.root_directory.child_directories = [
		Folder.new("Desktop", current_context.root_directory),
		Folder.new("Documents", current_context.root_directory),
		Folder.new("Downloads", current_context.root_directory),
		Folder.new("Music", current_context.root_directory)
		]
	current_context.working_directory = current_context.root_directory
	#current_context.working_directory = current_context.root_directory.child_directories[0]
	
	current_context.root_directory.child_files = [
		Document.new("readme.txt", current_context.root_directory), 
		Document.new("dontread.txt", current_context.root_directory),
		Document.new("passwords.txt", current_context.root_directory)
	]
	current_context.root_directory.child_files[0].set_content("Welcome to FakeDOS. Type '%s' for a list of useful commands. Enjoy your stay!" % HELP_COMMAND)
	current_context.root_directory.child_files[1].set_content("Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed aliquam felis ante, vitae placerat ante suscipit eu. Aliquam lacinia quis quam quis interdum. Pellentesque a justo vitae turpis fringilla maximus. Pellentesque ultricies condimentum nisl, sed sodales leo malesuada faucibus. Aenean accumsan porta orci, malesuada tincidunt nibh consequat et. Aliquam ornare eget odio eu porttitor. Donec in condimentum tellus. Etiam vel lectus quis quam venenatis porta quis ut enim. In justo nibh, efficitur vitae interdum at, sagittis vitae metus. Morbi commodo purus sagittis justo condimentum, quis vestibulum enim convallis. In vulputate non elit at pretium. Nunc cursus lacus eget justo laoreet luctus. Aliquam finibus varius urna et rhoncus. Vivamus mattis convallis tristique. Vestibulum sit amet tristique turpis, id scelerisque diam.")
	current_context.root_directory.child_files[2].set_content("Hah! Thought I'd keep my passwords in a plaintext file?")
	current_context.root_directory.child_directories[0].child_files = [
		Document.new("ratbag.txt", current_context.root_directory.child_directories[0])
	]
	current_context.root_directory.child_directories[0].child_files[0].set_content("You're a real ratbag, Dennis.")
	
	clear()
	
	# Draw technobbabble
	draw_new_line("FAKE-DOS version 1.2", false, false, false)
	draw_new_line("Copyright (C) 1994 VirtuTech Industrial Systems", false, true, false)
	draw_new_line("Current date is %s" % current_context.date, false, true, false)
	
	newline()
	bbcode_text += "\n"
	
	# Display help prompt
	draw_new_line("For assistance, type \'%s'." % HELP_COMMAND, false, true, true)
	draw_new_line("", false, true, false)
	
	# Draw new line with current working directory
	draw_new_line("", true, false, false)
	
	pass
	
func draw_new_line(input : String, draw_prefix : bool, new_line_before : bool, new_line_after : bool):
	if (new_line_before):
		newline()
		bbcode_text += "\n"
	
	if (draw_prefix):
		bbcode_text += "[color=#ff9b00][b]"+current_context.user_name.to_lower()+ "[/b]" + "@" + current_context.device_name.to_lower() + "[/color]"
		
		if (current_context.working_directory.folder_path != ""):
			bbcode_text += "<" + current_context.working_directory.folder_path + ">"
		else:
			#bbcode_text += "<*>"
			pass
		bbcode_text += ": "
	
	bbcode_text += input
	
	if (new_line_after):
		newline()
		bbcode_text += "\n"
	
	pass

func draw_new_character(input):
	bbcode_text += input
	pass

var current_user_input = ""

const ALPHANUMERIC_KEYS := {
	KEY_SPACE:" ", KEY_APOSTROPHE:"'", KEY_COMMA:",", KEY_MINUS:"-", KEY_PERIOD:".", KEY_SLASH:"/",
	KEY_0:"0", KEY_1:"1", KEY_2:"2", KEY_3:"3", KEY_4:"4", KEY_5:"5", KEY_6:"6", KEY_7:"7", KEY_8:"8", KEY_9:"9",
	KEY_SEMICOLON:";", KEY_EQUAL:"=", KEY_QUOTEDBL:"`", KEY_QUOTELEFT:"`",

	KEY_A:"a", KEY_B:"b", KEY_C:"c", KEY_D:"d", KEY_E:"e", KEY_F:"f", KEY_G:"g", KEY_H:"h", KEY_I:"i",
	KEY_J:"j", KEY_K:"k", KEY_L:"l", KEY_M:"m", KEY_N:"n", KEY_O:"o", KEY_P:"p", KEY_Q:"q", KEY_R:"r",
	KEY_S:"s", KEY_T:"t", KEY_U:"u", KEY_V:"v", KEY_W:"w", KEY_X:"x", KEY_Y:"y", KEY_Z:"z"
}

var current_past_command = 1
			
func _input(event):	
	if event is InputEventKey and event.pressed:
		# Cancel input
		if event.control and event.scancode == KEY_C:
			current_user_input = ""
			draw_new_line("^C", false, false, false)
			
			current_past_command = past_commands.size() - 1
			
			# Display current context
			draw_new_line("", true, true, false)
			return
		
		# Detect alphanumeric input
		if event.scancode in ALPHANUMERIC_KEYS and !event.control:
			var character = char(event.unicode)
			if (character == " " && current_user_input.length() == 0):
				return
				
			current_user_input += character
			past_commands[-1] = current_user_input
			
			draw_new_character(character)
			# print(character)
			return
		
		# Backspace, delete last typed character
		if event.scancode == KEY_BACKSPACE:
			# Backspace, delete character behind caret
			if (current_user_input.length() > 0):
				current_user_input.erase(current_user_input.length()-1, 1)
				bbcode_text = bbcode_text.left(bbcode_text.length()-1)
				past_commands[-1] = current_user_input
			return
		
		# Cycle up through past commands
		if event.scancode == KEY_UP:
			get_tree().set_input_as_handled()
			if (past_commands.size() > 0):
				if (current_past_command > 0):
					current_past_command -= 1
				else:
					#current_past_command = past_commands.size() - 1
					pass
					
				if (current_user_input.length() > 0):
					bbcode_text = bbcode_text.left(bbcode_text.length()-current_user_input.length())
					
				current_user_input = past_commands[current_past_command]
				bbcode_text += current_user_input
			
#				print(current_past_command)
				return
		
		
		# Cycle down through past commands
		if event.scancode == KEY_DOWN:
			get_tree().set_input_as_handled()
			if (past_commands.size() > 0):
				if (current_past_command < (past_commands.size() - 1)):
					current_past_command += 1
				else:
					# current_past_command = 0
					pass
					
				if (current_user_input.length() > 0):
					bbcode_text = bbcode_text.left(bbcode_text.length()-current_user_input.length())
				current_user_input = past_commands[current_past_command]
				bbcode_text += current_user_input
				
#				print(current_past_command)
				return
		
		# Detect 'enter' command
		if event.scancode == KEY_ENTER:
			# Submit user input, parse and clear current_user_input variable
			
			# Don't attempt to parse if input is blank
			if (current_user_input.length() > 0):
				past_commands.pop_back()
				if (past_commands.empty() || past_commands.back()!=current_user_input):
					past_commands.append(current_user_input)
				current_past_command = past_commands.size() - 1
				
				if (!parse_input(current_user_input)):
					draw_new_line("  Command not recognised. Type '%s' to list all available commmands." % HELP_COMMAND, false, true, false)
					
					# Display current context
					draw_new_line("", true, true,false)
					
				current_user_input = ""
				
				past_commands.append(current_user_input)
				current_past_command = past_commands.size() - 1
				
			return
		
		# Detect TAB auto-complete
		if event.scancode == KEY_TAB:
			# Don't attempt to auto-complete if input is blank
			if (current_user_input.length() > 0):
				
				var split_input = current_user_input.split(" ", false)
				
				if (split_input.size() > 0):
					if (split_input.size() == 1):
						var hint_text = split_input[0]
				
						# Search folders
						var folder_search_results = []
						
						if (current_context.working_directory.child_directories.size() > 0):
							for folder in current_context.working_directory.child_directories:
								if (folder.to_string().to_lower().begins_with(hint_text.to_lower())):
									folder_search_results.append(folder)
						
						if (folder_search_results.size() > 0):
							bbcode_text = bbcode_text.left(bbcode_text.length()-current_user_input.length())
							current_user_input = str(folder_search_results[0].to_string())
							bbcode_text += current_user_input
						
						# Search documents
						var document_search_results = []
						
						if (current_context.working_directory.child_files.size() > 0):
							for document in current_context.working_directory.child_files:
								if (document.to_string().to_lower().begins_with(hint_text.to_lower())):
									document_search_results.append(document)
						
						if (document_search_results.size() > 0):
							bbcode_text = bbcode_text.left(bbcode_text.length()-current_user_input.length())
							current_user_input = str(document_search_results[0].to_string())
							bbcode_text += current_user_input
					elif (split_input.size() == 2):
						var cmd = split_input[0]
						var hint_text = split_input[1]
				
						# Search folders
						var folder_search_results = []
						
						if (current_context.working_directory.child_directories.size() > 0):
							for folder in current_context.working_directory.child_directories:
								if (folder.to_string().to_lower().begins_with(hint_text.to_lower())):
									folder_search_results.append(folder)
						
						if (folder_search_results.size() > 0):
							bbcode_text = bbcode_text.left(bbcode_text.length()-current_user_input.length())
							current_user_input = cmd + " " + str(folder_search_results[0].to_string())
							bbcode_text +=  current_user_input
						
						# Search documents
						var document_search_results = []
						
						if (current_context.working_directory.child_files.size() > 0):
							for document in current_context.working_directory.child_files:
								if (document.to_string().to_lower().begins_with(hint_text.to_lower())):
									document_search_results.append(document)
						
						if (document_search_results.size() > 0):
							bbcode_text = bbcode_text.left(bbcode_text.length()-current_user_input.length())
							current_user_input = cmd + " " + str(document_search_results[0].to_string())
							bbcode_text += current_user_input
			

const SWEAR_WORDS = [
	"ass",
	"fuck",
	"shit",
	"cunt"
]

func parse_input(input : String):
	var split_input = input.split(" ", false)
	
	if (split_input.size() > 0):
		match (split_input[0].to_lower()):
			CHANGE_DIRECTORY_COMMAND:
				if (split_input.size() == 1):
					# not enough arguments supplied
					draw_new_line("  No path specified.", false, true, true)
					pass
				
				else:
					if (split_input[1] == ".."):
						# Go up a level
						if (current_context.working_directory.parent_directory != null):
							current_context.working_directory = current_context.working_directory.parent_directory
							
						# Display current context
						draw_new_line("", true, true, false)
						return true
					
					if (current_context.working_directory.child_directories.size() > 0):
						var search_successful = false
						for folder in current_context.working_directory.child_directories:
							if (split_input[1].to_lower() == folder.to_string().to_lower()):
								# Go to sub-folder
								current_context.working_directory = folder
								search_successful = true
								
								# Display current context
								draw_new_line("", true, true, false)
								return true
						
						if (!search_successful):
							draw_new_line("  Path not found.", false, true, false)
							
							# Display current context
							draw_new_line("", true, true, false)
							return true
				
				# Display current context
				draw_new_line("", true, true, false)
				return true
			HELP_COMMAND:
				display_help_commands()
				return true
			DIR_COMMAND:
				if (current_context.working_directory.child_directories.size() == 0 && current_context.working_directory.child_files.size() == 0):
					draw_new_line("  No sub-folders or files.", false, true, true)
					
					# Display current context
					draw_new_line("", true, true, false)
					return true
				
				draw_new_line(" - - - - - - - - - - - - - - - - - ", false, true, false)
				var num_files = current_context.working_directory.child_files.size() if (current_context.working_directory.child_files != null) else 0
				var num_folders = current_context.working_directory.child_directories.size() if (current_context.working_directory.child_directories != null) else 0
				draw_new_line(" [" + str(num_folders) + " folders, " + str(num_files) + " files]", false, true, false)
				draw_new_line(" - - - - - - - - - - - - - - - - - ", false, true, false)
				
				for folder in current_context.working_directory.child_directories:
					draw_new_line("  <DIR> " + folder.to_string(), false, true, false)
					num_files = folder.child_files.size() if (folder.child_files != null) else 0
					num_folders = folder.child_directories.size() if (folder.child_directories != null) else 0
					draw_new_line(" [" + str(num_files) + " files, " + str(num_folders) + " folders] ", false, false, false)
				
				if (current_context.working_directory.child_directories.size() > 0 && current_context.working_directory.child_files.size() > 0):
					newline()
					bbcode_text += "\n"
				
				for file in  current_context.working_directory.child_files:
					draw_new_line("  " + file.to_string(), false, true, false)	
				
				newline()
				bbcode_text += "\n"
				
				# Display current context
				draw_new_line("", true, true, false)
				return true
			CLEAR_COMMAND:
				clear();
				# Display current context
				draw_new_line("", true, false, false)
				return true
			QUIT_COMMAND:
				emit_signal("exit")
#				get_tree().quit()
				return true
		
		# Search documents
		var document_search_results = []
		
		if (current_context.working_directory.child_files.size() > 0):
			for document in current_context.working_directory.child_files:
				if (document.to_string().to_lower() == split_input[0].to_lower()):
					document_search_results.append(document)
		
		if (document_search_results.size() > 0):
			draw_new_line(" - - - - - - - - - - - - - - - - - ", false, true, false)
			draw_new_line("File name: %s" % str(document_search_results[0].document_name), false, true, false)
			if (document_search_results[0].size_kb != null):
				draw_new_line("Size: %sKb" % str(document_search_results[0].size_kb), false, true, false)
			draw_new_line(" - - - - - - - - - - - - - - - - - ", false, true, false)
			
			draw_new_line(str(document_search_results[0].content), false, true, true)
			
			# Display current context
			draw_new_line("", true, true, false)
			return true
		
		# Easter egg commands
		if split_input[0] in SWEAR_WORDS:
			draw_new_line("I'm sorry you feel that way :(", false, true, false)

			# Display current context
			draw_new_line("", true, true, false)
			return true
		
		if split_input[0] == "time":
			var datetime = OS.get_datetime()
			var hour = datetime["hour"]
			var minute = datetime["minute"]
			var second = datetime["second"]
			
			var am_pm = "AM" if hour < 12 else "PM"
			var final_time = str(hour % 12) + ":" + str(minute) + ":" + str(second) + " " + am_pm
			
			draw_new_line("  Current time: %s" % final_time + ", "+ str(current_context.date), false, true, false)
			
			newline()
			bbcode_text += "\n"
			
			# Display current context
			draw_new_line("", true, true, false)
			return true
			
		if split_input[0] == "zork":
			
			draw_new_line("Sorry bud - bit beyond my skills!", false, true, false)
			
			newline()
			bbcode_text += "\n"
			
			# Display current context
			draw_new_line("", true, true, false)
			return true
	
	return false

func display_help_commands():
	draw_new_line("", false, true, false)
	draw_new_line("  %s       Change working directory." % CHANGE_DIRECTORY_COMMAND, false, true, false)
	draw_new_line("  %s    Clear the terminal window." % CLEAR_COMMAND, false, true, false)
	draw_new_line("  %s      Display files and folders in the current working directory." % DIR_COMMAND, false, true, false)
	draw_new_line("  %s     Terminate the current terminal session." % QUIT_COMMAND, false, true, false)
	
	newline()
	bbcode_text += "\n"
	
	# Display current context
	draw_new_line("", true, true, false)

# Store past commands in an array so user can scroll back through using arrow keys
