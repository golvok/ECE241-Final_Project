ECE241-Final_Project
====================
Authors: **Matthew Walker** and **Linda Shen**

Almost all of the commits may be golvok(Matthew Walker)'s, but we pair-programmed essentially the whole thing.

This is our final project for Digital Systems (ECE241). Here follows some random excerpts from the report, and scroll down for some video.

###Intro

The goal of this project was to detect
and track motion in real time. Images
were extracted from a video camera and
analyzed to determine movement
between each frame and the centre of
motion was tracked. The results were
filtered and displayed. 

The project was done on an Altera DE2 board. (Cyclone II)

Explanations
------------
###Block Diagram 

![Block diagram](./doc/block_diagram.png?raw=true)

###Smoothing

To smooth the binary image, the 8 pixels surrounding the current pixel, as well as it’s value, are considered. If all 9 are high, we display the center one as high. To minimize the number of clock cycles needed, the pixels are loaded into 3 shift registers, one for the row above, below, and current. They are then shifted as it moves across the image. 

###Centroid Calcultation
The centroid is computed by dividing the x and y totals by the difference count. This must be done at a slower clock speed, as the dividend and divisor are large and variable.

###Motion Tracking/History
The centroid is stored in a shift register that keeps the centroid location of 20 frames. This history is drawn to show the path of motion, in the lower right corner of the screen.

###"Random" 3 Cycle Delays
There is a 3 clock cycle delay between the setting of the read address and the value being ready from the RAMs. We buffer pixel locations in several places to accommodate this delay.

Video Links
-----------
###Short Demo

<a href="http://www.youtube.com/watch?feature=player_embedded&v=7-euBfdgQd0
" target="_blank"><img src="http://img.youtube.com/vi/7-euBfdgQd0/0.jpg" 
alt="long demo" width="240" height="180" border="10" /></a>

###Long Demo

<a href="http://www.youtube.com/watch?feature=player_embedded&v=DNowxkbowgg
" target="_blank"><img src="http://img.youtube.com/vi/DNowxkbowgg/0.jpg" 
alt="short demo" width="240" height="180" border="10" /></a>