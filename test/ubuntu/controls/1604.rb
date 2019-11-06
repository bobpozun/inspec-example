include_controls 'linux-patch-baseline'

control '1604.1' do
    impact 1.0
    desc 'Check Sticky Bit on All World-Writable Directories'
    output = command('find / -type d \( -perm -g+w -or -perm -o+w \)')
    out = output.stdout.split(/\r?\n/)
    out.each do |line|
        describe file(line) do
          it { should be_sticky }
        end
    end
  end

unmounted_filesystems = ["cramfs","freevxfs","jffs2","hfs","hfsplus","squashfs","udf"]

control '1604.2' do
  impact 1.0
  desc 'Disable mounting of some filesystems'
  unmounted_filesystems.each do |filesystem|
    describe mount(filesystem) do
      it {should_not be_mounted}
    end
  end
end

control '1604.3' do
  impact 1.0
  desc 'Ensure that autofs is not running'
  output = command('service --status-all').stdout
  describe output do
    it {should_not include("autofs")}
  end
end

control '1604.4' do
  impact 1.0
  desc 'Bootloader config owner is root and permissions are 600 for root only'
  describe file('/boot/grub/grub.cfg') do
    it {should exist}
  end
  describe file('/boot/grub/grub.cfg') do
    it {should be_owned_by 'root'}
    it {should be_readable.by('owner')}
    it {should be_writable.by('owner')}
    it {should_not be_readable.by('others')}
    it {should_not be_writable.by('others')}
  end
end

control '1604.5' do
  impact 1.0
  desc 'Ensure that root account requires password'
  describe passwd do
    its('users') { should include('root') }
  end
end

control '1604.6' do
  impact 1.0
  desc 'Prelink is not installed'
  describe packages(/prelink/) do
    its('statuses') {should_not cmp 'installed'}
  end
end

legacy_services = ["nis","rsh-client","rsh-server","talk","talkd","telnetd"]

control '1604.7' do
  impact 1.0
  desc 'Ensure legacy services are disabled or not installed'
  legacy_services.each do |legacy_service|
    describe service(legacy_service) do
      it {should_not be_enabled}
      it {should_not be_running}
    end
  end
end

control '1604.8' do
    impact 1.0
    desc "Only SSH protocol version 2"
    describe sshd_config do
      its('Protocol') { should cmp '2' }
    end
end