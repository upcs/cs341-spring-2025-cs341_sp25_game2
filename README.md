# Welcome to WHERE IS WALLY!
This game was designed and implemented by the following students of University of Portland (UP) in their Software Engineering course (CS341): Kaitlyn Atalig, Jacqui Bouchard, Tyler Crosbie, Lucian Kennelly, and Joshua Krasnogorov. The intended use of the game is for UP students to access via the university's website and play to increase engagement on the website and increase school pride.

## ARTISTIC CREDITS

The tile maps found in the artwork of the game have been put together from the original tile sets created by various artists as indicated below. All artists' work was found through the database OpenGameArt.org.

|          Tiles        |         Artist - License           |
|-----------------------|------------------------------------|
| Ground textures       | gfx0 - [Creative Commons](https://creativecommons.org/licenses/by/4.0/)            |
| Trees, shrubbery      | (see APPENDIX: plantsCredits.txt) |
| Brick buildings/walls | (see CREDITS-colonial.txt)         |
| Roof types            | (see CREDITS-roofs.txt)            |
--------------------------------------------------------------

|    Pictures   |         Artist - License    |
|---------------|-----------------------------|
| Classroom pixel art | [LanaOnTheRoad](https://www.deviantart.com/lanaontheroad/art/Pixel-Art-Classroom-B-2-807285585) |
| Menu scene background | Found at *[stockcake.com](https://www.google.com/url?) |
| Books for library minigame | (see APPENDIX: CREDITS - Knowledge Vectors by Vecteezy ) |
-----------------------------------------------------------------------------------------
|         Music        |         Artist - License           |
|-----------------------|------------------------------------|
| Porto mp3 (Main scene soundtrack) | Evan Frueh (UP student)|

*stockcake.com is currently not a working site.

## BADGES
Code coverage: 46.7% (estimated directly by the CS341Game2 team as regular code coverage estimation is not implemented in Godot's testing framework yet and we are not using json).

### HOW WE ESTIMATED
- Summed the total lines of code the team has written. This total excludes test code and code automatically written by the Godot system. (383 lines)
- Summed the total lines of our own code that the test files called. (179 lines)
- Divided the total code called by tests by the total lines of code we wrote.

### CAVEATS
- Scripts excluded from total lines of code sum: shiley.gd, scene.gd, josh_map_5+7.gd, bc_interior.gd, enemy.gd, and global.gd; this is because they are based on functions automatically written into Godot.
- Need testing: inside_db.gd and start.gd

### BUG FIXES
- Fixed bug where player could see outside of the map or run outside of the map
- Fixed bug where browser (specifically Edge) displayed black background

## APPENDIX
[plantsCredits.txt](https://github.com/user-attachments/files/18759349/plantsCredits.txt) \
[CREDITS-colonial.txt](https://github.com/user-attachments/files/18759367/CREDITS-colonial.txt) \
[CREDITS-roofs.txt](https://github.com/user-attachments/files/18759389/CREDITS-roofs.txt) \
[CREDITS - Knowledge Vectors by Vecteezy](https://www.vecteezy.com/free-vector/knowledge)
