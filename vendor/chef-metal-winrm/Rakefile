task :default => [:up]

desc 'Provision bare metal nodes'
task :up => :setup do
  sh('chef-client -z -o chef-metal-winrm::default')
end

desc 'Chef setup tasks'
task :setup do
  unless Dir.exist?('vendor')
    sh('chef exec berks install --quiet')
    Dir.mkdir('vendor')
    sh('chef exec berks vendor vendor/ --quiet')
  else
    sh('chef exec berks update --quiet')
    sh('rm -rf vendor/*')
    sh('chef exec berks vendor vendor/ --quiet')
  end
end
