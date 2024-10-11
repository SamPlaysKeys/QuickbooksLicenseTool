# Default location for the Quickbooks registration file in Windows.
$qblicensefile = "C:\ProgramData\Common Files\Intuit\QuickBooks\qbregistration.dat"

# Making sure the file exists.
if (-Not (Test-Path $qblicensefile)) {
    Write-Error "QuickBooks registration file not found at $qblicensefile."
    exit
}

# converting the raw file into an xml file
$qbraw = New-Object xml
$qbraw.Load((Convert-Path $qblicensefile))

# Creating a datatable to display the licenses
$datatable = New-Object System.Data.DataTable
$datatable.Columns.Add("Year")
$datatable.Columns.Add("Version")
$datatable.Columns.Add("Install_ID")
$datatable.Columns.Add("License_Number")
$datatable.Columns.Add("QB_Mode")

# This foreach loop polls the XML table, and exports the relevant data to the DataTable, converting versions into friendly text.
$qbraw.QBREG.QUICKBOOKSREGISTRATION.VERSION | foreach-object {
    # Check if FLAVOR (qb version) exists
    if ($_.FLAVOR) {
        $count = ($_.FLAVOR.name | measure)
        for ($int = 0; $int -lt $count.Count; $int++){
            $row = $datatable.NewRow()
            # Safely attempt to calculate the year
            try {
                $row.Year = ([int]$_.number) + 1990
            } catch {
                $row.Year = "Unknown"
            }

            # This list of types comes from Intuit's community forum, but may not be complete. 
            # Added a default option of "Unknown" to resolve errors with out-of-bounds flavors
            $row.Version = switch ($_.FLAVOR.name[$int]) {
                "pro" {"Quickbooks Pro"}
                "superpro" {"QuickBooks Premier (not Accountant Edition)"}
                "bel" {"QuickBooks Enterprise Solutions (not Accountant Edition)"}
                "belacct" {"QuickBooks Enterprise Solutions Accountant Edition"}
                "accountant" {"QuickBooks Premier Accountant Edition"}
                default {"Unknown Version"}
            }

            # Check that InstallID, LicenseNumber, and QBMode exist before accessing them
            $row.Install_ID = if ($_.FLAVOR.InstallID[$int]) { $_.FLAVOR.InstallID[$int] } else { "Unknown" }
            $row.License_Number = if ($_.FLAVOR.LicenseNumber[$int]) { $_.FLAVOR.LicenseNumber[$int] } else { "Unknown" }
            $row.QB_Mode = if ($_.FLAVOR.QBMode[$int]) { $_.FLAVOR.QBMode[$int] } else { "Unknown" }

            # Add the row to the DataTable
            $datatable.Rows.Add($row)
            # Add the row to the DataTable
            $datatable.Rows.Add($row)
        }
    }
}

clear # For ease of reading.
# I know using clear isn't best practice, but it simplifies the output. Feel free to comment out.

$datatable | Format-Table # To display the datatable in CLI.
