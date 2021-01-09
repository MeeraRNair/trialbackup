/* 
History:
Version     Date            Modified By                     CR          Description     
--------------------------------------------------------------------------------------
1.0         18-Oct-2016     Sazleen Ahmad                13609       Story 2495505:Update D&B URL in Useful Links Section & Add Tracking
2.0         03-Jan-2017     Sazleen Ahmad                13871       Story 2726819:Update SF1 Adoption object Region field.
3.0         04-Aug-2018     SinLin                       16275       Story 5415829 Lightning Critical Update Fix - Theme
*/

public class DBPortal {
    public String currentRecord {get;set;}
    public String sPlatform {get; set;}
     public String objectType {get; set;}
    public String accRegion {get; set;}
    public String oppRegion {get; set;}
    
    public DBPortal() {
        currentRecord = ApexPages.currentPage().getParameters().get('id');
        objectType = ApexPages.currentPage().getParameters().get('obj');
        
        getOpportunityRegion();
        getAccountRegion();
        
    }
    
    
    public void getAccountRegion()
    { 
        if(objectType == 'Account'){
            Account AccObj = [Select Regional_Parent_Name_lookup__c from Account where id =:currentRecord];
            if(accObj!=null){
                accRegion = accObj.Regional_Parent_Name_lookup__c;
            }
        }
    system.debug('Debug AccRegion#########'+AccRegion);
    }

    public void getOpportunityRegion()
    { 
        if(objectType == 'Opportunity'){
            Opportunity oppObj = [Select Account.Regional_Parent_Name_lookup__c from Opportunity where id =:currentRecord];
            if(oppObj!=null){
                oppRegion = oppObj.Account.Regional_Parent_Name_lookup__c;
            }
        }
    system.debug('Debug oppRegion#########'+oppRegion);
    }

    
    public PageReference redirect() {
        DBcountClick();
        
        try{
            return new PageReference(Label.DB_Portal_Link);
            
        }catch(Exception e){System.debug(e.getMessage());}
        return null;
    }
    

    public void DBcountClick(){
        try{
            //Save data for tracking purpose (clicks count)
            SF1_Adoption__c obj = new SF1_Adoption__c();
            
            obj.Record_ID__c = currentRecord;
            obj.Source__c =  'D&B Portal Link';
            obj.User_Action__c = '';
            obj.User_Edited_Date__c = Datetime.now();
            obj.User_Name__c = UserInfo.getUserId(); 
            
            
            obj.Object_Name__c = objectType;
            if(obj.Object_Name__c=='Opportunity'){
                obj.Region__c = oppRegion;
            }else if(obj.Object_Name__c=='Account'){
                obj.Region__c = accRegion;
            }
            
            
            sPlatform = userinfo.getUiTheme();
            if (sPlatform == 'Theme1' || sPlatform == 'Theme2' || sPlatform == 'Theme3'){
                obj.Platform__c = 'Salesforce Classic';}
              else if (sPlatform == 'Theme4d' || sPlatform == 'Theme4u'){
                obj.Platform__c = 'Salesforce Lightning';}
                else if (sPlatform == 'Theme4t'){
                    obj.Platform__c = 'Salesforce1 Mobile';}
            
            insert obj;
        }catch(DmlException e){System.debug(e.getMessage());}
    }
}