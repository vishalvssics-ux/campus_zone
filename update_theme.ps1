$Path = "d:\Campus_zone_user\campus_zone_user\lib\screens"
$Files = Get-ChildItem -Path $Path -Recurse -Filter *.dart

$ImportString = "import 'package:campus_zone_user/utils/app_theme.dart';"

foreach ($File in $Files) {
    $Content = Get-Content $File.FullName -Raw
    
    $HasChanges = $false
    
    # Replace old primary colors
    if ($Content -match "Color\(0xFF3F61B5\)") {
        $Content = $Content -replace "Color\(0xFF3F61B5\)", "AppTheme.primaryColor"
        $HasChanges = $true
    }
    if ($Content -match "Color\(0xFF15244B\)") {
        $Content = $Content -replace "Color\(0xFF15244B\)", "AppTheme.primaryColor"
        $HasChanges = $true
    }
    if ($Content -match "Color\.fromARGB\(255, 21, 36, 75\)") {
        $Content = $Content -replace "Color\.fromARGB\(255, 21, 36, 75\)", "AppTheme.primaryColor"
        $HasChanges = $true
    }
    
    # Add AppTheme import if there were changes and the import is missing
    if ($HasChanges -and -not ($Content -match "app_theme\.dart")) {
        # Find the last import line
        $Lines = $Content -split "`n"
        $LastImportIndex = -1
        for ($i = 0; $i -lt $Lines.Count; $i++) {
            if ($Lines[$i] -match "^import ") {
                $LastImportIndex = $i
            }
        }
        
        if ($LastImportIndex -ge 0) {
            # Insert after the last import
            $NewLines = @()
            for ($i = 0; $i -lt $Lines.Count; $i++) {
                $NewLines += $Lines[$i]
                if ($i -eq $LastImportIndex) {
                    $NewLines += $ImportString
                }
            }
            $Content = $NewLines -join "`n"
        } else {
            # Just prepend
            $Content = $ImportString + "`n" + $Content
        }
    }
    
    if ($HasChanges) {
        Set-Content -Path $File.FullName -Value $Content -NoNewline
        Write-Host "Updated $($File.Name)"
    }
}
Write-Host "Done!"
