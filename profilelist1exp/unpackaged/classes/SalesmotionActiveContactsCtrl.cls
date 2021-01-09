/*
* Controller logic to fetch salesmotion Active & Inactive contacts
* 
* Getting salesmotion account associated partner track, then fetch the contacts under the master group account.
* Then check salesmotion account partner track exist in contact based on status and segregate active and inactive contacts.
* 
* 
* Story     CR Number   Release No      Date            Created By     Description
* --------  ---------   ----------      -----------     -----------    -----------
* #5906775               FY20-0402       04-Jan-2019      Varsha       To display salemotion Active & Inactive contacts
*                                                                      
*/
public with sharing class SalesmotionActiveContactsCtrl {
    
    //Declaration of variables and collections
    private ApexPages.StandardController controller;
    private Id accountId;//Getting AccountId from Url
    public List<Contact> listSalesMotionActiveContacts {get;set;}//This list is used to segregate Active contacts and return to page
    public List<Contact> listSalesMotionContacts {get;set;}
    public Account salesAccountObj;//This instance is used to fetch salesmotion account object based on url id
    public String  strConId {get; set;}// This is used to get contact id
    public List<String> listConStatus = new List<String> {'Customer','Active','Prospect','Marketing Suspect','INTERNAL - Crisis Mgmt'};
    //Constructor: Initiate of variables, fetching salesmotion account and calling method to fetch contacts on load
    public SalesmotionActiveContactsCtrl(ApexPages.StandardController controller) {
        
        this.controller = controller;
        accountId  = controller.getId();
        if(accountId != null){
            salesAccountObj = [SELECT Id, Master_Group_Id__c,Partner_Track__c FROM Account WHERE id =: accountId];
        }
        system.debug('masteraccountId:'+salesAccountObj.Master_Group_Id__c+'partnerTrackId:'+salesAccountObj.Partner_Track__c);
        getContacts();
    }
    
    //This method is used to segregate Active and Inactive contacts based on contact status
    public void getContacts(){
        List<String> listEligibleTracksId;
        listSalesMotionActiveContacts = new List<Contact>();
        //Getting all contacts based on masteraccountid
        for(Contact con: [SELECT Id, AccountId, EligibleTracks__c, Name, Enable_as_Partner_Group_Administrator__c, Partner_User_Partner_Admin__c, Decision_Making_Role__c, NPS_Qualified_Status__c, Primary_Contact_for_Service_Type__c, Partner_User_Active__c, Email, Status__c, Phone, Partner_User_Deal_Registration__c FROM Contact WHERE AccountId =: salesAccountObj.Master_Group_Id__c and Status__c IN: listConStatus]){
            listEligibleTracksId = new List<String>();
            if(String.isNotBlank(con.EligibleTracks__c)){
                if(String.ValueOf(con.EligibleTracks__c).contains(';')){
                    listEligibleTracksId.addAll(con.EligibleTracks__c.split(';'));
                }
                else{
                    listEligibleTracksId.add(con.EligibleTracks__c);
                }
               system.debug('listEligibleTracksId if block:'+listEligibleTracksId);
               if(listEligibleTracksId.size() > 0 && listEligibleTracksId.contains(salesAccountObj.Partner_Track__c)){
                   listSalesMotionActiveContacts.add(con);
               }
                }
                     
            }
        system.debug('salesmotioncontacts:'+listSalesMotionActiveContacts);
        List<Id> listConIds = new List<Id>();
        for(Contact con: listSalesMotionActiveContacts){
                listConIds.add(con.id);
        }
     /*   listSalesMotionContacts =  [SELECT id,AccountId, EligibleTracks__c, Name, Enable_as_Partner_Group_Administrator__c, Partner_User_Partner_Admin__c, Decision_Making_Role__c, NPS_Qualified_Status__c, 
                                        Primary_Contact_for_Service_Type__c, Partner_User_Active__c, Email, Status__c, Phone,
                                        Partner_User_Deal_Registration__c FROM Contact WHERE Id IN :listConIds and Status__c IN :listConStatus ];*/
        }
    
    //This method is used to get all Inactive contacts based on flag bGoToListActive
    public List<Contact> getSalesMotionActiveContacts(){
       
       
            List<Id> listConIds = new List<Id>();
            for(Contact con: listSalesMotionActiveContacts){
                listConIds.add(con.id);
            }
          //  system.debug('offsetSize in method!!!:'+intOffsetActiveSize);
            return [SELECT id,AccountId, EligibleTracks__c, Name, Enable_as_Partner_Group_Administrator__c, Partner_User_Partner_Admin__c, Decision_Making_Role__c, NPS_Qualified_Status__c, 
                    Primary_Contact_for_Service_Type__c, Partner_User_Active__c, Email, Status__c, Phone,
                    Partner_User_Deal_Registration__c FROM Contact WHERE Id IN :listConIds ];
           
        }
    
    
    
    
   
    //This method is used to redirect to contact edit page as standard edit
    public pageReference editContact(){
        //String strReturnURL = EncodingUtil.urlEncode('','UTF-8');
        String strSaveUrl = EncodingUtil.urlEncode('&nooverride=1&saveURL=/apex/AVSContactSuggestion?id=','UTF-8');
        pageReference pr = new PageReference('/'+strConId+'/e?retURL='+strConId+strSaveUrl+strConId);
        return pr;
    }
}