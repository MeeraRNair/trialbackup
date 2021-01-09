/*
 * Author   : Ismail Khan
 * Purpose  : To get the dynamic data from MLUR
 * 
 * Revision CR Number   Release No  Date            Modified By     Description
 * -------- ---------   ----------  -----------     ------------    -----------
 * 1.0      CR15347     0203        17-Nov-2017      Ismail Khan      To get the dynamic data from MLUR
 * 
 */

public class Channel_Email_Accepted_Leads_Ctrl{
    public Id thisUserId {get;set;} 
    public string thistypeOfEmail{get;set;}
    public List<tableData> thisUserLeads = new List<tableData>();
    public class tableData{
        public ID campID{get;set;}
        public String campName{get;set;}
        public String campMascotId{get;set;}
        public String partnerAcctAffinitiId{get;set;}
        public String partnerAcctName{get;set;}
        public tableData(ID campID, String campName, String campMascotId,String partnerAcctAffinitiId,String partnerAcctName){
          this.campID =campID;
          this.campName =campName;
          this.campMascotId =campMascotId;
          this.partnerAcctAffinitiId =partnerAcctAffinitiId;
          this.partnerAcctName =partnerAcctName;
          
        }
    }
    public List<tableData> getThisUserLeads() {  
        String query;
        if(thisUserId != null){         
            //query = 'SELECT Id, Campaign__c, PartnerAccount.Account_ID__c, PartnerAccount.Name, Campaign__r.Aprimo_Activity_ID__c, Campaign__r.Name FROM Lead WHERE Partner_User__c = \''+thisUserId+'\' and Status = \'Accepted by Channel\' ORDER BY Campaign__c';
            //query = 'SELECT Id, Campaign__c, PartnerAccount.Account_ID__c, PartnerAccount.Name, Campaign__r.Aprimo_Activity_ID__c, Campaign__r.Name FROM Lead WHERE Partner_User__c = \''+thisUserId+'\' ORDER BY Campaign__c';
            
            Id leadassignmnetRTId = IdLookupUtils.getRecordTypeId('Channel Lead - Assignment Complete', 'Lead', true);
            query = 'SELECT Id, Campaign__c, PartnerAccount.Account_ID__c, PartnerAccount.Name, Campaign__r.Aprimo_Activity_ID__c, Campaign__r.Name FROM Lead Where Partner_User__c = \''+thisUserId+'\' AND Status = \'Accepted By Channel Partner\' AND RecordTypeId = \''+leadassignmnetRTId +'\' AND Send_email_for_Accepted_Status__c = TRUE ORDER BY Campaign__c';
            SET<ID> campIds = new SET<ID>();
            for(Lead obj:Database.Query(query)){
                if(!campIds.contains(obj.Campaign__c)) {
                    campIds.add(obj.Campaign__c);
                    thisUserLeads.add(new tableData(obj.Campaign__c, obj.Campaign__r.Name, obj.Campaign__r.Aprimo_Activity_ID__c, obj.PartnerAccount.Account_ID__c, obj.PartnerAccount.Name));
                }
            }
        }
        return thisUserLeads;    
    }
}