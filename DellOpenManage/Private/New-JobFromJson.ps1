using module ..\Classes\Job.psm1
using module ..\Classes\JobDetail.psm1
function New-JobFromJson {
    Param(
        [PSCustomObject]$Job,
        [PSCustomObject]$JobDetails
    )
    $JobObj = [Job]@{
        Id = $Job.Id
        JobName = $Job.JobName
        JobDescription = $Job.JobDescription
        NextRun = $Job.NextRun
        LastRun = $Job.LastRun
        StartTime = $Job.StartTime
        EndTime = $Job.EndTime
        Schedule = $Job.Schedule
        State = $Job.State
        CreatedBy = $Job.CreatedBy
        UpdatedBy = $Job.UpdatedBy
        Visible = $Job.Visible
        Editable = $Job.Editable
        Builtin = $Job.Builtin
        UserGenerated = $Job.UserGenerated
        LastRunStatusId = $Job.LastRunStatus.Id
        LastRunStatus = $Job.LastRunStatus.Name
    }
    if ($JobDetails) {
        foreach ($JobDetail in $JobDetails) {
            $JobObj.JobDetail += [JobDetail]@{
                Id = $JobDetail.Id
                Key = $JobDetail.Key
                Progress = $JobDetail.Progress
                ElapsedTime = $JobDetail.ElapsedTime
                StatusId = $JobDetail.JobStatus.Id
                Status = $JobDetail.JobStatus.Name
                StartTime = $JobDetail.StartTime
                EndTime = $JobDetail.EndTime
                Output = $JobDetail.Value
            }
        }
    }
    return $JobObj
}