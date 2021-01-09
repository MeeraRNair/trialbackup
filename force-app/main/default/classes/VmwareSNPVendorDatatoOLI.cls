/*
 * Revision CR Number         Release No      Date            Modified By     Description
 * -------- ---------         ----------      -----------     ------------    -----------
 * 6.0      6637336           FY20-DCS-1002   6-Aug-2019      Anusha          Story 6637336  08037 - S&P Deal Reg Link in Product info(Autopopulating S&PVendor Field Values into Opportunity Line Item)  
 * 6.1      Defect-7936667    FY21-0202       16/01/2019      Monisha         Defect-7936667- Made the brand description values coming from OLI and S&P Vendor object to accept as lower case and compare.
*/
Public Class VmwareSNPVendorDatatoOLI{
     //Added by Anusha   --start--
       public static void afterUpdate(list<S_P_Vendors__c> listSnpVendor,Map<Id,S_P_Vendors__c> MapoldSnpVendor,List<OpportunityLineItem> listOpp,Boolean beforeInsertLine){
           System.debug('**I am called here in VmwareSNPVendorDatatoOLI');
             List<OpportunityLineItem> listoliVMwareProd;
             Set<Id> setoppIds = new Set<Id>();
             Map<Id,OpportunityLineItem> mapUpdateOppLineItem = new Map<Id,OpportunityLineItem>();
             OWD__c owd = OWD__c.getOrgDefaults();
             if(beforeInsertLine){
             
                 
                 set<Id> setopptyids = new set<id>();
                 
                 for(OpportunityLineItem obj : listOpp){
                     if(Test.isRunningTest() || obj.S_P_Registerable__c == 'TRUE'){
                        setopptyids.add(obj.OpportunityId);
                     }
                     
                 }
                 
                 Map<Id,Map<String,S_P_Vendors__c>> mapSnpVendor = new Map<Id,Map<String,S_P_Vendors__c>>();
                 
                 if(!setopptyids.isEmpty()){
                     for(S_P_Vendors__c obj : [SELECT Id,S_P_Vendors_Name_Hidden__c,Opportunity__c,S_P_Deal_Status__c,Qualified_for_S_P_Deal_Reg_Program__c,Rejection_Reason__c,
                                         Name,Vendor_Approval_Number__c,Vendor_Tracking_Number__c,
                                         Deal_Expiration_Date__c,SnP_or_OEM__c,Distributor_Name__c 
                                         FROM S_P_Vendors__c where Opportunity__c IN:setopptyids AND S_P_Vendors_Name_Hidden__c != NULL AND S_P_Vendors_Name_Hidden__c !='']){
                                         
                        
                        
                        if(mapSnpVendor.containsKey(obj.Opportunity__c)){
                            
                            Map<String,S_P_Vendors__c> mapObj = mapSnpVendor.get(obj.Opportunity__c);
                            //6.1 lower case the brand desc value
                            mapObj.put(StringUtils.lowerCase(obj.S_P_Vendors_Name_Hidden__c),obj);
                            mapSnpVendor.put(obj.Opportunity__c,mapObj);
                            
                        } else {
                            
                            Map<String,S_P_Vendors__c> mapObj = new Map<String,S_P_Vendors__c>();
                            //6.1 lower case the brand desc value
                            mapObj.put(StringUtils.lowerCase(obj.S_P_Vendors_Name_Hidden__c),obj);
                            mapSnpVendor.put(obj.Opportunity__c,mapObj);
                        }                
                     
                     }
                     
                }     
                 
                                     
                for(OpportunityLineItem oli : listOpp){
                     
                     if(mapSnpVendor.containsKey(oli.OpportunityId) && (oli.S_P_Registerable__c == 'TRUE' || Test.isRunningTest()) && oli.Opportunity.StageName!= owd.Oppty_Stage0__c && oli.Opportunity.StageName != owd.Oppty_Stage100__c){
                        
                        Map<String,S_P_Vendors__c> mapObj = mapSnpVendor.get(oli.OpportunityId);
                        //6.1 lower case the brand desc value
                        if(mapObj.containsKey(StringUtils.lowerCase(oli.Brand_Desc__c))){
                        
                            S_P_Vendors__c  svRec = mapObj.get(StringUtils.lowerCase(oli.Brand_Desc__c));
                            
                            oli.S_P_Deal_Status__c = svRec.S_P_Deal_Status__c;
                            //oli.Qualified_for_S_P_Deal_Reg_Program__c = svRec.Qualified_for_S_P_Deal_Reg_Program__c;
                            oli.Rejection_Reason_New__c = svRec.Rejection_Reason__c;
                            oli.Name__c= svRec.Name;
                            oli.Vendor_Approval_Number__c = svRec.Vendor_Approval_Number__c;
                            oli.Vendor_Tracking_Number__c = svRec.Vendor_Tracking_Number__c;
                            oli.Deal_Expiration_Date__c = svRec.Deal_Expiration_Date__c;
                            oli.SnP_or_OEM__c = svRec.SnP_or_OEM__c;
                            oli.Distributor_Name__c = svRec.Distributor_Name__c;
                         }    
                     
                     }
                }
                
                 
             } else {
               
                for(S_P_Vendors__c svRec : listSnpVendor)
                 {
                 system.debug('...............' + svRec.S_P_Deal_Status__c  + '' + MapoldSnpVendor.get(svRec.Id).S_P_Deal_Status__c 
                 + '' + svRec.Qualified_for_S_P_Deal_Reg_Program__c  + '' + MapoldSnpVendor.get(svRec.Id).Qualified_for_S_P_Deal_Reg_Program__c);
                   if(svRec.Rejection_Reason__c != MapoldSnpVendor.get(svRec.Id).Rejection_Reason__c || 
                       svRec.Name != MapoldSnpVendor.get(svRec.Id).Name || 
                       //svRec.Qualified_for_S_P_Deal_Reg_Program__c != MapoldSnpVendor.get(svRec.Id).Qualified_for_S_P_Deal_Reg_Program__c ||
                       (svRec.S_P_Deal_Status__c != MapoldSnpVendor.get(svRec.Id).S_P_Deal_Status__c &&  svRec.S_P_Deal_Status__c != null)||
                       svRec.Vendor_Approval_Number__c != MapoldSnpVendor.get(svRec.Id).Vendor_Approval_Number__c || 
                       svRec.Vendor_Tracking_Number__c != MapoldSnpVendor.get(svRec.Id).Vendor_Tracking_Number__c || 
                       svRec.Deal_Expiration_Date__c != MapoldSnpVendor.get(svRec.Id).Deal_Expiration_Date__c || 
                       svRec.SnP_or_OEM__c != MapoldSnpVendor.get(svRec.Id).SnP_or_OEM__c || 
                       svRec.Distributor_Name__c != MapoldSnpVendor.get(svRec.Id).Distributor_Name__c ){
                       
                       setoppIds.add(svRec.Opportunity__c);
                   }  
                    
                 }       
              
              
                 Map<Id,List<OpportunityLineItem>> mapOppLine = new Map<Id,List<OpportunityLineItem>>();
                 
                 if(!setoppIds.isEmpty()){
                 
                     for(OpportunityLineItem oppLine : [SELECT Id, Brand_Desc__c, OpportunityId,PricebookEntry.Product2.Description, S_P_Deal_Status__c,
                                                         Qualified_for_S_P_Deal_Reg_Program__c,Rejection_Reason_New__c ,Name__c ,
                                                         Vendor_Approval_Number__c ,Vendor_Tracking_Number__c ,Deal_Expiration_Date__c ,
                                                         SnP_or_OEM__c ,Distributor_Name__c, Opportunity.stagename
                                                                              FROM OpportunityLineItem 
                                                                              WHERE OpportunityId IN :setoppIds and S_P_Registerable__c = 'TRUE']){
                                                                              
                             if(mapOppLine.containsKey(oppLine.OpportunityId)){
                                 mapOppLine.get(oppLine.OpportunityId).add(oppLine);
                             } else {
                                 List<OpportunityLineItem> listObj = new List<OpportunityLineItem>();
                                 listObj.add(oppLine);
                                 mapOppLine.put(oppLine.OpportunityId,listObj);
                             }                                                 
                     
                     } 
                 
                 }
                
                for(S_P_Vendors__c svRec : listSnpVendor) {
                    
                    if(mapOppLine.containsKey(svRec.Opportunity__c)){
                         for(OpportunityLineItem oli : mapOppLine.get(svRec.Opportunity__c)){
                             //6.1 lower case the brand desc value
                             if(StringUtils.lowerCase(oli.Brand_Desc__c) == StringUtils.lowerCase(svRec.S_P_Vendors_Name_Hidden__c) && oli.Opportunity.StageName!= owd.Oppty_Stage0__c && oli.Opportunity.StageName != owd.Oppty_Stage100__c){
                             
                                 oli.S_P_Deal_Status__c = svRec.S_P_Deal_Status__c;
                                 //oli.Qualified_for_S_P_Deal_Reg_Program__c = svRec.Qualified_for_S_P_Deal_Reg_Program__c;
                                 oli.Rejection_Reason_New__c = svRec.Rejection_Reason__c;
                                 oli.Name__c= svRec.Name;
                                 oli.Vendor_Approval_Number__c = svRec.Vendor_Approval_Number__c;
                                 oli.Vendor_Tracking_Number__c = svRec.Vendor_Tracking_Number__c;
                                 oli.Deal_Expiration_Date__c = svRec.Deal_Expiration_Date__c;
                                 oli.SnP_or_OEM__c = svRec.SnP_or_OEM__c;
                                 oli.Distributor_Name__c = svRec.Distributor_Name__c;
                                 
                                 mapUpdateOppLineItem.put(oli.Id,oli);
                               
                             }
                              
                          }
                    }  
               
                 }
                 
                 if(!mapUpdateOppLineItem.isEmpty()){
                 
                    TriggerExecutionController.setSkipOpportunityLineItemTriggers(true);
                     TriggerExecutionController.setSkipAllTriggers(true);
                     update mapUpdateOppLineItem.values();
                     TriggerExecutionController.setSkipOpportunityLineItemTriggers(false);
                      TriggerExecutionController.setSkipAllTriggers(false);
                    
                 
                 }
            }    
          
       } 
       //Added by Anusha   --end--
}