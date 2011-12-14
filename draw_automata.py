#!/bin/python

# Colin Zwiebel
# 6 Nov 2011
#
# Python cellular automata printer
# Created with inspiration from
# * http://home.netwood.net/jessw/paint.py
# * http://mcsp.wartburg.edu/zelle/python/graphics.py

import os, struct, time
# Support 2.x and 3.x Tkinter naming
try:
   from tkinter import *
except:
   from Tkinter import *


GAME_STEP_FILE_NAME = "game_step.txt"
GAME_IMAGE_OUT_DIR = "board_imgs"
GAME_IMAGE_OUT_FORMAT = "gif"
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
        self.photoimage = None
        self.img_out_dir = ''
        if (not os.path.isdir(GAME_IMAGE_OUT_DIR)):
            os.mkdir(GAME_IMAGE_OUT_DIR)
        if (os.path.isdir(GAME_IMAGE_OUT_DIR)):
            self.img_out_dir = GAME_IMAGE_OUT_DIR + '/'

        self.pollGraphicsFile()
        
    def buildCanvases(self, gridWidth, gridHeight):
        if (self.canvas != None):
          self.canvas.destroy()
          del self.canvas
        self.canvas = Canvas(self.rootWin, height=gridHeight, width=gridWidth)
        self.canvas.grid(row=1, column=1)
        
        if (self.photoimage != None):
            del self.photoimage
        self.photoimage = PhotoImage(master=self.rootWin, height=gridHeight, width=gridWidth)
        
    def drawCell(self, x, y, fcolor):
        xPix = x * CELL_WIDTH
        yPix = y * CELL_WIDTH
        rowData = '{' + ' '.join([fcolor]*CELL_WIDTH) + '}'
        for offset in range(0, CELL_WIDTH):
            self.photoimage.put(rowData, (xPix, yPix + offset))
        
        
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
            self.buildCanvases(inputWidth, inputHeight)

        inputData = line[2:]
        boardIsIncomplete = inputRows*inputCols > len(inputData)
        if (boardIsIncomplete):
            print "!! Warning:", inputRows*inputCols, "cell grid specified, but only found", len(inputData)

        for row in range(inputRows):
            for col in range(inputCols):
                fcolor = DEAD_COLOR
                if (row*inputCols + col >= len(inputData)):
                    pass
                elif (inputData[row*inputCols + col] == LIVE_CHAR):
                    fcolor = LIVE_COLOR
                
                self.drawCell(col, row, fcolor)

        # Draw image to canvas for display
        self.canvas.create_image(0,0,image=self.photoimage, anchor="nw")

        if (not boardIsIncomplete):
            self.saveBoardImage()
    
    def saveBoardImage(self):
        tstamp = "%d" % (time.time()*100)   # milliseconds since epoch
        fname = self.img_out_dir + tstamp + '.' + GAME_IMAGE_OUT_FORMAT
        self.photoimage.write(fname, GAME_IMAGE_OUT_FORMAT)

        print "image written to", fname

    def pollGraphicsFile(self):
        try:
            # Check the file
            new_mod = os.path.getmtime(GAME_STEP_FILE_NAME)
            if new_mod != self.graphicsFileLastMod:
                # Do redraw loop
                self.graphicsFileLastMod = new_mod
                self.processInput(GAME_STEP_FILE_NAME)
        except Exception, e:
            print "-- Failed to read file, will retry later. --"
            print e
            

        # Check again in a few milliseconds
        self.rootWin.after(40, self.pollGraphicsFile)	# milliseconds


if __name__ == "__main__":
    window = gridWindow()
    window.rootWin.mainloop();
