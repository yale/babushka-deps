dep "rw sys" do
  requires 'configured zsh', "configured git", "macvim"
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