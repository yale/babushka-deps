if "~/.rvm".p.directory?
  $LOAD_PATH.unshift("~/.rvm/lib")
  autoload :RVM, 'rvm'
end

dep 'rails new' do
  requires 'rvm configured'

  define_var :app, :message => "What is the name of the Rails app?"

  met? { 
    var(:app).p.directory?
  }

  meet do
    new_rvm_gemset if confirm("new rvm gemset named after app?", :default => 'yes')
    
    log_shell *(["gem update --system"] * 2)
    log_shell *(["gem install rails --pre"] * 2)
    log_shell *(["gem update"] * 2)
    log_shell *(["rails new #{var :app}"] * 2)

    cd var(:app) do
      system "echo 'rvm use --create #{RVM.current.environment_name}' > .rvmrc"
      remove_overhead_files if confirm("Remove overhead files?", :default => 'yes')
      copy_examples if confirm("cp default files to .example?", :default => 'yes')
      shell "bundle install"
      git_init if confirm("git init?", :default => "yes")
    end
  end

  def new_rvm_gemset
    RVM.gemset_create var(:app)
    RVM.gemset_use var(:app)
  end

  def remove_overhead_files
    shell "rm public/index.html" 
  end

  def git_init
    shell "git init ."
    shell "git add ."
    shell "git commit -m 'inital commit'"
  end

  def copy_examples
    shell "echo 'config/database.yml' >> .gitignore"
    shell "cp config/database.yml config/database.example.yml"
  end
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
    shell "cp '#{File.expand_path("../rails-project/pry.rb.template", __FILE__)}' '#{File.expand_path("config/initializers/pry.rb", var(:rails_project))}'"
    @gem_line = grep(/['"]pry["']/, @gemfile)
    append_to_file("gem 'pry'", @gemfile) unless @gem_line
  end
end