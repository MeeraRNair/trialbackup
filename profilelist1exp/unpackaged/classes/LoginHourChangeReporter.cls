/*
 * Author : Devika Pujari 
 * Date   : 30/05/2016
 * Purpose: Helper class for VF Component -LoginHourChangeReporterComponent
 *          Retrieves a list of profiles whose login hours have changed the day before
 * Revision CR Number   Release No  Date            Modified By     Description
 * -------- ---------   ----------  -----------     ------------    -----------
 *
*/ 
public class LoginHourChangeReporter{
    
    public List<SetupAuditTrail> profileLoginHourUpdateList {get;set;}
    public LoginHourChangeReporter(){
        profileLoginHourUpdateList = [Select Field1,CreatedDate,CreatedBy.Name,CreatedBy.Email 
                                             From SetupAuditTrail Where CreatedDate = YESTERDAY 
                                             AND Action LIKE '%profileLoginHoursChanged%' ];
        
    }
    
    
}