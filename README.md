# `<Game Name Here>`
## About
It uses:
- GDScript
- Godot 4.7

## Developers
1. discord @caelan1999
2. discord @corbinscreations
3. discord @megadragon0779_97737
4. discord @dingus4882
5. discord @flamelane





## Game Blueprint

### Globals

#### Sound Manager
Has several sound types, like Button.
Sound oneshot will be played on SoundManager.play(SoundType.Button) or other types. 
Could be for attacks with differnt weapons, ...
Has a volume, at which the Sounds will be played. Updated from VariableController

#### Music Manager
Has several music types, like Menu or Game/Level.
Music will be played on MusicManager.play(MusicType.Menu) or other types. 
Music will loop a type and play different musics from same type at random.
Has a volume, at which the Music will be played. Updated from VariableController

#### VariableController
Manages several variables over the entire game.
It checks for changes in sound, music or keybinds and assignes the new values.
If game is downloaded it also creates a config to save the changes.

#### TimeManager
Stops Gametime on loading into the Level/game scene and then continues when loading finished.
Pauses Game when in Menues.
Saves a time variable for how long the player was in the Game/Level.

#### SceneLoader
Loads scenes.
Preloads some depending on current scene to minimise loadingtimes.

### UI

#### boot splash
Runs an empty animation and displays when main menu is loaded or animation is through to continue to main menu.

#### main menu
Contains buttons to go to settings, credits or start a game.

#### options combined
Options scene with subscenes.
Subscenes are Key remapping and sound/music volume changes.

#### inputs
button and slider without images to change them easier.
xor button to only show one of the menues.

### temp
Some temorary sounds and music to not throw errors.
