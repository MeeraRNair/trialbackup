/*
 * Author  : Krishnakumar M
 * Purpose : Buddy Request Functionality
 * 
 * Revision CR Number   Release No  Date            Modified By     Description
 * -------- ---------   ----------  -----------     ------------    -----------
 * 1.0      CR14112      05.02      20-Feb-2017     Krishnakumar    Buddy Request - Create Batch Processes to Add/Remove Buddy member to ATM
 * 2.0      CR16640      08.02      04-Jul-2017     Krishnakumar   SE149 - SE149 - Permanent Fix for the Defect 3497907 Buddy Access batch process
 */
public class AtmGDMRelationClass{
    public ID idGdmReq {get;set;}
    public ID idRolUser {get;set;}
    public ID idBuddyUser {get;set;}
    public ID idAccount {get;set;}
    public ID idBuddyATM {get;set;}
    public ID idRepATM {get;set;}    
    public ID idLastModifiedBy {get;set;}
    public Date dtStartDate {get;set;}
    public Date dtEndDate {get;set;}
    public String strRepAccountAccess {get;set;}
    public String strRepCaseAccess {get;set;}
    public String strRepOpportunityAccess {get;set;}
    public String strRepTeamMemberRole {get;set;}
    public String strBuddyAccountAccess {get;set;}
    public String strBuddyCaseAccess {get;set;}
    public String strBuddyOpportunityAccess {get;set;}
    public String strBuddyTeamMemberRole {get;set;}

    //public AccountTeamMember rolATM {get;set;}
    //public AccountTeamMember buddyATM {get;set;}

    public AtmGDMRelationClass(){

    }
}