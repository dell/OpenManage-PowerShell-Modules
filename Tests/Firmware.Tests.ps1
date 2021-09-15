$credentials = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $Global:OMEUsername, $(ConvertTo-SecureString -Force -AsPlainText $Global:OMEPassword)
Connect-OMEServer -Name $Global:OMEServer -Credentials $credentials -IgnoreCertificateWarning
Describe "Firmware Tests" {
    BeforeAll {
        $CatalogName = "Test01"
        $BaselineName = "TestBaseline01"
        $DeviceServiceTag = "GV6V673"
    }
    Context "Firmware" {
        It "Should export at least one function" {
            @(Get-Command -Module DellOpenManage).Count | Should -BeGreaterThan 0
        }

        It "Should create and return a new Catalog object" {
            # Need to implement Delete-Catalog to cleanup for subsequent runs
            #New-OMECatalog -Name $CatalogName -Wait
            New-OMECatalog -Name $CatalogName -RepositoryType "NFS" -Source "100.79.7.16" -SourcePath "/mnt/data/drm/OSELabAll" -CatalogFile "OSELabAll_1.00_Catalog.xml" -Wait
            $CatalogName | Get-OMECatalog | Measure-Object | Select-Object -ExpandProperty Count | Should -BeGreaterThan 0
        }

        It "Should create and return new Baseline object" {
            # Need to implement Delete-FirmwareBaseline
            $catalog = $($CatalogName | Get-OMECatalog)
            $devices = $($DeviceServiceTag | Get-OMEDevice -FilterBy "ServiceTag")
            New-OMEFirmwareBaseline -Name $BaselineName -Catalog $catalog -Devices $devices -AllowDowngrade -Wait
            $BaselineName | Get-OMEFirmwareBaseline | Measure-Object | Select-Object -ExpandProperty Count | Should -BeGreaterThan 0
        }

        It "Should return data from firmware compliance report" {
            $devices = $($DeviceServiceTag | Get-OMEDevice -FilterBy "ServiceTag")
            $BaselineName | Get-OMEFirmwareBaseline | Get-OMEFirmwareCompliance -DeviceFilter $devices -UpdateAction "All" | Measure-Object | Select-Object -ExpandProperty Count | Should -BeGreaterThan 0
        }

        It "Should update firmware but show preview only" {
            $devices = $($DeviceServiceTag | Get-OMEDevice -FilterBy "ServiceTag")
            $baseline = $($BaselineName | Get-OMEFirmwareBaseline)
            Update-OMEFirmware -Baseline $baseline -DeviceFilter $devices -UpdateAction "All" -UpdateSchedule "Preview" -ComponentFilter "PERC" | Measure-Object | Select-Object -ExpandProperty Count | Should -BeGreaterThan 0
        }

        It "Should refresh firmware baseline" {
            $BaselineName | Get-OMEFirmwareBaseline | Invoke-OMEFirmwareBaselineRefresh -Wait | Should -Be "Completed"
        }

        #It ("Should try to update firmware") {
        #    $devices = $($DeviceServiceTag | Get-OMEDevice -FilterBy "ServiceTag")
        #    $baseline = $($BaselineName | Get-OMEFirmwareBaseline)
        #    Update-OMEFirmware -Baseline $baseline -DeviceFilter $devices -UpdateAction "All" -UpdateSchedule "StageForNextReboot" -ComponentFilter "PERC" -Wait | Should -Be "Completed"
        #}
        
        It "Should try to update firmware from DUP with preview only" -Tag "DUP" {
            $devices = $($DeviceServiceTag | Get-OMEDevice -FilterBy "ServiceTag")
            Update-OMEFirmwareDUP -Device $devices -UpdateSchedule "Preview" -DupFile "C:\Temp\BIOS_92RFG_WN64_2.11.2.EXE" | Measure-Object | Select-Object -ExpandProperty Count | Should -BeGreaterOrEqual 0
        }

        #It ("Should try to update firmware from DUP") {
        #    $devices = $($DeviceServiceTag | Get-OMEDevice -FilterBy "ServiceTag")
        #    Update-OMEFirmwareDUP -Device $devices -UpdateSchedule "StageForNextReboot" -DupFile "C:\Temp\Network_Firmware_DK4G2_WN64_20.0.17_A00.EXE" | Measure-Object | Select-Object -ExpandProperty Count | Should -BeGreaterThan 0
        #}
    }
}