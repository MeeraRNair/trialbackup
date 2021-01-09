public without sharing class ResellerAccForDistiCntrl {
    
    //To return additional records based on offset
    @AuraEnabled
    public static PRWrapper loadPRRecords(String strEmail,Integer initialRows,Integer irowOffset){
        PRWrapper wrap = new PRWrapper();
        List<Partner_Request__c> prList = new List<Partner_Request__c>();
        System.debug('rowOffset'+irowOffset + 'initialRows'+initialRows+'strEmail'+strEmail);
        prList = [SELECT Id,Name,First_name__c,Account__c,Account__r.Name,Account__r.Account_ID__c,Account__r.EMC_ID__c,Account__r.BillingAddress,Account__r.Billing_Address_CN__c,Account__r.BillingCountry,
                  Last_name__c,Email__c,Website__c,Phone__c,Address_Line_1__c,Address_Line_2__c,Address_Line_3__c,Provision_First_User_Is_Complete_Flag__c,Provisioned_User__c,Provisioned_User__r.CreatedDate
                  FROM Partner_Request__c
                  WHERE Primary_Channel_Model__c = 'Solution Provider (Reseller)' AND Account__c != null and Provisioned_User__c != null AND Provision_First_User_Is_Complete_Flag__c = true AND
                  		(Sponsoring_Distributor_Secondary_Email__c =:strEmail OR 
                        Sponsoring_Distributor_Primary_Email__c =:strEmail)
                  LIMIT :initialRows 
                  OFFSET :irowOffset];  
         
        System.debug('prList'+prList);
        if(prList.size() > 0){
            	wrap.success = true;
                wrap.totalRecords = [SELECT COUNT() FROM PArtner_Request__c WHERE Primary_Channel_Model__c = 'Solution Provider (Reseller)' AND Account__c != null and Provisioned_User__c != null AND Provision_First_User_Is_Complete_Flag__c = true AND
                  		             (Sponsoring_Distributor_Secondary_Email__c =:strEmail OR Sponsoring_Distributor_Primary_Email__c =:strEmail)];//prList.size();
            	wrap.resellerAccDistiList.addAll(prList);
                wrap.message = 'records found';
        }
        
        return wrap; 
    }
    
    // wrapper class
    public class PRWrapper{
            @AuraEnabled
            public Integer totalRecords = 0;
            @AuraEnabled
            public List<Partner_Request__c> resellerAccDistiList = new List<Partner_Request__c>();
            @AuraEnabled
            public String message ='';
            @AuraEnabled
            public Boolean success;
        }
     @AuraEnabled
    public static List<Partner_Request__c> loadDistiRecords(String strEmail,Integer irowLimit,Integer irowOffset){
        List<Partner_Request__c> prDistiList = new List<Partner_Request__c>();
        System.debug('rowLimit'+irowLimit+'rowOffset'+irowOffset);
            PRWrapper wrap = new PRWrapper();
            wrap = loadPRRecords(strEmail,irowLimit,irowOffset);
            prDistiList = wrap.resellerAccDistiList;
            return prDistiList; 
        
       
    }
    // wrapper class
	
     @AuraEnabled
    public static PRWrapper findByName(String searchKey,String strEmail){
            
            PRWrapper wrap= new PRWrapper();
            System.debug('searchKey' + searchKey);
            
            String strName = '%' + searchKey + '%';
            for(Partner_Request__c con: [SELECT Id,First_name__c,Account__c,Account__r.Name,Account__r.Account_ID__c,Account__r.EMC_ID__c,Account__r.Billing_Address_CN__c,Account__r.BillingCountry,Provisioned_User__r.CreatedDate,Provisioned_User__c,Provision_First_User_Is_Complete_Flag__c,Last_name__c,Email__c,Website__c,Phone__c,Address_Line_1__c,Address_Line_2__c,Address_Line_3__c
                  						 FROM Partner_Request__c
                 						 WHERE Account__r.Name LIKE :strName
                                         AND Primary_Channel_Model__c = 'Solution Provider (Reseller)' 
                                         AND Account__c != null and Provisioned_User__c != null AND Provision_First_User_Is_Complete_Flag__c = true AND
                                         	(Sponsoring_Distributor_Secondary_Email__c =:strEmail OR 
                        						Sponsoring_Distributor_Primary_Email__c =:strEmail)
                                          ORDER BY Name ASC 
                                 ]){
                                      wrap.resellerAccDistiList.add(con);
                                     
                                 }
                if(wrap.resellerAccDistiList.size() > 0){
                    wrap.totalRecords = wrap.resellerAccDistiList.size();
                    System.debug('totalRecords'+wrap.totalRecords);
                    wrap.message = 'contact found';
                    wrap.success = true;
                }
                else{
                    wrap.totalRecords = 0;
                    System.debug('totalRecords'+wrap.totalRecords);
                    wrap.message = 'contact found';
                   // wrap.resellerAccDistiList.
                    wrap.success = true;
                }
                
                
              return wrap;   
            }
            
           
            
       
}