/*****************************************************************************************************************************************
REVISION HISTORY
================
Version     Author          Date            Release#    CR#     Description
-------     ------          ----            --------    ---     -----------
1.0         Krishnamoorthi  19-Apr-2013     14.5        8200    Created for R14.5 Maintenance CR 8200 -- To Add Internal Contact in Case

********************************************************************************************************************************************/

public class VFCntrlr_AddInternalContact {

    private Case caseRecord;
    public String accountId  {get;set;}
    public String internalContactId  {get;set;}
    public String caseId  {get;set;}
    public List<AcctTM> existingATM {get; set;}
    public List<AcctTM> otherATMList{get; set;}
    public string ExistATM {get; set;}
    public Boolean reShowATM {get;set;}
    public Boolean reExistATM {get;set;}
    public Boolean reotherATMList {get;set;}
    
    
    public VFCntrlr_AddInternalContact(ApexPages.StandardController controller) {
        
        this.caseRecord = (Case)controller.getRecord();
        caseId = caseRecord.Id;
        System.debug('## caseId : '+ caseId);
        accountId = ApexPages.currentPage().getParameters().get('caseaccountId');
        System.debug('## accountId : '+ accountId);
        
        internalContactId = ApexPages.currentPage().getParameters().get('internalcontact');
        System.debug('## internalContactId : '+ internalContactId);
        
        reExistATM = true;
        reotherATMList = true;
        reShowATM = false;
        getAccountTeamMember();
    }
    
    public void getAccountTeamMember(){
            if(accountId != ''){
                existingATM = new List<AcctTM>();
                otherATMList = new List<AcctTM>();
                AcctTM acc = null;
                for(AccountTeamMember accTM : [select UserId, User.Name, User.Phone, User.Email, TeamMemberRole, Id, AccountId from AccountTeamMember where AccountId =: accountId]) {
                    reShowATM = true;
                    
                    //To show the existing Internal Contact
                    acc = new AcctTM(accTM);
                    if(internalContactId != '' && acc.ATM.UserId == internalContactId){
                        acc.selected = true;
                        existingATM.add(acc); 
                        ExistATM = acc.ATM.UserId;
                        reExistATM = false;
                    }
                    else {
                        otherATMList.add(acc);
                        reotherATMLIst = false ;
                    }
                }
            }
                    
        }
    
     public PageReference doSave(){
        
        string selectedATMId; 
        string selectedPhone; 
        string selectedEmail; 
        
        try {
            
            for (AcctTM  selectedATM : otherATMList){
                if(selectedATM.selected == true){
                    
                    selectedATMId = selectedATM.ATM.UserId;
                    selectedPhone = selectedATM.ATM.User.Phone;
                    selectedEmail = selectedATM.ATM.User.Email;
                    
                    break;
                    
                }
            }
            
            //Update the Case Record
            if(selectedATMId != null) {
                
                Case updCase = new Case(Id = caseId);
                updCase.Internal_Contact__c = selectedATMId;
                updCase.Internal_Contact_Phone__c = selectedPhone;
                updCase.Internal_Contact_Email__c = selectedEmail;
                
                update updCase;
            }
            else {
                if(existingATM.size() > 0){
                    if(!existingATM[0].selected){
                        ApexPages.Message msg;     
                        msg = new ApexPages.Message(ApexPages.severity.FATAL,'Please select an Internal Contact.');
                        ApexPages.addMessage(msg);            
                        return null; 
                    }
                }
            }
        }
        
        catch(Exception e){              
                   ApexPages.addMessages(e);
        }
        
       return new PageReference('/'+caseId);
       return null;
     }
    
    public class AcctTM {
        public AccountTeamMember ATM {get; set;}
        public Boolean selected {get; set;}
               
        public AcctTM (AccountTeamMember AccTM) {
                ATM = AccTM;
                selected = false;
        }
    }
    
    public PageReference doCancel(){

        return new PageReference('/'+caseId);
    }
}