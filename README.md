# Godot-Kuwahara-filter
A Kuwahara Filter using the gd shading language.

## Use
The .gdshader file should just work when placed into a Godot 4.0 project.

I can't handle C style syntax without the preprocessor so have used it in the .shader source file. 
If you wish to make any changes and build to a gdshader just use GCC with the -E flag and manually clean up the output. 
