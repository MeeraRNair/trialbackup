/*
This class contains the changes made on Account which will be synced to CMI and Profiling Services.
*/

public class PartnerProfilingAccountSynctoDp{


        //when ever A Partner Account is Updated this method will check the changes happened for following fields in Account Or Not
        
        
        public static Boolean checkforChanges(Account PassedOldAccount,Account PassedNewAccount){
        boolean changesAreThere = false;
        
        
        list<String> FieldsNeedtoBechecked = System.Label.FieldsNeedtoBechecked.split(',');
        
        
        for( String eachField:FieldsNeedtoBechecked){
        
            if(PassedOldAccount.get(eachField) !=PassedNewAccount.get(eachField)){
            
                changesAreThere = true;
            }
        }
        
          // if(System.Label.SyncForAnyChange == 'True' 
          // || PassedOldAccount.Name!= PassedNewAccount.Name
          // || PassedOldAccount.Partner_Type__c != PassedNewAccount.Partner_Type__c
          // || PassedOldAccount.Partner_Relationship__c != PassedNewAccount.Partner_Relationship__c
          // || PassedOldAccount.Partner_Tier__c != PassedNewAccount.Partner_Tier__c
          // || PassedOldAccount.Account_Country__c!= PassedNewAccount.Account_Country__c
          // || PassedOldAccount.Partner_Registration__r.Country__r.Code__c!= PassedNewAccount.Account_Country_Code__c
          // || PassedOldAccount.Account_ID__c != PassedNewAccount.Account_ID__c
          // || (PassedOldAccount.Type=='End User'&& PassedNewAccount.Type=='Partner')
        // )
        
        if(changesAreThere){
             System.debug('PartnerProfilingAccountSynctoDp  sending : True');
        return  True;
        }else {
             System.debug('PartnerProfilingAccountSynctoDp  sending : False');
        return False;
        }
        }

}