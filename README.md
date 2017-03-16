


# Jumble Jam
## mpcs51030-2017-winter-project-RAM0N-LUIS
Student: Ramon Rodriguez
CNET: ramonlrodriguez
HW: Final Project


Jumble Jam is an iOS application that creates slider puzzles from images.  Users can 
select from 40+ beautiful images that come bundled with the game for free or use their 
own image from their personal Photo Library or Camera.


The application is designed to work in portrait mode for iPhones.  The formatting was
designed to work on an iPhone 5SE with auto-layout constraints that should adapt to
other iPhone shapes accordingly.


### The application contains:
- custom splashcreen
- settings bundle to manage user preference for access to Camera and Photo Library
.. - default settings are registered at launch
.. - users can set settings inside the application or the main iPhone settings
- information / instructions on the main screen
- simple, single view interface
- button to select an image for the puzzle
.. - collection view to choose images from a list of existing images
.... - button to choose custom pictures from Photo Library or Camera
.... - alert to select between Photo Library or Camera
- button to set the difficulty level (# of puzzle pieces)
.. - alert to notify that the puzzle will be jumbled for new difficulty setting
- button to jumble puzzle pieces on demand
- shake motion to jumble puzzle pieces on demand
- button to solve the puzzle on demand
.. - alert to when the puzzle is solved
- button to access settings
- hidden button for information
.. - elected to use an intuitive interface and basic instructions on main screen
- custom data structures to manage game data:
.. - PuzzlePiece
.. - Square
.. - GameBoard
- extension files to add functionality
.. - Collection+Shuffle
.. - Image+Effects
- animations
.. - splashscreen
.. - puzzle jumble
.. - puzzle solve
.. - settings view


### Attributions:
[https://drive.google.com/file/d/0B3XzcKIiWyccTDY4N2Jtb0RaMms/view]
[http://stackoverflow.com/questions/6110470/how-to-allow-the-user-to-pick-a-photo-from-his-camera-roll-or-photo-library]
[https://www.raywenderlich.com/136159/uicollectionview-tutorial-getting-started]
[http://stackoverflow.com/questions/24026510/how-do-i-shuffle-an-array-in-swift/24029847#24029847]
[http://stackoverflow.com/questions/39310729/problems-with-cropping-a-uiimage-in-swift]
[https://gist.github.com/cuxaro/20a5b9bbbccc46180861e01aa7f4a267]
