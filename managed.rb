dep 'macvim', :template => 'managed' do
  provides 'mvim'
end

dep "ruby-dev.managed" do
  provides []
end

de "ruby.managed"

dep "bash.managed"
dep 'ack', :template => 'managed'
dep 'vim', :template => 'managed'
dep 'exuberant-ctags', :template => 'managed' do
  provides 'ctags', 'ctags-exuberant'
end