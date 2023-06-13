$BuildNumber = $env:BUILD_NUMBER
$JMeterLogFile = "Logs_$BuildNumber.jtl"

# Replace the placeholder with the build number in the JMeter log file name
$JMeterLogFile = $JMeterLogFile -replace "%build.number%", $BuildNumber

# Execute the JMeter command with the updated log file name
& "C:\Users\s.slavcheva\Desktop\Demo\jmeterProjectDynamo\apache-jmeter-5.5\bin\jmeter.bat" -n -t "C:\Users\s.slavcheva\Desktop\Demo\jmeterProjectDynamo\apache-jmeter-5.5\bin\Perf_API.jmx" -l $JMeterLogFile

# & "C:\Users\s.slavcheva\Desktop\Demo\jmeterProjectDynamo\apache-jmeter-5.5\bin\jmeter.bat" -n -t "C:\Users\s.slavcheva\Desktop\Demo\jmeterProjectDynamo\apache-jmeter-5.5\bin\Perf_API.jmx" -l "%jmeter_logfile%"

Start-Sleep -Seconds 300
Copy-Item -Path "C:\BuildAgent\work\39fc5dc3e607d09c\Logs.jtl" -Destination "\\SF-SSLAVCHEVA\share\Logs23.jtl"

Write-Output "##teamcity[blockOpened name='script is run']"

Write-Host "Insert records in DB"
$DatabaseServer = "DYNAMOSQL3\SQL2019"
$DatabaseSchema = "testresults" 
$DatabaseUser = "profiler"
$DatabasePass = "profiler"

$SqlConnection = New-Object System.Data.SqlClient.SqlConnection
$SqlConnection.ConnectionString = "Data Source=$DatabaseServer;Initial Catalog=$DatabaseSchema;User Id=$DatabaseUser;Password=$DatabasePass" 
$SqlCmd = New-Object System.Data.SqlClient.SqlCommand
#$SqlCmd.CommandText = "BULK INSERT testresults.dbo.PerformanceAPISummaryReport FROM '\\sf-fs-01.netagesolutions.com\Sofia\Products\QA\PerformanceTesting\JmeterResults\Result.csv' WITH (FIELDTERMINATOR = ',', ROWTERMINATOR = '\n',FIRSTROW = 2);"

#Copy-Item -Path "C:\BuildAgent\work\39fc5dc3e607d09c\Logs.jtl" -Destination "\\SF-SSLAVCHEVA\share\Logs23.jtl"

$SqlCmd.CommandText = @"
BULK INSERT testresults.dbo.PerformanceAPISummaryReport 
FROM '\\SF-SSLAVCHEVA\share\Logs23.jtl'
WITH (FIELDTERMINATOR = ',', ROWTERMINATOR = '\n', FIRSTROW = 2);
"@


$SqlCmd.Connection = $SqlConnection 
$SqlConnection.Open()
$SqlCmd.ExecuteNonQuery()
$SqlConnection.Close()

Write-Host "Done"










