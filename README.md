# Base
# BaseProject

This project is a Godot 4 base template designed to provide a foundation for future games or applications. It includes a set of reusable screens, classes, and resources for rapid prototyping and development.

## Features

- **Main Menu, Editor, Game, and Pop-Up Scenes**: Modular scene structure for easy navigation and extension.
- **Custom Attribute System**: Define and edit attributes with types (String, Integer, Float, Boolean) in the editor.
- **Transition Effects**: Smooth scene transitions using an animated mask.
- **Audio Management**: Centralized interface audio playback with spatial positioning.
- **Resource Loading System**: Loader scene for progressive loading of scenes, images, audio, and data.
- **Random Utilities**: Custom random number utilities for gameplay or procedural generation.
- **UI Panels**: Editor UI for managing attributes, effects, and abilities.

## Project Structure

- `Scenes/` - Main Godot scenes (Main, Title, EditorScene, Loader, PopUp, etc.)
- `Scripts/Globals.gd` - Global singleton for scene management, audio, and utilities.
- `Data/` - Resource scripts and files for attributes and data storage.
- `Audio/`, `Images/`, `Fonts/` - Game assets.
- `.godot/` - Godot's internal project cache (ignored by git).
- `.vscode/` - VS Code settings for Godot integration.

## Main Scripts

- [`Scripts/Globals.gd`](Scripts/Globals.gd): Provides global functions for scene transitions, audio playback, and random utilities.
- [`Scenes/loader.gd`](Scenes/loader.gd): Handles progressive loading of resources at startup.
- [`Data/AttributeType.gd`](Data/AttributeType.gd): Defines the structure and types for custom attributes.
- [`Data/data.gd`](Data/data.gd): Stores dictionaries of all attributes, abilities, and effects.
- [`Scenes/editor_scene.gd`](Scenes/editor_scene.gd): Implements the editor UI logic for managing attributes.

## Usage

1. Open the project in Godot 4.4+.
2. The main scene is set to `Scenes/Main.tscn`, which loads the loader and then the main menu.
3. Use the editor scene to add or modify attributes, effects, and abilities.

## Customization

- Add new scenes to the `Scenes/` folder and register them in the loader if needed.
- Extend the attribute system by modifying [`Data/AttributeType.gd`](Data/AttributeType.gd).
- Add new images, audio, or fonts to their respective folders and update the loader dictionaries.

## License

See individual asset attributions in [`Scripts/Globals.gd`](Scripts/Globals.gd) comments.

---
*This project is intended as a starting point for Godot projects and is structured for easy extension and modification.*
