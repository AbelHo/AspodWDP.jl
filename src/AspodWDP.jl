module AspodWDP
#export cal_imgsfol, cal_imgsVideo, calibrate_video_checkerboard
# Write your package code here.
include("media_info.jl")
include("main.jl")
# include("edit_file.jl")

greet() = print("Hello World!")
# analyse_auto() = println("Analysis temporary interface begins....\n\n\n\n")
export greet, analyse_auto
analyse_auto()
end
