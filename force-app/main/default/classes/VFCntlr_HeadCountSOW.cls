public class VFCntlr_HeadCountSOW extends SOWBaseCls{
    
    RecordType headCountRT;
    
    public Integer marketingPlanTerm {get; set;}
    
   
    public VFCntlr_HeadCountSOW(ApexPages.StandardController controller) {
       
        apvList = new list<Associated_Programs_Vendors__c>();
                
        headCountRT=[select id,name,SobjectType  from RecordType 
        where SobjectType='Marketing_Plan__c' and name='Headcount Marketing Plan' limit 1];
      
        VfCtrl_ViperSOQLMethod_Utility ViperSOQLMethod= new VfCtrl_ViperSOQLMethod_Utility(); 
        
        MarketingPlan= database.query(ViperSOQLMethod.getQueryMethod1(new Marketing_Plan__c(),'VFCntlr_HeadCountSOW') + ' where id=\''+controller.getId()+'\' and recordTypeId=\''+headCountRT.id+'\' and Contract_Type__c=\'Headcount\'');
       
        System.debug('###MarketingPlan'+MarketingPlan);
        
        
        
        marketingPlanTerm = Integer.valueOf(MarketingPlan.Term__c);
        
         for(Associated_Programs_Vendors__c apvListElt:database.query(ViperSOQLMethod.getQueryMethod2(new Associated_Programs_Vendors__c(),'VFCntlr_HeadCountSOW') + 
                                                                    ' where vendor__c=\''+MarketingPlan.vendor__c+'\' and Marketing_Plan__c=\''+MarketingPlan.Id+
                                                                    '\' and status__c=\'Accepted\' and Fiscal_Quarter__c=\''+MarketingPlan.Fiscal_Quarter__c+'\'')){

            apvList.add(apvListElt);
            System.debug('###apvList'+apvList);    
                
        }
        
        concatenateAddress();
    }
    
   
}