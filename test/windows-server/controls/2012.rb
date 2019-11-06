include_controls "windows-patch-baseline"

control "2012.1" do
  impact 1.0
  desc "Verify small dump directory exists"
  describe directory("c:\\windows\\minidump")do
    it {should exist}
  end
end

control "2012.2" do
  impact 1.0
  desc "Verify NT Logon screensaver"
  describe registry_key('HKEY_USERS\S-1-5-20\Software\Policies\Microsoft\Windows\Control Panel\Desktop') do
    its(["SCRNSAVE.EXE"]) { should cmp "scrnsave.scr" }
    its(["ScreenSaverIsSecure"]) {should cmp "1"}
  end
end

control "2012.3" do
  impact 1.0
  desc "Verify CD Rom set to Z:"
  describe powershell("Get-CimInstance Win32_LogicalDisk | ?{ $_.DriveType -eq 5} | select DeviceID").stdout.strip do
    it {should cmp "Z:"}
  end
end

control "2012.4" do
  impact 1.0
  desc "Verify server time"
  time = Time.now.getutc.strftime("%H:%M")
  describe powershell("Get-Date -format 'HH:mm'").stdout.strip do
    it {should cmp time}
  end
end

control "2012.5" do
  impact 1.0
  desc "Verify BIOS Password Setting"
  describe wmi({
    class: 'DCIM_BiosPassword',
    namespace: 'root\dcim\sysman'
  }) do
    its("Setting") {cmp 1 }
  end
end


administrators = ["domain\\user"] #add admins

control "2012.6" do
    impact 1.0
    desc "Verify Administrators"
    describe group("Administrators") do
      it {should exist}
    end
    administrators.each do |member|
      describe user(member) do
        it {should exist}
      end
      describe group("Administrators") do
        its("members") {should include member}
      end
    end
  end

  control "2012.7" do
    impact 1.0
    desc "Verify Remote Desktop Service"
    describe service("TermService") do
      it {should be_installed}
    end
    describe powershell("Get-RDLicenseConfiguration | Select -Property Mode | FT -HideTableHeaders").stdout.strip do
      it {should cmp "PerDevice"}
    end
  end
  
  services = { aspnet_state: "Manual", BITS: "Automatic", EventSystem: "Automatic", Browser: "Disabled", PolicyAgent: "Manual", W3SVC: "Automatic" }
  
  control "2012.8" do
    impact 1.0
    desc "Verify Service Start Types"
    services.keys.each do |service|
      
      describe service(service) do
        it {should be_installed}
      end
      describe powershell("Get-Service #{service} | Select -Property StartType | FT -HideTableHeaders").stdout.strip do
        it {should cmp services[service]}
      end
    end
  end