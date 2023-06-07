using Dates

string__merge_VidAu_folder = """
#!/usr/bin/env zsh
julia -e 'using AspodWDP; merge_VidAu_folder();'

exit 0;

"""

function edit_files()
    open(joinpath(homedir(), "Desktop/aspod/test.command"), "w") do file
        write(file, "#!/usr/bin/env zsh\n echo edited this text file " * string(now()))
    end

    open(joinpath(homedir(), "Desktop/aspod/run_mergeVideoAudio.command"), "w") do file
        write(file, string__merge_VidAu_folder)
    end

    @info "EDITED Files!"

end

