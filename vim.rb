require File.expand_path("../helpers/rvm.rb", __FILE__)
dep "configured vim" do
  requires "vim.src", "exuberant-ctags"

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


dep 'vim.src' do
  source 'ftp://ftp.vim.org/pub/vim/unix/vim-7.3.tar.bz2'
  configure_args "--enable-rubyinterp --with-features=huge"

  setup do
    @ruby_support = confirm("ruby support?")
    @clipboard_support = confirm("clipboard support?")
    
    # on :osx do
    #   requires 'rvm configured' if @ruby_support
    # end
    # on :linux do
      requires 'ruby' if @ruby_support
    # end

    configure_args "--enable-clipboard=yes --enable-xterm_clipboard=yes" if @clipboard_support
  end

  before do
    if @ruby_support  and rvm_installed?
      # on :osx do
      #   rvm_run "rvm install 1.9.2"
      #   rvm_run "rvm use 1.9.2"
      # end
      # on :linux do
        rvm_run "rvm system" if rvm_installed?
      # end
      puts rvm_run("rvm current")
      shell("unalias ruby") if which("alias") and which("unalias") and shell("alias").match(/^ruby=/)
    end
    true
  end

  met? do
    # if vim is installed, check if the correct version is installed
    if which("vim")
      ruby_satisfied = @ruby_support ? shell('vim --version')["+ruby"] : true
      clipboard_satisfied = @clipboard_support ? shell('vim --version')['+clipboard'] : true
      in_path? and ruby_satisfied and clipboard_satisfied
    else
      false
    end
  end


  after do
    if File.exists? '/usr/bin/vim'
      log_shell "moving /usr/bin/vim to vim.bak", "mv /usr/bin/vim /usr/bin/vim.bak", :sudo => true
    end
    log_shell "linking vim to /usr/bin/vim", "ln -s /usr/local/bin/vim /usr/bin/vim", :sudo => true
  end
end

