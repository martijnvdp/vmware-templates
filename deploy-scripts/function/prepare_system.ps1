function prepsystem {
    param (
        $win_target_path = "c:\packer",
        $win_url_packer = "https://releases.hashicorp.com/packer/1.6.6/packer_1.6.6_windows_amd64.zip",
        $win_url_isobuilder = "https://sourceforge.net/projects/mkisofs-md5/files/mkisofs-md5-v2.01/mkisofs-md5-2.01-Binary.zip",
        $win_url_windowsupdates = "https://github.com/rgl/packer-provisioner-windows-update/releases/download/v0.10.1/packer-provisioner-windows-update_0.10.1_windows_amd64.zip",
        $lnx_url_windowsupdates = "https://github.com/rgl/packer-provisioner-windows-update/releases/download/v0.10.1/packer-provisioner-windows-update_0.10.1_linux_amd64.tar.gz"
    )
    if ($Iswindows) {
        try {
            mkdir $win_target_path
            Invoke-WebRequest -uri $win_url_packer  -OutFile $win_target_path/packer.zip
            invoke-webrequest -uri $win_url_windowsupdates -OutFile $win_target_path/packerwu.zip
            invoke-webrequest -uri $win_url_isobuilder -OutFile $win_target_path/packeriso.zip
            Expand-Archive $win_target_path\packer.zip $win_target_path
            Expand-Archive $win_target_path\packerwu.zip $win_target_path
            Expand-Archive $win_target_path\packeriso.zip $win_target_path
        }
        catch { Write-Error $error }
    }
    if ($IsLinux) {
        try {
            sudo apt-get install wget -y
            curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo apt-key add -
            sudo apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main" -y
            sudo apt-get update && sudo apt-get install packer -y
            $w = which packer
            wget $lnx_url_windowsupdates -P ./
            tar -xf $lnx_url_windowsupdates.Substring($lnx_url_windowsupdates.LastIndexOf("/") + 1) -C $w.substring(0, $w.length - 6)
        }
        catch { }
        if ($error.count -gt 0) {
            sudo yum install -y yum-utils
            sudo yum-config-manager --add-repo https://rpm.releases.hashicorp.com/RHEL/hashicorp.repo
            $w = which packer
            wget $lnx_url_windowsupdates -P ./
            tar -xf $lnx_url_windowsupdates.Substring($lnx_url_windowsupdates.LastIndexOf("/") + 1) -C $w.substring(0, $w.length - 6)
        }

    }
}