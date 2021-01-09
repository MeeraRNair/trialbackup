/*
 * Author   : Sazleen
 * Purpose  : Utility class to hold simple and reusable functionalities which are related to SFDC_Acct_Plan__c object. 
 *        
 * Revision CR Number   Release No  Date            Modified By     Description
 * -------- ---------   ----------  -----------     ------------    -----------
 * 1.0      US# 7067965  1101       30-Sept-2019     Sazleen| Naga   Update all related Account Plan record when Focus Account on Account object updated to AGL or NON AGL
 * 
 *
 */
 
public class AccountPlanFieldPopulator {

    //afterinsert
    public static void updateAGLStatusforAP(List<SFDC_Acct_Plan__c> listacc, map<id,SFDC_Acct_Plan__c> mapnewap){
    
    Set<Id> setAPInsertedIds = mapnewap.keySet();      
    Set <Id> setAccIds = new set<Id>();
    Set<String> setRT = new set<String>();
        
    for(SFDC_Acct_Plan__c s : [Select RecordType.Name, Account__c from SFDC_Acct_Plan__c where Id in :setAPInsertedIds]){
        setAccIds.add(s.Account__c); 
        setRT.add(s.RecordType.Name);  
    }
        
        
    system.debug('debug display setAccIds------>'+setAccIds);
    system.debug('debug display setRT------------>'+setRT);
        
    Set<String> setp = new set<String>();
    Set<String> setf = new set<String>();
    
    
    //when account plan is inserted, if Account is AGL, then update agl status for current FY     
        
        //first for loop for newly inserted AP
        List <SFDC_Acct_Plan__c> listap2 = new List <SFDC_Acct_Plan__c>();
        if(!setRT.contains('Account Plan Lite')){                      
       	 for(SFDC_Acct_Plan__c a:[select id, Focus_Account__c, Account__c,RecordType.Name, Plan_Starting_Fiscal_Year__c, AGL_Status_FY19__c,AGL_Status_FY20__c,AGL_Status_FY21__c,AGL_Status_FY22__c, AGL_Status_FY23__c 
                              from SFDC_Acct_Plan__c where Id in: setAPInsertedIds and RecordType.Name != 'Account Plan Lite']){
                                  
                                   
            if(a.Focus_Account__c == 'Account Growth Lab' || a.Focus_Account__c == 'Partner Growth Lab'){
                
                if(a.Plan_Starting_Fiscal_Year__c == 'FY19'){
                    a.AGL_Status_FY19__c = 'AGL 2019';
                }else if(a.Plan_Starting_Fiscal_Year__c == 'FY20'){
                    a.AGL_Status_FY20__c = 'AGL 2020';
                }else if(a.Plan_Starting_Fiscal_Year__c == 'FY21'){
                    a.AGL_Status_FY21__c = 'AGL 2021';
                }else if(a.Plan_Starting_Fiscal_Year__c == 'FY22'){
                    a.AGL_Status_FY22__c = 'AGL 2022';
                }else if(a.Plan_Starting_Fiscal_Year__c == 'FY23'){
                    a.AGL_Status_FY23__c = 'AGL 2023';
                }
                    
            } //end if AGL
        
           listap2.add(a); 
                                  
       } //end first for loop
 } // end if setRT 
        
        if(!listap2.IsEmpty()){
        
            List<String> listObjAPINames = new List<String>{'SFDC_Acct_Plan__c'};
                
            try{  
                SystemBehaviorBypasser.setSkipValidationRules(listObjAPINames);
                update listap2;
            	ResetSystemBehaviorBypasser.resetSkipValidationRules(listObjAPINames);
               }
             catch(Exception ex) {
               System.Debug('Error :' + ex.getMessage());
            }     
        
        system.debug('debug inserted new AP with current FY only. the previous FY will be updated in third for loop');
        }
          
        
        for(SFDC_Acct_Plan__c ap:[select id, Focus_Account__c, Account__c,Plan_Starting_Fiscal_Year__c, AGL_Status_FY19__c,AGL_Status_FY20__c,AGL_Status_FY21__c,AGL_Status_FY22__c, AGL_Status_FY23__c 
                              from SFDC_Acct_Plan__c where Account__c in :setAccIds and RecordType.Name != 'Account Plan Lite']){
        
        setp.add(ap.AGL_Status_FY19__c);
        setp.add(ap.AGL_Status_FY20__c);
        setp.add(ap.AGL_Status_FY21__c);
        setp.add(ap.AGL_Status_FY22__c);
        setp.add(ap.AGL_Status_FY23__c);                          
        system.debug('debug set p is====>'+setp);
                                  
        setf.add(ap.Plan_Starting_Fiscal_Year__c);
        system.debug('debug set f is====>'+setf);
                                  
                              } //end second for loop
        
        List <SFDC_Acct_Plan__c> listap = new List <SFDC_Acct_Plan__c>();
     
     if(!setRT.contains('Account Plan Lite')){
         
        for(SFDC_Acct_Plan__c ap:[select id, Focus_Account__c, Account__c, RecordType.Name, Plan_Starting_Fiscal_Year__c, AGL_Status_FY19__c,AGL_Status_FY20__c,AGL_Status_FY21__c,AGL_Status_FY22__c, AGL_Status_FY23__c 
                              from SFDC_Acct_Plan__c where Account__c in: setAccIds and RecordType.Name != 'Account Plan Lite']){
   
        
        //check all existing AP and new inserted AP        
        if(ap.Focus_Account__c == 'Account Growth Lab' || ap.Focus_Account__c == 'Partner Growth Lab'){
                
            if(setp.contains('AGL 2019')){
                  ap.AGL_Status_FY19__c = 'AGL 2019';    
            }
            if(setp.contains('AGL 2020')){
                  ap.AGL_Status_FY20__c = 'AGL 2020';    
            }
            if(setp.contains('AGL 2021')){
                  ap.AGL_Status_FY21__c = 'AGL 2021';    
            }
            if(setp.contains('AGL 2022')){
                ap.AGL_Status_FY22__c = 'AGL 2022';
            }
            if(setp.contains('AGL 2023')){
                ap.AGL_Status_FY23__c = 'AGL 2023';
            }
            
        } //end if AGL
        else{
            if(setp.contains('AGL 2019')){
                ap.AGL_Status_FY19__c = 'AGL 2019';
            }
            if(setp.contains('AGL 2020')){
                ap.AGL_Status_FY20__c = 'AGL 2020';
            }
            if(setp.contains('AGL 2021')){
                ap.AGL_Status_FY21__c = 'AGL 2021';
            }
            if(setp.contains('AGL 2022')){
                ap.AGL_Status_FY22__c = 'AGL 2022';
            }
            if(setp.contains('AGL 2023')){
                ap.AGL_Status_FY23__c = 'AGL 2023';
            }
        } 

                                  
        listap.add(ap);                                                  
  } //end for
} //end if setRT
        
    if(!listap.isEmpty()){
        
        List<String> listObjAPINames = new List<String>{'SFDC_Acct_Plan__c'};
                
            try{  
                SystemBehaviorBypasser.setSkipValidationRules(listObjAPINames);
                update listap;
            	ResetSystemBehaviorBypasser.resetSkipValidationRules(listObjAPINames);
               }
             catch(Exception ex) {
               System.Debug('Error :' + ex.getMessage());
             }     
        system.debug('debug listap after update'+listap);       
    } // tutup if empty
        
        
    
}  //end method
    
    //afterdelete
    public static void refreshAGLStatusforAP(List<SFDC_Acct_Plan__c> listoldacc, map<id,SFDC_Acct_Plan__c> mapoldAP){
           
        Set <Id> setAccIds = new set<Id>(); 
        Set <String> setAP = new set <String>();

        for(SFDC_Acct_Plan__c s : listoldacc){
        setAccIds.add(s.Account__c);
           
    }
        
    system.debug('debug display setAccIds------>'+setAccIds);
        
        List <SFDC_Acct_Plan__c> listap2 = new List <SFDC_Acct_Plan__c>(); 
        for(SFDC_Acct_Plan__c a:listoldacc){
                                   
          if(a.RecordType.Name != 'Account Plan Lite') {  
            if(a.Plan_Starting_Fiscal_Year__c == 'FY19'){
                    setAP.add('AGL 2019');
                }else if(a.Plan_Starting_Fiscal_Year__c == 'FY20'){
                    setAP.add('AGL 2020');
                }else if(a.Plan_Starting_Fiscal_Year__c == 'FY21'){
                    setAP.add('AGL 2021');
                }else if(a.Plan_Starting_Fiscal_Year__c == 'FY22'){
                    setAP.add('AGL 2022');
                }else if(a.Plan_Starting_Fiscal_Year__c == 'FY23'){
                    setAP.add('AGL 2023');
                }
          } //end if accountplanlite      
            } //end for loop

        system.debug('Debug setAP--------------->>'+setAP);
        
        
    List <SFDC_Acct_Plan__c> listap = new List <SFDC_Acct_Plan__c>();
    
    if(!setAP.IsEmpty()){    
    	for(SFDC_Acct_Plan__c ap:[select id, Focus_Account__c, Account__c, RecordType.Name, Plan_Starting_Fiscal_Year__c, AGL_Status_FY19__c,AGL_Status_FY20__c,AGL_Status_FY21__c,AGL_Status_FY22__c, AGL_Status_FY23__c 
                              from SFDC_Acct_Plan__c where Account__c in :setAccIds and RecordType.Name != 'Account Plan Lite']){
   
                
            if(setAP.contains('AGL 2019')){
                  ap.AGL_Status_FY19__c = '';    
            }
            if(setAP.contains('AGL 2020')){
                  ap.AGL_Status_FY20__c = '';    
            }
            if(setAP.contains('AGL 2021')){
                  ap.AGL_Status_FY21__c = '';    
            }
            if(setAP.contains('AGL 2022')){
                ap.AGL_Status_FY22__c = '';
            }
            if(setAP.contains('AGL 2023')){
                ap.AGL_Status_FY23__c = '';
            }
                                              
        listap.add(ap); 
                                                                
  } //end for
    } // end setAP    
        system.debug('Debug listap for refresh------------->'+listap);

    if(!listap.isEmpty()){
        
        List<String> listObjAPINames = new List<String>{'SFDC_Acct_Plan__c'};
                
            try{  
                SystemBehaviorBypasser.setSkipValidationRules(listObjAPINames);
                update listap;
            	ResetSystemBehaviorBypasser.resetSkipValidationRules(listObjAPINames);
               }
             catch(Exception ex) {
               System.Debug('Error :' + ex.getMessage());
             }     
        system.debug('debug listap after update'+listap);       
    } // end if empty
         
} //end delete method    
        
} //end class