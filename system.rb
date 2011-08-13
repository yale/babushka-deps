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
    shell "ln -sf ~/.vim/gvimrc ~/.gvimrc"
  end
end


dep 'rvm' do
  met? {
    "~/.rvm/scripts/rvm".p.file?
  }

  meet {
    shell 'bash -c "`curl https://rvm.beginrescueend.com/install/rvm`"'
  }
end

dep 'rvm globals' do
  requires 'rvm'

  define_var :rubyies, :default => "ruby-1.9.2", :message => "which rubies do you want to create? (seperate by ,)"
  define_var :gems, :default => "bundler, rake, gemedit, powder", :message => "which gems do you want to install into global? (seperate by ,)"

  def rvm_script
    "source ~/.rvm/scripts/rvm;"
  end

  def rvm_run cmd
    shell rvm_script + cmd
  end

  def rubies
    var(:rubies).split(/ *, */)
  end

  def gems
    var(:gems).split(/ *, */)
  end

  met? {
    # are all required rubies installed?
    ruby_list = `#{rvm_script} rvm list rubies`
    missing = rubies.select{|r| ruby_list[/#{r}/] == nil}
    unless missing.empty?
      false
    else
      # are all required gems installed?
      result = true;
      rubies.each do |r|
        list = `#{rvm_script} rvm use #{r}@global;gem list`

        # are all gems in the gemset?
        missing = gems.select{|e| list[/#{e}/] == nil}
        result = false and break unless missing.empty?
      end
    end
  }

  meet {
    # log("run: rvm install 1.9.2") and STDIN.gets

    rubies.each do |r|
      log "installing ruby: #{r}"
      rvm_run "rvm install #{r}"
      log "installing gems"
      rvm_run "rvm use --create #{r}@global;" +
        "gem install #{gems.join(' ')}"
    end

  }
end