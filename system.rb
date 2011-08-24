dep "rw sys" do
  requires 'configured zsh', "configured vim"
  on :osx do
    requires "configured git", 'pow', "user in wheel group", "locate daemon running"
  end
end

dep "sh is bash" do
  setup do
    requires 'bash.managed' unless which("bash")
  end

  met? do
     "/bin/sh".p.symlink? and "/bin/sh".p.readlink == which("bash")
  end 

  meet do
    shell "rm -rf /bin/sh", :sudo => true
    shell "ln -s #{which("bash")} /bin/sh", :sudo => true, :perms => 555
  end
end

dep "user in wheel group" do
  define_var :user, :default => shell("whoami"), :message => "Which user do you want to add to the wheel group?"

  met?{shell("dscl . read /Groups/wheel GroupMembership", :sudo => true)[/(^| )#{var(:user)}($| )/]}
  meet{shell "dscl . append /Groups/wheel GroupMembership #{var(:user)}", :sudo => true}
end

dep "locate daemon running" do
  met? {shell("launchctl list", :sudo => true)[/com.apple.locate/]}
  meet do
    log_shell "starting locate daemon", "launchctl load -w /System/Library/LaunchDaemons/com.apple.locate.plist", :sudo => true
  end
end

dep "pow" do
  met?{"~/.pow".p.exists?}
  meet do
    shell "curl get.pow.cx | sh"
  end
end

dep "configured git" do
  requires "git"

  met? {"~/.gitconfig".p.exists?}
  meet do
    render_erb "render/gitconfig.erb", :to => "~/.gitconfig".p
  end
end

dep "configured zsh" do
  requires 'rw dotfiles', 'benhoskings:zsh', "oh-my-zsh", 'ack'
  set :username, shell("whoami")

  met?{"~/.zshrc".p.exists?}
  meet do
    shell "ln -sf ~/.dotfiles/zsh ~/.zsh"
    shell "ln -sf ~/.zsh/zshrc ~/.zshrc"
  end
end

dep "rw dotfiles" do
  met? {"~/.dotfiles".p.exists?}
  meet do
    shell "git clone https://github.com/rweng/dotfiles.git ~/.dotfiles"
  end
end

dep "oh-my-zsh" do
  met? {"~/.oh-my-zsh".p.exists?}
  meet do
    shell "git clone git://github.com/robbyrussell/oh-my-zsh.git ~/.oh-my-zsh"
  end
end

dep "configured vim" do
  on :osx do
    requires "macvim"
  end

  requires "vim", "exuberant-ctags"

  met? { "~/.vim/".p.exists? }
  meet do
    log_shell "cloning dotvim", "git clone http://github.com/rweng/dotvim.git ~/.vim"
    log_shell "cloning vundle", "git clone http://github.com/gmarik/vundle.git ~/.vim/bundle/vundle"

    # this doesn't work, blocks, so please do it manually
    log_shell "installing vim bundles", "vim -u ~/.vim/vundle.vim -U NONE +'silent! BundleInstall' +q"

    # log "please run the following command and press enter: " + "'vim -u ~/.vim/vundle.vim -U NONE +BundleInstall +q'"
    # STDIN.gets

    log_shell "building", "cd ~/.vim/bundle/Command-T/ruby/command-t;ruby extconf.rb;make"
    shell "ln -sf ~/.vim/vimrc ~/.vimrc"
    shell "ln -sf ~/.vim/gvimrc ~/.gvimrc"
  end
end


