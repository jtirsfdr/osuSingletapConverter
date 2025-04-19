package osusingletapconverter

//60000 / ms = BPM
import "core:fmt"
import "core:os"
import "core:strings"
import "core:strconv"


//Modify version (diff) line

main :: proc() {

	//Read file
	osufile, ok := os.read_entire_file("cfextra.osu")
	defer delete(osufile)

	if !ok { 
		fmt.println("unable to read file")
		os.exit(1)
	}

	//Get all timing points and BPMs
	osufiless := strings.split_lines(string(osufile))
	defer delete(osufiless)

	timings : [dynamic][2]int
	defer delete(timings)

	oldhitobjects : [dynamic]string
	newhitobjects : [dynamic]string
	defer delete(oldhitobjects)
	defer delete(newhitobjects)

	for line, i in osufiless {
		if line == "[TimingPoints]" {
			for tp := i+1; osufiless[tp] != "[Colours]"; tp += 1{		
				//Add all uninherited timing points to list
				templine := strings.split(osufiless[tp], ",")
				defer delete(templine)
				if len(templine) >= 7 {
					if templine[6] == "1" {
						append(&timings, [2]int{ strconv.atoi(templine[0]), strconv.atoi(templine[1]) })
					}
				}
			}
		}
		if line == "[HitObjects]" {
			for tp := i+1; tp < len(osufiless)-1; tp += 1{
				append(&oldhitobjects, osufiless[tp])
			}
		}
	}
	//Also 1/3s :)
	//Also check for which bpm to apply this for (for varying bpm maps)
	//Delete all hitobjects faster than 1/4 BPM 
	//Get line, compare to next line, if difference > bpm/4, delete second line, if not, go to next line
	notst := false
	for line, i in oldhitobjects {
		if notst == true {
			notst = false
			continue
		}
		if i < len(oldhitobjects)-1 {
			tempho1 := strings.split(line, ",")
			tempho2 := strings.split(oldhitobjects[i+1], ",")
			if strconv.atoi(tempho2[2]) - strconv.atoi(tempho1[2]) <= timings[0][1]/4 {
				notst = true
			}
			append(&newhitobjects, line)
		}
	}
	output, err := os.open("test.osu", os.O_RDWR|os.O_CREATE|os.O_TRUNC, 0o666)
	defer os.close(output)
	for line in osufiless {
		newline := strings.concatenate([]string{ line, "\n" })
		_, _ = os.write(output, transmute([]u8)newline)
		if line == "[HitObjects]" { break }
	}
	for line in newhitobjects {
		newline := strings.concatenate([]string{ line, "\n" })
		_, _ = os.write(output, transmute([]u8)newline)
	}
	fmt.println("done")
}
