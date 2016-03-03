# Raycaster in a maze

A simulated 3D environment with raycasting in a 2D randomly generated maze.
Using a fixed number of raycasts it determines the distance of walls from the player and draws them accordingly.

The maze is generated with the recursive backtracking algorithm and then converted to a format suitable for the renderer.

Player controls:
* W/S - move forward and backward
* A/D - strafe left and right
* Mouse - turn left and right
* TAB - toggle overlay map

Written in Lua with [LÖVE](https://love2d.org/) 0.10.1.

The raycaster subsystem is a partial port from http://www.playfuljs.com/a-first-person-engine-in-265-lines/
