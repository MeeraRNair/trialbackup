/*
 * Revision CR Number   Release No  Date            Modified By     Description
 * -------- ---------   ----------  -----------     ------------    -----------
 *  2.0     17789       FY20-0802   16-Jul-2019     Fenny           As part of trigger refactoring, moved updateEMCOperationDEllEMCKeyContacts method to PartnerServiceUtilities
 *
 */
public class ServicesTriggerRelatedHelper {
    //public static Boolean check = true;
    public static void updateEMCOperationServiceCompetencies(List<Service_Competencies__c> listnewSerComp){
        
        List<Service_Competencies__c> listdelete = new List<Service_Competencies__c>();
        for(Service_Competencies__c serCompRecord : listnewSerComp){
            if(serCompRecord.EMC_Operation__c == 'Deletion' && serCompRecord.EMC_Integration_Status__c == 'Completed'){
                System.debug('On After Update Deletion Block');
                listdelete .add(new Service_Competencies__c(Id=serCompRecord.Id));  
             }
            
        }
        if(listdelete .size() > 0){
           system.debug('listdelete.size'+listdelete.size());
           try{
                    delete listdelete ;
                }catch(Exception e){
                    System.debug('Exception'+e.getMessage());
                    
                }
        } 
        else{
                System.debug('Record cannot be deleted as its not synced to EMC yet');
            }
        
        
       
    }
    
    //Sneha
    
    public static void updateEMCOperationSPSO(List<Partner_Service_Enabled_Product__c > listnewSPSO){
        
        List<Partner_Service_Enabled_Product__c> listdelete = new List<Partner_Service_Enabled_Product__c>();
        for(Partner_Service_Enabled_Product__c  spsoRecord : listnewSPSO){
            if(spsoRecord.EMC_Operation__c == 'Deletion' && spsoRecord.EMC_Integration_Status__c == 'Completed'){
                System.debug('On After Update Deletion Block');
                listdelete.add(new Partner_Service_Enabled_Product__c(Id=spsoRecord.Id));  
             }
            
        }
        if(listdelete.size() > 0){
           System.debug('listdelete '+listdelete );
           try{
                  delete listdelete;
          }catch(Exception e){
                    System.debug('Exception'+e.getMessage());
                }
        }
        else{
                System.debug('Record cannot be deleted as its not synced to EMC yet');
            }
        
        
        
    }
    
    //Srikanth
    
       //PQR
       
       public static void updateEMCOperationPartnerQuotingRelationships(List<Partner_Quoting_Relationships__c> listnewPQR){
        
        
        List<Partner_Quoting_Relationships__c> listdelete = new List<Partner_Quoting_Relationships__c>();
         
        for(Partner_Quoting_Relationships__c pQRRecord : listnewPQR){
            if(pQRRecord.EMC_Operation__c == 'Deletion' && pQRRecord.EMC_Integration_Status__c == 'Completed'){
                System.debug('On After Update Deletion Block');
                listdelete.add(new Partner_Quoting_Relationships__c(Id=pQRRecord.Id));  
             }
            
        }
        if(listdelete.size() > 0){
           try{
                 delete listdelete;
            }catch(Exception e){
                    System.debug('Exception'+e.getMessage());
            }
        }else{
                System.debug('Record cannot be deleted as its not synced to EMC yet');
            }
        
        }
    
    //PTA

    public static void updateEMCOperationPartnerTypeAttributes(List<Partner_Type_Attribute__c> listnewPTA){
        
        
        List<Partner_Type_Attribute__c> listdelete = new List<Partner_Type_Attribute__c>();
         
        for(Partner_Type_Attribute__c pTARecord : listnewPTA){
            if(pTARecord.EMC_Operation__c == 'Deletion' && pTARecord.EMC_Integration_Status__c == 'Completed'){
                System.debug('On After Update Deletion Block');
                listdelete.add(new Partner_Type_Attribute__c(Id=pTARecord.Id));  
             }
            
        }
        if(listdelete.size() > 0){
           try{
                 delete listdelete;
            }catch(Exception e){
                    System.debug('Exception'+e.getMessage());
            }
        }else{
                System.debug('Record cannot be deleted as its not synced to EMC yet');
            }
        
        }
    
    //Pallavi
    public static void updateSCAfterInsert(List<Service_Competencies__c> listnewSCList){
        Map<String,List<Service_Competencies__c>> mapPTToSC = new Map<String,List<Service_Competencies__c>>();
        List<Partner_Track__c> listptList = new List<Partner_Track__c>();
        List<Partner_Track__c> listupdatePTList = new List<Partner_Track__c>();
        
        for(Service_Competencies__c sc : listnewSCList){
            // Check if its none
            if(String.isNotBlank(sc.Services_Competencies_Held__c)||String.isEmpty(sc.Services_Competencies_Held__c)){
                if(mapPTToSC.containsKey(sc.Partner_Track__c)){
                    mapPTToSC.get(sc.Partner_Track__c).add(sc);
                    
                }else{
                    mapPTToSC.put(sc.Partner_Track__c, new List<Service_Competencies__c>{sc}); 
                }
                
            } 
            System.debug('mapPTToSC::'+mapPTToSC);
        }
        
        if(mapPTToSC.size()>0){
          listptList =[Select id,Name,Services_Competencies__c,(select id,Name,Services_Competencies_Held__c from Service_Competencies__r) From Partner_Track__c Where Id IN :mapPTToSC.keySet()];
            for(Partner_Track__c objPT: listptList ){
               for(Service_Competencies__c sc :mapPTToSC.get(objPT.Id) ){
                if(String.isNotBlank(objPT.Services_Competencies__c) && objPT.Services_Competencies__c!='None'){
                    if(!objPT.Services_Competencies__c.contains(sc.Services_Competencies_Held__c)){
                    objPT.Services_Competencies__c =  objPT.Services_Competencies__c +';'+sc.Services_Competencies_Held__c;
                 }
                }    
                else{
                    // Append directly
                     objPT.Services_Competencies__c = sc.Services_Competencies_Held__c;
                }
               }
                listupdatePTList.add(objPT);
               system.debug('####updatedPTList'+listupdatePTList ); 
            }  
            if(listupdatePTList.size()>0){
                try{
                    update listupdatePTList ;
                }catch(exception e){}
            } 
    }
    }
    
   /* public static void UpdateSCAfterUpdate(List<Service_Competencies__c> listnewSCList,map<id,Service_Competencies__c> oldSCMap){
       List<Service_Competencies__c> listscList = new List<Service_Competencies__c>();      
        for(Service_Competencies__c sc: listnewSCList){
            if(sc.Services_Competencies_Held__c!= oldSCMap.get(sc.id).Services_Competencies_Held__c){
              listscList.add(sc);  
            }
        }
        if(listscList.size()>0){
           updateSCAfterInsert(listscList);
        }
       
    } */

/*public static void UpdateSCAfterUpdate(List<Service_Competencies__c> listnewSCList,map<id,Service_Competencies__c> oldSCMap){
       
    List<Service_Competencies__c> listscList= new List<Service_Competencies__c>(); 
    String oldSCHeld = '';
    String newSCHeld = '';
    String PtScOnSC = '';
    String PtScOnSCAfterReplace = '';
    String ptScAfterRemoveOldValue = '';
    Map<String,List<Service_Competencies__c>> mapPTToSC = new Map<String,List<Service_Competencies__c>>();
    List<Partner_Track__c> listptList  = new List<Partner_Track__c>();
    List<Partner_Track__c> listupdatePTList = new List<Partner_Track__c>();
        
        for(Service_Competencies__c sc: listnewSCList){
            if(sc.Services_Competencies_Held__c!= oldSCMap.get(sc.id).Services_Competencies_Held__c){
              oldSCHeld = oldSCMap.get(sc.id).Services_Competencies_Held__c;
              newSCHeld = sc.Services_Competencies_Held__c;
              System.debug('##oldSCHeld'+oldSCHeld);
              System.debug('##newSCHeld'+newSCHeld);
              //PtScOnSC = sc.Partner_Track__r.Services_Competencies__c;
              //System.debug('##PtScOnSC'+PtScOnSC);
            }
            if(mapPTToSC.containsKey(sc.Partner_Track__c)){
                    mapPTToSC.get(sc.Partner_Track__c).add(sc);
                    
            }else{
                    mapPTToSC.put(sc.Partner_Track__c, new List<Service_Competencies__c>{sc}); 
                 }
        }
        System.debug('##mapPTToSC::'+mapPTToSC);
        
        if(mapPTToSC.size()>0){
          listptList =[Select id,Name,Services_Competencies__c,(select id,Name,Services_Competencies_Held__c from Service_Competencies__r) From Partner_Track__c Where Id IN :mapPTToSC.keySet()];
          for(Partner_Track__c objPT: listptList ){
            for(Service_Competencies__c sc :mapPTToSC.get(objPT.Id) ){
            if(String.isNotBlank(objPT.Services_Competencies__c) && objPT.Services_Competencies__c!='None'){
              if(!objPT.Services_Competencies__c.contains(newSCHeld)){
                PtScOnSC = objPT.Services_Competencies__c;
                System.debug('##PtScOnSC'+PtScOnSC);
                if(PtScOnSC.contains(oldSCHeld)){
                  PtScOnSCAfterReplace =  PtScOnSC.replace(oldSCHeld,newSCHeld); 
                  System.debug('##PtScOnSCAfterReplace'+PtScOnSCAfterReplace);
                  objPT.Services_Competencies__c = PtScOnSCAfterReplace;
                  System.debug('##PtScOnSCAfterReplace(AfterUpdate)'+PtScOnSCAfterReplace); 
                }
              }else{
                PtScOnSC = objPT.Services_Competencies__c;
                ptScAfterRemoveOldValue = PtScOnSC.remove(oldSCHeld);
                System.debug('##ptScAfterRemoveOldValue'+ptScAfterRemoveOldValue);
                objPT.Services_Competencies__c = ptScAfterRemoveOldValue;
                System.debug('##ptScAfterRemoveOldValue(AfterUpdate)'+ptScAfterRemoveOldValue); 
              }
            }else{
                    // Append directly
                     objPT.Services_Competencies__c = sc.Services_Competencies_Held__c;
                } 
            }
            listupdatePTList.add(objPT);
               system.debug('####updatedPTList'+listupdatePTList ); 
          }
          if(listupdatePTList.size()>0){
                try{
                    update listupdatePTList;
                }catch(exception e){}
            }
        }
       
}   */

   /* public static void updateSCAfterDelete(List<Service_Competencies__c> listnewSCList){
    System.debug('UpdateSCAfterDelete'+listnewSCList);
    set<id> setdeletingSCId = new set<id>();
    List<Id> listptIdOfSC = new List<Id>();
    List<Partner_Track__c> listptsList = new List<Partner_Track__c>();
    List<Partner_Track__c> listupdatePTList = new List<Partner_Track__c>();
    List<Service_Competencies__c> listscList = new List<Service_Competencies__c>();
    List<id> listScPTIdToUpdate = new List<id>();
   // set<String> SCHeldOnSC = new set<String>();
    string SCHeldOnSC ='';
    String SCOnPT = '';
    String SCHeldToRemove = '';
    
    for(Service_Competencies__c sc : listnewSCList){
        listptIdOfSC.add(sc.Partner_Track__c);
        SCHeldOnSC = sc.Services_Competencies_Held__c;
        setdeletingSCId.add(sc.id);
    }
     // SCHeldOnSC.add(scheld);  
    system.debug('##SCHeldonSC'+SCHeldonSC);
    system.debug('##deletingSCId'+setdeletingSCId);
    system.debug('ptIdofSC'+listptIdOfSC);
    
    listscList = [select id,Name,Services_Competencies_Held__c,Partner_Track__c,Partner_Track__r.Services_Competencies__c from Service_Competencies__c where Partner_Track__c=:listptIdOfSC AND Services_Competencies_Held__c=:SCHeldonSC];
     system.debug('**scList'+listscList );
        if(listscList .size()>0){
          for(Service_Competencies__c scObj: listscList ){
            system.debug('##scObjSCHeld'+scObj.Services_Competencies_Held__c);
               if(!scObj.Services_Competencies_Held__c.contains(SCHeldonSC)){
                SCOnPT = scObj.Partner_Track__r.Services_Competencies__c;
                system.debug('##SCOnPT'+SCOnPT);
                if(SCOnPT.contains(SCHeldonSC)){
                    SCHeldToRemove = SCOnPT.remove(SCHeldonSC);
                    system.debug('##SCHeldToRemove'+SCHeldToRemove);
                }
               }
            listScPTIdToUpdate.add(scObj.Partner_Track__c);
            Partner_Track__c pt = [select id,Name,Services_Competencies__c from Partner_Track__c where id In: listScPTIdToUpdate ];
            pt.Services_Competencies__c = SCHeldToRemove;
            listupdatePTList.add(pt);
            if(listupdatePTList.size()>0){
                try{
                update listupdatePTList;
                }catch(exception e){}
               system.debug('##UpdatedValues'+listupdatePTList);
            } 
          }
        }
        /*else{
            Partner_Track__c pt = [select id,Name,Services_Competencies__c from Partner_Track__c where id In:listptIdOfSC];
            pt.Services_Competencies__c = '';
            listupdatePTList.add(pt);
            if(listupdatePTList.size()>0){
                try{
                update listupdatePTList;
                }catch(exception e){}
               system.debug('##UpdatedValues'+listupdatePTList);
            } 
        }*/
          
      //  }
      

        
        public static void updateSCAfterDelete(List<Service_Competencies__c> listnewSCList){
    System.debug('UpdateSCAfterDelete'+listnewSCList);
    set<id> setdeletingSCId = new set<id>();
    List<Id> listptIdOfSC = new List<Id>();
    List<Partner_Track__c> listptsList = new List<Partner_Track__c>();
    List<Partner_Track__c> listupdatePTList = new List<Partner_Track__c>();
    List<Service_Competencies__c> listscList = new List<Service_Competencies__c>();
    List<Service_Competencies__c> listafterdeletescList = new List<Service_Competencies__c>();
    List<id> listScPTIdToUpdate = new List<id>();
    set<String> setofScheldvalue = new set<String>();
    String strSCHeldOnSC = '';
    String strSCOnPT = '';
    String strSCHeldToRemove = '';
    
    for(Service_Competencies__c sc : listnewSCList){
        listptIdOfSC.add(sc.Partner_Track__c);
        strSCHeldOnSC = sc.Services_Competencies_Held__c;
        setdeletingSCId.add(sc.id);
    }
    
    listscList = [select id,Name,Services_Competencies_Held__c,Partner_Track__c from Service_Competencies__c where Partner_Track__c=:listptIdOfSC];
     system.debug('**scList'+listscList );
        if(listscList .size() > 0){
          for(Service_Competencies__c scObj: listscList ){
            system.debug('##scObjSCHeld'+scObj.Services_Competencies_Held__c);
               setofScheldvalue.add(scObj.Services_Competencies_Held__c);
           }
        }
        system.debug('**setofScheldvalue'+setofScheldvalue);
        
        Partner_Track__c pt = [select id,Name,Services_Competencies__c from Partner_Track__c where id In:listptIdOfSC ];
            pt.Services_Competencies__c = String.join(new List<String>(setofScheldvalue), ';');

            listupdatePTList.add(pt);
            if(listupdatePTList.size()>0){
                try{
                update listupdatePTList;
                }catch(exception e){}
               system.debug('##UpdatedValues'+listupdatePTList);
            } 
}

//After Update

public static void updateSCAfterUpdate(List<Service_Competencies__c> listnewSCList){
    System.debug('UpdateSCAfterDelete'+listnewSCList);
    set<id> setdeletingSCId = new set<id>();
    List<Id> listptIdOfSC= new List<Id>();
    List<Partner_Track__c> listptsList = new List<Partner_Track__c>();
    List<Partner_Track__c> listupdatePTList= new List<Partner_Track__c>();
    List<Service_Competencies__c> listscList = new List<Service_Competencies__c>();
    List<Service_Competencies__c> listafterdeletescList = new List<Service_Competencies__c>();
    List<id> listScPTIdToUpdate = new List<id>();
    set<String> setofScheldvalue = new set<String>();
    String strSCHeldOnSC = '';
    String strSCOnPT = '';
    String strSCHeldToRemove = '';
    
    for(Service_Competencies__c sc : listnewSCList){
        listptIdOfSC.add(sc.Partner_Track__c);
        strSCHeldOnSC = sc.Services_Competencies_Held__c;
        setdeletingSCId.add(sc.id);
    }
   
    listscList = [select id,Name,Services_Competencies_Held__c,Partner_Track__c from Service_Competencies__c where Partner_Track__c=:listptIdOfSC];
     system.debug('**scList'+listscList );
        if(listscList.size() > 0){
          for(Service_Competencies__c scObj: listscList ){
            system.debug('##scObjSCHeld'+scObj.Services_Competencies_Held__c);
               setofScheldvalue.add(scObj.Services_Competencies_Held__c);
           }
        }
        system.debug('**setofScheldvalue'+setofScheldvalue);
        
       Partner_Track__c pt = [select id,Name,Services_Competencies__c from Partner_Track__c where id In:listptIdOfSC];
            pt.Services_Competencies__c = String.join(new List<String>(setofScheldvalue), ';');

            listupdatePTList.add(pt);
            if(listupdatePTList.size()>0){
                try{
                update listupdatePTList;
                }catch(exception e){}
               system.debug('##UpdatedValues'+listupdatePTList );
            } 
}
 }