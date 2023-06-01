module AspodWDP
#export cal_imgsfol, cal_imgsVideo, calibrate_video_checkerboard
# Write your package code here.
#include("init.jl")
#include("projection.jl")
greet() = print("Hello World!")
analyse_auto() = println("Analysis temporary interface begins....")
export greet, analyse_auto
end
