def rvm_script
    "source ~/.rvm/scripts/rvm;"
end

def rvm_run cmd
    `#{rvm_script}#{cmd}`
end