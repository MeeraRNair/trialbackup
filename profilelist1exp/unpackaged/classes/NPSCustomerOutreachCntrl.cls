/* ============================================================
 * This Controller Created for disaplying list of cases having Owner Id as login User ID
 * CR 9025 - Version 0.1 Developed by Rakesh Muppiri on 22-01-2014
 * ============================================================
 */
 
public class NPSCustomerOutreachCntrl{
    public List<case> C{set;get;}
    public boolean OldCasesExist{set;get;}
    public NPSCustomerOutreachCntrl(){
        C = [SELECT CreatedDate,subject,AccountId,CaseNumber,ClosedDate,ContactId,Description,Id, Status, Due_Date__c FROM Case WHERE RecordTypeID IN (SELECT Id FROM RecordType WHERE Name = 'NPS Cases') AND OwnerId =: userinfo.getUserId() ORDER BY  CreatedDate DESC];
        
        //Cases that are older than 7 days, with status not completed having Owner Id as Login User Id
        Integer i = [SELECT count() from Case Where CreatedDate <: System.now()-7 AND Status != 'Completed' AND OwnerId =: userinfo.getUserId()];
        if(i>0)
           OldCasesExist = true; 
    }
}