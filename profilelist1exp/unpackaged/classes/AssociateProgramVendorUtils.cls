/***********************************************************
* Name          : AssociateProgramVendorUtils
* Description   :  BR 8.1.1.3 & 8.3.1.14
* ---------------------------------------------------------
* Revision  Name     Date        Description
* 1.0       Hanan    12.0.201    Utility class to do 1)Convert the budgeted price of APV from USD to the currency 
*                                selected in marketing plan 2)Assign the email-Id of the comarketing manager
*                                to the Associated program vendor record 
* 
************************************************************/

Public class AssociateProgramVendorUtils{
    Public static void convertBudgetedPrice(Map<Id,List<Associated_Programs_Vendors__c>> IdAPVMap,Map<Id,Marketing_Plan__c> MPlanMap,Set<String> currencyCodeSet){
        
        
        //try{  
            for(Id idElt:MPlanMap.KeySet()){
                Marketing_Plan__c mplanVar=MPlanMap.get(idElt);           
                
                    //List<Associated_Programs_Vendors__c> apvList=IdAPVMap.get(idElt); 
                    List<Associated_Programs_Vendors__c> apvList = new List<Associated_Programs_Vendors__c>();
                    if(IdAPVMap.get(idElt)!= null){
                      apvList.addAll(IdAPVMap.get(idElt));
                    } 
                    if(apvList.size()>0){
                            for(Associated_Programs_Vendors__c apv:apvList){
                                if(mplanVar.Currency_Code__c!=null && apv.marketing_plan__c==idElt && mplanVar.Conversion_Rate__c!=null){
                                    apv.Converted_Budget_Price__c= apv.Budgeted_Price__c* mplanVar.Conversion_Rate__c;
                                }
                                apv.MP_Co_Marketing_Manager_Email__c=mplanVar.Co_Marketing_manager_Email__c;                                   
                            }
                    }                    
            }  
        /*}Catch(Exception e){
            System.debug('### Exception in AssociateProgramVendorUtils'+e);
        }*/
          
    }
    
    public static void alertComarMgr(Map<Id,List<Associated_Programs_Vendors__c>> IdAPVMap,Set<Id> vendorIdset, List<Associated_Programs_Vendors__c> assVendors){        
      //try     
          
          List<Viper_Email_Subscription__c> viperEmailSubscriptionList = new List<Viper_Email_Subscription__c>();
          viperEmailSubscriptionList = [Select Id, User__c, Send_APV_Notification__c from Viper_Email_Subscription__c where Send_APV_Notification__c = true AND User__r.IsActive = true];

          set<Id> viperSubscrptionUsers = new set<Id>();
          for(Viper_Email_Subscription__c viper: viperEmailSubscriptionList){
            viperSubscrptionUsers.add(viper.User__c);
          }
                              
          //List<MDF_Program__c> mdfprgm1=[select Pop_Owner__c,Pop_Owner__r.email from MDF_Program__c where Pop_Owner__c in: viperSubscrptionUsers limit 1];
                    
          System.debug('***viperSubscrptionUsers: '+viperSubscrptionUsers);
         
         
      // Viper APV SAR-13425: Defect from US # 191861
      // logic implemented to fix the SAR - 13425   
          List<MDF_Associated_Contact__c> mdfACntct=[select Vendor__c,MDF_Contact__r.Name,MDF_Contact__c,MDF_Contact__r.Id,MDF_Contact__r.Region__c,MDF_Contact__r.Sub_Region__c,
                                                  MDF_Contact__r.Country__c,MDF_Contact__r.Business_Segment__c,MDF_Contact__r.Notify_When_APV_Created__c,
                                                  MDF_Contact__r.Email__c, MDF_Contact__r.Primary_Secondary__c from MDF_Associated_Contact__c
                                                  where Vendor__c in:vendorIdset and MDF_Contact__r.recordType.name='Co-Marketing Contact' and MDF_Contact__r.Status__c='Active' and MDF_Contact__r.User__c IN: viperSubscrptionUsers
                                                  order by CreatedDate ASC]; 
                                                  // and MDF_Contact__r.Notify_When_APV_Created__c = true
                                                             
           //for(MDF_Associated_Contact__c mdfAC : mdfACntct){
       
     /*      if(mdfACntct != null && mdfACntct.size() >0 ){
               for(Integer i=0; i<mdfACntct.size(); i++){
                    List<Associated_Programs_Vendors__c> apvList=IdAPVMap.get(mdfACntct[i].Vendor__c);
                    if(apvList != null){
                        System.debug('****APVList is not null: ');
                        for(Associated_Programs_Vendors__c apvElt:apvList){ 

                          apvElt.Co_Marketing_Manager_Email__c = NULL;
                          apvElt.Co_Marketing_Manager_Email2__c = NULL;

                          for(Integer j=0; j< mdfACntct.size(); j++ ){
                            If(j == 0){
                              apvElt.Co_Marketing_Manager_Email__c=mdfACntct[0].MDF_Contact__r.Email__c;
                            }else If(j == 1){
                              apvElt.Co_Marketing_Manager_Email2__c=mdfACntct[1].MDF_Contact__r.Email__c;
                            }
                          }      
                        }
                        
                    }
                }
           }else{
               for(Associated_Programs_Vendors__c apv : assVendors){
                   apv.Co_Marketing_Manager_Email__c = NULL;
                   apv.Co_Marketing_Manager_Email2__c = NULL;
               }
           }
                        
     
     
 */    
 
 if(mdfACntct == null || mdfACntct.size() == 0 ){
 for(Associated_Programs_Vendors__c apv : assVendors){
 
 system.debug('mdfACntct.size()=========='+mdfACntct.size() );
                   apv.Co_Marketing_Manager_Email__c = NULL;
                   apv.Co_Marketing_Manager_Email2__c = NULL;
               }
 
 } 
 
  Map<Id, List<MDF_Associated_Contact__c>>  mdfConMap1 = new Map<Id,List<MDF_Associated_Contact__c>>();
  for(MDF_Associated_Contact__c mac : mdfACntct){
      List<MDF_Associated_Contact__c> tmpList = new List<MDF_Associated_Contact__c>();
      if(mdfConMap1.containsKey(mac.Vendor__c)){
          tmpList = mdfConMap1.get(mac.Vendor__c);
          system.debug('tmpList.size()=========='+tmpList.size() );
      }else{
         system.debug('tmpList.size()=========='+tmpList.size() );
      }
      tmpList.add(mac);
      system.debug('tmpList.size()=========='+tmpList.size() );
      system.debug('mdfACntct.size()=========='+mdfACntct.size() );
      mdfConMap1.put(mac.Vendor__c,tmpList);
      
  }
  
  for(Associated_Programs_Vendors__c apvElt : assVendors){
      if(mdfConMap1.containsKey(apvElt.Vendor__c)){
          List<MDF_Associated_Contact__c> apvList = mdfConMap1.get(apvElt.Vendor__c);
          
          if(apvList<>null){
             system.debug('apvList=========='+apvList );
               apvElt.Co_Marketing_Manager_Email__c = NULL;
               apvElt.Co_Marketing_Manager_Email2__c = NULL;   
               
                  
            for(Integer j=0; j< apvList.size(); j++ ){
            system.debug('apvList List=========='+apvList );
                If(j == 0){
                  apvElt.Co_Marketing_Manager_Email__c=apvList[0].MDF_Contact__r.Email__c;
                }else If(j == 1){
                  apvElt.Co_Marketing_Manager_Email2__c=apvList[1].MDF_Contact__r.Email__c;
                }
            }    
        }
       else{
           for(Associated_Programs_Vendors__c apv : assVendors){
           system.debug('apvList null=========='+apv );
                   apv.Co_Marketing_Manager_Email__c = NULL;
                   apv.Co_Marketing_Manager_Email2__c = NULL;
            } 
        } 
        
     
      }
   /*   else{
           for(Associated_Programs_Vendors__c apv : assVendors){
          
                   apv.Co_Marketing_Manager_Email__c = NULL;
                   apv.Co_Marketing_Manager_Email2__c = NULL;
            } 
        }  */

  }
     
     
     
     
                        
       // Viper APV SAR-13425: Defect from US # 191861
      // logic implemented to fix the SAR - 13425  
       
    List<MDF_Associated_Contact__c> mdfACntct1=[select Vendor__c,MDF_Contact__r.Name,MDF_Contact__c,MDF_Contact__r.Id,MDF_Contact__r.Region__c,MDF_Contact__r.Sub_Region__c,
                                                  MDF_Contact__r.Country__c,MDF_Contact__r.Business_Segment__c,MDF_Contact__r.Notify_When_APV_Created__c,
                                                  MDF_Contact__r.Email__c, MDF_Contact__r.Primary_Secondary__c from MDF_Associated_Contact__c
                                                  where Vendor__c in:vendorIdset and MDF_Contact__r.recordType.name='Product Manager Contact' and MDF_Contact__r.Status__c='Active' and MDF_Contact__r.User__c IN: viperSubscrptionUsers
                                                  order by CreatedDate ASC]; 
                                                  
          if(mdfACntct1 == null || mdfACntct1.size() == 0 ){
 for(Associated_Programs_Vendors__c apv : assVendors){
 
 system.debug('mdfACntct1.size()=========='+mdfACntct1.size() );
                apv.Product_Manager_Email__c=NULL;
                apv.Product_Manager_Email2__c =NULL;
                apv.Product_Manager_Email3__c=NULL;
                apv.Product_Manager_Email4__c=NULL;
                apv.Product_Manager_Email5__c=NULL;
                apv.Product_Manager_Email6__c=NULL;
                apv.Product_Manager_Email7__c=NULL;
                apv.Product_Manager_Email8__c=NULL;
                apv.Product_Manager_Email9__c=NULL;
                apv.Product_Manager_Email10__c=NULL;
                apv.Product_Manager_Email11__c=NULL;
                apv.Product_Manager_Email12__c=NULL;
                apv.Product_Manager_Email13__c=NULL;
                apv.Product_Manager_Email14__c=NULL;  
               }
 } 
 
          
                                                 
  Map<Id, List<MDF_Associated_Contact__c>>  mdfConMap = new Map<Id,List<MDF_Associated_Contact__c>>();
  for(MDF_Associated_Contact__c mac : mdfACntct1){
      List<MDF_Associated_Contact__c> tmpList = new List<MDF_Associated_Contact__c>();
      if(mdfConMap.containsKey(mac.Vendor__c)){
          tmpList = mdfConMap.get(mac.Vendor__c);
      }else{
          tmpList = new List<MDF_Associated_Contact__c>();
      }
      tmpList.add(mac);
      mdfConMap.put(mac.Vendor__c,tmpList);
      
  }
  
  for(Associated_Programs_Vendors__c apvElt : assVendors){
      if(mdfConMap.containsKey(apvElt.Vendor__c)){
          List<MDF_Associated_Contact__c> apvList = mdfConMap.get(apvElt.Vendor__c);
             if(apvList<>null){
             system.debug('apvList=========='+apvList );
              
                 apvElt.Product_Manager_Email__c=NULL;
                  apvElt.Product_Manager_Email2__c =NULL;
                  apvElt.Product_Manager_Email3__c=NULL;
                  apvElt.Product_Manager_Email4__c=NULL;
                  apvElt.Product_Manager_Email5__c=NULL;
                  apvElt.Product_Manager_Email6__c=NULL;
                  apvElt.Product_Manager_Email7__c=NULL;
                  apvElt.Product_Manager_Email8__c=NULL;
                  apvElt.Product_Manager_Email9__c=NULL;
                  apvElt.Product_Manager_Email10__c=NULL;
                  apvElt.Product_Manager_Email11__c=NULL;
                  apvElt.Product_Manager_Email12__c=NULL;
                  apvElt.Product_Manager_Email13__c=NULL;
                  apvElt.Product_Manager_Email14__c=NULL; 
                  
              for(Integer l=0; l< apvList.size(); l++ ){
                    
                      If(l == 0){
                        apvElt.Product_Manager_Email__c=apvList[0].MDF_Contact__r.Email__c;
                        }else If(l == 1){
                        apvElt.Product_Manager_Email2__c=apvList[1].MDF_Contact__r.Email__c;
                        }else If(l == 2){
                        apvElt.Product_Manager_Email3__c=apvList[2].MDF_Contact__r.Email__c;
                        }else If(l == 3){
                        apvElt.Product_Manager_Email4__c=apvList[3].MDF_Contact__r.Email__c;
                        }else If(l == 4){
                        apvElt.Product_Manager_Email5__c=apvList[4].MDF_Contact__r.Email__c;
                        }else If(l == 5){
                        apvElt.Product_Manager_Email6__c=apvList[5].MDF_Contact__r.Email__c;
                        }else If(l == 6){
                        apvElt.Product_Manager_Email7__c=apvList[6].MDF_Contact__r.Email__c;
                        }else If(l == 7){
                        apvElt.Product_Manager_Email8__c=apvList[7].MDF_Contact__r.Email__c;
                        }else If(l == 8){
                        apvElt.Product_Manager_Email9__c=apvList[8].MDF_Contact__r.Email__c;
                        }else If(l == 9){
                        apvElt.Product_Manager_Email10__c=apvList[9].MDF_Contact__r.Email__c;
                        }else If(l == 10){
                        apvElt.Product_Manager_Email11__c=apvList[10].MDF_Contact__r.Email__c;
                        }else If(l == 11){
                        apvElt.Product_Manager_Email12__c=apvList[11].MDF_Contact__r.Email__c;
                        }else If(l == 12){
                        apvElt.Product_Manager_Email13__c=apvList[12].MDF_Contact__r.Email__c;
                        }else If(l == 13){
                        apvElt.Product_Manager_Email14__c=apvList[13].MDF_Contact__r.Email__c;
                }          
        
          }
        }
        else{
            for(Associated_Programs_Vendors__c apv : assVendors){
                apv.Product_Manager_Email__c=NULL;
                apv.Product_Manager_Email2__c =NULL;
                apv.Product_Manager_Email3__c=NULL;
                apv.Product_Manager_Email4__c=NULL;
                apv.Product_Manager_Email5__c=NULL;
                apv.Product_Manager_Email6__c=NULL;
                apv.Product_Manager_Email7__c=NULL;
                apv.Product_Manager_Email8__c=NULL;
                apv.Product_Manager_Email9__c=NULL;
                apv.Product_Manager_Email10__c=NULL;
                apv.Product_Manager_Email11__c=NULL;
                apv.Product_Manager_Email12__c=NULL;
                apv.Product_Manager_Email13__c=NULL;
                apv.Product_Manager_Email14__c=NULL;        
            } 
        }  
      }
     /*  else{
            for(Associated_Programs_Vendors__c apv : assVendors){
                apv.Product_Manager_Email__c=NULL;
                apv.Product_Manager_Email2__c =NULL;
                apv.Product_Manager_Email3__c=NULL;
                apv.Product_Manager_Email4__c=NULL;
                apv.Product_Manager_Email5__c=NULL;
                apv.Product_Manager_Email6__c=NULL;
                apv.Product_Manager_Email7__c=NULL;
                apv.Product_Manager_Email8__c=NULL;
                apv.Product_Manager_Email9__c=NULL;
                apv.Product_Manager_Email10__c=NULL;
                apv.Product_Manager_Email11__c=NULL;
                apv.Product_Manager_Email12__c=NULL;
                apv.Product_Manager_Email13__c=NULL;
                apv.Product_Manager_Email14__c=NULL;        
            } 
        } */

  }

/*                     
if(mdfACntct1 != null && mdfACntct1.size() > 0){
   for(Integer k=0; k<mdfACntct1.size(); k++){
        List<Associated_Programs_Vendors__c> apvList=IdAPVMap.get(mdfACntct1[k].Vendor__c);
        if(apvList != null){
            for(Associated_Programs_Vendors__c apvElt:apvList){   
                  apvElt.Product_Manager_Email__c=NULL;
                  apvElt.Product_Manager_Email2__c =NULL;
                  apvElt.Product_Manager_Email3__c=NULL;
                  apvElt.Product_Manager_Email4__c=NULL;
                  apvElt.Product_Manager_Email5__c=NULL;
                  apvElt.Product_Manager_Email6__c=NULL;
                  apvElt.Product_Manager_Email7__c=NULL;
                  apvElt.Product_Manager_Email8__c=NULL;
                  apvElt.Product_Manager_Email9__c=NULL;
                  apvElt.Product_Manager_Email10__c=NULL;
                  apvElt.Product_Manager_Email11__c=NULL;
                  apvElt.Product_Manager_Email12__c=NULL;
                  apvElt.Product_Manager_Email13__c=NULL;
                  apvElt.Product_Manager_Email14__c=NULL;
                    for(Integer l=0; l< mdfACntct1.size(); l++ ){
                      If(l == 0){
                        apvElt.Product_Manager_Email__c=mdfACntct1[0].MDF_Contact__r.Email__c;
                        }else If(l == 1){
                        apvElt.Product_Manager_Email2__c=mdfACntct1[1].MDF_Contact__r.Email__c;
                        }else If(l == 2){
                        apvElt.Product_Manager_Email3__c=mdfACntct1[2].MDF_Contact__r.Email__c;
                        }else If(l == 3){
                        apvElt.Product_Manager_Email4__c=mdfACntct1[3].MDF_Contact__r.Email__c;
                        }else If(l == 4){
                        apvElt.Product_Manager_Email5__c=mdfACntct1[4].MDF_Contact__r.Email__c;
                        }else If(l == 5){
                        apvElt.Product_Manager_Email6__c=mdfACntct1[5].MDF_Contact__r.Email__c;
                        }else If(l == 6){
                        apvElt.Product_Manager_Email7__c=mdfACntct1[6].MDF_Contact__r.Email__c;
                        }else If(l == 7){
                        apvElt.Product_Manager_Email8__c=mdfACntct1[7].MDF_Contact__r.Email__c;
                        }else If(l == 8){
                        apvElt.Product_Manager_Email9__c=mdfACntct1[8].MDF_Contact__r.Email__c;
                        }else If(l == 9){
                        apvElt.Product_Manager_Email10__c=mdfACntct1[9].MDF_Contact__r.Email__c;
                        }else If(l == 10){
                        apvElt.Product_Manager_Email11__c=mdfACntct1[10].MDF_Contact__r.Email__c;
                        }else If(l == 11){
                        apvElt.Product_Manager_Email12__c=mdfACntct1[11].MDF_Contact__r.Email__c;
                        }else If(l == 12){
                        apvElt.Product_Manager_Email13__c=mdfACntct1[12].MDF_Contact__r.Email__c;
                        }else If(l == 13){
                        apvElt.Product_Manager_Email14__c=mdfACntct1[13].MDF_Contact__r.Email__c;
                }
            }
        
        }
    }
}  
}else{
    for(Associated_Programs_Vendors__c apv : assVendors){
        apv.Product_Manager_Email__c=NULL;
        apv.Product_Manager_Email2__c =NULL;
        apv.Product_Manager_Email3__c=NULL;
        apv.Product_Manager_Email4__c=NULL;
        apv.Product_Manager_Email5__c=NULL;
        apv.Product_Manager_Email6__c=NULL;
        apv.Product_Manager_Email7__c=NULL;
        apv.Product_Manager_Email8__c=NULL;
        apv.Product_Manager_Email9__c=NULL;
        apv.Product_Manager_Email10__c=NULL;
        apv.Product_Manager_Email11__c=NULL;
        apv.Product_Manager_Email12__c=NULL;
        apv.Product_Manager_Email13__c=NULL;
        apv.Product_Manager_Email14__c=NULL;        
    } 
}
*/
        
}

/*
    //This method "updatePrgmOwnerMail" is not used and we have written new method named  "updatePrgmPopupOwnerMail" and used same in triggers as well
    public static void updatePrgmOwnerMail(List<Associated_Programs_Vendors__c> newAssPrgmVendrs){
       
        List<Viper_Email_Subscription__c> viperEmailSubscriptionList = new List<Viper_Email_Subscription__c>();
        viperEmailSubscriptionList = [Select Id, User__c, Send_APV_Notification__c from Viper_Email_Subscription__c where Send_APV_Notification__c = true AND User__r.IsActive = true];
          
        Set<Id> viperSubscrptionUsers = new Set<Id>();
        for(Viper_Email_Subscription__c viper: viperEmailSubscriptionList){
          viperSubscrptionUsers.add(viper.User__c);
        }
        
        Set<Id> assPrgmVednrsSet = new Set<Id>();
        for( Associated_Programs_Vendors__c assPrgmVendor: newAssPrgmVendrs ){
          assPrgmVednrsSet.add(assPrgmVendor.Id);
        }

        Map<Id, Associated_Programs_Vendors__c> assPrgmVendorsMap = new Map<Id, Associated_Programs_Vendors__c>([Select Id, MDF_Program__r.Program_Owner__c, Program_Owner_Email__c, MDF_Program__r.Program_Owner__r.Email, POP_Owner_Email__c, MDF_Program__r.POP_Owner__c, MDF_Program__r.POP_Owner__r.Email from Associated_Programs_Vendors__c where ID IN: assPrgmVednrsSet]);
        
        System.debug('***assPrgmVendorsMap: '+ assPrgmVendorsMap);

        for( Associated_Programs_Vendors__c assPrgmVendor: newAssPrgmVendrs ){ 

          Associated_Programs_Vendors__c assPrgVnd = assPrgmVendorsMap.get(assPrgmVendor.Id);

          If( assPrgVnd != NULL ){
          If( assPrgVnd.MDF_Program__r.Program_Owner__c != NULL ){
            if(viperSubscrptionUsers.contains(assPrgVnd.MDF_Program__r.Program_Owner__c)){
              assPrgmVendor.Program_Owner_Email__c = assPrgVnd.MDF_Program__r.Program_Owner__r.Email;
            }else{
              assPrgmVendor.Program_Owner_Email__c = NULL;
            }  
          }
       
          If(assPrgVnd.MDF_Program__r.POP_Owner__c != NULL){
            if(viperSubscrptionUsers.contains(assPrgVnd.MDF_Program__r.POP_Owner__c)){
              assPrgmVendor.POP_Owner_Email__c = assPrgVnd.MDF_Program__r.POP_Owner__r.Email;
            }else{
              assPrgmVendor.POP_Owner_Email__c = NULL;
            }
          }
          }
        }   
    }
*/
    public static void updatePrgmPopupOwnerMail(List<Associated_Programs_Vendors__c> apvList ){
        List<Viper_Email_Subscription__c> viperEmailSubscriptionList = new List<Viper_Email_Subscription__c>();
        viperEmailSubscriptionList = [Select Id, User__c, Send_APV_Notification__c from Viper_Email_Subscription__c where Send_APV_Notification__c = true AND User__r.IsActive = true];
        Set<Id> viperSubscrptionUsers = new Set<Id>();
        for(Viper_Email_Subscription__c viper: viperEmailSubscriptionList){
            viperSubscrptionUsers.add(viper.User__c);
        }
        Map<ID,MDF_Program__c> MdfProgramMap = new Map<ID,MDF_Program__c>();
        set<ID> MdfProgramIDSet = new Set<ID>();
        for(Associated_Programs_Vendors__c ap : apvList){
            MdfProgramIDSet.add(ap.MDF_Program__c);
        }
        MdfProgramMap = new Map<ID,MDF_Program__c>([select ID, POP_Owner__c,POP_Owner__r.name,POP_Owner__r.Email, Program_Owner__c,Program_Owner__r.Email,Program_Owner__r.Name from MDF_Program__c where ID in :MdfProgramIDSet]);
        for( Associated_Programs_Vendors__c apv: apvList ){ 
            if(MdfProgramMap.containsKey(apv.MDF_Program__c)){
                MDF_Program__c mdf = MdfProgramMap.get(apv.MDF_Program__c);
                if(mdf.Program_Owner__c != NULL){
                    if(viperSubscrptionUsers.contains(mdf.Program_Owner__c)){
                        apv.Program_Owner_Email__c = mdf.Program_Owner__r.Email;
                    }else{
                        apv.Program_Owner_Email__c = NULL;
                    }  
                }else{
                    apv.Program_Owner_Email__c = NULL;
                }
                If(mdf.POP_Owner__c != NULL){
                    if(viperSubscrptionUsers.contains(mdf.POP_Owner__c)){
                        apv.POP_Owner_Email__c = mdf.POP_Owner__r.Email;
                    }else{
                        apv.POP_Owner_Email__c = NULL;
                    }
                }else{
                    apv.POP_Owner_Email__c = NULL;
                }
            }else{
                apv.Program_Owner_Email__c = NULL;
                apv.POP_Owner_Email__c = NULL;
            }
            
        }
    }
}