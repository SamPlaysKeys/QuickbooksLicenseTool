# Default location for the Quickbooks registration file in Windows.
$qblicensefile = "C:\ProgramData\Common Files\Intuit\QuickBooks\qbregistration.dat"

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
    $count = ($_.FLAVOR.name | measure)
    for($int = 0; $int -lt $count.Count; $int++){
        $row = $datatable.NewRow()
        $row.Year = ([int]$_.number)+1990
        $row.Version = switch ($_.FLAVOR.name[$int]){ # This list of types comes from Intuit's community forum, but may not be complete. 
            "pro" {"Quickbooks Pro"}
            "superpro" {"QuickBooks Premier (not Accountant Edition)"}
            "bel" {"QuickBooks Enterprise Solutions (not Accountant Edition)"}
            "belacct" {"QuickBooks Enterprise Solutions Accountant Edition"}
            "accountant" {"QuickBooks Premier Accountant Edition"}
        }
        $row.Install_ID = $_.FLAVOR.InstallID[$int]
        $row.License_Number = $_.FLAVOR.LicenseNumber[$int]
        $row.QB_Mode = $_.FLAVOR.QBMode[$int]

        $datatable.Rows.Add($row)
    } 
}

clear # For ease of reading.
$datatable | Format-Table # To display the datatable in CLI.
