dep 'rails init' do
  define_var :app_name, :default => "rails_app", :message => "What is the name of the Rails app?"
  define_var :ruby_version, :default => "1.9.2", :message => "Which version of ruby do you want to use?"
  define_var :gemset, :default => "rails_app", :message => "Which gemset do you want to use?"
  
  met? { 
    File.exists? var(:app_name)
    #TODO: check if the file really is a rails directory
  }

  def rvm?
    rvm = `rvm -v`
    not rvm.empty?
  end

  def remove_overhead_files
    shell "rm public/index.html" 
  end

  def git_init
    shell "git init ."
    shell "echo 'config/database.yml' >> .gitignore"
    shell "git add ."
    shell "git commit -m 'inital commit'"
  end

  def copy_examples
    shell "cp config/database.yml config/database.example.yml"
  end

  def rvm_use_cmd
    "rvm use --create '#{var(:ruby_version)}@#{var :gemset}';"
  end

  def rvm_run cmd
    shell "source ~/.rvm/scripts/rvm;" + 
      rvm_use_cmd +
      cmd
  end

  meet {
    if rvm?
      rvm_run "gem install rails --pre;" +
        "rails new #{var :app_name}"

      cd var(:app_name) do
        shell "echo '#{rvm_use_cmd}' > .rvmrc"
        remove_overhead_files
        copy_examples
        git_init
      end
    end
  }
end

def rails_project? path
  gemfile = File.expand_path "Gemfile", path
  if gemfile.p.file?
    grep("rails", gemfile) ? true : false
  else
    false
  end
end

def gemfile_for project
  File.expand_path "Gemfile", project
end

dep "rails - pry is used" do
  var :rails_project, :default => ".", :message => "Which rails project do you want to pry-ify?", :type => :path

  def pry_initializer_exists?
    if rails_project? var(:rails_project) 
      file = File.expand_path 'config/initializers/pry.rb', var(:rails_project)
      file.p.exists?
    else
      unmeetable "Path is not a rails project"
    end
  end

  met?{
    @gemfile ||= gemfile_for(var(:rails_project))
    pry_initializer_exists? and grep(/['"]pry["']/, @gemfile)
  }

  meet do
     shell "cp '#{File.expand_path("../rails-project/pry.rb", __FILE__)}' '#{File.expand_path("config/initializers/pry.rb", var(:rails_project))}'"
     @gem_line = grep(/['"]pry["']/, @gemfile)
     append_to_file("gem 'pry'", @gemfile) unless @gem_line
  end
end