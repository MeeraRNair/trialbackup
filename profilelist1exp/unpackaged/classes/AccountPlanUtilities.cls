/*
 * Author   : Sazleen
 * Purpose  : Utility class to hold simple and reusable functionalities which are related to Account and SFDC_Acct_Plan__c object. 
 *        
 * Revision CR Number   Release No  Date            Modified By     Description
 * -------- ---------   ----------  -----------     ------------    -----------
 * 1.0      US# 7067965  1101       30-Sept-2019     Sazleen| Naga   Update all related Account Plan record when Focus Account on Account object updated to AGL or NON AGL
 * 
 *
 */
 
public class AccountPlanUtilities {

  public static integer intcurrentYear = system.today().year();  

  public static void updateNonAGLtoAGLAccountPlan(List<Account> listacc, map<Id, Account> mapOldAccnt){

       list <SFDC_Acct_Plan__c> listAP = new list<SFDC_Acct_Plan__c>();
       Set<id> setAcctId = new Set<id>();
       
      // if focus account field on account change from NON AGL to AGL, then assign account id into setAcctId
       for(Account a: listacc){
           system.debug('debug old value for focus account is '+mapOldAccnt.get(a.Id).Focus_Account__c);
           system.debug('debug new value for focus account is '+a.Focus_Account__c);
           if(mapOldAccnt.get(a.Id).Focus_Account__c != a.Focus_Account__c){               
               setAcctId.add(a.id);
           }
       }
       
       System.debug('Debug update Account list are : '+setAcctId);   
       
       //Update AGL field for all Account plan related to Account which have focus account change from/to AGL n Non AGL
       //e.g If focus account field on account is updated to Account Growth Lab in FY20, then AGL status for that particular FY will be updated to AGL 2020
       
      if(!setAcctId.isEmpty()) {
          
           for(SFDC_Acct_Plan__c ap: [Select Id, Plan_Starting_Fiscal_Year__c,Focus_Account__c, RecordType.Name, AGL_Status_FY19__c,AGL_Status_FY20__c,AGL_Status_FY21__c,AGL_Status_FY22__c,AGL_Status_FY23__c
                                           from SFDC_Acct_Plan__c WHERE Account__c in :setAcctId and RecordType.Name != 'Account Plan Lite']){
            
               system.debug('Debug focus account update to '+ap.Focus_Account__c);
                                               
               if(ap.Focus_Account__c == 'Account Growth Lab' || ap.Focus_Account__c == 'Partner Growth Lab')
               {
                   
                    if(intcurrentYear == 2019){
                    ap.AGL_Status_FY20__c = 'AGL 2020';   
                    } if(intcurrentYear == 2020){
                    ap.AGL_Status_FY21__c ='AGL 2021';   
                    } if(intcurrentYear == 2021){
                       ap.AGL_Status_FY22__c = 'AGL 2022';
                    } if(intcurrentYear == 2022){
                       ap.AGL_Status_FY23__c = 'AGL 2023';
                    }
               } // close if
               else{
                
                   if(intcurrentYear == 2019){
                    ap.AGL_Status_FY20__c = '';   
                    } if(intcurrentYear == 2020){
                    ap.AGL_Status_FY21__c ='';   
                    } if(intcurrentYear == 2021){
                       ap.AGL_Status_FY22__c = '';
                    } if(intcurrentYear == 2022){
                       ap.AGL_Status_FY23__c = '';
                    }             
               }
               
               listAP.add(ap);
               
             } // end for loop
      } // end if set not empty    
        
        if(!listAP.isEmpty()){
            List<String> listObjAPINames = new List<String>{'SFDC_Acct_Plan__c'};
                
            try{  
                SystemBehaviorBypasser.setSkipValidationRules(listObjAPINames);
                update listAP;
            	ResetSystemBehaviorBypasser.resetSkipValidationRules(listObjAPINames);
               }
             catch(Exception ex) {
               System.Debug('Error :' + ex.getMessage());
            }
        }

  }  
}// end class