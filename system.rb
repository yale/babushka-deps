dep "rw sys" do
  requires 'configured zsh' 
  requires "configured git", "configured vim", 'pow', "user in wheel group", "locate daemon running", :on => :osx
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

  requires "vim"

  met? { "~/.vim/".p.exists? }
  meet do
    log_shell "cloning dotvim", "git clone http://github.com/rweng/dotvim.git ~/.vim"
    log_shell "cloning vundle", "git clone http://github.com/gmarik/vundle.git ~/.vim/bundle/vundle"

    # this doesn't work, blocks, so please do it manually
    # log_shell "installing vim bundles", "vim -u ~/.vim/vundle.vim -U NONE +BundleInstall +q"

    log "please run the following command and press enter: " + "'vim -u ~/.vim/vundle.vim -U NONE +BundleInstall +q'"
    STDIN.gets

    log_shell "building", "cd ~/.vim/bundle/Command-T/ruby/command-t;ruby extconf.rb;make"
    shell "ln -sf ~/.vim/vimrc ~/.vimrc"
    shell "ln -sf ~/.vim/gvimrc ~/.gvimrc"
  end
end


