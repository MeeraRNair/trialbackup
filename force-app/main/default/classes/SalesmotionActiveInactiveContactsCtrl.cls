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
public with sharing class SalesmotionActiveInactiveContactsCtrl {
    
    //Declaration of variables and collections
    private ApexPages.StandardController controller;
    private Id accountId;//Getting AccountId from Url
    public transient List<Contact> listSalesMotionActiveContacts {get;private set;}//This list is used to segregate Active contacts and return to page
    public List<Contact> listSalesMotionInactiveContacts {get;set;}//This list is used to segregate Inactive contacts and return to page
    public Account salesAccountObj;//This instance is used to fetch salesmotion account object based on url id
    public Integer intActTotalRecs {get;set;}//This is used to set total active records and display total active contacts count
    public Integer intInActTotalRecs {get;set;}//This is used to set total inactive records and display total inactive contacts count
    public Integer intLimitSize;//This is used to set limit to display set of records in table
    public Integer intOffsetActiveSize {get;set;}//This is used to set offset for Active contacts
    public Integer intOffsetInactiveSize {get;set;}//This is used to set offset for Inactive contacts
    public Boolean bGoToListActive {get;set;}//This flag is used to get all active contacts
    public Boolean bGoToListInActive {get;set;}//This flag is used to get all inactive contacts
    public String  strConId {get; set;}// This is used to get contact id
    public Boolean bLinkActiveEnableDisable {get;set;}//This flag is used to enable/disable active links
    public Boolean bLinkInactiveEnableDisable {get;set;}//This flag is used to enale/disable inactive links
    
    //Constructor: Initiate of variables, fetching salesmotion account and calling method to fetch contacts on load
    public SalesmotionActiveInactiveContactsCtrl(ApexPages.StandardController controller) {
        intActTotalRecs = 0;
        intInActTotalRecs = 0;
        intOffsetActiveSize = 0;
        intOffsetInactiveSize  = 0;
        intLimitSize = 5;
        bGoToListActive = false;
        bGoToListInActive = false;
        bLinkActiveEnableDisable = true;
        bLinkInactiveEnableDisable = true;
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
        listSalesMotionInactiveContacts = new List<Contact>();
        //Getting all contacts based on masteraccountid
        for(Contact con: [SELECT Id, AccountId, EligibleTracks__c, Name, Enable_as_Partner_Group_Administrator__c, Partner_User_Partner_Admin__c, Decision_Making_Role__c, NPS_Qualified_Status__c, Primary_Contact_for_Service_Type__c, Partner_User_Active__c, Email, Status__c, Phone, Partner_User_Deal_Registration__c FROM Contact WHERE AccountId =: salesAccountObj.Master_Group_Id__c]){
            listEligibleTracksId = new List<String>();
            if(String.isNotBlank(con.EligibleTracks__c)){
                //This will execute if eligible tracks has one or more id's
                //One id with semicolon it will work
                //If more than one id, in ending if there is no semicolon will work
               
                if(String.ValueOf(con.EligibleTracks__c).contains(';')){
                    listEligibleTracksId = con.EligibleTracks__c.split(';');
                    //TODO:Remove
                    system.debug('listEligibleTracksId if block:'+listEligibleTracksId);
                    if(listEligibleTracksId.contains(salesAccountObj.Partner_Track__c)){
                        if(con.Status__c == 'Customer' || con.Status__c == 'Active' || con.Status__c == 'Prospect' || con.Status__c == 'Marketing Suspect' || con.Status__c == 'INTERNAL - Crisis Mgmt')
                        {
                            listSalesMotionActiveContacts.add(con);
                        }
                        else{
                            listSalesMotionInactiveContacts.add(con);
                        }
                    }
                }
                //If one value with out semicolon
                else{
                    listEligibleTracksId.add(con.EligibleTracks__c);
                    system.debug('listEligibleTracksId else block:'+listEligibleTracksId);
                    if(listEligibleTracksId.contains(salesAccountObj.Partner_Track__c)){
                        if(con.Status__c == 'Customer' || con.Status__c == 'Active' || con.Status__c == 'Prospect' || con.Status__c == 'Marketing Suspect' || con.Status__c == 'INTERNAL - Crisis Mgmt')
                        {
                            listSalesMotionActiveContacts.add(con);
                        }
                        else{
                            listSalesMotionInactiveContacts.add(con);
                        }
                    }
                }      
            }
        }
        system.debug('salesmotioncontacts:'+listSalesMotionActiveContacts);
        intActTotalRecs = listSalesMotionActiveContacts.size();
        intInActTotalRecs = listSalesMotionInactiveContacts.size();
    }
    
    //This method is used to get all Inactive contacts based on flag bGoToListActive
  /*  public List<Contact> getSalesMotionActiveContacts(){
        System.debug('bGoToListActive'+bGoToListActive);
        if(bGoToListActive == true){
            getContacts();
            return listSalesMotionActiveContacts;
        }
        else{
            System.debug('listSalesMotionActiveContacts'+listSalesMotionActiveContacts);
            getContacts();
            List<Id> listConIds = new List<Id>();
            for(Contact con: listSalesMotionActiveContacts){
                listConIds.add(con.id);
            }
            system.debug('offsetSize in method!!!:'+intOffsetActiveSize);
            return [SELECT id,AccountId, EligibleTracks__c, Name, Enable_as_Partner_Group_Administrator__c, Partner_User_Partner_Admin__c, Decision_Making_Role__c, NPS_Qualified_Status__c, 
                    Primary_Contact_for_Service_Type__c, Partner_User_Active__c, Email, Status__c, Phone,
                    Partner_User_Deal_Registration__c FROM Contact WHERE Id IN :listConIds LIMIT :intLimitSize OFFSET :intOffsetActiveSize];
           
        }
    }*/
    
    //This method is used to get all Inactive contacts based on flag bGoToListInActive
    public List<Contact> getSalesMotionInactiveContacts(){
        if(bGoToListInActive == true){
            return listSalesMotionInactiveContacts;
        }
        else{
            List<Id> listConIds = new List<Id>();
            for(Contact con: listSalesMotionInactiveContacts){
                listConIds.add(con.id);
            }
            system.debug('offsetSize in method!!!:'+intOffsetInactiveSize);
            return [SELECT AccountId, EligibleTracks__c, Name, Enable_as_Partner_Group_Administrator__c, Partner_User_Partner_Admin__c, Decision_Making_Role__c, NPS_Qualified_Status__c, 
                    Primary_Contact_for_Service_Type__c, Partner_User_Active__c, Email, Status__c, Phone,
                    Partner_User_Deal_Registration__c FROM Contact WHERE Id IN :listConIds ];
        }
    }
   
    //This methos is used to get next Active contacts
  /*  public pageReference getNextActiveContacts(){
        system.debug('offsetSize in method!!!:'+intOffsetActiveSize);
        intOffsetActiveSize = intOffsetActiveSize + intLimitSize;
        getSalesMotionActiveContacts(); 
        return null; 
    }   
    
    //This methos is used to get previous Active contacts
    public pageReference getPreviousActiveContacts(){
        intOffsetActiveSize = intOffsetActiveSize - math.mod(intLimitSize,intActTotalRecs);
        getSalesMotionActiveContacts(); 
        return null;
    }
    
    //This method is used to enable/disable previous link for Active contacts
    public boolean getprev(){
        if(intOffsetActiveSize == 0){
            return false;
        }
        else{
            return true;
        }
    }    
    
    //This method is used to enable/disable next link for Active contacts
    public boolean getnxt(){
       if((intOffsetActiveSize + intLimitSize) >= intActTotalRecs){
          return false;
       }
       else{
           return true;
       }
    }
    
    //This methos is used to get previous Inactive contacts
    public pageReference getPreviousInactiveContacts(){
        intOffsetInactiveSize = intOffsetInactiveSize - math.mod(intLimitSize,intInActTotalRecs);
        getSalesMotionInactiveContacts(); 
        return null;
    }
    
    //This methos is used to get next Inactive contacts
    public pageReference getNextInActiveContacts(){
        intOffsetInactiveSize = intOffsetInactiveSize + intLimitSize;
        getSalesMotionInactiveContacts(); 
        return null; 
        
    }  
    
    //This method is used to enable/disable previous link for Inactive contacts
    public boolean getInactPrev(){
        if(intOffsetInactiveSize == 0){
            return false;}
        else{
            return true;}
    }    
    
    //This method is used to enable/disable next link for Inactive contacts
    public boolean getInactNxt(){
        
        if((intOffsetInactiveSize + intLimitSize) >= intInActTotalRecs){
            return false;}
        else{
            return true;}
    }
    
    //This method is used to display all Active contacts, this will execute when click on Go to List link
    public pageReference goToActiveList(){
        bGoToListActive = true;
        getSalesMotionActiveContacts();
        bLinkActiveEnableDisable = false;
        return null ;
    }
    
    //This method is used to display all Inactive contacts, this will execute when click on Go to List link
    public pageReference goToInActiveList(){
        bGoToListInActive = true;
        getSalesMotionInactiveContacts();
        bLinkInactiveEnableDisable = false;
        return null ;
    }
    */
    //This method is used to redirect to contact edit page as standard edit
    public pageReference editContact(){
        //String strReturnURL = EncodingUtil.urlEncode('','UTF-8');
        String strSaveUrl = EncodingUtil.urlEncode('&nooverride=1&saveURL=/apex/AVSContactSuggestion?id=','UTF-8');
        pageReference pr = new PageReference('/'+strConId+'/e?retURL='+strConId+strSaveUrl+strConId);
        return pr;
    }
}