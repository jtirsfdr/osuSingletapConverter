package osusingletapconverter

import rl "vendor:raylib"
import "core:fmt"
import "core:strings"

RES_X :: 640
RES_Y :: 360
LIGHTBLACK : rl.Color : { 40, 40, 40, 255 } 
main :: proc(){
	subfolder := rl.Rectangle{240, 20, 20, 20}
	minsr := rl.Rectangle{430, 20, 20, 20}
	maxsr := rl.Rectangle{520, 20, 20, 20}
	pathcounter := 0
	paths : [dynamic]string

	rl.InitWindow(RES_X, RES_Y, "osu! Singletap Converter")
	rl.SetTargetFPS(60);

	for !rl.WindowShouldClose(){
//-------------- Update ----------------
		if rl.IsFileDropped() {
			droppedfiles := rl.LoadDroppedFiles()
			append(&paths, strings.clone(string(cstring(droppedfiles.paths[0]))))
			pathcounter += 1
			rl.UnloadDroppedFiles(droppedfiles)
		}
//-------------- Draw ------------------
		rl.BeginDrawing()
		rl.ClearBackground(rl.DARKGRAY)
		
		//Header
		rl.DrawRectangle(10, 10, RES_X-20, 40, LIGHTBLACK)
		rl.DrawText("Singletap Conv", 20, 17, 28, rl.BEIGE)
		rl.DrawRectangleRec(subfolder, rl.GRAY)
		rl.DrawText("Search subfolders", 270, 22, 16, rl.BEIGE)
		rl.DrawRectangleRec(minsr, rl.GRAY)
		rl.DrawText("Min SR", 455, 22, 16, rl.BEIGE)
		rl.DrawRectangleRec(maxsr, rl.GRAY)
		rl.DrawText("Max SR", 545, 22, 16, rl.BEIGE)

		for i in 0..<pathcounter{
			rl.DrawText(strings.unsafe_string_to_cstring(paths[i]), 20, 100 + i32(20*i), 16, rl.BEIGE)
		}
		rl.EndDrawing()
	}
	rl.CloseWindow()
}
