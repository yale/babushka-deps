dep 'fixed: admins can sudo' do
  requires 'admin group', 'sudo'

  def admin_line
    '%admin  ALL=(ALL) ALL'
  end

  met? { sudo('cat /etc/sudoers').split("\n").include?(admin_line) }
  meet { append_to_file admin_line, '/etc/sudoers', :sudo => true }
end