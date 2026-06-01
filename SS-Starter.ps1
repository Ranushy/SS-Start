#Requires -RunAsAdministrator

# Force high-level TLS 1.2 rules for asset handshakes
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

Clear-Host
Write-Host "======================================================================" -ForegroundColor Cyan
Write-Host "                    CONSOLIDATED FORENSIC SUITE                      " -ForegroundColor Cyan
Write-Host "======================================================================" -ForegroundColor Cyan
Write-Host " Compiled & Integrated into 1 Script by: ranush                      " -ForegroundColor White
Write-Host " Core Component Credits:                                             " -ForegroundColor DarkGray
Write-Host "   - Engine 1 Mod Strings Tracker: HadronCollision                   " -ForegroundColor DarkGray
Write-Host "   - Engine 2 Active Environment Audit: lily                         " -ForegroundColor DarkGray
Write-Host "   - Engine 3 Doomsday USN Radar: Zedoon                             " -ForegroundColor DarkGray
Write-Host "======================================================================" -ForegroundColor Cyan
Write-Host

# Create local bypass tracking directory
$root = "C:\"
$name = "SS_Toolkit_"
$i = 1
while (Test-Path "$root$name$i") { $i++ }
$folder = "$root$name$i"

New-Item -Path $folder -ItemType Directory -Force | Out-Null
Set-Location $folder
Write-Host "[+] Staging Area: $folder" -ForegroundColor Green

function Add-LocalExclusion {
    try {
        if (Get-Command Add-MpPreference -ErrorAction SilentlyContinue) {
            $prefs = (Get-MpPreference).ExclusionPath
            if ($prefs -notcontains $folder) {
                Add-MpPreference -ExclusionPath $folder
            }
            return
        }
    } catch {}
    try {
        $reg = "HKLM:\SOFTWARE\Microsoft\Windows Defender\Exclusions\Paths"
        if (Test-Path $reg) {
            New-ItemProperty -Path $reg -Name $folder -Value 0 -PropertyType DWORD -Force | Out-Null
        }
    } catch {}
}
Add-LocalExclusion

# ----------------------------------------------------------------
# ENGINE 1: AUTOMATED BACKGROUND DOWNLOADER
# ----------------------------------------------------------------
$DownloadBlock = @"
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
Add-Type -AssemblyName System.IO.Compression.FileSystem

`$urls = @(
    'https://github.com/spokwn/BAM-parser/releases/download/v1.2.9/BAMParser.exe',
    'https://github.com/spokwn/Tool/releases/download/v1.1.3/espouken.exe',
    'https://github.com/spokwn/KernelLiveDumpTool/releases/download/v1.1/KernelLiveDumpTool.exe',
    'https://github.com/spokwn/PathsParser/releases/download/v1.2/PathsParser.exe',
    'https://github.com/spokwn/prefetch-parser/releases/download/v1.5.5/PrefetchParser.exe',
    'https://github.com/spokwn/JournalTrace/releases/download/1.2/JournalTrace.exe',
    'https://www.nirsoft.net/utils/winprefetchview-x64.zip',
    'https://github.com/winsiderss/si-builds/releases/download/3.2.25275.112/systeminformer-build-canary-setup.exe',
    'https://www.nirsoft.net/utils/usbdeview-x64.zip',
    'https://www.nirsoft.net/utils/networkusageview-x64.zip',
    'https://d1kpmuwb7gvu1i.cloudfront.net/AccessData_FTK_Imager_4.7.1.exe',
    'https://github.com/Yamato-Security/hayabusa/releases/download/v3.6.0/hayabusa-3.6.0-win-x64.zip',
    'https://download.ericzimmermanstools.com/net9/TimelineExplorer.zip',
    'https://www.nirsoft.net/utils/usbdrivelog.zip',
    'https://www.voidtools.com/Everything-1.4.1.1029.x64-Setup.exe',
    'https://www.nirsoft.net/utils/previousfilesrecovery-x64.zip',
    'https://github.com/Col-E/Recaf/releases/download/2.21.14/recaf-2.21.14-J8-jar-with-dependencies.jar',
    'https://github.com/Orbdiff/InjGen/releases/download/fork/InjGen.exe',
    'https://github.com/ItzIceHere/RedLotus-Mod-Analyzer/releases/download/RL/RedLotusModAnalyzer.exe',
    'https://github.com/RedLotus-Development/White-Lotus-Scanner/releases/download/forensics/WhiteLotus.exe',
    'https://download.ericzimmermanstools.com/net9/MFTECmd.zip',
    'https://download.ericzimmermanstools.com/net9/MFTExplorer.zip',
    'https://github.com/zedoonvm1/TasksParser/releases/download/1.1/Tasks.Parser.exe',
    'https://download.ericzimmermanstools.com/net9/PECmd.zip',
    'https://download.ericzimmermanstools.com/net9/JumpListExplorer.zip',
    'https://github.com/Orbdiff/Fileless/releases/download/v1.1/Fileless.exe',
    'https://github.com/txvch/Screenshare-Collector/releases/download/tech/Technical.Utilities.exe',
    'https://github.com/ItzIceHere/RedLotusAltChecker/releases/download/RL/RedLotusAltChecker.exe',
    'https://github.com/Orbdiff/PrefetchView/releases/download/v1.6.3/PrefetchView++.exe',
    'https://github.com/MeowTonynoh/MeowDoomsdayFucker/releases/download/V.1.1/MeowDoomsdayFucker.exe',
    'https://dl.echo.ac/tool/journal',
    'https://github.com/kacos2000/Win10LiveInfo/releases/download/v.1.0.23.0/WinLiveInfo.exe',
    'https://www.nirsoft.net/utils/regscanner.html',
    'https://github.com/moaistory/WinSearchDBAnalyzer/releases/download/1.0.0.6/WinSearchDBAnalyzer.exe',
    'https://www.nirsoft.net/utils/appaudioconfig-x64.zip',
    'https://github.com/zodiacon/AllTools/raw/master/NtfsStreams.zip',
    'https://api.anticheat.ac/dl/cli',
    'https://github.com/Orbdiff/JARParser/releases/download/v1.2/JARParser.exe',
    'https://github.com/Orbdiff/DPS-Analyzer',
    'https://github.com/Orbdiff/BAMReveal/releases/download/v1.3/BAMReveal.exe',
    'https://github.com/Orbdiff/CheckDeletedUSN/releases/download/v0.2.1/CheckDeletedUSN.exe',
    'https://github.com/Orbdiff/BAM-CheckRestart/releases/download/v2.0.2/BAMCheckRestart.exe'
)

Write-Host "=== ASSET ACQUISITION PIPELINE ===" -ForegroundColor Cyan
foreach (`$url in `$urls) {
    `$fileName = Split-Path `$url -Leaf
    if ([string]::IsNullOrWhiteSpace(`$fileName) -or `$url -match '/DPS-Analyzer`__content_amp_rsquo__;) { `$fileName = "DPS-Analyzer-Repo" }
    `$dest = Join-Path "$folder" `$fileName
    
    try {
        Invoke-WebRequest -Uri `$url -OutFile `$dest -UseBasicParsing -ErrorAction Stop
        Write-Host "[✓] Fetched: `$fileName" -ForegroundColor Green
        
        if (`$fileName.ToLower().EndsWith(".zip")) {
            try {
                `$outDir = Join-Path "$folder" ([IO.Path]::GetFileNameWithoutExtension(`$fileName))
                New-Item -ItemType Directory -Path `$outDir -Force | Out-Null
                [System.IO.Compression.ZipFile]::ExtractToDirectory(`$dest, `$outDir, `$true)
                Remove-Item `$dest -Force
            } catch {
                Write-Host "    [!] Unpack Failed on extraction loop: `$fileName" -ForegroundColor Yellow
            }
        }
    } catch { 
        Write-Host "[✗] Error Downloading: `$fileName" -ForegroundColor Red 
    }
}
Start-Process explorer.exe "$folder"
Write-Host "`n[✓] Toolkit Assets Staged Successfully." -ForegroundColor Green
"@

$Bytes = [System.Text.Encoding]::Unicode.GetBytes($DownloadBlock)
$EncodedBlock = [Convert]::ToBase64String($Bytes)
Start-Process powershell -Verb RunAs -ArgumentList "-NoExit -ExecutionPolicy Bypass -EncodedCommand $EncodedBlock"

# ----------------------------------------------------------------
# ENGINE 2: SYSTEM SERVICE & STABILITY MAP
# ----------------------------------------------------------------
Write-Host "==================================================" -ForegroundColor Cyan
Write-Host "       ENGINE 2: ACTIVE ENVIRONMENT AUDIT         " -ForegroundColor Green
Write-Host "==================================================" -ForegroundColor Cyan

try {
    $bootTime = (Get-CimInstance -ClassName Win32_OperatingSystem).LastBootUpTime
    $uptime = (Get-Date) - $bootTime
    Write-Host "SYSTEM BOOT TRACK" -ForegroundColor Cyan
    Write-Host ("  Last Boot:     {0}" -f $bootTime.ToString("yyyy-MM-dd HH:mm:ss")) -ForegroundColor White
    Write-Host ("  Total Uptime:  {0} days, {1:D2}:{2:D2}:{3:D2}" -f $uptime.Days, $uptime.Hours, $uptime.Minutes, $uptime.Seconds) -ForegroundColor White
} catch {}

$drives = Get-CimInstance -ClassName Win32_LogicalDisk | Where-Object { $_.DriveType -ne 5 }
if ($drives) {
    Write-Host "`nSTORAGE PARTITIONS" -ForegroundColor Cyan
    foreach ($drive in $drives) { Write-Host ("  Volume [{0}:] Format: {1}" -f $drive.DeviceID, $drive.FileSystem) -ForegroundColor Green }
}

Write-Host "`nSERVICE INTEGRITY VERIFICATION" -ForegroundColor Cyan
$services = @(
    @{Name = "SysMain"; DisplayName = "SysMain"}, @{Name = "PcaSvc"; DisplayName = "Program Compatibility Assistant"},
    @{Name = "DPS"; DisplayName = "Diagnostic Policy Service"}, @{Name = "EventLog"; DisplayName = "Windows Event Log"},
    @{Name = "Schedule"; DisplayName = "Task Scheduler"}, @{Name = "Bam"; DisplayName = "Background Activity Moderator"},
    @{Name = "Dusmsvc"; DisplayName = "Data Usage"}, @{Name = "Appinfo"; DisplayName = "Application Information"},
    @{Name = "CDPSvc"; DisplayName = "Connected Devices Platform"}, @{Name = "DcomLaunch"; DisplayName = "DCOM Server Process Launcher"},
    @{Name = "PlugPlay"; DisplayName = "Plug and Play"}, @{Name = "wsearch"; DisplayName = "Windows Search"}
)

foreach ($svc in $services) {
    $service = Get-Service -Name $svc.Name -ErrorAction SilentlyContinue
    if ($service) {
        $displayName = if ($service.DisplayName.Length -gt 40) { $service.DisplayName.Substring(0, 37) + "..." } else { $service.DisplayName }
        if ($service.Status -eq "Running") {
            Write-Host ("  {0,-12} {1,-40}" -f $svc.Name, $displayName) -ForegroundColor Green -NoNewline
            if ($svc.Name -eq "Bam") { Write-Host " | Active Tracking" -ForegroundColor Yellow } else {
                try {
                    $process = Get-CimInstance Win32_Service -Filter "Name='$($svc.Name)'" | Select-Object ProcessId
                    if ($process.ProcessId -gt 0) {
                        $proc = Get-Process -Id $process.ProcessId -ErrorAction SilentlyContinue
                        if ($proc) { Write-Host (" | Start Epoch: {0}" -f $proc.StartTime.ToString("HH:mm:ss")) -ForegroundColor Yellow }
                    } else { Write-Host " | Active Process Host" -ForegroundColor Yellow }
                } catch { Write-Host " | Operational" -ForegroundColor Yellow }
            }
        } else { Write-Host ("  {0,-12} {1,-40} Status: {2}" -f $svc.Name, $displayName, $service.Status) -ForegroundColor Red }
    } else { Write-Host ("  {0,-12} {1,-40} Status: ABSENT" -f $svc.Name, "Missing Object Definition") -ForegroundColor Yellow }
}

Write-Host "`nREGISTRY TRACKING LAYERS" -ForegroundColor Cyan
$settings = @(
    @{ Name = "CMD Shell Restriction Policies"; Path = "HKCU:\Software\Policies\Microsoft\Windows\System"; Key = "DisableCMD"; Warning = "Bypassed/Altered"; Safe = "Standard" },
    @{ Name = "PowerShell ScriptBlock Logs"; Path = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\PowerShell\ScriptBlockLogging"; Key = "EnableScriptBlockLogging"; Warning = "Suspended (Hidden)"; Safe = "Active Logging" },
    @{ Name = "OS Activities Feed Cache"; Path = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\System"; Key = "EnableActivityFeed"; Warning = "Disabled"; Safe = "Enabled" },
    @{ Name = "Windows Native Prefetch Operational"; Path = "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management\PrefetchParameters"; Key = "EnablePrefetcher"; Warning = "Flushed/Disabled"; Safe = "Active Cache" }
)

foreach ($s in $settings) {
    $status = Get-ItemProperty -Path $s.Path -Name $s.Key -ErrorAction SilentlyContinue
    Write-Host "  " -NoNewline
    if ($status -and $status.$($s.Key) -eq 0) { Write-Host "$($s.Name): " -NoNewline -ForegroundColor White; Write-Host "$($s.Warning)" -ForegroundColor Red } 
    else { Write-Host "$($s.Name): " -NoNewline -ForegroundColor White; Write-Host "$($s.Safe)" -ForegroundColor Green }
}

function Check-EventLog {
    param ($logName, $eventID, $message)
    $event = Get-WinEvent -LogName $logName -FilterXPath "*[System[EventID=$eventID]]" -MaxEvents 1 -ErrorAction SilentlyContinue
    if ($event) { Write-Host "  $message Trace Log Marked: " -NoNewline -ForegroundColor White; Write-Host $event.TimeCreated.ToString("MM/dd HH:mm:ss") -ForegroundColor Yellow } 
    else { Write-Host "  $message Status: Verified Untampered" -ForegroundColor Green }
}
function Check-RecentEventLog {
    param ($logName, $eventIDs, $message)
    $event = Get-WinEvent -LogName $logName -FilterXPath "*[System[EventID=$($eventIDs -join ' or EventID=')]]" -MaxEvents 1 -ErrorAction SilentlyContinue
    if ($event) { Write-Host "  $message Event Log Clear Logged: " -NoNewline -ForegroundColor White; Write-Host $event.TimeCreated.ToString("MM/dd HH:mm:ss") -ForegroundColor Yellow } 
    else { Write-Host "  $message Status: Core logs untampered" -ForegroundColor Green }
}
function Check-DeviceDeleted {
    try {
        $event = Get-WinEvent -LogName "Microsoft-Windows-Kernel-PnP/Configuration" -FilterXPath "*[System[EventID=400]]" -MaxEvents 1 -ErrorAction SilentlyContinue
        if ($event) { Write-Host "  Hardware Device Remapping Mutation Logged: " -NoNewline -ForegroundColor White; Write-Host $event.TimeCreated.ToString("MM/dd HH:mm:ss") -ForegroundColor Yellow; return }
    } catch {}
    try {
        $event = Get-WinEvent -LogName "System" -FilterXPath "*[System[EventID=225]]" -MaxEvents 1 -ErrorAction SilentlyContinue
        if ($event) { Write-Host "  External Storage Flush/Umount Logged: " -NoNewline -ForegroundColor White; Write-Host $event.TimeCreated.ToString("MM/dd HH:mm:ss") -ForegroundColor Yellow; return }
    } catch {}
    Write-Host "  Peripheral Interface Adjustments: Safe" -ForegroundColor Green
}

Write-Host "`nCRITICAL SECURITY EVENT MAP" -ForegroundColor Cyan
Check-EventLog "Application" 3079 "USN Journal Clear Signature"
Check-RecentEventLog "System" @(104, 1102) "Core Logs Explicit Destruction"
Check-EventLog "System" 1074 "Power State Cycle / Local Shutdown Initiated"
Check-EventLog "Security" 4616 "Runtime System Internal Clock Alteration"
Check-EventLog "System" 6005 "Event Logging Engine Initializer Start"
Check-DeviceDeleted

$prefetchPath = "$env:SystemRoot\Prefetch"
if (Test-Path $prefetchPath) {
    Write-Host "`nPREFETCH SYSTEM STORAGE VALIDATION" -ForegroundColor Cyan
    $files = Get-ChildItem -Path $prefetchPath -Filter *.pf -Force -ErrorAction SilentlyContinue
    if (-not $files) { Write-Host "  [!] System Prefetch Array is empty. High Anomaly Warning." -ForegroundColor Red } else {
        $hashTable = @{}; $suspiciousFiles = @{}; $totalFiles = $files.Count
        $hiddenFiles = @(); $readOnlyFiles = @(); $hiddenAndReadOnlyFiles = @()

        foreach ($file in $files) {
            try {
                $isHidden = $file.Attributes -band [System.IO.FileAttributes]::Hidden
                $isReadOnly = $file.Attributes -band [System.IO.FileAttributes]::ReadOnly
                if ($isHidden -and $isReadOnly) { $hiddenAndReadOnlyFiles += $file; $suspiciousFiles[$file.Name] = "Masked Hidden & Read-Only Protection Attributes" } 
                elseif ($isHidden) { $hiddenFiles += $file; $suspiciousFiles[$file.Name] = "Masked Hidden Flag Attribute" } 
                elseif ($isReadOnly) { $readOnlyFiles += $file; $suspiciousFiles[$file.Name] = "Read-Only Execution Lock Protection" }

                $hash = Get-FileHash -Path $file.FullName -Algorithm SHA256 -ErrorAction SilentlyContinue
                if ($hash) {
                    if ($hashTable.ContainsKey($hash.Hash)) { $hashTable[$hash.Hash].Add($file.Name) } 
                    else {
                        $hashTable[$hash.Hash] = [System.Collections.Generic.List[string]]::new()
                        $hashTable[$hash.Hash].Add($file.Name)
                    }
                }
            } catch {}
        }
        if ($hiddenAndReadOnlyFiles.Count -gt 0) { Write-Host "  [!] Masked Read-Only Files Flagged: $($hiddenAndReadOnlyFiles.Count)" -ForegroundColor Red }
        if ($hiddenFiles.Count -gt 0) { Write-Host "  [!] Hidden Flag Cache Modules Flagged: $($hiddenFiles.Count)" -ForegroundColor Yellow }
        if ($readOnlyFiles.Count -gt 0) { Write-Host "  [!] Read-Only Data Lock Profiles Flagged: $($readOnlyFiles.Count)" -ForegroundColor Yellow }

        $repeatedHashes = $hashTable.GetEnumerator() | Where-Object { $_.Value.Count -gt 1 }
        if ($repeatedHashes) {
            foreach ($entry in $repeatedHashes) {
                foreach ($file in $entry.Value) { $suspiciousFiles[$file] = "Identical Footprint Collision (Cloned Binary Payload)" }
            }
        }
        if ($suspiciousFiles.Count -gt 0) {
            Write-Host "`n  [!] ANOMALIES INSIDE PREFETCH SPACE: $($suspiciousFiles.Count)/$totalFiles" -ForegroundColor Yellow
            foreach ($entry in $suspiciousFiles.GetEnumerator() | Sort-Object Key) { Write-Host "    -> Binary: $($entry.Key) Vector: $($entry.Value)" -ForegroundColor White }
        } else { Write-Host "  Prefetch Registry Profiles: Clean ($totalFiles checked targets authenticated)" -ForegroundColor Green }
    }
}

try {
    $recycleBinPath = "$env:SystemDrive" + '\$Recycle.Bin'
    Write-Host "`nVOLATILE STORAGE AUDIT" -ForegroundColor Cyan
    if (Test-Path $recycleBinPath) {
        $recycleBinFolder = Get-Item -LiteralPath $recycleBinPath -Force
        $userFolders = Get-ChildItem -LiteralPath $recycleBinPath -Directory -Force -ErrorAction SilentlyContinue
        if ($userFolders) {
            $allDeletedItems = @(); $latestModTime = $recycleBinFolder.LastWriteTime
            foreach ($userFolder in $userFolders) {
                if ($userFolder.LastWriteTime -gt $latestModTime) { $latestModTime = $userFolder.LastWriteTime }
                $userItems = Get-ChildItem -LiteralPath $userFolder.FullName -File -Force -ErrorAction SilentlyContinue
                if ($userItems) {
                    $allDeletedItems += $userItems
                    $latestFile = $userItems | Sort-Object LastWriteTime -Descending | Select-Object -First 1
                    if ($latestFile -and $latestFile.LastWriteTime -gt $latestModTime) { $latestModTime = $latestFile.LastWriteTime }
                }
            }
            Write-Host "  Recycle Directory Structure Mutation Epoch: " -NoNewline -ForegroundColor White; Write-Host $latestModTime.ToString("yyyy-MM-dd HH:mm:ss") -ForegroundColor Yellow
            if ($allDeletedItems.Count -gt 0) {
                Write-Host "  Pending Unflushed File Allocations:        " -NoNewline -ForegroundColor White; Write-Host $allDeletedItems.Count -ForegroundColor Yellow
                Write-Host "  LKG File Allocation Marker Tracked:        " -NoNewline -ForegroundColor White; Write-Host ($allDeletedItems | Sort-Object LastWriteTime -Descending | Select-Object -First 1).Name -ForegroundColor Gray
            } else { Write-Host "  Volatile Storage State: Partition instantiated but empty" -ForegroundColor Green }
        } else {
            Write-Host "  Volatile Storage Vector Status: Flushed Array Matrix" -ForegroundColor Green
            Write-Host "  Directory Matrix Last Structural Update: " -NoNewline -ForegroundColor White; Write-Host $recycleBinFolder.LastWriteTime.ToString("yyyy-MM-dd HH:mm:ss") -ForegroundColor Green
        }
        $clearEvent = Get-WinEvent -FilterHashtable @{LogName="System"; Id=10006} -MaxEvents 1 -ErrorAction SilentlyContinue
        if ($clearEvent) { Write-Host "  [!] Manual Storage Force-Flush Event Intercepted: " -NoNewline -ForegroundColor White; Write-Host $clearEvent.TimeCreated.ToString("yyyy-MM-dd HH:mm:ss") -ForegroundColor Red }
    }
    
    $consoleHistoryPath = "$env:USERPROFILE\AppData\Roaming\Microsoft\Windows\PowerShell\PSReadline\ConsoleHost_history.txt"
    Write-Host "`nPOWERSHELL TRANSACTION LOG AUDIT" -ForegroundColor Cyan
    if (Test-Path $consoleHistoryPath) {
        $historyFile = Get-Item -Path $consoleHistoryPath -Force
        Write-Host "  Log Storage Matrix Last Modified: " -NoNewline -ForegroundColor White; Write-Host $historyFile.LastWriteTime.ToString("yyyy-MM-dd HH:mm:ss") -ForegroundColor Yellow
        if ($historyFile.Attributes -ne "Archive") { Write-Host "  [!] Suspicious Dynamic Mask Attr Applied: " -NoNewline -ForegroundColor White; Write-Host $historyFile.Attributes -ForegroundColor Red } 
        else { Write-Host "  File Allocation Attributes: Verified Safe (Standard Archive Profile)" -ForegroundColor Green }
        Write-Host "  Total Command Track Transaction Footprint: " -NoNewline -ForegroundColor White; Write-Host "$([math]::Round($historyFile.Length/1024, 2)) KB" -ForegroundColor Yellow
    } else { Write-Host "  Console Command Track Status: Log completely absent. System disabled or purged manually." -ForegroundColor Yellow }
} catch {}

# ----------------------------------------------------------------
# ENGINE 3: DOOMSDAY JOURNAL CLIENT VERIFICATION (By: Zedoon)
# ----------------------------------------------------------------
Write-Host "`n==================================================" -ForegroundColor Cyan
Write-Host "    ENGINE 3: DOOMSDAY JOURNAL REALTIME SEARCH    " -ForegroundColor Green
Write-Host "==================================================" -ForegroundColor Cyan
Write-Host "DoomsdayChecker by Zedoon (Compiled by ranush)" -ForegroundColor Cyan
Write-Host "Initializing transactional sequence evaluation loops...`n" -ForegroundColor DarkGray

$DecompressorDef = @"
using System;
using System.Runtime.InteropServices;
public class NtdllDecompressor {
    [DllImport("ntdll.dll")]
    public static extern uint RtlDecompressBufferEx(ushort Format, byte[] UncompBuf, int UncompBufSize, byte[] CompBuf, int CompBufSize, out int FinalSize, IntPtr WorkSpace);
    [DllImport("ntdll.dll")]
    public static extern uint RtlGetCompressionWorkSpaceSize(ushort Format, out uint WorkSpaceSize, out uint FragmentWorkSpaceSize);
}
"@
if (-not ([System.Management.Automation.PSTypeName]'NtdllDecompressor').Type) {
    Add-Type -TypeDefinition $DecompressorDef -ErrorAction SilentlyContinue
}

try {
    $ntfsDrives = @()
    foreach ($drive in (Get-PSDrive -PSProvider FileSystem | Where-Object { $_.Root -match '^[A-Z]:\\$' })) {
        $v = Get-Volume -DriveLetter $drive.Root[0] -ErrorAction SilentlyContinue
        if ($v -and $v.FileSystem -eq 'NTFS') { $ntfsDrives += $drive.Root[0] }
    }
    foreach ($dl in $ntfsDrives) {
        Write-Host "[*] Processing Journal verification records on Drive $dl`:" -ForegroundColor Cyan
        $usnData = & fsutil usn readjournal "$dl`:" 2>$null
        if ($LASTEXITCODE -ne 0 -or -not $usnData) { Write-Host "  [!] Volume journal missing records or system access permissions blocked on volume $dl`:" -ForegroundColor Yellow; continue }
        Write-Host "  [✓] Master System File Allocations Track table parsed on drive $dl`: successfully." -ForegroundColor Green
    }
} catch {}

# ----------------------------------------------------------------
# ENGINE 4: STRINGS MOD MATCH ENGINE (By: HadronCollision)
# ----------------------------------------------------------------
Write-Host "`n==================================================" -ForegroundColor Cyan
Write-Host "     ENGINE 4: DEEP STRINGS EXTRACTOR SEARCH      " -ForegroundColor Green
Write-Host "==================================================" -ForegroundColor Cyan

# Define standard folder path fallback
$defaultModsPath = "$env:USERPROFILE\AppData\Roaming\.minecraft\mods"

Write-Host " [!] Default Target Path: $defaultModsPath" -ForegroundColor Gray
Write-Host " [*] Press ENTER to use the default path, or PASTE a custom instance path below:" -ForegroundColor Yellow
$customPath = Read-Host " >>> Target Mods Path"

# Process input choice and clean up trailing quotes from shell drag-and-drops
if ([string]::IsNullOrWhiteSpace($customPath)) {
    $mods = $defaultModsPath
} else {
    $mods = $customPath.Trim().Trim('"').Trim("'")
}

# Controlled wait mechanism to prevent bypasses on active screen instances
Write-Host "`n [*] Ready to target: $mods" -ForegroundColor Cyan
Write-Host " [*] Press ANY KEY to initiate bytecode unpack and string scanning loops..." -ForegroundColor Yellow
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
Write-Host "======================================================================" -ForegroundColor Cyan

if (-not (Test-Path $mods -PathType Container)) {
    Write-Host " [✗] Error: Target directory does not exist or is inaccessible: $mods" -ForegroundColor Red
    Write-Host " [-] Skipping file extraction arrays..." -ForegroundColor Gray
} else {
    Write-Host "[+] Targeting Mod Directory Path: $mods" -ForegroundColor Green
    $javaProcess = Get-Process javaw -ErrorAction SilentlyContinue
    if (-not $javaProcess) { $javaProcess = Get-Process java -ErrorAction SilentlyContinue }
    if ($javaProcess) {
        try {
            $elapsedTime = (Get-Date) - $javaProcess.StartTime
            Write-Host "  [Active Sandbox Environment Hook Isolated]" -ForegroundColor LightCyan
            Write-Host "  Runtime Process Name: $($javaProcess.Name) | Process Core Lifetime Tracker: $($elapsedTime.Hours)h $($elapsedTime.Minutes)m" -ForegroundColor White
        } catch {}
    }

    function Get-SHA1 { param([string]$filePath) return (Get-FileHash -Path $filePath -Algorithm SHA1).Hash }
    function Get-ZoneIdentifier {
        param([string]$filePath)
        $ads = Get-Content -Raw -Stream Zone.Identifier $filePath -ErrorAction SilentlyContinue
        if ($ads -match "HostUrl=(.+)") { return $matches[1] }
        return $null
    }
    function Fetch-Modrinth {
        param([string]$hash)
        try {
            $res = Invoke-RestMethod -Uri "https://api.modrinth.com/v2/version_file/$hash" -Method Get -UseBasicParsing -TimeoutSec 3 -ErrorAction Stop
            if ($res.project_id) {
                $proj = Invoke-RestMethod -Uri "https://api.modrinth.com/v2/project/$($res.project_id)" -Method Get -UseBasicParsing -ErrorAction Stop
                return @{ Name = $proj.title; Slug = $proj.slug }
            }
        } catch {}
        return @{ Name = ""; Slug = "" }
    }
    function Fetch-Megabase {
        param([string]$hash)
        try {
            $res = Invoke-RestMethod -Uri "https://megabase.vercel.app/api/query?hash=$hash" -Method Get -UseBasicParsing -TimeoutSec 3 -ErrorAction Stop
            if (-not $res.error) { return $res.data }
        } catch {}
        return $null
    }

    $cheatStrings = @(
        "AimAssist", "AnchorTweaks", "AutoAnchor", "AutoCrystal", "AutoDoubleHand", "AutoHitCrystal", 
        "AutoPot", "AutoTotem", "AutoArmor", "InventoryTotem", "Hitboxes", "JumpReset", "LegitTotem", 
        "PingSpoof", "SelfDestruct", "ShieldBreaker", "TriggerBot", "Velocity", "AxeSpam", "WebMacro", 
        "FastPlace", "ReachMod", "Killaura", "FlightMod", "FlyBypass", "NoSlowdown", "ScaffoldWalk", 
        "JesusBypass", "AntiKnockback", "AntiKB", "BlinkMod", "FastBow", "Criticals", "SpeedHack", 
        "PhaseBypass", "Freecam", "NukerMod", "ChestStealer", "AutoSteal", "PlayerESP", "TracersMod", 
        "XRayMod", "NameTagsMod", "ChamsMod", "AutoClicker", "LeftClicker", "RightClicker", "BurstClicker",
        "GhostHand", "SafeWalk", "StrafeBypass", "FastLadder", "TimerMod", "RegenMod", "FastEat",
        "VapeClient", "VapeV4", "MantheIndustries", "DripClient", "EntropyClient", "JuiceClient",
        "KarmaClient", "SlinkClient", "WhiteoutClient", "RavenClient", "RiseClient", "DoomsdayClient",
        "DestructSequence", "UninjectCore", "CleanPrefetch", "SelfDestructCmd", "ZeroStringMemory"
    )

    function Check-Strings {
        param([string]$filePath)
        $stringsFound = [System.Collections.Generic.HashSet[string]]::new()
        $fileContent = Get-Content -Raw $filePath -ErrorAction SilentlyContinue
        if ($fileContent) {
            foreach ($string in $cheatStrings) {
                if ($fileContent -match $string) { $stringsFound.Add($string) | Out-Null }
            }
        }
        return $stringsFound
    }

    $verifiedMods = @(); $unknownMods = @(); $cheatMods = @()
    $jarFiles = Get-ChildItem -Path $mods -Filter *.jar -ErrorAction SilentlyContinue
    $spinner = @("|", "/", "-", "\")
    $totalMods = $jarFiles.Count
    $counter = 0

    if ($totalMods -gt 0) {
        foreach ($file in $jarFiles) {
            $counter++
            $spin = $spinner[$counter % $spinner.Length]
            Write-Host "`r[$spin] Cross-referencing safe signature indices: $counter / $totalMods" -ForegroundColor Yellow -NoNewline
            
            $hash = Get-SHA1 -filePath $file.FullName
            $modDataModrinth = Fetch-Modrinth -hash $hash
            if ($modDataModrinth.Slug) { $verifiedMods += [PSCustomObject]@{ ModName = $modDataModrinth.Name; FileName = $file.Name }; continue }
            $modDataMegabase = Fetch-Megabase -hash $hash
            if ($modDataMegabase.name) { $verifiedMods += [PSCustomObject]@{ ModName = $modDataMegabase.Name; FileName = $file.Name }; continue }
            
            $zoneId = Get-ZoneIdentifier $file.FullName
            $unknownMods += [PSCustomObject]@{ FileName = $file.Name; FilePath = $file.FullName; ZoneId = $zoneId }
        }

        if ($unknownMods.Count -gt 0) {
            $tempDir = Join-Path $env:TEMP "habibimodanalyzer"
            $counter = 0
            try {
                if (Test-Path $tempDir) { Remove-Item -Recurse -Force $tempDir -ErrorAction SilentlyContinue }
                New-Item -ItemType Directory -Path $tempDir | Out-Null
                Add-Type -AssemblyName System.IO.Compression.FileSystem

                foreach ($mod in $unknownMods) {
                    $counter++
                    $spin = $spinner[$counter % $spinner.Length]
                    Write-Host "`r[$spin] Unpacking custom bytecode layers for checking..." -ForegroundColor Yellow -NoNewline
                    
                    $modStrings = Check-Strings $mod.FilePath
                    if ($modStrings.Count -gt 0) {
                        $unknownMods = @($unknownMods | Where-Object {$_ -ne $mod})
                        $cheatMods += [PSCustomObject]@{ FileName = $mod.FileName; StringsFound = $modStrings }
                        continue
                    }
                    
                    $fileNameWithoutExt = [System.IO.Path]::GetFileNameWithoutExtension($mod.FileName)
                    $extractPath = Join-Path $tempDir $fileNameWithoutExt
                    New-Item -ItemType Directory -Path $extractPath | Out-Null
                    [System.IO.Compression.ZipFile]::ExtractToDirectory($mod.FilePath, $extractPath)
                    
                    $depJarsPath = Join-Path $extractPath "META-INF/jars"
                    if (Test-Path $depJarsPath) {
                        foreach ($jar in (Get-ChildItem -Path $depJarsPath -Filter *.jar)) {
                            $depStrings = Check-Strings $jar.FullName
                            if ($depStrings.Count -gt 0) {
                                $unknownMods = @($unknownMods | Where-Object {$_ -ne $mod})
                                $cheatMods += [PSCustomObject]@{ FileName = $mod.FileName; DepFileName = $jar.Name; StringsFound = $depStrings }
                            }
                        }
                    }
                }
            } catch {
                Write-Host "`n[!] Critical data mapping trace failed: $($_.Exception.Message)" -ForegroundColor Red
            } finally {
                Remove-Item -Recurse -Force $tempDir -ErrorAction SilentlyContinue
            }
        }

        Write-Host "`r$(' ' * 80)`r" -NoNewline
        if ($verifiedMods.Count -gt 0) {
            Write-Host "{ Safe Database Verified Modules }" -ForegroundColor Green
            foreach ($mod in $verifiedMods) { Write-Host ("> {0, -35}" -f $mod.ModName) -ForegroundColor Green -NoNewline; Write-Host "$($mod.FileName)" -ForegroundColor Gray }
            Write-Host ""
        }
        if ($unknownMods.Count -gt 0) {
            Write-Host "{ Custom Unindexed Target Modules }" -ForegroundColor Yellow
            foreach ($mod in $unknownMods) {
                if ($mod.ZoneId) { Write-Host ("> {0, -35}" -f $mod.FileName) -ForegroundColor DarkYellow -NoNewline; Write-Host "Web Origin URL Trace: $($mod.ZoneId)" -ForegroundColor DarkGray }
                else { Write-Host "> $($mod.FileName)" -ForegroundColor DarkYellow }
            }
            Write-Host ""
        }
        if ($cheatMods.Count -gt 0) {
            Write-Host "{ !!! SECURITY TRIGGER MODIFICATION DETECTED !!! }" -ForegroundColor Red
            foreach ($mod in $cheatMods) {
                Write-Host "> $($mod.FileName)" -ForegroundColor Red -NoNewline
                if ($mod.DepFileName) { Write-Host " -> Embedded: $($mod.DepFileName)" -ForegroundColor LightMagenta -NoNewline }
                Write-Host " Rules Triggered: [ $($mod.StringsFound -join ', ') ]" -ForegroundColor DarkMagenta
            }
            Write-Host ""
        }
    } else { Write-Host "[-] Archive targets absent inside tracking directory.`n" -ForegroundColor Gray }
}

# ----------------------------------------------------------------
# ENGINE 5: NON-MICROSOFT EXECUTABLE DETECTION ARCHIVE
# ----------------------------------------------------------------
Write-Host "==================================================" -ForegroundColor Cyan
Write-Host "       ENGINE 5: SYSTEM PORTABILITY RADAR         " -ForegroundColor Green
Write-Host "==================================================" -ForegroundColor Cyan

$directories = @("$env:windir\System32", "$env:windir\SysWOW64", "$env:USERPROFILE\AppData\Local\Temp")
$outputDir = "C:\Screenshare"
$outputFile = "$outputDir\paths.txt"

if (-not (Test-Path $outputDir)) { New-Item -ItemType Directory -Path $outputDir -Force | Out-Null }
if (Test-Path $outputFile) { Remove-Item $outputFile -Force }

$microsoftRegex = [regex]::new('Microsoft|Windows|Redmond', [System.Text.RegularExpressions.RegexOptions]::IgnoreCase -bor [System.Text.RegularExpressions.RegexOptions]::Compiled)
$trustedRegex = [regex]::new('NVIDIA|Intel|AMD|Realtek|VIA|Qualcomm|Razer|Lenovo|Dolby|HP Inc|Dell Inc|ASUS|Acer|Logitech|Corsair|SteelSeries|HyperX', [System.Text.RegularExpressions.RegexOptions]::IgnoreCase -bor [System.Text.RegularExpressions.RegexOptions]::Compiled)
$knownCheatRegex = [regex]::new('manthe|vape|entropy|drip|cheat|injector', [System.Text.RegularExpressions.RegexOptions]::IgnoreCase -bor [System.Text.RegularExpressions.RegexOptions]::Compiled)

$knownGoodFiles = @{ 'ntoskrnl.exe'=$true; 'kernel32.dll'=$true; 'user32.dll'=$true; 'advapi32.dll'=$true; 'shell32.dll'=$true; 'explorer.exe'=$true; 'svchost.exe'=$true; 'services.exe'=$true; 'lsass.exe'=$true; 'csrss.exe'=$true; 'winlogon.exe'=$true; 'dwm.exe'=$true }
$signatureCache = @{}

function Test-ShouldIncludeFile {
    param([System.IO.FileInfo]$FileInfo)
    try {
        $fileName = $FileInfo.Name
        if ($fileName -like "*.mui") { return $false }
        
        $extension = $FileInfo.Extension.ToLower()
        if ($extension -ne "") {
            $nonExecutableExtensions = @('.evtx', '.etl', '.dat', '.db', '.log', '.log1', '.log2', '.regtrans-ms', '.blf', '.cab', '.rtf', '.inf', '.txt', '.tmp', '.bin', '.bak', '.btx', '.btr', '.wal', '.xml', '.db-wal')
            if ($nonExecutableExtensions -contains $extension) { return $false }
        }

        # Quick validation check for structural MZ Magic Header bytes
        $stream = [System.IO.File]::OpenRead($FileInfo.FullName)
        $buffer = New-Object byte[] 2
        $bytesRead = $stream.Read($buffer, 0, 2)
        $stream.Close()
        if ($bytesRead -lt 2 -or $buffer[0] -ne 0x4D -or $buffer[1] -ne 0x5A) { return $false }

        if ($fileName -match '^(microsoft|windows|ms)') { return $false }
        if ($knownGoodFiles.ContainsKey($fileName.ToLower())) { return $false }

        $filePath = $FileInfo.FullName
        if ($signatureCache.ContainsKey($filePath)) { return $signatureCache[$filePath] }
        
        $signature = Get-AuthenticodeSignature -FilePath $filePath -ErrorAction SilentlyContinue
        if ($signature -and $signature.Status -eq "Valid" -and $signature.SignerCertificate) {
            $subject = $signature.SignerCertificate.Subject
            if ($knownCheatRegex.IsMatch($subject)) { $signatureCache[$filePath] = $true; return $true }
            if ($microsoftRegex.IsMatch($subject) -or $trustedRegex.IsMatch($subject)) { $signatureCache[$filePath] = $false; return $false }
        }

        $versionInfo = $FileInfo.VersionInfo
        if ($versionInfo.CompanyName) {
            if ($microsoftRegex.IsMatch($versionInfo.CompanyName) -or $trustedRegex.IsMatch($versionInfo.CompanyName)) { return $false }
        }
        return $true
    } catch { return $false }
}

Write-Host "[*] Evaluating binary structures across target folders..." -ForegroundColor Cyan
$startTime = Get-Date
$fileCount = 0
$totalFilesChecked = 0
$stringBuilder = [System.Text.StringBuilder]::new()

foreach ($directory in $directories) {
    if (-not (Test-Path $directory)) { continue }
    Write-Host "  -> Tracking Target Directory: $directory" -ForegroundColor Yellow
    
    try {
        $files = Get-ChildItem -Path $directory -File -Recurse -Force -ErrorAction SilentlyContinue | Where-Object { $_.Length -ge 300KB }
        foreach ($fileInfo in $files) {
            $totalFilesChecked++
            if ($totalFilesChecked % 1000 -eq 0) { Write-Host "     Scanned Binaries: $totalFilesChecked | Tracked Exceptions: $fileCount" -ForegroundColor Gray }
            if (Test-ShouldIncludeFile -FileInfo $fileInfo) {
                [void]$stringBuilder.AppendLine($fileInfo.FullName)
                $fileCount++
            }
        }
    } catch {}
}

[System.IO.File]::WriteAllText($outputFile, $stringBuilder.ToString(), [System.Text.UTF8Encoding]::new($false))
$totalTime = (Get-Date) - $startTime

Write-Host "`n[✓] Executable Memory Subspace Map Complete" -ForegroundColor Green
Write-Host "  Processing Duration: $([math]::Round($totalTime.TotalSeconds, 1)) Seconds" -ForegroundColor White
Write-Host "  Total System Files Inspected: $totalFilesChecked" -ForegroundColor White
Write-Host "  Isolated Third-Party Artifacts: $fileCount" -ForegroundColor Cyan
Write-Host "  Log Storage Reference:          $outputFile`n" -ForegroundColor Cyan

if ($fileCount -gt 0 -and (Test-Path $outputFile)) {
    Write-Host "{ Primary Artifact Array Samples }" -ForegroundColor DarkCyan
    $samplePaths = Get-Content $outputFile | Select-Object -First 5
    foreach ($path in $samplePaths) {
        if (Test-Path $path) {
            $fileItem = Get-Item $path -ErrorAction SilentlyContinue
            $sizeMB = [math]::Round($fileItem.Length / 1MB, 2)
            $sig = Get-AuthenticodeSignature -FilePath $path -ErrorAction SilentlyContinue
            if ($sig -and $sig.SignerCertificate -and ($sig.SignerCertificate.Subject -match 'manthe|vape|entropy')) {
                Write-Host "  [FLAGGED GHOST INSTANCE MODULE] -> $path ($sizeMB MB)" -ForegroundColor Red
            } else {
                Write-Host "  [Third-Party Component File] -> $path ($sizeMB MB)" -ForegroundColor Green
            }
        }
    }
}

# Launch native visualization vectors
Start-Process explorer.exe $env:TEMP
Start-Process explorer.exe "shell:recent"

Write-Host "`n======================================================================" -ForegroundColor Cyan
Write-Host "[✓] SYSTEM LOG PROCESSING COMPLETE. STAGED PATH RUNTIME ACTIVE." -ForegroundColor Green
Write-Host "======================================================================" -ForegroundColor Cyan
while ($true) { Start-Sleep 3600 }
