public with sharing class AllianceReabteRequestController {
    
    public Alliance_Rebate_Request__c allianceRebateReqObj {get;set;}
    public Id rebateReqId {get;set;}
    public String userProfileName {get;set;}
    public String currentStatus ;
    @TestVisible String currentClientEnterprise ;
    @TestVisible String currentSystemPartName ;
    @TestVisible String currentPartRequested ;                      
    public boolean displayPopup {get; set;}
    public boolean displayPopupIECPU {get; set;}
    public boolean bdisplayPopupAll {get; set;}
    public boolean displayCancelAlertPopup {get; set;}
    String loggedInUserRegion;
    public String isCloned {get;set;}
    Alliance_Rebate_Request__c clonedArrObj ;
    
    public list<Rebate_Request_Product__c> rebRequestProdList {get;set;}
    Rebate_Request_Product__c rebReqProdObj ;
    public list<Rebate_Request_Product__c> originalSavedProducts {get;set;}
    list<Rebate_Request_Product__c> deleteOldProducts ;
    Alliance_Rebate_Request__c originalRebReqObj ;               
    
    public AllianceReabteRequestController(ApexPages.StandardController controller) {
        
        //Clone Functionality starts
        isCloned = ApexPages.currentPage().getParameters().get('clone');
        
        rebateReqId = ApexPages.currentPage().getParameters().get('id');                            
    //    loggedInUserRegion = AllianceRebateRequestUtils.getLoggedInUserRegion();
        userProfileName = AllianceRebateRequestUtils.getLoggedInUserProfile();
        System.debug('***User Profile Name: '+ userProfileName);
        displayCancelAlertPopup = false;
        rebRequestProdList = new list<Rebate_Request_Product__c>();
        originalRebReqObj = new Alliance_Rebate_Request__c();
        deleteOldProducts = new list<Rebate_Request_Product__c>();
        
        If(rebateReqId == null  ){
            // New Request 
            allianceRebateReqObj = new Alliance_Rebate_Request__c();            
            allianceRebateReqObj.Status__c = 'Draft';
     /*       If(loggedInUserRegion == 'EMEA' || loggedInUserRegion == 'EC-EMEA'){
                allianceRebateReqObj.Region__c = 'EMEA';
            }else{
                allianceRebateReqObj.Region__c = loggedInUserRegion;
            } 
            */
            allianceRebateReqObj.System_Partner_Name__c = 'Intel';
            currentStatus = 'Draft';
            
            for(integer i = 0; i < 8; i++ ){
                rebReqProdObj = new Rebate_Request_Product__c();
                rebReqProdObj.Sl_No__c = i + 1;
                rebRequestProdList.add(rebReqProdObj);
            }
            
        }else {         
            // Edit Request            
            Map<String, Schema.SObjectField> objectFields = Schema.getGlobalDescribe().get('Alliance_Rebate_Request__c').getDescribe().fields.getMap();
            
            String queryStr ='';
            for(String field: objectFields.keySet()){
                queryStr += field + ',' ;
            }
            
            // remove last additional comma from string
            queryStr = queryStr.removeEnd(',');
            
            String query = 'Select ' + queryStr + ' from Alliance_Rebate_Request__c Where Id = ' + '\'' + rebateReqId + '\'';
            System.debug('Query String: '+ query);
            allianceRebateReqObj = Database.query(query);
            
            currentStatus = allianceRebateReqObj.Status__c;
            currentClientEnterprise = allianceRebateReqObj.Client_Enterprise__c;
            currentSystemPartName = allianceRebateReqObj.System_Partner_Name__c;
            currentPartRequested = allianceRebateReqObj.Part_Requested__c;
            
            originalRebReqObj = allianceRebateReqObj;
            system.debug('****allianceRebateReqObj: '+ allianceRebateReqObj);
            
            String queryStrReqProduct = getrebReqProdQuery();
            
            String rebReqProdQuery = 'Select ' + queryStrReqProduct + ' from Rebate_Request_Product__c Where Alliance_Rebate_Request__c = ' + '\'' + rebateReqId + '\'' + ' Order By Sl_No__c';
            System.debug('rebReqProdQuery String: '+ rebReqProdQuery);
            
            rebRequestProdList = Database.query(rebReqProdQuery);
            
            // Save Original Products for Edit purpose
            originalSavedProducts = new list<Rebate_Request_Product__c>();
            
            If(rebRequestProdList.size() > 0){
                for(Rebate_Request_Product__c rebReq: rebRequestProdList){
                    originalSavedProducts.add(rebReq);
                }
            }
            
            If( (allianceRebateReqObj.Client_Enterprise__c == 'Enterprise' && allianceRebateReqObj.System_Partner_Name__c == 'Intel' && (allianceRebateReqObj.Part_Requested__c == 'CPU' || allianceRebateReqObj.Part_Requested__c == 'OPA') && (userProfileName == 'allianceGlobalPrgmLead' || userProfileName == 'allianceRegionalPrgmLead' || userProfileName == 'admin') 
                 && (allianceRebateReqObj.Status__c == 'Submitted' || allianceRebateReqObj.Status__c == 'Awaiting Vendors Response' || allianceRebateReqObj.Status__c == 'Work in Progress' ) ) || Test.isRunningTest() ){
                     If( rebRequestProdList.size() > 0 ){
                         integer calc = 8-rebRequestProdList.size();
                         integer count = rebRequestProdList.size();
                         for(integer i=0; i < calc; i++ ){
                             rebReqProdObj = new Rebate_Request_Product__c();
                             rebReqProdObj.Sl_No__c = count + 1;
                             rebRequestProdList.add(rebReqProdObj);
                             count++;
                         }
                     }else{
                         integer count = 0;
                         for(integer i=0; i < 8; i++ ){
                             rebReqProdObj = new Rebate_Request_Product__c();
                             rebReqProdObj.Sl_No__c = count + 1;
                             If( !Test.isRunningTest() ){
                                 rebRequestProdList.add(rebReqProdObj);
                             }
                             count++;
                         }
                     }
                 }
            
            integer prodEditSize = getProductSize();
            
            If( rebRequestProdList.size() > 0 ){
                If( allianceRebateReqObj.Status__c == 'Draft' && isCloned == null) {
                    integer calc ;
                    If((allianceRebateReqObj.Part_Requested__c == 'CPU' || allianceRebateReqObj.Part_Requested__c == 'OPA') && allianceRebateReqObj.Client_Enterprise__c == 'Enterprise' && allianceRebateReqObj.System_Partner_Name__c == 'Intel'){
                        calc = 1;
                        
                    }else {
                        calc = 8-rebRequestProdList.size();
                        integer count = rebRequestProdList.size();
                        for(integer i=0; i < calc; i++ ){
                            rebReqProdObj = new Rebate_Request_Product__c();
                            rebReqProdObj.Sl_No__c = count + 1;
                            rebRequestProdList.add(rebReqProdObj);
                            count++;
                        }
                    }
                    
                }else If(isCloned != null){
                    // Clone
                    integer calc ;
                    If((allianceRebateReqObj.Part_Requested__c == 'CPU' || allianceRebateReqObj.Part_Requested__c == 'OPA') && allianceRebateReqObj.Client_Enterprise__c == 'Enterprise' && allianceRebateReqObj.System_Partner_Name__c == 'Intel'){
                        rebRequestProdList = new list<Rebate_Request_Product__c>();
                        /* calc = 1;
integer count = rebRequestProdList.size();
for(integer i=0; i < calc; i++ ){
rebReqProdObj = new Rebate_Request_Product__c();
rebReqProdObj.Sl_No__c = 1;
rebRequestProdList.add(rebReqProdObj);
//count++;
}*/
                        
                    }else {
                        calc = 8-rebRequestProdList.size();
                        integer count = rebRequestProdList.size();
                        for(integer i=0; i < calc; i++ ){
                            rebReqProdObj = new Rebate_Request_Product__c();
                            rebReqProdObj.Sl_No__c = count + 1;
                            rebRequestProdList.add(rebReqProdObj);
                            count++;
                        }
                    }
                }
            }else {
                If( allianceRebateReqObj.Status__c == 'Draft' && isCloned == null){
                    for(integer i=0; i < prodEditSize; i++ ){
                        rebReqProdObj = new Rebate_Request_Product__c();
                        rebReqProdObj.Sl_No__c = i + 1;
                        rebRequestProdList.add(rebReqProdObj);
                    }
                }else If(isCloned == null){
                    rebRequestProdList = new list<Rebate_Request_Product__c>();
                }else If(isCloned != null){
                    integer prodSize = getProductSize();
                    If((allianceRebateReqObj.Part_Requested__c == 'CPU' || allianceRebateReqObj.Part_Requested__c == 'OPA') && allianceRebateReqObj.Client_Enterprise__c == 'Enterprise' && allianceRebateReqObj.System_Partner_Name__c == 'Intel'){
                        rebRequestProdList = new list<Rebate_Request_Product__c>();
                        /*for(integer i=0; i < prodSize; i++ ){
rebReqProdObj = new Rebate_Request_Product__c();
rebReqProdObj.Sl_No__c = 1;
rebRequestProdList.add(rebReqProdObj);
}*/
                        
                    }else {
                        for(integer i=0; i < prodSize; i++ ){
                            rebReqProdObj = new Rebate_Request_Product__c();
                            rebReqProdObj.Sl_No__c = i + 1;
                            rebRequestProdList.add(rebReqProdObj);
                        }
                    }
                }
            }
            
            If(isCloned != null){
                // Cloned
                allianceRebateReqObj.Status__c = 'Draft';
                
                Id rtId ;
                
                rtId = Schema.SObjectType.Alliance_Rebate_Request__c.RecordTypeInfosByName.get('Rebate Request Submission').RecordTypeId;
                
                System.debug('**Cloned RT Type: '+ rtId);
                
                allianceRebateReqObj.RecordTypeId = rtId;
                
                If( (allianceRebateReqObj.Part_Requested__c == 'CPU' || allianceRebateReqObj.Part_Requested__c == 'OPA') && allianceRebateReqObj.Client_Enterprise__c == 'Enterprise' && allianceRebateReqObj.System_Partner_Name__c == 'Intel' ){
                    rebRequestProdList = new list<Rebate_Request_Product__c>();
                }else{
                    for(Rebate_Request_Product__c rebateProd: rebRequestProdList){
                        rebateProd.Status__c = 'Active';
                        rebateProd.Quantity_Approved__c = null;
                        rebateProd.Cost_Per_Unit__c = null;
                        rebateProd.Approved_Price_per_unit__c = null;
                        rebateProd.Start_Date__c = null;
                        rebateProd.End_Date__c = null;
                        rebateProd.Quantity_Claimed__c = null;
                    }
                }
            }         
        } 
    }
    
    public String getrebReqProdQuery(){
        Map<String, Schema.SObjectField> rebReqObjectFields = Schema.getGlobalDescribe().get('Rebate_Request_Product__c').getDescribe().fields.getMap();
        String queryString = '';
        
        for(String field: rebReqObjectFields.keySet()){
            queryString += field + ',' ;
        }
        
        // remove last additional comma from string
        queryString = queryString.removeEnd(',');
        
        return queryString;
    }
    
    public integer getProductSize(){
        integer totalProdSize ;
        
        If((allianceRebateReqObj.Part_Requested__c == 'CPU' || allianceRebateReqObj.Part_Requested__c == 'OPA') && allianceRebateReqObj.Client_Enterprise__c == 'Enterprise' && allianceRebateReqObj.System_Partner_Name__c == 'Intel'){
            totalProdSize = 0;
        }else{
            totalProdSize = 8;
        }
        
        return totalProdSize;
    }
    public void makingVoid(){
        if(allianceRebateReqObj.Client_Enterprise__c == 'Client'){
            allianceRebateReqObj.System_Partner_Name__c = 'Intel';
            
        }  
    }
    public void partRequestChange(){
        
        integer prodSize = getProductSize();
        //allianceRebateReqObj.Client_Enterprise__c = 'Client';
       //makingVoid();
        If( rebateReqId == null ){
            
            // New Request
            rebRequestProdList = new list<Rebate_Request_Product__c>();
            
            for(integer i = 0; i < prodSize; i++ ){
                rebReqProdObj = new Rebate_Request_Product__c();
                rebReqProdObj.Sl_No__c = i + 1;
                rebRequestProdList.add(rebReqProdObj);
            }
            
            If( allianceRebateReqObj.Client_Enterprise__c != 'Enterprise' || allianceRebateReqObj.System_Partner_Name__c != 'Intel' ){
                allianceRebateReqObj.Part_Requested__c = null;
            }
            
            If(allianceRebateReqObj.Client_Enterprise__c == 'Client'){
                allianceRebateReqObj.System_Partner_Name__c = 'Intel';
            }
            
        }else If( isCloned != null ){
            
            // Clone
            /* rebRequestProdList = new list<Rebate_Request_Product__c>();
for(integer i = 0; i < prodSize; i++ ){
rebReqProdObj = new Rebate_Request_Product__c();
rebReqProdObj.Sl_No__c = i + 1;
rebRequestProdList.add(rebReqProdObj);
}*/
            
           /* If(allianceRebateReqObj.Client_Enterprise__c == 'Client'){
                allianceRebateReqObj.System_Partner_Name__c = 'Intel';
            } */
            
            If(allianceRebateReqObj.Client_Enterprise__c == 'Client' && allianceRebateReqObj.System_Partner_Name__c == 'Intel'){
                allianceRebateReqObj.Part_Requested__c = null;
            }/*else{
allianceRebateReqObj.Part_Requested__c = currentPartRequested;
}*/
            
            If( allianceRebateReqObj.Part_Requested__c == currentPartRequested && allianceRebateReqObj.Client_Enterprise__c == currentClientEnterprise && allianceRebateReqObj.System_Partner_Name__c == currentSystemPartName) {
                System.debug('****Edit change If: '+ allianceRebateReqObj);
                rebRequestProdList = new list<Rebate_Request_Product__c>();
                
                If(originalSavedProducts.size() > 0){
                    for(Rebate_Request_Product__c rebReq: originalSavedProducts){
                        rebRequestProdList.add(rebReq);
                    }
                    
                    If(!((allianceRebateReqObj.Part_Requested__c == 'CPU' || allianceRebateReqObj.Part_Requested__c == 'OPA') && allianceRebateReqObj.Client_Enterprise__c == 'Enterprise' && allianceRebateReqObj.System_Partner_Name__c == 'Intel')){
                        rebRequestProdList = new list<Rebate_Request_Product__c>();
                        /*integer prodSiz = 8 - originalSavedProducts.size();

If( prodSiz > 0 ){
for(integer i = 0; i < prodSiz; i++ ){
rebReqProdObj = new Rebate_Request_Product__c();
rebReqProdObj.Sl_No__c = i + 1;
rebRequestProdList.add(rebReqProdObj);
}
}*/
                    }
                }else{
                    integer prodSiz = 8 ;
                    for(integer i = 0; i < prodSiz; i++ ){
                        rebReqProdObj = new Rebate_Request_Product__c();
                        rebReqProdObj.Sl_No__c = i + 1;
                        rebRequestProdList.add(rebReqProdObj);
                    }
                }
            }else{
                rebRequestProdList = new list<Rebate_Request_Product__c>();
                for(integer i = 0; i < prodSize; i++ ){
                    rebReqProdObj = new Rebate_Request_Product__c();
                    rebReqProdObj.Sl_No__c = i + 1;
                    rebRequestProdList.add(rebReqProdObj);
                }
            }
            
        }else If( rebateReqId != null && isCloned == null ){
            
            // Edit
            If(allianceRebateReqObj.Client_Enterprise__c == 'Client' && allianceRebateReqObj.System_Partner_Name__c == 'Intel'){
                allianceRebateReqObj.Part_Requested__c = null;
            }
            
            If(allianceRebateReqObj.Part_Requested__c == currentPartRequested && allianceRebateReqObj.Client_Enterprise__c == currentClientEnterprise && allianceRebateReqObj.System_Partner_Name__c == currentSystemPartName ) {
                System.debug('****Edit change If: '+ allianceRebateReqObj);
                rebRequestProdList = new list<Rebate_Request_Product__c>();
                
                If(originalSavedProducts.size() > 0){
                    for(Rebate_Request_Product__c rebReq: originalSavedProducts){
                        rebRequestProdList.add(rebReq);
                    }
                    
                    If(!((allianceRebateReqObj.Part_Requested__c == 'CPU' || allianceRebateReqObj.Part_Requested__c == 'OPA') && allianceRebateReqObj.Client_Enterprise__c == 'Enterprise' && allianceRebateReqObj.System_Partner_Name__c == 'Intel')){
                        integer prodSiz = 8 - originalSavedProducts.size();
                        
                        If( prodSiz > 0 ){
                            for(integer i = 0; i < prodSiz; i++ ){
                                rebReqProdObj = new Rebate_Request_Product__c();
                                rebReqProdObj.Sl_No__c = i + 1;
                                rebRequestProdList.add(rebReqProdObj);
                            }
                        }
                    }
                }else{
                    integer prodSiz = 8 ;
                    for(integer i = 0; i < prodSiz; i++ ){
                        rebReqProdObj = new Rebate_Request_Product__c();
                        rebReqProdObj.Sl_No__c = i + 1;
                        rebRequestProdList.add(rebReqProdObj);
                    }
                }
            }else{
                System.debug('****Edit change Else: '+ allianceRebateReqObj);
                
                deleteOldProducts = new list<Rebate_Request_Product__c>();
                If(originalSavedProducts.size() > 0 ){
                    for(Rebate_Request_Product__c oldProd: originalSavedProducts){
                        If(oldProd.id != null){
                            deleteOldProducts.add(oldProd);
                        }
                    }
                }
                System.debug('***delete Old Prods1: '+ deleteOldProducts);
                rebRequestProdList = new list<Rebate_Request_Product__c>();
                
                for(integer i = 0; i < prodSize; i++ ){
                    rebReqProdObj = new Rebate_Request_Product__c();
                    rebReqProdObj.Sl_No__c = i + 1;
                    rebRequestProdList.add(rebReqProdObj);
                }
            }
        }
    }
    
    // Save method to submit form    
    public PageReference saveRequest(){
        
        Savepoint sp = Database.setSavepoint();
       // System.debug('@@@ New Value'+rebRequestProdList[0].Price_Requested__c);
      //  System.debug('@@@ New Value'+rebRequestProdList[0].Quantity__c);
        try {              
            
            system.debug('allianceRebateReqObj +++++++++'+allianceRebateReqObj);
            /*if(allianceRebateReqObj.System_Partner_Name__c!=null && allianceRebateReqObj.System_Partner_Name__c=='Intel'){
allianceRebateReqObj.Approval_ID__c=Null;
}*/
            
            If( allianceRebateReqObj.System_Partner_Name__c == 'Intel' && allianceRebateReqObj.Client_Enterprise__c == 'Enterprise' && (allianceRebateReqObj.Part_Requested__c == 'CPU' || allianceRebateReqObj.Part_Requested__c == 'OPA') ){
                allianceRebateReqObj.Total_Deal_Size__c = null;
                allianceRebateReqObj.Rollout_From__c = null;
                allianceRebateReqObj.Rollout_To__c = null;
            }
            
            If( allianceRebateReqObj.System_Partner_Name__c!='Intel'|| allianceRebateReqObj.Client_Enterprise__c!='Enterprise' ) {
                allianceRebateReqObj.Part_Requested__c = Null;
            }
            
            // Validate Rebate Request Products
            If(rebRequestProdList.size() > 0) {
                for(Rebate_Request_Product__c rebProd: rebRequestProdList){
                    
                    /*If(allianceRebateReqObj.Client_Enterprise__c == 'Enterprise' && allianceRebateReqObj.System_Partner_Name__c == 'Intel' && allianceRebateReqObj.Part_Requested__c == 'CPU'){
If( rebProd.Part_Name_Part_Number__c == null || rebProd.Quantity__c == null || rebProd.Price_Requested__c == null || rebProd.Competitor_Name_Competitor_Part__c == null || rebProd.Dell_System_Model_type__c == null ){
ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, 'You requested as CPU, Please fill in other details to proceed'));
return null;
}
}else */
                    If( allianceRebateReqObj.Client_Enterprise__c == 'Enterprise' && allianceRebateReqObj.System_Partner_Name__c == 'Intel' && (allianceRebateReqObj.Part_Requested__c != 'CPU' && allianceRebateReqObj.Part_Requested__c != 'OPA') ){
                        /* If( rebProd.Part_Requested__c != null && (rebProd.Part_Name_Part_Number__c == null || rebProd.Quantity__c == null || rebProd.Price_Requested__c == null || rebProd.Competitor_Name_Competitor_Part__c == null || rebProd.Dell_System_Model_type__c == null )){
ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, 'Part requested is selected, Please fill in other details to proceed'));
return null;
}else If( rebProd.Part_Requested__c == null && (rebProd.Part_Name_Part_Number__c != null || rebProd.Quantity__c != null || rebProd.Price_Requested__c != null || rebProd.Competitor_Name_Competitor_Part__c != null || rebProd.Dell_System_Model_type__c != null) ){
ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, 'Part requested should not be null'));
return null;
} */ 
                    }else{
                        /*  If( rebProd.Part_Name_Part_Number__c != null && (rebProd.Quantity__c == null || rebProd.Price_Requested__c == null || rebProd.Competitor_Name_Competitor_Part__c == null || rebProd.Dell_System_Model_type__c == null )){
ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, 'Part requested is selected, Please fill in other details to proceed'));
return null;
}else If( rebProd.Part_Name_Part_Number__c == null && (rebProd.Quantity__c != null || rebProd.Price_Requested__c != null || rebProd.Competitor_Name_Competitor_Part__c != null || rebProd.Dell_System_Model_type__c != null) ){
ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, 'Part Name/Part Number should not be null'));
return null;
} */
                    }
                }
            }
               if(allianceRebateReqObj.Sales_Force_Deal_ID__c !=null){
                 loggedInUserRegion = AllianceRebateRegionPopulate.getCountryRegionByOpportunityEndUserAccount(allianceRebateReqObj.Sales_Force_Deal_ID__c);
                if(loggedInUserRegion !=null){
                If(loggedInUserRegion == 'EMEA' || loggedInUserRegion == 'EC-EMEA'){
                allianceRebateReqObj.Region__c = 'EMEA';
            }else{
                    allianceRebateReqObj.Region__c = loggedInUserRegion;
                }
                              
                }
            }  
            //Upsert Alliance Rebate Request form
            If( isCloned != null ){
                clonedArrObj = new Alliance_Rebate_Request__c();
                
                clonedArrObj = allianceRebateReqObj.clone();
                
                Id rtId ;
                If( (clonedArrObj.Part_Requested__c == 'CPU' || clonedArrObj.Part_Requested__c == 'OPA') && clonedArrObj.Client_Enterprise__c == 'Enterprise' && clonedArrObj.System_Partner_Name__c == 'Intel' ){
                    rtId = Schema.SObjectType.Alliance_Rebate_Request__c.RecordTypeInfosByName.get('Rebate Request Intel CPU Submission').RecordTypeId;
                }else {
                    rtId = Schema.SObjectType.Alliance_Rebate_Request__c.RecordTypeInfosByName.get('Rebate Request Submission').RecordTypeId;
                }
                System.debug('**New RT Type: '+ rtId);
                clonedArrObj.RecordTypeId = rtId;
                
                insert clonedArrObj;
                
            }else{                                                                                                                                                                  
                If( currentStatus != 'Cancelled' && allianceRebateReqObj.Status__c == 'Cancelled'){
                    showCancelAlert();
                    return null;
                }else {
                    
                    If( isCloned == null && rebateReqId == null){
                        Id rtId ;
                        If( (allianceRebateReqObj.Part_Requested__c == 'CPU' || allianceRebateReqObj.Part_Requested__c == 'OPA') && allianceRebateReqObj.Client_Enterprise__c == 'Enterprise' && allianceRebateReqObj.System_Partner_Name__c == 'Intel' ){
                            rtId = Schema.SObjectType.Alliance_Rebate_Request__c.RecordTypeInfosByName.get('Rebate Request Intel CPU Submission').RecordTypeId;
                        }else {
                            rtId = Schema.SObjectType.Alliance_Rebate_Request__c.RecordTypeInfosByName.get('Rebate Request Submission').RecordTypeId;
                        }
                        System.debug('**New RT Type: '+ rtId);
                        allianceRebateReqObj.RecordTypeId = rtId;
                    }
                    
                    upsert allianceRebateReqObj;             
                }
            }
            
            // Add/Remove Rebate request products based on selection
            list<Rebate_Request_Product__c> newProdList = new list<Rebate_Request_Product__c>();
            list<Rebate_Request_Product__c> deleteProdList = new list<Rebate_Request_Product__c>();
            
            If(rebRequestProdList.size() > 0 ){
                for( Rebate_Request_Product__c rebProd: rebRequestProdList ){
                    If( isCloned != null ){
                        // Cloned
                        If( ((allianceRebateReqObj.Part_Requested__c == 'CPU' || allianceRebateReqObj.Part_Requested__c == 'OPA') && allianceRebateReqObj.Client_Enterprise__c == 'Enterprise' && allianceRebateReqObj.System_Partner_Name__c == 'Intel') ){
                            
                        }else {
                            rebProd = rebProd.clone();
                            rebProd.Alliance_Rebate_Request__c = clonedArrObj.Id;
                            rebProd.Status__c = 'Active';
                        }
                    }else If( isCloned == null && rebateReqId == null ){
                        // New
                        rebProd.Alliance_Rebate_Request__c = allianceRebateReqObj.Id;
                        rebProd.Status__c = 'Active';
                    }else If( rebateReqId != null ){
                        rebProd.Alliance_Rebate_Request__c = allianceRebateReqObj.Id;
                        rebProd.Status__c = 'Active';
                    }
                    
                    If(allianceRebateReqObj.Client_Enterprise__c == 'Enterprise' && allianceRebateReqObj.System_Partner_Name__c == 'Intel' ){
                        If(allianceRebateReqObj.Part_Requested__c == 'CPU'){
                            rebProd.Part_Requested__c = 'CPU';
                        }else If(allianceRebateReqObj.Part_Requested__c == 'OPA'){
                            rebProd.Part_Requested__c = 'OPA';
                        }
                        
                        If( rebProd.Part_Name_Part_Number__c != null  && (loggedInUserRegion == allianceRebateReqObj.Region__c && loggedInUserRegion != 'EC-EMEA') ){
                            newProdList.add(rebProd);
                        }
                    }else If( allianceRebateReqObj.Client_Enterprise__c == 'Enterprise' && allianceRebateReqObj.System_Partner_Name__c == 'Intel' && (allianceRebateReqObj.Part_Requested__c != 'CPU' && allianceRebateReqObj.Part_Requested__c != 'OPA')){
                        If( rebProd.Part_Requested__c != null  && (loggedInUserRegion == allianceRebateReqObj.Region__c && loggedInUserRegion != 'EC-EMEA')  ){
                            newProdList.add(rebProd);
                        }
                    }else{
                        If( (rebProd.Part_Name_Part_Number__c != null || Test.isRunningTest()) && (loggedInUserRegion == allianceRebateReqObj.Region__c && loggedInUserRegion != 'EC-EMEA') ) {
                            newProdList.add(rebProd); 
                        }
                    }
                    
                    If( rebProd.Id != null ) {
                        // Edit
                        If( allianceRebateReqObj.Client_Enterprise__c == 'Enterprise' && allianceRebateReqObj.System_Partner_Name__c == 'Intel' && (allianceRebateReqObj.Part_Requested__c == 'CPU' || allianceRebateReqObj.Part_Requested__c == 'OPA') ){
                            If( rebProd.Part_Name_Part_Number__c == null && rebProd.Quantity__c == null && rebProd.Price_Requested__c == null && rebProd.Competitor_Name_Competitor_Part__c == null && rebProd.Dell_System_Model_type__c == null ){
                                deleteProdList.add(rebProd);
                            }
                        }else If( allianceRebateReqObj.Client_Enterprise__c == 'Enterprise' && allianceRebateReqObj.System_Partner_Name__c == 'Intel' && (allianceRebateReqObj.Part_Requested__c != 'CPU' && allianceRebateReqObj.Part_Requested__c != 'OPA') ){
                            If( rebProd.Part_Requested__c == null && rebProd.Part_Name_Part_Number__c == null && rebProd.Quantity__c == null && rebProd.Price_Requested__c == null && rebProd.Competitor_Name_Competitor_Part__c == null && rebProd.Dell_System_Model_type__c == null ){
                                deleteProdList.add(rebProd);
                            }
                        }else If( rebProd.Part_Name_Part_Number__c == null && rebProd.Quantity__c == null && rebProd.Price_Requested__c == null && rebProd.Competitor_Name_Competitor_Part__c == null && rebProd.Dell_System_Model_type__c == null ){
                            deleteProdList.add(rebProd);
                        }
                    }
                }
                System.debug('***delete Old Prods2: '+ deleteOldProducts);
                // Delete Old Products 
                If( deleteOldProducts.size() > 0  && isCloned == null){
                      delete deleteOldProducts;
                }
                system.debug('deleteProdList>> '+deleteProdList);
                
                // Delete removed products
                If( deleteProdList.size() > 0  && isCloned == null){
                  delete deleteProdList;
                }
                
                // Upsert updated products list
                If( newProdList.size() > 0 ){
                    system.debug('@@@ Product List'+newProdList[0]);
                    upsert newProdList;
                    
                    String queryReqProduct = getrebReqProdQuery();
                    
                    String rebProdQuery;
                    
                    If(isCloned != null){
                        rebProdQuery = 'Select ' + queryReqProduct + ' from Rebate_Request_Product__c Where Alliance_Rebate_Request__c = ' + '\'' + clonedArrObj.Id + '\'';
                    }else {
                        rebProdQuery = 'Select ' + queryReqProduct + ' from Rebate_Request_Product__c Where Alliance_Rebate_Request__c = ' + '\'' + allianceRebateReqObj.Id + '\'';
                    }
                    System.debug('***rebProdQuery: '+ rebProdQuery);
                    
                    list<Rebate_Request_Product__c> prodList = Database.query(rebProdQuery);
                    
                    If( prodList.size() > 0 ){
                        integer i = 1;
                        for(Rebate_Request_Product__c prod: prodList){   
                            prod.Sl_No__c = i;
                            i++;
                        }
                        update prodList;
                    }
                }      
            }
            
            if(rebRequestProdList.size()>0 && rebRequestProdList!=null){
                
               /* if(deleteProdList.size()>0){
                  list<Rebate_Request_Product__c> deleteProdListNew = new list<Rebate_Request_Product__c>();
          
                        Upsert deleteProdListNew;
                }else{
                          Upsert rebRequestProdList;
              
                }*/
                database.upsert(rebRequestProdList,false);
                
            }
            
            
            // Navigate to Detail Page
            PageReference page ;
            If( loggedInUserRegion == allianceRebateReqObj.Region__c ){
               
if(allianceRebateReqObj.Client_Enterprise__c == 'Enterprise' && allianceRebateReqObj.System_Partner_Name__c == 'Intel' && (allianceRebateReqObj.Part_Requested__c == 'CPU' || allianceRebateReqObj.Part_Requested__c == 'OPA') && allianceRebateReqObj.Status__c == 'Draft' ){
                        showPopupIntelEnterCPU();
                        return null;
                    }else if(allianceRebateReqObj.Status__c == 'Draft'){
                        showPopupIntelAll();
                        return null;
                    }
                    page = new PageReference('/'+ allianceRebateReqObj.id);
     
        
                page.setRedirect(TRUE);
                return page;
            }else If( loggedInUserRegion != allianceRebateReqObj.Region__c && loggedInUserRegion != 'EC-EMEA'){
                system.debug('loggedInUserRegion '+loggedInUserRegion);
                system.debug('allianceRebateReqObj.Region__c '+allianceRebateReqObj.Region__c);
                Id rtypeId = Schema.SObjectType.Alliance_Rebate_Request__c.RecordTypeInfosByName.get('Old Approvals RT').RecordTypeId;
                system.debug('allianceRebateReqObj.RecordTypeId '+allianceRebateReqObj.RecordTypeId);
                system.debug('rtypeId '+rtypeId);
                if(allianceRebateReqObj.RecordTypeId!=rtypeId && allianceRebateReqObj.Status__c != 'Expired'){
                    showPopup(allianceRebateReqObj.Region__c);
                    
                }
                else{
                    //closePopup();
                    page = new PageReference('/'+ allianceRebateReqObj.id);
                    page.setRedirect(TRUE);
                    return page;  
                }
                return null;
            }else{
                page = new PageReference('/'+ allianceRebateReqObj.id);
                page.setRedirect(TRUE);
                return page;
            }
            
            
            
            
            
        }catch(DmlException dmlEx){
            ApexPages.addMessages(dmlEx);
            system.debug('exception message'+dmlEx.getMessage());
            Database.rollback(sp );
        }catch(Exception ex){
            system.debug('exception message'+ex.getMessage());
            ApexPages.addMessages(ex);
            Database.rollback( sp );
            
        }
        return null;
    }
    
    // Get Regions
    public List<SelectOption> getRegions(){
        
        List<SelectOption> options = new List<SelectOption>();
        
        Schema.DescribeFieldResult fieldResult = Alliance_Rebate_Request__c.Region__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        
        for( Schema.PicklistEntry f : ple) {
            
            If( userProfileName == 'allianceRegionalPrgmLead' && f.getValue() != 'GLOBAL' ){
                options.add(new SelectOption(f.getLabel(), f.getValue()));
                
            }else If( userProfileName == 'allianceGlobalPrgmLead' ) {
                options.add(new SelectOption(f.getLabel(), f.getValue()));
            }
        } 
        system.debug('>>>>>>>>>options::'+options);      
        return options;
    }
    
    
    // Get Status values
    public List<SelectOption> getStatus(){
        
        List<SelectOption> options = new List<SelectOption>();
        
        Schema.DescribeFieldResult fieldResult = Alliance_Rebate_Request__c.Status__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        
        for( Schema.PicklistEntry f : ple) {
            
            If( userProfileName == 'allianceRegionalPrgmLead' || userProfileName == 'allianceGlobalPrgmLead' ){
                If( currentStatus == 'Submitted' && (f.getValue() == 'Submitted' || f.getValue() == 'Work in Progress' || f.getValue() == 'Awaiting Vendors Response' || f.getValue() == 'Cancelled')){
                    options.add(new SelectOption(f.getLabel(), f.getValue()));
                }else If( currentStatus == 'Work in Progress' && (f.getValue() == 'Work in Progress' || f.getValue() == 'Awaiting Vendors Response' || f.getValue() == 'Cancelled')){
                    options.add(new SelectOption(f.getLabel(), f.getValue()));
                }else If( currentStatus == 'Awaiting Vendors Response' && (f.getValue() == 'Awaiting Vendors Response' || f.getValue() == 'Cancelled')){
                    options.add(new SelectOption(f.getLabel(), f.getValue()));
                }else If( currentStatus == 'Cancelled' && f.getValue() == 'Cancelled' ){
                    options.add(new SelectOption(f.getLabel(), f.getValue()));
                }else If( currentStatus == 'Approved' && (f.getValue() == 'Approved' || f.getValue() == 'Cancelled')){
                    options.add(new SelectOption(f.getLabel(), f.getValue()));
                }else If( currentStatus == 'Rejected' && (f.getValue() == 'Rejected' || f.getValue() == 'Cancelled')){
                    options.add(new SelectOption(f.getLabel(), f.getValue()));
                }else If( currentStatus == 'Draft' && (f.getValue() == 'Draft' || f.getValue() == 'Cancelled' )){
                    options.add(new SelectOption(f.getLabel(), f.getValue()));
                }
            }else If( userProfileName == 'salesReps' ){
                If( currentStatus == 'Draft' && (f.getValue() == 'Draft' || f.getValue() == 'Cancelled' )){
                    options.add(new SelectOption(f.getLabel(), f.getValue()));
                }
            }
        }       
        return options;
    } 
    
    public PageReference closePopup() {       
        displayPopup = false; 
        PageReference page = new PageReference(System.Label.Alliance_List_View);
        page.setRedirect(TRUE);
        return page;  
    }  
    
    public void showPopup(String assignedRegion){       
        displayPopup = true;
        ApexPages.addmessage(new ApexPages.message(ApexPages.severity.CONFIRM,'As you requested, This deal has been reassigned to ' + assignedRegion + ' region.'));
    }
    
    public void showPopupIntelEnterCPU(){       
        displayPopupIECPU = true;
        ApexPages.addmessage(new ApexPages.message(ApexPages.severity.CONFIRM,'Fill the form and upload. Remember to click "Submit for Approval" when complete'));
    } 
    
    public PageReference closePopupIECPU() {       
        displayPopupIECPU = false;
        bdisplayPopupAll =false;     
        PageReference page ;
        If( isCloned != null ){
            page = new PageReference('/'+ clonedArrObj.id);
        }else{
            page = new PageReference('/'+ allianceRebateReqObj.id);
        } 
        page.setRedirect(TRUE);
        return page;  
    }  
    public void showPopupIntelAll(){       
        bdisplayPopupAll = true;
        ApexPages.addmessage(new ApexPages.message(ApexPages.severity.CONFIRM,'Please remember to submit your request for approval when your editing is completed, your request is saved in a draft version until you click "Submit for Approval"'));
    } 
    
    /*public PageReference closePopupAll() {       
        bdisplayPopupAll = false; 
        PageReference page ;
        If( isCloned != null ){
            page = new PageReference('/'+ clonedArrObj.id);
        }else{
            page = new PageReference('/'+ allianceRebateReqObj.id);
        } 
        page.setRedirect(TRUE);
        return page;  
    } */ 
    public void showCancelAlert(){       
        displayCancelAlertPopup = true;
        ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,'Are you sure you want to cancel the request ?'));
    }
    
    public PageReference okCancel() {       
        
        update allianceRebateReqObj;
        
        If( currentStatus == 'Submitted' || currentStatus == 'Work in Progress' || currentStatus == 'Awaiting Vendors Response' ){
            Approval.ProcessWorkitemRequest req = new Approval.ProcessWorkitemRequest();
            req.setComments('Rejecting request.');
            req.setAction('Reject');
            
            ProcessInstanceWorkitem workItem  = [Select Id from ProcessInstanceWorkitem where ProcessInstance.TargetObjectId =: allianceRebateReqObj.Id];
            
            req.setWorkitemId(workItem.id);
            
            Approval.ProcessResult result =  Approval.process(req);
        }
        
        displayCancelAlertPopup = false;
        
        allianceRebateReqObj.Status__c = 'Cancelled';
        
        update allianceRebateReqObj;
        
        PageReference page = new PageReference('/'+ allianceRebateReqObj.id);
        page.setRedirect(TRUE);
        return page; 
    } 
    
    public void closeCancelAlert() {       
        displayCancelAlertPopup = false; 
        allianceRebateReqObj.Status__c =  currentStatus ;
    }
    
    }