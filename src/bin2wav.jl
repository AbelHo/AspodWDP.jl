function bin2wav(fname; fs=400000, num_channels=4, outfol=fname)
    @ffmpeg_env run(`$ffmpeg -f s16le -ar $fs -ac $num_channels -i $fname -f wav "$outfol${f%%.bin}.wav" -loglevel quiet -n && rm "$fname"`)
end