using FFMPEG
include("media_info.jl")

split_basename(x) = splitext(basename(x))[1]

function analyse_auto(;folname=joinpath(homedir(), "Desktop/aspod/new"), newfolname=joinpath(homedir(), "Desktop/aspod/merged"))
    vids, audios = extract_vid_au(folname)
    vids, audios = match_recording(vids, audios)
    @show [vids, audios]

    !isdir(newfolname) && mkdir(newfolname)
    combine_VidAu.(vids, audios, joinpath.(newfolname, split_basename.(vids).*".mp4") )
    return vids, audios
end

function combine_VidAu(vidfname, aufname, new_vidfname)
    output = @ffmpeg_env run(`ffmpeg -i "$vidfname" -i "$aufname" -map 0:v -map 1:a -vf format=yuv420p -ar 96000 -af loudnorm=I=-16:LRA=11:TP=-1.5 "$new_vidfname" -y`)
end