global class VFCntrlr_VIPERCustomerPortal{
    public Marketing_Plan__c marketingPlan=new Marketing_Plan__c();    
    public VFCntrlr_VIPERCustomerPortal(ApexPages.StandardController stdController){
        try{
            marketingPlan=[select id,Contract_Type__c from Marketing_Plan__c where id=:stdController.getId()];
        }catch(Exception e){}
                       
              
    }
    public PageReference actionFn(){
        PageReference pageRef;
        String contractType=ApexPages.currentPage().getParameters().get('contractType');
        String idStr=ApexPages.currentPage().getParameters().get('Id'); 
        
        if(marketingPlan.Contract_Type__c=='Volume Based'){
            pageRef=new PageReference('/apex/CustomerPortal_MarketingPlan?id='+idStr);        
        }
        if(marketingPlan.Contract_Type__c=='Ala Carte'){
            pageRef=new PageReference('/apex/CustomerPortal_MarketingPlan_AlaCarte?id='+idStr);        
        }
        if(marketingPlan.Contract_Type__c=='Headcount'){
            pageRef=new PageReference('/apex/CustomerPortal_MarketingPlan_HeadCount?id='+idStr);        
        }
        if(marketingPlan.Contract_Type__c=='Rebates'){
            pageRef=new PageReference('/apex/CustomerPortal_MarketingPlan_Rebates?id='+idStr);        
        }  
        return pageRef; 
    } 

}