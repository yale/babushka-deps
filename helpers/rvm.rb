include ShellHelpers

def rvm_script
    "source ~/.rvm/scripts/rvm;"
end

def rvm_run cmd
    shell(rvm_script + cmd)
end