dep "rw sys" do
  requires 'configured zsh', "configured git", "configured macvim"
end

dep "configured git" do
  requires "git"
  
  met? {"~/.gitconfig".p.exists?}
  meet do
    render_erb "render/gitconfig.erb", :to => "~/.gitconfig".p
  end
end

dep "configured zsh" do
  requires 'rw dotfiles', 'benhoskings:zsh', "oh-my-zsh"
  
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

dep "configured macvim" do
  requires "macvim"
  
  met? { "~/.vim/".p.exists? }
  meet do
    log_shell "cloning dotvim", "git clone https://rweng@github.com/rweng/dotvim.git ~/.vim"
    log_shell "cloning vundle", "git clone http://github.com/gmarik/vundle.git ~/.vim/bundle/vundle"
    
    # this doesn't work, blocks, so please do it manually
    # log_shell "installing vim bundles", "vim -u ~/.vim/vundle.vim -U NONE +BundleInstall +q"
    
    log "please run the following command and press enter: " + "'vim -u ~/.vim/vundle.vim -U NONE +BundleInstall +q'"
    STDIN.gets
    
    log_shell "building", "cd ~/.vim/bundle/Command-T/ruby/command-t;ruby extconf.rb;make"
    shell "ln -sf ~/.vim/vimrc ~/.vimrc"
  end
end