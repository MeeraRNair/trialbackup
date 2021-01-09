/*--------------------------------------------------
Description: Helper Class for 
    - navigating to new Account Handover record after some checking (CR #1356)

Version:0.0 
History:

Revision    Name      Date          Description
0.0         Krishna   05-Jan-2010   Creation CR #1356  (R11.1)

---------------------------------------------------*/
public with sharing class VFCntrlr_NewAccountHandOver {
    
    public Boolean Error {get;set;}
    
    public Account accountRecord {get;set;}
    public Boolean openHandOverRecExists {get;set;} 
    public List<Account_Handover__c> accountHandOverList {get;set;}
    
    public VFCntrlr_NewAccountHandOver(ApexPages.StandardController controller){        
        
        Error = false;
        openHandOverRecExists = false;
        
        accountRecord = (Account)controller.getRecord();             
        List<Account> accountRecordList = [SELECT NumberOfEmployees, Name, Id, Est_Buying_Power__c, Account_ID__c
                                            FROM Account
                                            WHERE Id =:accountRecord.Id LIMIT 1];
                                            
        System.debug ('## accountRecordList = '+ accountRecordList);  
        if (accountRecordList.isEmpty()){
            showError('Could not find a valid Account record');
            return;
        }
        
        accountRecord = accountRecordList[0];
        
        
        //checks for open AHO records. 
        checkForOpenHandOverRecords();
        System.debug ('## openHandOverRecExists = '+openHandOverRecExists);                         
        System.debug ('## End of constructor');
    }//end of controller
    
    
    //Method to add error to Page
    private void showError (String errorMessage){
        System.debug ('## Error! '+errorMessage);
        PageUtils.addError(errorMessage);       
        Error = True;   
    } 
    
    
    // Go to the new AHO page
    public void checkForOpenHandOverRecords() {        
        accountHandOverList = [SELECT Status__c, Outgoing_rep__c, Outgoing_Handover_Tasks_Completed__c, Account__c 
                               FROM Account_Handover__c
                               WHERE Account__c = :accountRecord.Id
                               AND (Status__c = 'Draft' 
                                    OR Status__c = 'Pending Assignment') 
                               LIMIT 1000];                                       
        
        System.debug ('## accountHandOverList = '+ accountHandOverList);
        if(accountHandOverList.size()> 0){
            openHandOverRecExists = true;
        } 
        System.debug ('## accountHandOverList.size = '+accountHandOverList.size());
                        
    } // end of checkForOpenHandOverRecords
    
    
    // Go to the new AHO page
    public PageReference navigateToNewAccountHandOver() {       
       
       System.debug ('## Inside Navigation method');
       
       //Production parameters for Account Handover object       
       String objectPrefixForAHO    = 'a0d';
       String fieldAcctName         = 'CF00NA0000001rn1v'; 
       String fieldAcctGUID         = 'CF00NA0000001rn1v_lkid'; 
       String fieldEstBuyingPower   = '00NA0000001rn2L'; 
       String fieldNumberOfEmp      = '00NA0000001rn2Q';    
       
       String newAHOUrl = '/'+ objectPrefixForAHO + '/e?nooverride=1&retURL=%2F'+accountRecord.Id
                             + '&' + fieldAcctGUID + '=' + accountRecord.Id 
                             + '&' + fieldAcctName + '=' + PageUtils.encodeVariable(accountRecord.Name)  
                             + '&' + fieldEstBuyingPower + '=' + ifNullReturnEmpty(''+accountRecord.Est_Buying_Power__c)
                             + '&' + fieldNumberOfEmp + '=' + ifNullReturnEmpty(''+accountRecord.NumberOfEmployees);
                             
      System.debug ('## newAHOUrl = '+newAHOUrl);
      PageReference newURL = new PageReference(newAHOUrl);      
      newURL.setRedirect(true);
      return newURL;         
    }  
    
    public PageReference navigate(){
        //if(!Error && !openHandOverRecExists){ //Commented for Defect# 133206
        if(!Error){
            //navigate to new AHO page
            return navigateToNewAccountHandOver();
        } 
        return null;        
    }
    
    public String ifNullReturnEmpty(String value){
        if(value == null || value == 'null'){
            return '';
        }
        return PageUtils.encodeVariable(value);
    }
    
    
} // end of class