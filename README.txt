#----BOMBERMAN GAME CONSOLE VERSION----

HOW TO COMPILE AND RUN:

m4 utility.asm > utility.s
m4 main.asm > main.s
as main.s utility.s -o main.o 
as rand.s -o rand.o
gcc main.o rand.o -o exe
./exe <my_name> <number_of_rows> <number_of_cols>

HOW TO PLAY:

This game is a simplification of the 1983 bomberman game.

1. You have to run the game after compiling it -> ./exe bomber man 50 50 for example
2. Then you will be asked if you want to see the leaderboard and how many records you want to retrieve.
3. Then the game will automatically start -> You will have to provide valid x and y position for the bomb. Unlike the original game, the bomberman cannot die in this version of the game.
4. Whenever a bomb is placed, it will "explode" and reveal some tiles. The possible tiles you can find are:
	- [+] tile -> Gain score
	- [-] tile -> Lose score
	- [$] tile -> Double range rewards that allows you to discover more tiles
	- [*] tile -> This is the exit tile. You can ONLY WIN if you find it.
5. You will lose if you haven no more lives or bombs and can only win if you find the exit tile.
6. If you want to exit at any time, you can just insert -1 whenever asked for an x or y bomb position.
7. At the end, you will be asked if you want to see the leaderboard and how many records to retrieve. 

Some Pictures of how to game looks:

<img width="911" alt="Screen Shot 2021-01-03 at 1 58 09 PM" src="https://user-images.githubusercontent.com/51538046/103485569-99dd8c80-4dcd-11eb-84c6-2238ffd8bf01.png">
<img width="911" alt="Screen Shot 2021-01-03 at 1 57 48 PM" src="https://user-images.githubusercontent.com/51538046/103485570-9e09aa00-4dcd-11eb-9c3c-e6192709ad37.png">
<img width="911" alt="Screen Shot 2021-01-03 at 1 58 42 PM" src="https://user-images.githubusercontent.com/51538046/103485571-a235c780-4dcd-11eb-941b-718521e36603.png">
<img width="911" alt="Screen Shot 2021-01-03 at 1 58 27 PM" src="https://user-images.githubusercontent.com/51538046/103485572-a661e500-4dcd-11eb-9115-aa460e9684d6.png">

