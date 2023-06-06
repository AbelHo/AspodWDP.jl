function analyse_auto(folname=joinpath(homedir(), "Desktop/aspod/new"))
    vids, audios = extract_vid_au(folname)
    vids, audios = match_recording(vids, audios)
    @show [vids, audios]
    return vids, audios
end