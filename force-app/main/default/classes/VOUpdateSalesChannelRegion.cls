global class VOUpdateSalesChannelRegion {
    @InvocableMethod
    global static void updateCompanyRegion(List<ID> listSalesChannelID) {
        Map<ID,String> mapAccReg = new Map<ID,String>();
        Map<ID,String> mapOppReg = new Map<ID,String>();
        List<VisitOps__Company__c> listUpdateComp = new List<VisitOps__Company__c>();       
        List<VisitOps__VisitBundle__c> listUpdateBundle = new List<VisitOps__VisitBundle__c>();     
        for(Account objAcc:[SELECT Id, Sales_Channel__r.Region_Name__c FROM Account Where Sales_Channel__c in :listSalesChannelID]){
            System.debug('****Region Name---'+objAcc.Sales_Channel__r.Region_Name__c);
            mapAccReg.put(objAcc.id,objAcc.Sales_Channel__r.Region_Name__c);
        } 
            
       for(VisitOps__Company__c comp : [Select id,VO_Account_Region_District__c,VisitOps__Account__c From VisitOps__Company__c Where VisitOps__Account__c in :mapAccReg.keyset()]){
            comp.VO_Account_Region_District__c = mapAccReg.get(comp.VisitOps__Account__c);
            listUpdateComp.add(comp);
       }       
       if(!listUpdateComp.isEmpty()){
            update listUpdateComp;
       }
       
       //Update Visit Bundle
       for(Opportunity objOpp:[SELECT Id, Account.Sales_Channel__r.Region_Name__c FROM Opportunity Where Account.Sales_Channel__c in :listSalesChannelID]){
            mapOppReg.put(objOpp.id,objOpp.Account.Sales_Channel__r.Region_Name__c);
        } 
            
       for(VisitOps__VisitBundle__c  bundle : [Select id,VO_Account_Region_District__c,VisitOps__Opportunity__c From VisitOps__VisitBundle__c Where VisitOps__Opportunity__c in :mapOppReg.keyset()]){
            bundle.VO_Account_Region_District__c  = mapOppReg.get(bundle.VisitOps__Opportunity__c);
            listUpdateBundle.add(bundle);
       }       
       if(!listUpdateBundle.isEmpty()){
            update listUpdateBundle;
       }
                                        
    }
}