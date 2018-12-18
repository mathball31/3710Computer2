# Snake!

All of the main Verilog code and files needed for that code is placed under the main directory. Unfortunately, there was no way found that could put them in a folder without breaking the project within Quartus. However, the tests and unneeded documents have been separated into folders aptly named "tests" and "documents". Refer to the assembler folder for the assembler and other files pertaining to it. Datapath should already be placed as the top-level module, but that is the file that runs the entire program.

Please be aware that to run the full program on another computer, certain lines of code must be changed. These changes take place in the VGA.v and Memory.v files. These lines refer to the full path of the Glyph.txt and snake.mif files, which differs from computer to computer, so change them to the path within your computer. Refer to the lines already written if there is any confusion.
  In VGA, this is on line 116. In Memory, this is on line 15.
