dep "rweng babushka used" do
  def babushka_path; "/usr/local/babushka"; end

  met? do
    cd babushka_path do
      shell("git remote -v")[/^origin.+\/rweng\/.+$/]
    end
  end

  meet do
    cd babushka_path do
      shell "git remote set-url origin git://github.com/rweng/babushka.git"
    end
  end
end