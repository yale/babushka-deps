def rvm_script
    "source ~/.profile"
end

def rvm_installed?
  "~/.rvm".p.exists?
end

def rvm_run cmd
    log_shell("rvm_run: #{cmd}", rvm_script + cmd)
end

def current_rubies
  out = rvm_run("rvm list rubies")
  rubies = out.scan(/^[=> ]{3}([^ ]+) /).flatten
end