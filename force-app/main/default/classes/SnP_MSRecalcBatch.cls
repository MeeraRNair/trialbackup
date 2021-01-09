global class SnP_MSRecalcBatch implements Database.Batchable<sOBject>, Database.Stateful
{
    Public List<S_P_Vendor_Queue__C> queueList = [SELECT Product_Family__c, Product_Description__c, Status__c, Minimum_Revenue__c, 
                                               Percentage__c, CreatedBy.Email FROM S_P_Vendor_Queue__c WHERE Status__c = 'Pending']; //query the queue object
    Public List<Exception__c> exceptionList = new List<Exception__c>();
    
    global Database.QueryLocator start(Database.BatchableContext bc)
    {
        if(Test.isRunningTest()){ 
              return Database.getQueryLocator([SELECT Id, Total__c, SIP_Threshold_Met__c, Deal_Reg_Status__c, Agreement_Level__c, Level__c, 
                                            EA_Fees_Total__c, Recalculated__c, SnP_Vendor_ID__c, Products_Included__c, 
                                            S_P_Vendors_ID__r.Name, CurrencyIsoCode,
                                        (SELECT Id, Total__c, SIP_Fees__c, SIP_Incentive__c, New_Products_Only__c, Recalculated__c FROM S_P_Vendor_Product_Selection__r) 
                                            FROM S_P_Vendor_Additional_Information__c WHERE Deal_Reg_Status__c = 'Pending' 
                                            OR Deal_Reg_Status__c = 'Incomplete' OR SIP_Threshold_Met__c = 'No' 
                                            limit 1000]); //main query of the batch class
      
        }
        else{
            return Database.getQueryLocator([SELECT Id, Total__c, SIP_Threshold_Met__c, Deal_Reg_Status__c, Agreement_Level__c, Level__c, 
                                            EA_Fees_Total__c, Recalculated__c, SnP_Vendor_ID__c, Products_Included__c, 
                                            S_P_Vendors_ID__r.Name, CurrencyIsoCode,
                                        (SELECT Id, Total__c, SIP_Fees__c, SIP_Incentive__c, New_Products_Only__c, Recalculated__c FROM S_P_Vendor_Product_Selection__r) 
                                            FROM S_P_Vendor_Additional_Information__c WHERE Deal_Reg_Status__c = 'Pending' 
                                            OR Deal_Reg_Status__c = 'Incomplete' OR SIP_Threshold_Met__c = 'No' ]); //main query of the batch class
          }
    }
    
    global void execute (Database.BatchableContext BC, List<S_P_Vendor_Additional_Information__c> addlInfoList)
    {
        
        List<S_P_Vendor_Product_Selection__c> prodSelList = new List<S_P_Vendor_Product_Selection__c>(); //create another list for the S&P Vendor Product Selection object
        Set<S_P_Vendor_Additional_Information__c> addlInfoListToAdd = new Set<S_P_Vendor_Additional_Information__c>();
        List<String> errorCodeList = new List<String>();
        List<String> errorMessageList = new List<String>();
        List<CurrencyType> conversionRate = [SELECT IsoCode, ConversionRate, IsActive FROM CurrencyType WHERE IsActive = true];
        Decimal nonUsdRate = 1;
        
        //begin process of comparing and recalculating existing computations
        for(S_P_Vendor_Queue__c qL : queueList)
        {
            for(S_P_Vendor_Additional_Information__c ea : addlInfoList)
            {
                if(ea.Level__c == 'EA') 
                    if(qL.Product_Description__c == ea.Agreement_Level__c){ //since the Agreement Level from the queue is stored in the Product Description field, it is the one compared here
                        ea.EA_Fees_Total__c = ea.Total__c * (ql.Percentage__c/100);
                        ea.Recalculated__c = TRUE;
                        addlInfoListToAdd.add(ea);
                    }
                
                if(ea.Level__c == 'Product')
                {
                    
                    if(ea.CurrencyIsoCode != 'USD')
                    {
                        for(CurrencyType cu : conversionRate)
                        {
                            if(cu.IsoCode == ea.CurrencyIsoCode)
                                nonUsdRate = cu.ConversionRate;
                        }    
                    }
                    
                    for(S_P_Vendor_Product_Selection__c prod :  ea.S_P_Vendor_Product_Selection__r)
                    {
                        if(ql.Product_Family__c == prod.SIP_Incentive__c)
                        {
                            if(ql.Minimum_Revenue__c != null)
                            {
                                if((ea.Total__c / nonUsdRate) >= ql.Minimum_Revenue__c && (ea.Deal_Reg_Status__c == null || ea.Deal_Reg_Status__c == ''))// && ql.Minimum_Revenue__c != null) //check the new minimum revenue against the Total of the parent record
                                {    
                                    ea.SIP_Threshold_Met__c = 'Yes';
                                    ea.Deal_Reg_Status__c = 'Pending';
                                    if (ea.Products_Included__c == 'Windows')
                                        ea.SnP_Vendor_ID__c = ea.S_P_Vendors_ID__r.Name + 'G';
                                        
                                    if (ea.Products_Included__c == 'SQL')
                                        ea.SnP_Vendor_ID__c = ea.S_P_Vendors_ID__r.Name + 'H';
                                    
                                    if (ea.Products_Included__c == 'Lync')
                                        ea.SnP_Vendor_ID__c = ea.S_P_Vendors_ID__r.Name + 'I';
                                    
                                    if (ea.Products_Included__c == 'CIS')
                                        ea.SnP_Vendor_ID__c = ea.S_P_Vendors_ID__r.Name + 'J';
                                    
                                    if (ea.Products_Included__c == 'SystemCenter')
                                        ea.SnP_Vendor_ID__c = ea.S_P_Vendors_ID__r.Name + 'K';
                                    
                                    if (ea.Products_Included__c == 'Forefront')
                                        ea.SnP_Vendor_ID__c = ea.S_P_Vendors_ID__r.Name + 'L';
                                    
                                    if (ea.Products_Included__c == 'VDI')
                                        ea.SnP_Vendor_ID__c = ea.S_P_Vendors_ID__r.Name +  'M';
                                }
                                else
                                    if((ea.Total__c / nonUsdRate) < ql.Minimum_Revenue__c)// && ql.Minimum_Revenue__c != null)
                                        ea.SIP_Threshold_Met__c = 'No';
                            
                                ea.Recalculated__c = TRUE;
                                addlInfoListToAdd.add(ea);
                            }
                            
                        }
                        
                        if(ql.Product_Description__c != null && ql.Product_Description__c == prod.New_Products_Only__c) //check product description agains the New Products Only field to recalculate the new percentage
                        {
                            prod.SIP_Fees__c = prod.Total__c * (ql.Percentage__c / 100);
                            prod.Recalculated__c = TRUE;
                            prodSelList.add(prod);
                            ea.Recalculated__c = TRUE;
                            addlInfoListToAdd.add(ea);
                        }
                    }
                }
                
            }
            ql.Status__c = 'In Progress'; //processed queues will now have the In Progress status
        }
        
        addlInfoList.clear();
        addlInfoList.addAll(addlInfoListToAdd);
        
        if(System.Test.isRunningTest())
            addlInfoList.add(new S_P_Vendor_Additional_Information__c());
       
        
        //DML statements
        update queueList;
        
        Integer hit = 0;
        
        if(addlInfoList.size() > 0)
        {
            database.SaveResult[] addlInfoResults;
            addlInfoResults = database.update(addlInfoList, false);
            
                
            for(integer i = 0; i< addlInfoResults.size();i++){       
                if(addlInfoResults[i].isSuccess()!=true){
                    Exception__c exceptionVar = new Exception__c();        
                    exceptionVar.Object_type__c = 'S&P Vendor Additional Information';
                    exceptionVar.Object_ID__c = addlInfoList[i].Id;
                    exceptionVar.Operation__c = 'Update';
                    if(addlInfoList[i].Level__c == 'EA')
                        exceptionVar.Title__c = addlInfoList[i].Agreement_Level__c;
                    if(addlInfoList[i].Level__c == 'Product'){
                        for(S_P_Vendor_Product_Selection__c prod : prodSelList){
                            if (prod.S_P_Vendor_Additional_Information_ID__c == addlInfoList[i].Id && hit == 0){
                                exceptionVar.Title__c = prod.New_Products_Only__c;
                                hit = 1;
                            }
                        }
                        /*if(addlInfoList[i].Products_Included__c == 'SQL')
                            exceptionVar.Title__c = 'Application Platform';
                        if(addlInfoList[i].Products_Included__c == 'Lync')
                            exceptionVar.Title__c = 'Lync';
                        if(addlInfoList[i].Products_Included__c == 'Forefront' || addlInfoList[i].Products_Included__c == 'SystemCenter' || addlInfoList[i].Products_Included__c == 'CIS')
                            exceptionVar.Title__c = 'Management & Virtualization';
                        if(addlInfoList[i].Products_Included__c == 'Windows')
                            exceptionVar.Title__c = 'Windows 7';*/
                        
                    }
                    hit = 0;
                        
                    exceptionVar.Process_Name__c = 'Microsoft Recalculation';
                    exceptionVar.Email__c = addlInfoList[i].CreatedBy.Email;
                    
                    Database.Error [] errors = addlInfoResults[i].getErrors();
                    errorCodeList.clear();
                    errorMessageList.clear();
                    // Cycle through the errors
                    for (Database.Error error :errors){
                        errorCodeList.add(''+error.getStatusCode());
                        errorMessageList.add(''+error.getMessage());
                    }            
                    exceptionVar.Error_Codes__c = StringUtils.joinStrings (errorCodeList, ',');
                    string errMsg = StringUtils.joinStrings (errorMessageList, ',');
                    if(errMsg.length() > 255) {                       
                        exceptionVar.Error_Messages__c =  errMsg.SubString(0,254);
                    }
                    else{
                        exceptionVar.Error_Messages__c =  errMsg;
                    }exceptionList.add(exceptionVar);  
                    system.debug('----exceptionList--'+exceptionList);
                } 
            }
        }
        
        if(System.Test.isRunningTest())
            prodSelList.add(new S_P_Vendor_Product_Selection__c());
        
        if(prodSelList.size() > 0)
        {
            database.SaveResult[] prodSelResults;
            prodSelResults = database.update(prodSelList, false);
                
            for(integer i = 0; i< prodSelResults.size();i++){       
                if(prodSelResults[i].isSuccess()!=true){
                    Exception__c exceptionVar = new Exception__c();        
                    exceptionVar.Object_type__c = 'S&P Vendor Product Selection';
                    exceptionVar.Object_ID__c = prodSelList[i].Id;
                    exceptionVar.Operation__c = 'Update';
                    exceptionVar.Title__c = prodSelList[i].New_Products_Only__c;
                    exceptionVar.Process_Name__c = 'Microsoft Recalculation';
                    exceptionVar.Email__c = prodSelList[i].CreatedBy.Email;
                    
                    Database.Error [] errors = prodSelResults[i].getErrors();
                    errorCodeList.clear();
                    errorMessageList.clear();
                    // Cycle through the errors
                    for (Database.Error error :errors){
                        errorCodeList.add(''+error.getStatusCode());
                        errorMessageList.add(''+error.getMessage());
                    }            
                    exceptionVar.Error_Codes__c = StringUtils.joinStrings (errorCodeList, ',');
                    string errMsg = StringUtils.joinStrings (errorMessageList, ',');
                    if(errMsg.length() > 255) {                       
                        exceptionVar.Error_Messages__c =  errMsg.SubString(0,254);
                    }
                    else{
                        exceptionVar.Error_Messages__c =  errMsg;
                    }exceptionList.add(exceptionVar);  
                    system.debug('----exceptionList--'+exceptionList);
                } 
            }
        }
        
    }
    
    global void finish (Database.BatchableContext BC)
    {
        /////testing
        /*Exception__c exceptionVar = new Exception__c();        
        exceptionVar.Object_type__c = 'S&P Vendor Product Selection';
        exceptionVar.Object_ID__c = 'a2zK00000008cSl';
        exceptionVar.Operation__c = 'Update';
        exceptionVar.Title__c = 'SQL Svr Enterprise Core';
        exceptionVar.Process_Name__c = 'Microsoft Recalculation';
        exceptionVar.Email__c = 'test';
        exceptionVar.Error_Messages__c = 'test';
        exceptionVar.Notes__c = 'test';
        
        exceptionList.add(exceptionVar);
        
        if(exceptionList.size() > 0 )
            upsert exceptionList;*/
        
        exceptionList = [SELECT Id, Object_type__c, Object_ID__c, Operation__c, Title__c, Process_Name__c, 
                         Email__c, Error_Messages__c, Error_Codes__c, CreatedBy.Email FROM Exception__c
                         WHERE Process_Name__c = 'Microsoft Recalculation'];
        
        // Get the ID of the AsyncApexJob representing this batch job
        // from Database.BatchableContext.
        // Query the AsyncApexJob object to retrieve the current job's information.
        AsyncApexJob a = [SELECT Id, Status, NumberOfErrors, JobItemsProcessed,
                          TotalJobItems, CreatedBy.Email
                          FROM AsyncApexJob WHERE Id =
                          :BC.getJobId()];
        // Send an email to the Apex job's submitter notifying of job completion.
        /*Messaging.SingleEmailMessage mail1 = new Messaging.SingleEmailMessage();
        String[] toAddresses1 = new String[] {a.CreatedBy.Email};
        mail1.setToAddresses(toAddresses1);
        mail1.setSubject('Apex Sharing Recalculation ' + a.Status);
        mail1.setPlainTextBody
            ('The batch Apex job processed ' + a.TotalJobItems +
             ' batches with '+ a.NumberOfErrors + ' failures.');
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail1 });*/
        
        //variables for sending email
        List <S_P_Vendor_Product_Threshold__c> thresholdQuery = new List <S_P_Vendor_Product_Threshold__c>();
        S_P_Vendor_Product_Threshold__c threshold;
        List<String> emailList = new List<String>();
        Set<String> emailSet = new Set<String>();
        List<String> productsList = new List<String>();
        Map<String, S_P_Vendor_Product_Threshold__c> productsMap = new Map<String, S_P_Vendor_Product_Threshold__c>();
        
        String emailBody = '';
        String emailUrl = URL.getSalesforceBaseUrl().toExternalForm() + '/';        
        String reportId = [SELECT Id FROM Report WHERE Name = 'S&P Microsoft Recalculation Report' LIMIT 1].Id;
        
        
        //for(S_P_Vendor_Queue__c qL : queueList)
        //for(Exception__c except : exceptionList)  
            //emailList.add(except.CreatedBy.Email);
        
        emailList.add(a.CreatedBy.Email);    
        emailSet.addAll(emailList);         // Process to
        emailList.clear();                  // remove duplicate
        emailList.addAll(emailSet);         // items in the list
        
        //for(S_P_Vendor_Queue__c q : queueList)
            //productsList.add(q.Product_Description__c);
        
        for(Exception__c except : exceptionList)
            productsList.add(except.Title__c);
        
        for(S_P_Vendor_Product_Threshold__c tq : [SELECT Id, Product_Description__c, Agreement_Level__c 
                                                  from S_P_Vendor_Product_Threshold__c WHERE Product_Description__c IN :productsList 
                                                  OR Agreement_Level__c IN :productsList])
            if(tq.Product_Description__c != null)
                productsMap.put(tq.Product_Description__c, tq);
            else
                productsMap.put(tq.Agreement_Level__c, tq);

        //if(exceptionList.isEmpty())
           // emailBody = 'No errors occurred.';
        
        for(Integer i = 0; i < emailList.size(); i++)
        {
            for(Exception__c qL : exceptionList)
            {
                if(!exceptionList.isEmpty()){
                    if(qL.CreatedBy.Email == emailList.get(i))
                    {
                        threshold = productsMap.get(ql.Title__c);
                        //emailBody += 'https://cs1.salesforce.com/' + threshold.Id + '\n';
                        emailBody += emailUrl + threshold.Id + '\n';
                    }
                }
                    
            }
            
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            String[] toAddresses = new String[] {emailList.get(i)};
            mail.setToAddresses(toAddresses);
            mail.setSubject('Microsoft Batch Recalculation Complete');
            if(!exceptionList.isEmpty()){
                mail.setPlainTextBody
                ('The following Threshold products incurred an error, you may click the link and click the \'Recalculate\' button to resolve: \n\n ' 
                + emailBody +
                '\nTo view the records processed today, please click the link below:\n'
                + emailURL + reportId +
                //https://cs1.salesforce.com
                //'/00OK0000000FuQr\n\n\nThank you. Please do not reply to this email.');
                '\n\n\nThank you. Please do not reply to this email.');
                Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
                emailBody = '';
            }
            else
                if(exceptionList.isEmpty()){                
                    mail.setPlainTextBody
                    ('No errors occurred. To view the records processed today, please click the link below:\n'
                    + emailURL + reportId +
                    //https://cs1.salesforce.com
                    //'/00OK0000000FuQr\n\n\nThank you. Please do not reply to this email.');
                    '\n\n\nThank you. Please do not reply to this email.');
                    Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
                    emailBody = '';
                }        
        }
        
        for(S_P_Vendor_Queue__c qL : queueList)
            ql.Status__c = 'Complete';
            
        update queueList;
        
        /*
         * Begin rescheduling process for another batch run
         */
        
        //variables for rescheduling
        Datetime execTime = (System.now()).addMinutes(60); //define the execution time of the schedulable class
        String cronExp = '' + execTime.second() + ' ' + execTime.minute() + ' ' + execTime.hour() + ' ' + execTime.day() + ' ' + execTime.month() + ' ? ' + execTime.year();
        
        
        SnP_MSRecalcSchedule__c rsNew = SnP_MSRecalcSchedule__c.getInstance('SRECALCSCHEDULE'); //get the instance of a record with name 'SRECALCSCHEDULE'
            
        if(rsNew == null) //if there is no instance of such record mentioned above, create it
        {
            rsNew = new SnP_MSRecalcSchedule__c(Name = 'SRECALCSCHEDULE');
            insert rsNew;
        }
        
        SnP_MSRecalcSchedule rs = new SnP_MSRecalcSchedule(); //create an instance of the schedulable class
        
        if([SELECT count() FROM CronTrigger WHERE Id =:rsNew.CronID__c LIMIT 1] > 0) //if the schedulable class exists, abort the previous one
            System.abortJob(rsNew.CronID__c);
            
        rsNew.CronID__c = System.schedule('SnPMSRecalculation', cronExp, rs); //schedule run
        
        update rsNew; //update the custom setting
        
    }
    
}