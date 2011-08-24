require File.expand_path("../helpers/rvm.rb", __FILE__)

dep 'rvm' do
  requires 'sh is bash', 'rvm base', 'rvm globals', 'rvm default'
end


def current_rubies
  out = rvm_run("rvm list rubies")
  rubies = out.scan(/^[=> ]{3}([^ ]+) /).flatten
end

dep 'rvm default' do
  requires 'rvm base'
  define_var :default_ruby, :choices => current_rubies, :message => "Which ruby do you what to use as default?"

  met?{rvm_run("rvm current")[/system/] == nil}
  meet do
    rvm_run("rvm use #{var(:default_ruby)} --default")
  end
end

dep 'rvm base' do
  met? {
    "~/.rvm/scripts/rvm".p.file?
  }

  meet {
    shell 'bash -c "`curl https://rvm.beginrescueend.com/install/rvm`"'
  }
end

dep 'rvm globals' do
  requires 'rvm base'

  define_var :rubyies, :default => "ruby-1.9.2", :message => "which rubies do you want to create? (seperate by ,)"
  define_var :gems, :default => "bundler, rake, gemedit, powder, pry", :message => "which gems do you want to install into global? (seperate by ,)"


  def rubies
    var(:rubies).split(/ *, */)
  end

  def gems
    var(:gems).split(/ *, */)
  end

  met? {
    # are all required rubies installed?
    ruby_list = `#{rvm_script} rvm list rubies`
    missing = rubies.select{|r| ruby_list[/#{r}/] == nil}
      unless missing.empty?
	false
      else
	# are all required gems installed?
	result = true;
	rubies.each do |r|
	  list = `#{rvm_script} rvm use #{r}@global;gem list`

	  # are all gems in the gemset?
	  missing = gems.select{|e| list[/#{e}/] == nil}
	    result = false and break unless missing.empty?
	end
      end
  }

  meet {
    # log("run: rvm install 1.9.2") and STDIN.gets

    rubies.each do |r|
    log "installing ruby: #{r}"
    rvm_run "rvm install #{r}"
    log "installing gems"
    rvm_run "rvm use --create #{r}@global;" +
      "gem install #{gems.join(' ')}"
    end

  }
end

