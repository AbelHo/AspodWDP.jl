module AspodWDP
#export cal_imgsfol, cal_imgsVideo, calibrate_video_checkerboard
# Write your package code here.
include("media_info.jl")
include("main.jl")
include("edit_file.jl")
edit_files()

greet() = print("Hello World!")
# analyse_auto() = println("Analysis temporary interface begins....\n\n\n\n")
export greet, analyse_auto, merge_VidAu_folder, edit_files
# analyse_auto()
end
