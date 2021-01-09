/* 
REVISION HISTORY
======================================================================================================================
Version    Author    Date           Release#    CR#    Description
-------    ------    ----           --------    ---    -----------
1.0        Jiji      30-Nov-2013     15.07      9355   To delete the permissionset assignment during R2C/R2S
*/
global class Batch_CMAPDelAssignmentScheduler implements Schedulable{
    global void execute(SchedulableContext sc) {
        
        datetime systime = datetime.now();
        Batch_CMAPDelAssignment batchDelAssignment = new Batch_CMAPDelAssignment ();
        batchDelAssignment.query= 'SELECT Id, AssigneeId,PermissionSetId,SystemModstamp  '+
                                  ' FROM PermissionSetAssignment '+
                                  //' WHERE PermissionSet.Name LIKE \'Channel_R2S_Access\'';
                                  
                                  ' WHERE (PermissionSet.Name LIKE \'Channel_Permission_Set_for_R2C\' OR PermissionSet.Name LIKE  \'Channel_R2S_Access\' ) ';
                                  /*' AND SystemModstamp  <= '+dateperiod ;
                                  */
        database.executebatch(batchDelAssignment,200);
        
    }  
}