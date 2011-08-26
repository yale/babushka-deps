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
  
    # on osx, ruby is assumed
    on :linux do
      requires 'ruby.managed', 'ruby-dev.managed' if @ruby_support
    end

    configure_args "--enable-clipboard=yes --enable-xterm_clipboard=yes" if @clipboard_support
  end

  before do
    if @ruby_support  and rvm_installed?
			# set rvm to system if rvm is installed
			if "~/.rvm".p.exists?
				$LOAD_PATH.unshift("~/.rvm/lib")
				require 'rvm'
				RVM.use "system"
			end

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

dep "removed vim" do
	met? {!which("vim")}
	meet do
		while which("vim") do
			shell "rm -rf #{which "vim"}", :sudo => true
		end
	end
end
