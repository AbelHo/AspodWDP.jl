module AspodWDP
#export cal_imgsfol, cal_imgsVideo, calibrate_video_checkerboard
# Write your package code here.
include("edit_file.jl")
#include("projection.jl")
greet() = print("Hello World!")
# analyse_auto() = println("Analysis temporary interface begins....\n\n\n\n")
export greet, analyse_auto
end
