function pi --wraps pi
    switch "$argv[1]"
        case install remove uninstall update list config auth mcp
            command pi $argv
        case '*'
            command pi --use-theme omarchy-system $argv
    end
end
