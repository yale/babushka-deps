def rvm_script
    "source ~/.rvm/scripts/rvm;"
end

def rvm_run cmd
    shell(rvm_script + cmd)
end

def current_rubies
  out = rvm_run("rvm list rubies")
  rubies = out.scan(/^[=> ]{3}([^ ]+) /).flatten
end