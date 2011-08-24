def rvm_script
    ". ~/.rvm/scripts/rvm;"
end

def rvm_run cmd
    shell(rvm_script + cmd)
end