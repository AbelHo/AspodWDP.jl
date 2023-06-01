function analyse_auto()
    open(joinpath(homedir(), "Desktop/aspod/test.command"), "w") do file
        write(file, "#!/usr/bin/env zsh\n echo edited this text file 2022-06-01T01:50")
    end
end
