/*
 * Revision CR Number   Release No  Date            Modified By     Description
 * -------- ---------   ----------  -----------     ------------    -----------
 *  1.0     17789       FY20-0802   16-Jul-2019     Fenny           As part of trigger refactoring, this method copied from ServicesTriggerRelatedHelper
 *
 * NOTE: Strictly NO business logics inside this trigger.
 */
public class PartnerServiceUtilities {

    public static void updateEMCOperationDEllEMCKeyContacts(List<DellEMC_Key_Contacts__c> listnewDEMKC){
        
        
        List<DellEMC_Key_Contacts__c> listdelete = new List<DellEMC_Key_Contacts__c>();
         
        for(DellEMC_Key_Contacts__c dEKCRecord: listnewDEMKC){
            if(dEKCRecord.EMC_Operation__c == 'Deletion' && dEKCRecord.EMC_Integration_Status__c == 'Completed'){
                System.debug('On After Update Deletion Block');
                listdelete.add(new DellEMC_Key_Contacts__c(Id=dEKCRecord.Id));  
             }
            
        }
        if(listdelete.size() > 0){
           try{
                 delete listdelete ;
            }catch(Exception e){
                    System.debug('Exception'+e.getMessage());
            }
        }else{
                System.debug('Record cannot be deleted as its not synced to EMC yet');
            }
        
        }

}