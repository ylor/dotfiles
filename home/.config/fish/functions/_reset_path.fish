function _reset_path --description "Reset PATH to system login shell defaults"
    set --global --export PATH (string split -- : (env --ignore-environment $SHELL --login --command 'echo $PATH'))
end
