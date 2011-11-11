#!/bin/python

# Colin Zwiebel
# 6 Nov 2011
#
# Python cellular automata printer
# Created with inspiration from http://home.netwood.net/jessw/paint.py

from Tkinter import *
import os, struct

GRAPHICS_FILE_NAME = "game_step.txt"
LIVE_CHAR = 'X'
LIVE_COLOR = 'white'
DEAD_COLOR = 'black'
CELL_WIDTH = 10


class gridWindow:
    def __init__(self):
        self.gridWidth = -1
        self.gridHeight = -1
        self.graphicsFileLastMod = 0;
        
        self.rootWin = Tk()
        self.rootWin.title("NoClass Virtual MIPS Graphics Device")
        
        self.canvas = None
        self.pollGraphicsFile()
        
    def buildCanvas(self, gridWidth, gridHeight):
        if (self.canvas != None):
		        self.canvas.destroy()
        self.canvas = Canvas(self.rootWin, height=gridHeight, width=gridWidth)
        self.canvas.grid(row=1, column=1)
        
    def processInput(self, fname):
        f = open(fname, 'r')
        line = f.readline()
        f.close()

        # '>' is for big endian, 'B' is for unsigned byte
        inputRows = struct.unpack('>B', line[0])[0]
        inputCols = struct.unpack('>B', line[1])[0]
        
        print "%d,%d board" % (inputCols, inputRows)

        inputWidth = inputCols * CELL_WIDTH;
        inputHeight = inputRows * CELL_WIDTH;

        # Check is we changed board size (change of game)
        if (inputWidth != self.gridWidth or inputHeight != self.gridHeight):
            self.buildCanvas(inputWidth, inputHeight)

        inputData = line[2:]
        if (inputRows*inputCols > len(inputData)):
            return
        for row in range(inputRows):
            for col in range(inputCols):
                fcolor = DEAD_COLOR
                if (inputData[row*inputCols + col] == LIVE_CHAR):
                    fcolor = LIVE_COLOR
                x = col * CELL_WIDTH
                x_max = x + CELL_WIDTH
                y = row * CELL_WIDTH
                y_max = y + CELL_WIDTH
                self.canvas.create_rectangle(x, y, x_max, y_max, fill=fcolor)
    
    def pollGraphicsFile(self):
        # Check the file
        new_mod = os.path.getmtime(GRAPHICS_FILE_NAME)
        if new_mod != self.graphicsFileLastMod:
            # Do redraw loop
            self.graphicsFileLastMod = new_mod
            self.processInput(GRAPHICS_FILE_NAME)
        # Check again in a few milliseconds
        self.rootWin.after(100, self.pollGraphicsFile)	# milliseconds


if __name__ == "__main__":
    window = gridWindow()
    window.rootWin.mainloop();
