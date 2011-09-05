dep "babushka switched" do
  define_var :user, :default => "benhoskings", :message => "Which github users babushka do you want to use?"
  def babushka_path; "/usr/local/babushka"; end

  met? do
    cd babushka_path do
      shell("git remote -v")[/^origin.+\/#{var :user}\/.+$/]
    end
  end

  meet do
    cd babushka_path do
      shell "git remote set-url origin git://github.com/#{var :user}/babushka.git"
    end
  end
end