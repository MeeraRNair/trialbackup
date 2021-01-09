/* Revision CR Number   Release No      Date            Modified By     Description
  * -------- ---------   ----------     -----------     ------------    -----------
  * 1.0                  DCS-0303       06-02-2017       Shivam         Method to assign Lead Source as Outside Agency when channel agency user submits a lead.
*/
 
public class LeadUtils{
    //Method to assign Lead Source as Outside Agency when channel agency user submits a lead.
    public static void assignLeadStatusForChannelUser(List<Lead> lstLeads){
     Id channelRecordTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('Channel Lead 2.0').getRecordTypeId();
     Profile pf =[Select Id,Name from Profile Where Id=:userinfo.getProfileid() LIMIT 1];
     for(Lead obj:lstLeads){
       if(channelRecordTypeId == obj.RecordTypeId && pf.Name.contains('Channel Agency')){
            obj.LeadSource = 'Outside Agency';
       }
     }
    }
}