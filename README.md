# Sudoku Solver
This is a simple sudoku solver I wrote in my first year of university. It runs on the command line and it's not even all that good. It can solve simple sudoku puzzles with a healthy dose of given digits, but certainly can't solve any puzzles to the degree that Cracking the Cryptic and others can do.

## How to Use
When you run the script, the console will be cleared, and instructions will be printed in the first few lines, followed by a blank grid and a prompt. The cell with an `X` in the grid (starts in the top-left) is the selected cell into which you will input a digit or blank.

- To input a digit into the selected cell, type the digit at the prompt and press `RETURN`.
- To leave the selected cell blank, press `RETURN` without typing a digit.

As you submit numbers and blanks, the `X` will move across the row from left to right, jumping to the start of the next row after you reach the end of the row. To delete a just-submitted digit or blank, type a period `.` and press `RETURN` (the `X` will go back one cell and delete the digit/blank).

In short, write the digits of the sudoku grid in normal English reading order (left to right, top to bottom): type a digit and press `RETURN` for given digits, press just `RETURN` for blanks, and if you make a mistake type a period `.` and press `RETURN`.

To exit the program during this phase, either type an `x` and press `RETURN`, or use `CTRL-C`.

Once you submit all 81 cells the solver will confirm if the grid is correct.

- Type an `n` and press `RETURN` to delete the last cell and re-enter the digit entry phase.
- Type a `y` and press `RETURN` to submit the grid. The solver will then attempt to solve the puzzle.

When it either solves the puzzle or can no longer make progress, it will print out the digits it found.

It will prompt you if you want to have it solve another puzzle.

- To solve another puzzle, type `y` and press `RETURN`, and repeat the process as before.
- To exit, type anything else other than a capital or lowercase `y` and press `RETURN`. Alternatively, use `CTRL-C`.

## How it works
The program is pretty dumb. It intializes a list of candidates for every cell. When a cell's digit is found, cells in the same row, column, and box are updated to remove the discovered digit from their candidates list. The solver understands two basic sudoku solving strategies:

- Naked Single: if a cell has exactly one possible candidate, then that candidate must be the digit that goes into that cell (the cell can't be anything else).
- Hidden Single: if a digit has exactly one cell in a row, column, or box that it is able to be placed in, that digit must go into that cell (the digit can't go into any other cell in that row, column, or box).

The solver does not understand any of the more-advanced strategies (X-wings, Y-wings, pointing pairs/triples, etc), so it's likely to flounder at more difficult puzzles (you know, the difficulties that it would be nice to have a solver be able do for you).

When all cells are filled in, the puzzle is solved. If the solver makes a pass through all 81 cells and is unable to determine a digit during that pass, then it fails to solve the puzzle and just prints out what it was able to do.

## Unknown Issues (will not address/fix)
The script relies on using `os.execute("clear")` to clear and redraw the screen when you input a digit. This might not work on Windows, but I don't know as I don't use Windows.

The grid uses a unicode character for box boundaries (U+2016 DOUBLE VERTICAL LINE `‖`). This might not work in various terminal programs and could render incorrectly.
