using FFMPEG
using Glob

function get_fps(file::AbstractString, streamno::Integer = 0)
    streamno >= 0 || throw(ArgumentError("streamno must be non-negative"))
    fps_strs = FFMPEG.exe(
        `-v 0 -of compact=p=0 -select_streams v:0 -show_entries stream=r_frame_rate $file`,
        command = FFMPEG.ffprobe,
        collect = true,
    )
	@debug fps_strs
	try
		fps = split(fps_strs[1], '=')[2]
		if occursin("No such file or directory", fps)
			error("Could not find file $file")
		elseif occursin("N/A", fps)
			return nothing
		end
		return reduce(//, parse.(Int, split(fps,'/')) )
		# return round(reduce(/, parse.(Float64, split(fps,'/')) ), digits=3)
	catch err
		@debug(err)
		return NaN
	end
end

function get_framerate(file::AbstractString, streamno::Integer = 0, video_or_audio="v")
    streamno >= 0 || throw(ArgumentError("streamno must be non-negative"))
	if video_or_audio == "v"
		entries = "r_frame_rate"
	elseif video_or_audio == "a"
		entries = "sample_rate"
	end
	
    fps_strs = FFMPEG.exe(
        `-v 0 -of compact=p=0 -select_streams $video_or_audio:$streamno -show_entries stream="$entries" $file`,
        command = FFMPEG.ffprobe,
        collect = true,
    )
	@debug fps_strs
	try
		fps = split(fps_strs[1], '=')[2]
		if occursin("No such file or directory", fps)
			error("Could not find file $file")
		elseif occursin("N/A", fps)
			return nothing
		end
		return reduce(//, parse.(Int, split(fps,'/')) )
		# return round(reduce(/, parse.(Float64, split(fps,'/')) ), digits=3)
	catch err
		@debug(err)
		return NaN
	end
end

function get_whatever(file::AbstractString, streamno::Integer = 0, video_or_audio="v"; entries_custom=nothing)
    streamno >= 0 || throw(ArgumentError("streamno must be non-negative"))
	if video_or_audio == "v"
		entries = "r_frame_rate"
	elseif video_or_audio == "a"
		entries = "sample_rate"
	end
	if !isnothing(entries)
		entries = entries_custom
	end
	
    fps_strs = FFMPEG.exe(
        `-v 0 -of compact=p=0 -select_streams $video_or_audio:$streamno -show_entries stream="$entries" $file`,
        command = FFMPEG.ffprobe,
        collect = true,
    )
	@debug fps_strs
	try
		fps = split(fps_strs[1], '=')[2]
		if occursin("No such file or directory", fps)
			error("Could not find file $file")
		elseif occursin("N/A", fps)
			return nothing
		end
		if occursin('/', fps)
			return reduce(//, parse.(Int, split(fps,'/')) )
		else
			return parse.(Float64, fps) 
		end
		# return round(reduce(/, parse.(Float64, split(fps,'/')) ), digits=3)
	catch err
		@debug(err)
		return NaN
	end
end

"""
    get_number_frames(file [, streamno])
Query the the container `file` for the number of frames in video stream
`streamno` if applicable, instead returning `nothing` if the container does not
report the number of frames. Will not decode the video to count the number of
frames in a video.
"""
function get_number_frames(file::AbstractString, streamno::Integer = 0)
    streamno >= 0 || throw(ArgumentError("streamno must be non-negative"))
    frame_strs = FFMPEG.exe(
		`-v error -select_streams v:0 -count_packets -show_entries stream=nb_read_packets $file`, #-hide_banner
        # `-v error -select_streams v:0 -count_packets -show_entries stream=nb_read_packets -of csv=p=0 $file`,
        command = FFMPEG.ffprobe,
        collect = true,
    )
	@debug frame_strs
	frame_str = frame_strs[1]
	# num_frames = parse(Int, split(frame_str,'=')[end])
    if occursin("No such file or directory", frame_str)
        error("Could not find file $file")
    elseif occursin("N/A", frame_str)
        return NaN
    end
	
	try
		frame_str = frame_strs[2]
	    return parse(Int, split(frame_str,'=')[end])
	catch err
		@debug (err)
		return NaN
	end
end

function get_duration(file::AbstractString, streamno::Integer = 0)
	try
		streamno >= 0 || throw(ArgumentError("streamno must be non-negative"))

		
		frame_strs = FFMPEG.exe(
			`-show_entries format=duration -v quiet -of csv="p=0" $file`,
			# `-v error -select_streams v:0 -count_packets -show_entries stream=nb_read_packets -of csv=p=0 $file`,
			command = FFMPEG.ffprobe,
			collect = true,
		)
		@debug frame_strs
		frame_str = frame_strs[1]
		# num_frames = parse(Int, split(frame_str,'=')[end])
		if occursin("No such file or directory", frame_str)
			error("Could not find file $file")
		elseif occursin("N/A", frame_str)
			@debug "manually calculate duration"
			return get_number_frames(file) / get_fps(file) |> Float64
		end
	
	# try
		frame_str = frame_str
	    return parse(Float64, split(frame_str,'=')[end])
	catch err
		@debug (err)
		return NaN
	end
end

function get_videos_audiodata(vidfname)
	strs = @ffmpeg_env read(`$ffmpeg -i $vidfname -f s16le -acodec pcm_s16le -loglevel error -`)# .|> Int16;
	# ltoh.(reinterpret(Int16, strs)), get_framerate(vidfname, 0, "a")
	# vid_audioFS =  get_framerate(vidfname, 0, "a")
	# length(strs)/vid_audioFS/2 #vid_auDur
	# get_duration(vidfname) #vid_Dur

	# # method 1, fast and creates array
	# vid_audiodata = Array{Int16}(undef, Int(length(strs)/2)) # 8bits to 16bits per frame
	# map!( x -> strs[2x[1]-1] + Int16(256)*strs[2x[1]] , vid_audiodata, 1:length(vid_audiodata)) # convert to 8bits little endian to Int16 merging each 2 bytes to 1 frame
	# vid_audiodata, get_framerate(vidfname, 0, "a")
	
	# # method 2, slow but easy to read, create array
	# ltoh.(reinterpret(Int16, strs)), get_framerate(vidfname, 0, "a")
	# method 3, fastest, doesnt create array, does the job
	vid_audiodata = reinterpret(Int16, strs)#, get_framerate(vidfname, 0, "a")
	if get_whatever(vidfname, 0, "a"; entries_custom="channels")>1
		vid_audiodata = reshape(vid_audiodata, get_whatever(vidfname, 0, "a"; entries_custom="channels")|>Int, :)'
	end
	vid_audiodata, get_framerate(vidfname, 0, "a")
end

function get_videos_audiodata_direct(vidfname)
	strs = @ffmpeg_env read(`$ffmpeg -i $vidfname -f s16le -acodec pcm_s16le -loglevel error -`)# .|> Int16;
	# ltoh.(reinterpret(Int16, strs)), get_framerate(vidfname, 0, "a")
	# vid_audioFS =  get_framerate(vidfname, 0, "a")
	# length(strs)/vid_audioFS/2 #vid_auDur
	# get_duration(vidfname) #vid_Dur

	# # method 1, fast and creates array
	# vid_audiodata = Array{Int16}(undef, Int(length(strs)/2)) # 8bits to 16bits per frame
	# map!( x -> strs[2x[1]-1] + Int16(256)*strs[2x[1]] , vid_audiodata, 1:length(vid_audiodata)) # convert to 8bits little endian to Int16 merging each 2 bytes to 1 frame
	# vid_audiodata, get_framerate(vidfname, 0, "a")
	
	# # method 2, slow but easy to read, create array
	# ltoh.(reinterpret(Int16, strs)), get_framerate(vidfname, 0, "a")
	# method 3, fastest, doesnt create array, does the job
	reinterpret(Int16, strs), get_framerate(vidfname, 0, "a")
end

####    #####

function extract_vid_au(folname; vidtype=["*.mkv","*.MP4","*.avi","*.mp4"], autype=["*.wav","*.mat","*.flac","*.mp3"])

    vids = []
    for vt in vidtype
        vids = glob(vt, folname);
        if !isempty(vids)
            break;
        end
    end

    audios = []
    for vt in autype
        audios = glob(vt, folname);
        if !isempty(audios)
            break;
        end
    end

    return vids, audios
end

function match_recording(vids, aus; timediff_tolerance=3, tolerance_dur_to_skip=3, get_duration=get_duration)
    if length(vids)==0 || length(aus)==0
        return vids, aus
    end

    if occursin("_1.mat", aus[1]) #calf recording
        filter!( x->occursin("_1.mat",x), aus)
        if length(vids) == length(aus)
            return vids, aus
        else
            @warn "Different total number of videos and corresponding audio file!!! shorten audio list"
            return vids, aus[1:length(vids)]
        end
    end

    
    vids_new = Vector{typeof(first(vids))}()
    aus_new = Vector{typeof(first(aus))}()

    # len_aus = length(aus)
    # au_durs = get_duration.(aus)
    aus_copy = deepcopy(aus)

    # au_ind = 1
    for vid ∈ vids
        vid_dur = get_duration(vid)
        vid_dur < tolerance_dur_to_skip && continue
        for ind ∈ eachindex(aus_copy)
            if abs(vid_dur - get_duration(aus_copy[ind])) < timediff_tolerance
                @debug (basename(vid), basename(aus_copy[ind]), (vid_dur - get_duration(aus_copy[ind])))
                push!(vids_new, vid)
                push!(aus_new, aus_copy[ind])
                deleteat!(aus_copy, ind)
                break
            end
        end
    end

    return vids_new, aus_new
end


@info "LOADED!\tmedia_info"