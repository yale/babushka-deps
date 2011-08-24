dep 'macvim', :template => 'managed' do
  provides 'mvim'
end

dep "bash.managed"
dep "ruby.managed" do
  installs 'ruby', "ruby-dev", :via => :apt
end

dep 'ack', :template => 'managed'
dep 'vim', :template => 'managed'
dep 'exuberant-ctags', :template => 'managed' do
  provides 'ctags', 'ctags-exuberant'
end