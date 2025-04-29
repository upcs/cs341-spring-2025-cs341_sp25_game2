# Welcome to WHERE IS WALLY!
This game was designed and implemented by the following students of University of Portland (UP) in their Software Engineering course (CS341): Kaitlyn Atalig, Jacqui Bouchard, Tyler Crosbie, Lucian Kennelly, and Joshua Krasnogorov. The intended use of the game is for UP students to access via the university's website and play to increase engagement on the website and increase school pride.

## ARTISTIC CREDITS

The tile maps found in the artwork of the game have been put together from the original tile sets created by various artists as indicated below. All artists' work was found through the database OpenGameArt.org.

|          Tiles        |         Artist - License           |
|-----------------------|------------------------------------|
| Ground textures       | gfx0 - [Creative Commons](https://creativecommons.org/licenses/by/4.0/)            |
| Trees, shrubbery      | (see APPENDIX: plantsCredits.txt) |
| Brick buildings/walls | (see APPENDIX: CREDITS-colonial.txt)         |
| Roof types            | (see APPENDIX: CREDITS-roofs.txt)            |
|Cosmic Legacy for Computer Science Shiley minigame | (see APPENDIX: CREDITS-PetricakeGames) |
|Neo Zero CyberPunk City Shiley Electrical Eng. minigame | (see APPENDIX: CREDITS-Yanin)|
|RGP Urban Kit Civil Eng. Shiley Minigame | (see APPENDIX: CREDITS-Kenney) |
|Sci-fi survival camp Mechanical Eng. Shiley Minigame | (see APPENDIX: CREDITS-Penusbmic) |
--------------------------------------------------------------

|    Pictures   |         Artist - License    |
|---------------|-----------------------------|
| Classroom pixel art | [LanaOnTheRoad](https://www.deviantart.com/lanaontheroad/art/Pixel-Art-Classroom-B-2-807285585) |
| Menu scene background | Found at *[stockcake.com](https://www.google.com/url?) |
| Books for library minigame | (see APPENDIX: CREDITS - Knowledge Vectors by Vecteezy) |
| Robot for Shiley minigame | (see APPENDIX: CREDITS-Hiskia Revaldo) |
| Assests Free Laser Bullets for CS Shiley MiniGame |(see APPENDIX:CREDITS-Wenrexa) |

-----------------------------------------------------------------------------------------
|         Music        |         Artist - License           |
|-----------------------|------------------------------------|
| Porto mp3 (Main scene soundtrack) | Evan Frueh (UP student)|
| Energetic Chiptune Adventure (Shiley Minigame soundtrack) | (see APPENDIX: CREDITS-Nicholas Panek)|
*stockcake.com is currently not a working site.

## Acceptance Tests
- The game loads within 7 seconds on any standard browser
- The campus map loads fully and correctly via web-launch on either computers or mobile devices. 
- With input from keyboard keys or mobile screen taps, the Game User Interface (GUI) responds correctly with movement from Wally. 
- The user shouldn’t be able to move Wally through walls and past campus map boundaries. 
- The user plays a minigame, gets a high score, and can see their username and high score on the leaderboard. 

## Design & Implementation Constraints
The project must be completed by the end of the semester. The game must be family friendly as it will be played by high school students and possibly younger users. All text is displayed in English, which will not allow the user access to secure information on the up.edu site. We will comment on and document our code for future developers since we are not expected to maintain the software continually. The game's performance should be very minimally demanding as the game will be 2D, use pixel art, and have a small number of entities involved. The game will also be attached to a university website as a link and not embedded into it unless the clients require it. 

## BADGES
Code coverage for unit tests: estimated directly by the CS341Game2 team as regular code coverage estimation is not implemented in Godot's testing framework yet and we are not using json
- Including all lines we've written: 8.9%

### HOW WE ESTIMATED
#### Including All Lines:
- Summed the total lines of code the team has written. This code excludes test code. (2198 lines)
- Summed the total lines of our own code that the test files called. (196 lines)
- Divided the total code called by tests by the total lines of code we wrote.

### CAVEATS
- Many of the functions in many of the gd script files are functions that Godot already has within its system. So, we did not choose to test many of those. 
- Much of our overall testing was done manually by running the game and using beta release testers.
- By manually playing the game ourselves and from our beta testers, we were able to test all our accpetance tests accurately. The only caveat associated with the acceptance tests is that it can sometimes take longer for the game to load on a user's device for the first time. After this first time, it should not take longer than that first time to load. The acceptance tests were 90% if not 100% covered by our manual tests.

### BUG FIXES
- Fixed bug where player could see outside of the map or run outside of the map
- Fixed bug where browser (specifically Edge) displayed black background
- Fixed bug where player couldn't run around the big Oak tree
- Fixed bug where player could run through the trees (instead of behind them)

## APPENDIX
[plantsCredits.txt](https://github.com/user-attachments/files/18759349/plantsCredits.txt) \
[CREDITS-colonial.txt](https://github.com/user-attachments/files/18759367/CREDITS-colonial.txt) \
[CREDITS-roofs.txt](https://github.com/user-attachments/files/18759389/CREDITS-roofs.txt) \
[CREDITS-Knowledge Vectors by Vecteezy](https://www.vecteezy.com/free-vector/knowledge) \
[CREDITS-PetricakeGames](https://petricakegames.itch.io/cosmic-legacy-scifi-tileset) \
[CREDITS-Yanin](https://yaninyunus.itch.io/neo-zero-cyberpunk-city-tileset?download#google_vignette) \
[CREDITS-Kenney](https://creativecommons.org/publicdomain/zero/1.0/) \
[CREDITS-Hiskia Revaldo](https://www.vecteezy.com/free-vector/80s) \
[CREDITS-Wenrexa](https://wenrexa.itch.io/laser2020) \
[CREDITS-Nicholas Panek](https://pixabay.com/music//?utm_source=link-attribution&utm_medium=referral&utm_campaign=music&utm_content=318348) 


