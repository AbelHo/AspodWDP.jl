function analyse_auto()
    open(joinpath(homedir(), "Desktop/aspod/test.command"), "w") do file
        write(file, "this is a test")
    end
end
