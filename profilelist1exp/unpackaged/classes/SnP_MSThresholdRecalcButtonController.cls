public class SnP_MSThresholdRecalcButtonController{
    
    S_P_Vendor_Product_Threshold__c spThreshold; //= [SELECT Level__c, Agreement_Level__c, Product_Description__c, Percentage__c,
                                                   //Minimum_Revenue__c FROM S_P_Vendor_Product_Threshold__c];
    List<String> ListOfIds = new List<String>();
    List<Exception__c> exceptionsList;
    //Exception__c[] exceptionsList;
    List<S_P_Vendor_Additional_Information__c> addlInfoList;
    List<S_P_Vendor_Product_Selection__c> prodSelList;
    //List<S_P_Vendor_Additional_Information__c> addlInfoList = new List<S_P_Vendor_Additional_Information__c>();
    //List<S_P_Vendor_Product_Selection__c> prodSelList = new List<S_P_Vendor_Product_Selection__c>();
    
    //public Boolean noRecMsg {get; set;}
    
    public SnP_MSThresholdRecalcButtonController(ApexPages.StandardController stdController){
        this.spThreshold = (S_P_Vendor_Product_Threshold__c)stdController.getRecord();
        if(this.spThreshold.Level__c == 'EA')
            processEA(this.spThreshold.Agreement_Level__c);
        else
            if(this.spThreshold.Level__c == 'Product')
                processProduct(this.spThreshold.Product_Description__c, this.spThreshold.Product_Family__c);
        
        
    }
    
    public void processEA(String agreementLevel){
        //exceptionsList = queryExceptions(agreementLevel, null);
        exceptionsList = [SELECT Object_ID__c FROM Exception__c WHERE Title__c = :agreementLevel];
        
        for(Exception__c ex : exceptionsList)
            ListOfIds.add(ex.Object_ID__c);
        
        //addlInfoList = queryAddlInfo(ListOfIds);
        addlInfoList = [SELECT Id, Level__c, Total__c, Products_Included__c, SIP_Threshold_Met__c, EA_Fees_Total__c, Recalculated__c 
            FROM S_P_Vendor_Additional_Information__c WHERE Id IN :ListOfIds];
        
        for(S_P_Vendor_Additional_Information__c ea : addlInfoList){
            ea.EA_Fees_Total__c = ea.Total__c * (this.spThreshold.Percentage__c/100);
            ea.Recalculated__c = TRUE;
        }
        
    }
    
    public void processProduct(String productDescription, String productFamily){
        //exceptionsList = queryExceptions(productDescription, productFamily);
        exceptionsList = [SELECT Object_ID__c FROM Exception__c WHERE Title__c = :productDescription OR Title__c = :productFamily];
        
        for(Exception__c ex : exceptionsList)
            ListOfIds.add(ex.Object_ID__c);
        
        addlInfoList = [SELECT Id, Level__c, Total__c, Products_Included__c, SIP_Threshold_Met__c, EA_Fees_Total__c, Recalculated__c 
                        FROM S_P_Vendor_Additional_Information__c WHERE Id IN :ListOfIds];
        prodSelList = [SELECT Id, SIP_Fees__c, Total__c, Recalculated__c FROM S_P_Vendor_Product_Selection__c WHERE Id IN :ListOfIds];
        
        for(S_P_Vendor_Additional_Information__c ea : addlInfoList){
            if(ea.Total__c >= this.spThreshold.Minimum_Revenue__c)
                ea.SIP_Threshold_Met__c = 'Yes';
            else
                ea.SIP_Threshold_Met__c = 'No';    
            
            ea.Recalculated__c = TRUE;
        }
        
        for(S_P_Vendor_Product_Selection__c prod : prodSelList){
            prod.SIP_Fees__c = prod.Total__c * (this.spThreshold.Percentage__c/100);
            prod.Recalculated__c = TRUE;
        }
        
        
    }

    /*public List<Exception__c> queryExceptions(String value1, String value2){
        String exceptionQuery;
        String exceptionStatement1 = value1;
        String exceptionStatement2 = value2;
        
        exceptionQuery = 'SELECT Object_ID__c FROM Exception__c WHERE Title__c = ' + string.escapeSingleQuotes(exceptionStatement1);
        
        if(exceptionStatement2 != null)
            exceptionQuery = exceptionQuery + ' OR Title__c = ' + string.escapeSingleQuotes(exceptionStatement2);
        
        return Database.query(exceptionQuery);
    }
    
    public List<S_P_Vendor_Additional_Information__c> queryAddlInfo(List<String> addlInfoStatement){
        String addlInfoQuery;
        addlInfoQuery = 'SELECT Id, Level__c, Total__c, Products_Included__c, SIP_Threshold_Met__c, EA_Fees_Total__c FROM S_P_Vendor_Additional_Information__c WHERE Id IN :' + addlInfoStatement;
        return Database.query(addlInfoQuery);
    }*/
    
    public pageReference goBack(){
        Pagereference back = new Pagereference('/' + spThreshold.Id);
        back.setRedirect(true);
        
        if (!addlInfoList.isEmpty())
            Database.update(addlInfoList);
        
        if(this.spThreshold.Level__c == 'Product')
            if (!prodSelList.isEmpty())
                Database.update(prodSelList);
        
        if (!exceptionsList.isEmpty()){
            Database.delete(exceptionsList);
            String userId = UserInfo.getUserId();
            User activeUser = [Select Email From User where Id = : userId limit 1];
            String userEmail = activeUser.Email;
            String[] toAddresses = new String[] {userEmail};
            String emailUrl = URL.getSalesforceBaseUrl().toExternalForm() + '/';
            String reportId = [SELECT Id FROM Report WHERE Name = 'S&P Microsoft Recalculation Report' LIMIT 1].Id;
            
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            mail.setToAddresses(toAddresses);
            mail.setSubject('Microsoft Manual Recalculation Complete');
            mail.setPlainTextBody
            ('Manual recalculation has been completed for all the data related to this threshold record: ' 
            + emailURL + this.spThreshold.Id +
            '\nTo view the records processed today, please click the link below:\n'
            + emailURL + reportId +
            //https://cs1.salesforce.com
            //'/00OK0000000FuQr\n\n\nThank you. Please do not reply to this email.');
            '\n\n\nThank you. Please do not reply to this email.');
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
        }
        
        return back;
    }
    
    public Boolean getShowNoRecMsg(){
        if(exceptionsList.isEmpty())
            return true;
        else
            return false;
    }    
}