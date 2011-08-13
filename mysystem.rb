dep "mysystem" do
  requires 'myzsh'
end

dep "myzsh" do
  shell "wget --no-check-certificate https://github.com/robbyrussell/oh-my-zsh/raw/master/tools/install.sh -O - | sh"
  shell "git clone git@github.com:rweng/dotfiles.git .dotfiles"
  shell "ln -sf ~/.dotfiles/zshrc .zshrc"
end