public class ApprovalRequestCommentsController {

    // ID of the record whose most recent approval process comments to retrieve
    public ID targetObjectId { get; set; }
    
    // The most recent approval process comments
    // Could show in visualforce email template, for example
    public String strComments {
        get {
            if ( strComments == null ) {
                ProcessInstanceStep lastStep = getLastApprovalStep();
                strComments = ( lastStep != null ) ? lastStep.comments : '';
            }
            return strComments;
        }
        private set;
    }
    
    public ApprovalRequestCommentsController() {}
    
    // Queries the most recent approval process step for the target record
    private ProcessInstanceStep getLastApprovalStep() {
        List<ProcessInstanceStep> listSteps = new List<ProcessInstanceStep>([
            SELECT
                Comments
            FROM
                ProcessInstanceStep
            WHERE
                ProcessInstance.TargetObjectId = :targetObjectId
            ORDER BY
                SystemModStamp DESC
            LIMIT
                1
        ]);
        return ( listSteps.size() > 0 ) ? listSteps[0] : null;
    }
    
}