function Get-AMHCTaskVersionOld {
    <#
        .SYNOPSIS
            Old Task Versions

        .DESCRIPTION
            Tasks whose version doesn't match the server version

        .PARAMETER Tasks
            The tasks to perform health check against
    #>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [AllowNull()]
        $Tasks
    )

    foreach ($task in ($Tasks | Where-Object {-not [string]::IsNullOrEmpty($_.AML)})) {
        try {
            $xml = [xml]$task.AML
        } catch {
            # Old Task Version health check will report this
            continue
        }
        $taskConnection = Get-AMConnection -Connection $task.ConnectionAlias
        switch ($taskConnection.Version.Major) {
            10      {$taskVersion = $xml.AMTASK.AMTASKHEAD.TASKINFO.TASKVERSION}
            default {$taskVersion = $xml.AutomateTask.TaskInfo.Version.TaskVersion}
        }
        if ([Version]$taskVersion -ne $taskConnection.Version) {
            [AMConstructHealthCheckItem]::New($task, "Task version: $taskVersion")
        }
    }
}