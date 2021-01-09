public class PartnerOnboardingUpdateAccount {

     public static void updateUDAValuesOnAccount(List<AccountChangeEvent> listNewAccounts){
         List<AccountChangeEvent> listOfChanges = listNewAccounts;
    
    Set<String> setOfAccountIds = new Set<String>();
    map<id,account> mapOfAccMap = new map<id,account>();
    List<Account> listOfAcctList = new List<Account>(); 
    try{
        for(AccountChangeEvent accountChange : listOfChanges){
            if (accountChange.ChangeEventHeader.getChangetype()  == 'UPDATE' ) {
                EventBus.ChangeEventHeader header = accountChange.ChangeEventHeader;
                List<String> listOfRecordId = accountChange.ChangeEventHeader.getRecordIds();
                system.debug('listOfRecordId******'+listOfRecordId);
                Map<String,Object> mapOfEventChanges = (Map<String,Object>)JSON.deserializeUntyped(JSON.serialize(accountChange));
                system.debug('mapOfEventChanges*****'+mapOfEventChanges);
                if(mapOfEventChanges.keySet().contains('Partner_Track__c') ){
                    System.debug('The Partner_Track__c updated during update operation:');
                    setOfAccountIds.addAll(listOfRecordId);
                }
                else if(header.nulledFields.size() > 0) {
                    for (String strOfField : header.nulledFields) {
                      System.debug(strOfField);
                      if(strOfField.contains('Partner_Track__c') ){
                        System.debug('22 The Partner_Track__c updated during update operation:');
                        setOfAccountIds.addAll(listOfRecordId);
                      }
                     
                    }
              } 
                
            }
        }
        System.debug('setOfAccountIds****'+setOfAccountIds.size());
        if(setOfAccountIds.size() > 0){
            List<Account> listOfSalesMotionAccountList=[select id,Distribution_Sell_To_Countries__c,Partner_Track__r.DELLEMC_Ts_and_Cs_agreed_date__c,Partner_Track__r.DELLEMC_Ts_and_Cs_agreement__c,Purchasing_Model__c,Partner_Relationship__c,Partner_Track__c,
                                                  Partner_Tier__c,New_Partner_Programme_T_C_s_agreed_on__c,New_Partner_Programme_T_C_s__c,Partner_Type__c,Partner_Track__r.Authorized_Countries__c,Partner_Track__r.Purchase_Path__c,
                                                  Partner_Track__r.Track_PPT__c,Partner_Track__r.Partner_Program_Tier__c,Partner_Track__r.Speciality_Product_Purchase_Path__c
                                                  from Account 
                                                  where Id IN: setOfAccountIds];
            System.debug('listOfSalesMotionAccountList'+listOfSalesMotionAccountList.size());
            for(Account salesmotionAcc:listOfSalesMotionAccountList){
                System.debug('salesmotionAcc'+salesmotionAcc);
                if(salesmotionAcc.Partner_Track__c != null ){
                    salesmotionAcc.Distribution_Sell_To_Countries__c =salesmotionAcc.Partner_Track__r.Authorized_Countries__c;
                    salesmotionAcc.Partner_Tier__c = salesmotionAcc.Partner_Track__r.Purchase_Path__c;
                    salesmotionAcc.Partner_Type__c = salesmotionAcc.Partner_Track__r.Track_PPT__c;
                    salesmotionAcc.Partner_Relationship__c = salesmotionAcc.Partner_Track__r.Partner_Program_Tier__c;
                    salesmotionAcc.Purchasing_Model__c =salesmotionAcc.Partner_Track__r.Speciality_Product_Purchase_Path__c;
                    salesmotionAcc.New_Partner_Programme_T_C_s_agreed_on__c = salesmotionAcc.Partner_Track__r.DELLEMC_Ts_and_Cs_agreed_date__c;
                    salesmotionAcc.New_Partner_Programme_T_C_s__c = salesmotionAcc.Partner_Track__r.DELLEMC_Ts_and_Cs_agreement__c;
                }
                else {
                    salesmotionAcc.Distribution_Sell_To_Countries__c = null;
                    salesmotionAcc.Partner_Tier__c = null;
                    salesmotionAcc.Partner_Type__c = null;
                    salesmotionAcc.Partner_Relationship__c = null;
                    salesmotionAcc.Purchasing_Model__c =null;
                    salesmotionAcc.New_Partner_Programme_T_C_s_agreed_on__c = null;
                    salesmotionAcc.New_Partner_Programme_T_C_s__c = false;
                }
                System.debug('salesmotionAcc'+salesmotionAcc);
                listOfAcctList.add(salesmotionAcc);
            }
            
            if(listOfAcctList.size() > 0){
                mapOfAccMap.putall(listOfAcctList);
                Database.SaveResult[] listsrAccList = Database.update(mapOfAccMap.values(),false);
                WebServiceExceptionHandling.exceptionHandlingMethod(listsrAccList,'Account','UpdateUDAonAccount','Exception',null,mapOfAccMap.values());
            }
            
        }
    }catch(Exception e){
        system.debug('Exception occured in Update UDA Values on Account'+e.getMessage());
    }
    }
}