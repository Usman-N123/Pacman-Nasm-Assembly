# Pacman-Nasm-Assembly
Welcome to the classic Pacman game brought to life in NASM assembly 8086! Dive into nostalgic gaming with this assembly-coded Pacman adventure. Navigate mazes, gobble dots, evade ghosts, and enjoy the thrill of retro gaming. Let's relive the arcade era together!

## How To Run
Using Dosbox compiler to run nasm files. [Install Nasm and Dosbox according to the instructions in the link](https://theiteducation.com/how-to-install-nasm-on-windows-10-how-to-type-and-run-assembly-language-program/).
Enter following lines in dosbox window. Mount NASM folder to a Drive  using "mount [driveletter] [NASM Path]".

![Dosbox Instructions](https://github.com/Usman-N123/Pacman-Nasm-Assembly/assets/155843127/694f3149-6195-43ff-99ad-f6e7bbdc6df7)
## Files
- **Pacman.asm:**  The assembly file in which NASM code is written.
- **P1.com:**  executable file or compiled file in MS-DOS
- **pacman.imf:** This is a Music file that is used to play sound at start of the program. It contains sound data. More about sound is given below. Refrences: (https://moddingwiki.shikadi.net/wiki/IMF_Format) (https://www.vgmpf.com/Wiki/index.php?title=IMF)

## Logic
### 1. Pacman😃 and interface
The movement of Pac-Man in the given code is controlled by arrow keys. Press any key to start the game. The movement of Pac-Man in the given code is controlled by arrow keys. During the game any key other than the arrow keys will exit the game. Colliding with the ghosts will also result in end of the game. The score is displayed on the top left corner. You have to score 150 points to win the game.
#### 1.1 Sound
Pacman music is played at the start of the game. "sound:" function is used to play music in the home screen. Function is also called at end of the program once to stop the beep sound which remains stuck in speakers. [Playing sound using imf files is explained completely in this video(Check video description for source code).](https://www.youtube.com/watch?v=ifqq7reyNa0)
### 2. Ghosts
Ghosts use a Targeting system to determine which direction to travel. The decision is between 3 new tiles and turning around is not an option. It will calculate distances from all the possible moves and move to the one with shortest distance.

![Calculating Distance](https://github.com/Usman-N123/Pacman-Nasm-Assembly/assets/155843127/13870eed-b052-44af-8f81-9055a3e50eb9)

During chase, a new target tile is calculated every time before a decision to move is made. Each ghost has it’s unique way of determining the active target tile.
#### 2.1 Blinky
Blinky has the simplest way of determining the target tile. Which is simply the tile where Pac-Man is located.

![Blinky Target](https://github.com/Usman-N123/Pacman-Nasm-Assembly/assets/155843127/2d0794f9-4864-41b7-b488-0694423e0627)

Hence, Blinky will always chase Pacman from behind.
#### 2.2 Pinky
Pinky’s target tile is 4 tiles in front of Pac-Man. 4 left if he is facing left. 4 below if facing below or four to the right when facing right.
4 above and 4 left when facing up.

![Pinky Target](https://github.com/Usman-N123/Pacman-Nasm-Assembly/assets/155843127/88a1b28b-5f25-4ebb-9f84-6ad9e4b774e4)

Hence, Pinky will always chase Pacman from front.
#### 2.3 Safe Places
Pacman has safe places where the ghosts can reach him from behind.

![Safe Places](https://github.com/Usman-N123/Pacman-Nasm-Assembly/assets/155843127/0d260710-3c76-4376-8054-a48586ec2363)

Ghosts cannot go up from these tiles. Hence they will keep looping around near the Pacman.

## Screenshots
![Home Screen](https://github.com/Usman-N123/Pacman-Nasm-Assembly/assets/155843127/9f5ce47b-fbc6-43f1-be6a-6b14117682b1)
![Gameover](https://github.com/Usman-N123/Pacman-Nasm-Assembly/assets/155843127/2ff4f2ac-efff-49ba-9d2a-6b3bce3315bf)

Feel free to contact me if any help needed. Info in bio.
