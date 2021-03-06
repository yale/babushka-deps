dep 'macvim', :template => 'managed' do
  provides 'mvim'
end

dep "ruby-dev.managed" do
  provides []
end

dep "ruby.managed"

dep "bash.managed"
dep 'ack.managed'
dep 'vim.managed'

dep "ctags", :template => 'managed'

dep 'exuberant-ctags', :template => 'managed' do
  provides 'ctags', 'ctags-exuberant'
end