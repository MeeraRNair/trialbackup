/***********************************************************
* Name          : ViperUtilities
* Description   : Utility Class for all Viper related Business Logic
* ---------------------------------------------------------
* Revision  Name     Date          Description
* 1.0      Shivam  30.11.2016  fetchContractStatusFromMPToPOPV-Method to fetch Contract Status from APV to POP Line Item.
* 1.0      Shivam  30.11.2016  updateContractStatusOnPOPV-Method to update contract status on POPV When Updated on APV.
* 2.0      sharad  5-jun,2018  CR15899  Viper: Contract Status is blank on the POP page - INC5974188
************************************************************/
public class ViperUtilities{
    //1.0 Method to fetch Marketing Plan Contract Status to POP Line Item
    public static void fetchContractStatusFromAPVToPOPV(List<POP_Line_Item__c> lstPOPV){
       Set<Id> setPliToPOP = new Set<Id>();
       Set<Id> setPliToVendor = new Set<Id>();
       for(POP_Line_Item__c pli:lstPOPV){
          setPliToPOP.add(pli.Proof_of_Performance_POP__c);
          setPliToVendor.add(pli.Vendor__c);
       }
       System.Debug('POPV TO POP Map##'+setPliToPOP);
       System.Debug('POPV TO Vendor Map##'+setPliToVendor);
       
       Map<Id,Id> mapPOPToMDF = new Map<Id,Id>();
       Map<Id,Proof_of_Performance_POP__c> mapPOP = new Map<Id,Proof_of_Performance_POP__c>();
       for(Proof_of_Performance_POP__c objPOP :[Select Id,MDF_Program__c,Region__c,Sub_Region__c,Country__c,Business_Segment__c,Fiscal_Quarter__c from Proof_of_Performance_POP__c Where Id IN:setPliToPOP]){
          mapPOPToMDF.put(objPOP.Id,objPOP.MDF_Program__c);
          mapPOP.put(objPOP.Id,objPOP);
       }
       System.Debug('POP TO MDF Map##'+mapPOPToMDF);
       System.Debug('POP MAP##'+mapPOP);
       
       Map<String,String> mapMDFToMP = new Map<String,String>();
       for(Associated_Programs_Vendors__c apv:[Select Id,Marketing_Plan__c,Status__c,MDF_Program__c,Vendor__c,Fiscal_Quarter_New__c,Country__c,Region__c,Sub_Region__c,Business_Segment__c from Associated_Programs_Vendors__c Where Vendor__c IN:setPliToVendor and MDF_Program__c IN:mapPOPToMDF.values()]){
           mapMDFToMP.put(apv.Vendor__c+'-'+apv.MDF_Program__c+'-'+apv.Fiscal_Quarter_New__c+'-'+apv.Region__c+'-'+apv.Sub_Region__c+'-'+apv.Country__c+'-'+apv.Business_Segment__c,apv.Marketing_Plan__c+'-'+apv.Status__c);
       }
       System.Debug('APV MAP##'+mapMDFToMP);
       
       for(POP_Line_Item__c pliToUpd : lstPOPV){
           String strValue = mapMDFToMP.get(pliToUpd.Vendor__c+'-'+mapPOPToMDF.get(pliToUpd.Proof_of_Performance_POP__c)+'-'+mapPOP.get(pliToUpd.Proof_of_Performance_POP__c).Fiscal_Quarter__c+'-'+mapPOP.get(pliToUpd.Proof_of_Performance_POP__c).Region__c+'-'+mapPOP.get(pliToUpd.Proof_of_Performance_POP__c).Sub_Region__c+'-'+mapPOP.get(pliToUpd.Proof_of_Performance_POP__c).Country__c+'-'+mapPOP.get(pliToUpd.Proof_of_Performance_POP__c).Business_Segment__c);
           //System.Debug('strValue##'+strValue);
           //System.Debug('strValue##'+strValue.split('-')[1]);
           if(strValue!=null && strValue!=''){
               pliToUpd.Contract_Status__c = strValue.split('-')[1]; //2.0
           }
           
       }    
    }
    //1.0 Method to update contract status on POPV When Contract Status is changed on APV 
    public static void updateContractStatusOnPOPV(Map<Id,Associated_Programs_Vendors__c> mapOldMP ,Map<Id,Associated_Programs_Vendors__c> mapNewMP){
        Map<String,String> mapMDF = new Map<String,String>();
        Set<Id> MDFIds = new Set<Id>();
        for(Associated_Programs_Vendors__c objMP:mapNewMP.values()){
            if(objMP.Status__c != mapOldMP.get(objMP.Id).Status__c){
                mapMDF.put(objMP.MDF_Program__c+'-'+objMP.Vendor__c+'-'+objMP.Fiscal_Quarter_New__c+'-'+objMP.Region__c+'-'+objMP.Sub_Region__c+'-'+objMP.Country__c+'-'+objMP.Business_Segment__c,objMP.Status__c);
                MDFIds.add(objMP.MDF_Program__c);
            }
        }
        System.Debug('APV MAP##'+mapMDF);
        System.Debug('MDF MAP##'+MDFIds);
        if(MDFIds.size() > 0){
            Map<Id,Proof_of_Performance_POP__c> mapPOP = new Map<Id,Proof_of_Performance_POP__c>();
            Map<Id,Id> mapPOPTOMDF = new Map<Id,Id>();
            for(Proof_of_Performance_POP__c pop:[Select Id,MDF_Program__c,Region__c,Sub_Region__c,Country__c,Business_Segment__c,Fiscal_Quarter__c from Proof_of_Performance_POP__c Where MDF_Program__c IN:MDFIds]){
                mapPOP.put(pop.Id,pop);
            }
            System.Debug('POP MAP##'+mapPOP);
            List<POP_Line_Item__c> lstPOPOliToUpdate = new List<POP_Line_Item__c>();
            for(POP_Line_Item__c popOli:[Select Id,Program__c,Vendor__c,Proof_of_Performance_POP__c,Contract_Status__c from POP_Line_Item__c Where Proof_of_Performance_POP__c IN:mapPOP.keyset()]){
                if(mapMDF.get(mapPOP.get(popOli.Proof_of_Performance_POP__c).MDF_Program__c+'-'+popOli.Vendor__c+'-'+mapPOP.get(popOli.Proof_of_Performance_POP__c).Fiscal_Quarter__c+'-'+mapPOP.get(popOli.Proof_of_Performance_POP__c).Region__c+'-'+mapPOP.get(popOli.Proof_of_Performance_POP__c).Sub_Region__c+'-'+mapPOP.get(popOli.Proof_of_Performance_POP__c).Country__c+'-'+mapPOP.get(popOli.Proof_of_Performance_POP__c).Business_Segment__c) != null){
                    popOli.Contract_Status__c = mapMDF.get(mapPOP.get(popOli.Proof_of_Performance_POP__c).MDF_Program__c+'-'+popOli.Vendor__c+'-'+mapPOP.get(popOli.Proof_of_Performance_POP__c).Fiscal_Quarter__c+'-'+mapPOP.get(popOli.Proof_of_Performance_POP__c).Region__c+'-'+mapPOP.get(popOli.Proof_of_Performance_POP__c).Sub_Region__c+'-'+mapPOP.get(popOli.Proof_of_Performance_POP__c).Country__c+'-'+mapPOP.get(popOli.Proof_of_Performance_POP__c).Business_Segment__c);
                    System.Debug('CONTRACT STATUS##'+popOli.Contract_Status__c);
                    lstPOPOliToUpdate.add(popOli);
                }
            }
            if(!lstPOPOliToUpdate.isEmpty()){
              update lstPOPOliToUpdate;
            }
        }       
    }
}