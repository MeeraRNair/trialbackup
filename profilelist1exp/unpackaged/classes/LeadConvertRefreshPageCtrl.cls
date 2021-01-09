/*
* Author   : Azwanti
* Purpose  : This is the controller for the Visual Force page leadConvertRefreshPage.
* 
* Revision CR Number   Release No      Date            Modified By     Description
* -------- ---------   ----------      -----------     ------------    -----------
* 1.0      14012      FY18-DCS-0302   21-Feb-2017     Azwanti         LM2_Optimization in lead conversion process - UI changes refresh
* 2.0      14117      FY18 DCS-0502   11-Apr-2017     Ashok           LM2_Account chatter feed deletion after lead conversion
* 8.0      17465      FY20-DCS-1002   01-Aug-2019     Sonali          Added Logic to update Contact_from_Lead_Conversion__c flag for contacts created from Lead conversion
* 8.1      18006      FY20-DCS-1002   05-Aug-2019     Kokila          Link Contact to Master Group Account for Lead's attached to Partner Account during conversion
* 9.0      18330      FY20-DCS-0102   25-Nov-2019     Yamini          Added logic to check user theme and call the opportunity Edit page accordingly
* 9.1      18330      FY20-DCS-0102   09-Dec-2019     Yamini          Defect    7774691: SDET-Wunderkind-Classic-When lead is converted to Small Deal Oppty , after editing the details on the deal and saving, it is redirected to home page
*/
public class LeadConvertRefreshPageCtrl {
    public id leadId;
    public Lead leadToConvert {get; set;}
    public id contactId;
    public id opptyId;
    public string strOpptyType;
    public string strOpptyDaysCreated;
    public string salesLoginUser;
    public string strPartnerAccountRT;
          
    public LeadConvertRefreshPageCtrl(ApexPages.StandardController stdController){
        //leadId = stdController.getId();
        Map<string, string> pageParams = Apexpages.currentpage().getparameters();
        leadId = pageParams.get('id');
        contactId = pageParams.get('contactId');
        opptyId = pageParams.get('OpptyId');
        strOpptyType = pageParams.get('OpptyType');
        strOpptyDaysCreated = pageParams.get('strOpptyDaysCreated');
        salesLoginUser = pageParams.get('salesLoginUser');
        
                      
        leadToConvert = [SELECT Questions_Comments__c,IsConverted,Department__c,ConvertedAccountId,Status,Reason__c,campaign__c,RecordTypeId,sales_comments__c,marketing_comments__c FROM Lead WHERE Id = :leadId LIMIT 1];
         //updateAccContCMTask(); 
    }
    
    public pageReference updateAccContCMTask(){
         //v1.6 - Explicitly call two methods referenced in contact triggers that were skipped.
        //6.0 //6.2 //7.0
        list<contact> lstContacts = [select Id,Contact_from_Lead_Conversion__c, Mailing_Address_Changed__c, Status__c, AccountId, Account_Active_Contact__c, Account_Inactive_Contact__c, Department from contact where Id = :contactId];
        
        //Start - v8.1
        strPartnerAccountRT = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Partner Account').getRecordTypeId();
        if(lstContacts!=null && !lstContacts.isEmpty()){ 
            Account[] listacc = [select Id, Master_Group_Id__c from Account where id =:lstContacts[0].AccountId and Master_Group_Id__c != null and RecordTypeId =:strPartnerAccountRT];
            if(listacc.size() > 0){
                lstContacts[0].AccountId = listacc[0].Master_Group_Id__c;
            }           
        }    
        //End - v8.1
        
        if(strOpptyType == 'New' || strOpptyType == 'SmallDeal') {
            ContactFieldPopulator.populateActiveInactiveLookupFieldsToAccount(lstContacts);
            ContactFieldPopulator.populateMailingAddressChanged(lstContacts);
            //6.5
            TriggerExecutionController.setSkipOpportunityTriggers(true);
            Map<string, List<Id>> mapOpptyTypeOpptyId = new map<string, List<Id> >{strOpptyType => new List<Id> {opptyId}};                    
                Lead2OpptyAssnUtils.setupOpptyAfterConversion(mapOpptyTypeOpptyId);
            TriggerExecutionController.setSkipOpportunityTriggers(false);
        }
        //6.0 Do the necessary to link up the lead with the oppty selected
        else if(strOpptyType == 'Existing') {
            
            TriggerExecutionController.setSkipOpportunityTriggers(true);   
            Map<Id, List<Id>> mapOppIdToContactId = new Map<Id, List<Id>>{opptyId => new List<Id>{contactId}};
                Lead2OpptyAssnUtils.insertOpportunityContactRole(mapOppIdToContactId);
            
            if(integer.valueOf(strOpptyDaysCreated) <= 97) {
                Map<String, String> mapOpptyToCampaign = new Map<String, String>{opptyId => leadToConvert.Campaign__c};
                    Lead2OpptyAssnUtils.setPrimaryCampaignInfluence(mapOpptyToCampaign);
            }
            
            TriggerExecutionController.setSkipOpportunityTriggers(false);
        }
        //7.0
        if(leadToConvert.Department__c != NULL && lstContacts[0].Department == NULL) {
            lstContacts[0].Department = leadToConvert.Department__c;
        } 
        
        List<string> listObjectNames = new List<string>(); 
        listObjectNames.add('Contact'); 
        TriggerExecutionController.setSkipContactTriggers(true);  
        SystemBehaviorBypasser.setSkipValidationRules(listObjectNames);
        //8.0 Added Logic to update Contact_from_Lead_Conversion__c flag for contacts created from Lead conversion
         if(!lstContacts.isEmpty()) {
         lstContacts[0].Contact_from_Lead_Conversion__c = FALSE;
        }            
        update lstContacts;
        
        ResetSystemBehaviorBypasser.resetSkipValidationRules(listObjectNames); 
        TriggerExecutionController.setSkipContactTriggers(false);   
        //7.0
        // v1.3 - Update Campaign Members explicitly
        // . After Update trigger on Lead is not updating the Campaign Member's CM Status - Technical Limitation
        // v5.0
        CampaignMember2StatusUtils.populateCampaignMember2Status(leadToConvert, true);
        //V9.0 Getting base url when user in lightning to use it in page reference
        String baseUrl = URL.getSalesforceBaseUrl().toExternalForm();
        pagereference pageref;
        if(salesLoginUser == 'true' && opptyId !=null && (strOpptyType == 'New' || strOpptyType == 'SmallDeal')){
        //V9.0 Starts: Checking the user theme.. to call opportunity edit page based on theme. 
            if(UserInfo.getUiTheme() != 'Theme3'){
              pageref = new PageReference(baseUrl+'/apex/Opptyeditforleadconversion?recordId='+opptyId+'&Opptytype='+strOpptyType);
          }
            
           //6.2
          else if(strOpptyType == 'SmallDeal') {
               // pageref = new PageReference('/' + leadConvertResult.getOpportunityId() + '/e');
               // 9.1 defect : Added ?retURL='+ opptyId
                 pageref = new PageReference('/' + opptyId + '/e?retURL='+ opptyId);
            }
          
          else{
              //v3.0 - add saveURL to navigate to Add Product Page
              //  pageref = new PageReference('/' + leadConvertResult.getOpportunityId()+'/e?retURL='+leadConvertResult.getOpportunityId()+'&saveURL=/p/opp/SelectSearch?addTo='+leadConvertResult.getOpportunityId());
                pageref = new PageReference('/' + opptyId +'/e?retURL='+ opptyId +'&saveURL=/p/opp/SelectSearch?addTo='+ opptyId);
              
            }                                
        }
        //V9.0 ends
        else{
            pageref = new PageReference('/' + contactId); 
        }   
        
        //V2.0
        if(!system.label.Bypass_AccountFeed_Deletion.equalsIgnoreCase('On')){
         DeleteAccountFeedFutureClass.invokeDelAccountFeed(new list<lead>{LeadToConvert});
        }
              
        pageRef.setRedirect(true);
        return pageRef; 
        
    }
}