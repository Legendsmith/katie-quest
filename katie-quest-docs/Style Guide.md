# [GDscript Class Declaration Order](https://github.com/Scony/godot-gdscript-toolkit/wiki/3.-Linter#class-checks)
# Directories & File Structure
Group files by locality: UI in the `/UI` folder.
- Scripts associated with scenes go together in their relevant folder. Eg, level scenes go in a World folder.
- Sub types can have their own directories. Example: Buttons for the UI go in `UI/Buttons`
- A script is still associated with a subfolder if it's entirely used by such, eg a image handler script is probably for `UI`.
- True standalone Scripts belong in `/Scripts`. The exceptions are Autoloads, which go in their own folder, and Components, which go in `/Scripts/Components`.

## Naming
Follow [Godot Project Best Practices Guide](https://docs.godotengine.org/en/stable/tutorials/best_practices/project_organization.html#style-guide) rules.
Folder and file names use snake_case. All lowercase letters, spaces are repalced with underscores.
Scripts are an exception to this rule, as the convention is to name them after the class name which should be in PascalCase.
## Texture & Art Assets
Textures go in `/Textures`, flat structure. Prefix with the type if needed, Eg. `button_texture_A.tga`.
Full Gallery images and their thumbnails go inside subfolders Full and Thumbnail respectively.
### Sound
  Audio folder. Subfolders are only for categories of sound.
- Music for musical tracks
- Voice for voice acted lines and soundbites.
### Example structure
- /autoload s
	- `SpecialAutoload.gd`
- /audio
	-  `button_sound.wav`
	- /Music
		- `victory_theme.mp3`
- /textures
	- `button_texture_a.tga`
	- `shared_texture.tga`
	- /gallery
		- /full
			- `hot_springs.png`
		- /thumbnails
			- `hot_springs_thumb.tga`
- /ui
	- `Menu.gd`
	- `Menu.tscn`
	- /buttons
		- `Button.gd`
		- `Button.tscn`
- /world
	- `Overworld.tscn`
	- `Level.gd`
	- `Level.tscn`
	- `Battle.tscn`
	- `Battle.gd`
- /entities 
	- `Actor3D.tscn`
	- `Actor3D.gd`
- /scripts
	- `AudioHandler.gd`
	- /components
		- `HealthComponent.gd`
		- `MoveComponent.gd`
## #Godot Folder Colour guide
- UI: Green
- Addons: Grey
- Autoloads: Purple

