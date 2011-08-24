require File.expand_path("../helpers/rvm.rb", __FILE__)

dep 'vim.src' do
  source 'ftp://ftp.vim.org/pub/vim/unix/vim-7.3.tar.bz2'
  configure_args "--enable-rubyinterp --with-features=huge"

  setup do
    @ruby_support = confirm("ruby support?")
    @clipboard_support = confirm("clipboard support?")
    # requires 'rvm configured' if @ruby_support
    requires 'ruby.managed' if @ruby_support
    configure_args "--enable-clipboard=yes --enable-xterm_clipboard=yes" if @clipboard_support
  end

  before do
    if @ruby_support  and rvm_installed?
      # rvm_run "rvm install 1.9.2"
      rvm_run "rvm use system"
      shell("unalias ruby") if which("alias") and which("unalias") and shell("alias").match(/^ruby=/)
    end
    true
  end

  met? do
    ruby_satisfied = @ruby_support ? shell('vim --version')["+ruby"] : true
    clipboard_satisfied = @clipboard_support ? shell('vim --version')['+clipboard'] : true
    in_path? and ruby_satisfied and clipboard_satisfied
  end


  after do
    if File.exists? '/usr/bin/vim'
      log_shell "moving /usr/bin/vim to vim.bak", "mv /usr/bin/vim /usr/bin/vim.bak", :sudo => true
    end
    log_shell "linking vim to /usr/bin/vim", "ln -s /usr/local/bin/vim /usr/bin/vim", :sudo => true
  end
end