threads=5

rm -r ./produce/*
mkdir ./produce

PROJ='plastic_bottle_cutter_03.scad'
EX='openscad '$PROJ
OS=$EX

declare -a parts

spacer_height_diff="0.6"

parts+=("$OS -o produce/nuts.stl -D part=\"nuts\"")

parts+=("$OS -o produce/vice.stl -D part=\"vice\"")
parts+=("$OS -o produce/vice_bolt.stl -D part=\"vice_bolt\"")

parts+=("$OS -o produce/6203_caps.stl -D bearing_index=0 -D part=\"caps\"")
parts+=("$OS -o produce/6203_main.stl -D part=\"main\" -D bearing_index=0 -D string_height=13.0 -D spacer_height_diff=$spacer_height_diff -D string_width=1.0")
parts+=("$OS -o produce/6203_14p0.stl -D part=\"spacer\" -D bearing_index=0 -D string_height=13.5  -D string_height_req=14.0 -D spacer_height_diff=$spacer_height_diff -D string_width=1.0")
parts+=("$OS -o produce/6203_13p0.stl -D part=\"spacer\" -D bearing_index=0 -D string_height=13.5  -D string_height_req=13.0 -D spacer_height_diff=$spacer_height_diff -D string_width=1.0")
parts+=("$OS -o produce/6203_12p0.stl -D part=\"spacer\" -D bearing_index=0 -D string_height=13.5 -D string_height_req=12.0 -D spacer_height_diff=$spacer_height_diff -D string_width=1.0")
parts+=("$OS -o produce/6203_11p0.stl -D part=\"spacer\" -D bearing_index=0 -D string_height=13.5 -D string_height_req=11.0 -D spacer_height_diff=$spacer_height_diff -D string_width=1.0")
parts+=("$OS -o produce/6203_10p0.stl -D part=\"spacer\" -D bearing_index=0 -D string_height=13.5 -D string_height_req=10.0 -D spacer_height_diff=$spacer_height_diff -D string_width=1.0")
parts+=("$OS -o produce/6203_9p0.stl -D part=\"spacer\" -D bearing_index=0 -D string_height=13.5 -D string_height_req=9.0 -D spacer_height_diff=$spacer_height_diff -D string_width=1.0")
parts+=("$OS -o produce/6203_8p0.stl -D part=\"spacer\" -D bearing_index=0 -D string_height=13.5 -D string_height_req=8.0 -D spacer_height_diff=$spacer_height_diff -D string_width=1.0")
parts+=("$OS -o produce/6203_7p5.stl -D part=\"spacer\" -D bearing_index=0 -D string_height=13.5 -D string_height_req=7.5 -D spacer_height_diff=$spacer_height_diff -D string_width=1.0")
parts+=("$OS -o produce/6203_7p0.stl -D part=\"spacer\" -D bearing_index=0 -D string_height=13.5 -D string_height_req=7.0 -D spacer_height_diff=$spacer_height_diff -D string_width=1.0")

parts+=("$OS -o produce/R82RS_caps.stl -D part=\"caps\"")
parts+=("$OS -o produce/R82RS_15p0.stl -D part=\"main_spacer\" -D bearing_index=1 -D string_height=15.0 -D spacer_height_diff=$spacer_height_diff -D string_width=1.0")
parts+=("$OS -o produce/R82RS_14p0.stl -D part=\"main_spacer\" -D bearing_index=1 -D string_height=14.0 -D spacer_height_diff=$spacer_height_diff -D string_width=1.0")
parts+=("$OS -o produce/R82RS_13p0.stl -D part=\"main_spacer\" -D bearing_index=1 -D string_height=13.0 -D spacer_height_diff=$spacer_height_diff")
parts+=("$OS -o produce/R82RS_12p0.stl -D part=\"main_spacer\" -D bearing_index=1 -D string_height=12.0 -D spacer_height_diff=$spacer_height_diff")
parts+=("$OS -o produce/R82RS_11p0.stl -D part=\"main_spacer\" -D bearing_index=1 -D string_height=11.0 -D spacer_height_diff=$spacer_height_diff -D string_width=1.0")
parts+=("$OS -o produce/R82RS_10p5.stl -D part=\"main_spacer\" -D bearing_index=1 -D string_height=10.5 -D spacer_height_diff=$spacer_height_diff")
parts+=("$OS -o produce/R82RS_10p0.stl -D part=\"main_spacer\" -D bearing_index=1 -D string_height=10.0 -D spacer_height_diff=$spacer_height_diff -D string_width=1.2")
parts+=("$OS -o produce/R82RS_9p5.stl -D part=\"main_spacer\" -D bearing_index=1 -D string_height=9.5 -D spacer_height_diff=$spacer_height_diff")
parts+=("$OS -o produce/R82RS_9p0.stl -D part=\"main_spacer\" -D bearing_index=1 -D string_height=9.0 -D spacer_height_diff=$spacer_height_diff")
parts+=("$OS -o produce/R82RS_8p5.stl -D part=\"main_spacer\" -D bearing_index=1 -D string_height=8.5 -D spacer_height_diff=$spacer_height_diff")
parts+=("$OS -o produce/R82RS_8p0.stl -D part=\"main_spacer\" -D bearing_index=1 -D string_height=8.0 -D spacer_height_diff=$spacer_height_diff")
parts+=("$OS -o produce/R82RS_7p5.stl -D part=\"main_spacer\" -D bearing_index=1 -D string_height=7.5 -D spacer_height_diff=$spacer_height_diff -D string_width=1.0")
parts+=("$OS -o produce/R82RS_7p0.stl -D part=\"main_spacer\" -D bearing_index=1 -D string_height=7.0 -D spacer_height_diff=$spacer_height_diff -D string_width=1.0")


index=0
for (( ; ; ))
do
    count=$(ps aux --no-heading | grep -v grep | grep $PROJ | wc -l)
    if [ "$count" -lt "$threads" ]
    then 
	current=${parts[$index]}
	if [ -z "$current" ]; then break; fi
	index=$((index+1))
	
	echo $current
	$current &
    fi
    sleep 1
done