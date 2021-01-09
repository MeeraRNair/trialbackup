global class Batch_DeactivateInvalid_EndCustomers implements Database.Batchable < sObject > {

        String BatchCreatedDate = System.Label.Batch_Created_Date; //LAST_N_DAYS:30
        String BatchStageNameLost = System.Label.Batch_StageName_Lost; // Lost, Cancelled - 0%
        String BatchStageNameWin = System.Label.Batch_StageName_Win; // Win - 100%
        String BatchStageChangedOn = System.Label.Batch_Stage_Changed_On; //LAST_N_DAYS:1095
        Integer queryLimitVar = Integer.ValueOf(System.Label.Query_Limit);
        //Integer BatchCreatedDateDays = Integer.ValueOf(System.Label.Batch_Created_Date_Days); //-30
        //Integer BatchStageChangedOn = System.Label.Batch_Stage_Changed_On; //-1095
    
       // global final String Query;
        global final String finalEndCustmrWithOpp;
        set < id > endCustomerIds = new set < id > ();
        List < End_Customer__c > endCustomerList = new List < End_Customer__c > ();

        //Start 
        global Database.QueryLocator start(Database.BatchableContext BC) {

            //Query1: End Customer created without a deal reg && End Customer created with deal reg but deal reg is not submitted for approval
            string endCustmrWithoutOpp = 'SELECT id,name,status__c,CreatedDate, (SELECT id, StageName,Deal_Registration_Status__c,Stage_Changed_On__c FROM opportunities__r Limit 1) FROM End_Customer__c WHERE status__c = ' + '\'' + 'Active' + '\' AND CreatedDate < '+ BatchCreatedDate +' AND Source_System__c = ' + '\'' + 'Deal Registration'  + '\' Limit ' + queryLimitVar;
            
            system.debug('@@@@@endCustmrWithoutOpp:'+endCustmrWithoutOpp);
            for (End_Customer__c endcust: database.query(endCustmrWithoutOpp)) {
                if(endcust.opportunities__r.size() < 1){
                    endCustomerIds.add(endCust.Id);
                } 
            }
            
            //Query2: End Customer created without a deal reg && End Customer created with deal reg but deal reg is not submitted for approval
            string endCustmrWithNewOpp = 'SELECT id,name,status__c,CreatedDate, (SELECT id, StageName,Deal_Registration_Status__c,Stage_Changed_On__c FROM opportunities__r Where Deal_Registration_Status__c != ' + '\'' + 'New' + '\' Limit 1) FROM End_Customer__c WHERE status__c = ' + '\'' + 'Active' + '\' AND CreatedDate < '+ BatchCreatedDate +' AND Source_System__c = ' + '\'' + 'Deal Registration'  + '\' Limit ' + queryLimitVar;
            
            system.debug('@@@@@endCustmrWithNewOpp:'+endCustmrWithNewOpp);
            for (End_Customer__c endcust: database.query(endCustmrWithNewOpp)) {
                if(endcust.opportunities__r.size() < 1){
                    endCustomerIds.add(endCust.Id);
                } 
            }
            
            //Query3:Most recent opportunities tied to the end customer if Won/Lost-Cancelled is more than 3 years ago.
            String endCustmrWithOpp = 'SELECT id,name,status__c,CreatedDate, (SELECT id, End_Customer__c,End_Customer__r.CreatedDate, StageName,Deal_Registration_Status__c,Stage_Changed_On__c FROM opportunities__r WHERE (StageName = ' + '\'' + 'Lost, Cancelled - 0%' + '\'' + ' OR StageName =' + '\'' + 'Win - 100%' + '\'' + ' ) AND Stage_Changed_On__c <' + BatchStageChangedOn + ' ORDER BY LastModifiedDate DESC Limit 1) FROM End_Customer__c where status__c = ' + '\'' + 'Active' + '\' Limit '+ queryLimitVar;
            system.debug('@@Query2:'+endCustmrWithOpp);           
            for (End_Customer__c endcustWithOpp: database.query(endCustmrWithOpp)) {
                endCustomerIds.add(endcustWithOpp.Id);
            }
            // ((opp.StageName == BatchStageNameLost || opp.StageName == BatchStageNameWin) && opp.Stage_Changed_On__c < system.today().adddays(BatchStageChangedOn))
            String finalEndCustmrWithOpp = 'SELECT id,name,status__c,CreatedDate, (SELECT id,End_Customer__c,End_Customer__r.CreatedDate, StageName,Deal_Registration_Status__c,Stage_Changed_On__c FROM opportunities__r ORDER BY LastModifiedDate DESC Limit 1) FROM End_Customer__c where status__c = ' + '\'' + 'Active' + '\' AND Id IN: endCustomerIds  Limit '+ queryLimitVar;
            system.debug('@@@@@finalEndCustmrWithOpp:'+finalEndCustmrWithOpp);
            return Database.getQueryLocator(finalEndCustmrWithOpp);
        }

        //Execute    
        global void execute(Database.BatchableContext BC, List < sObject > scope) {
            try {
                system.debug('@@@@ScopeSize:'+scope.size());
                for (sobject s: scope) {
                    End_Customer__c endCustObj = (End_Customer__c) s;
                    endCustomerList.add(endCustObj);
                    /* 1 Condition
                    //if (endCustObj.opportunities__r.size() == 0 && endCustObj.CreatedDate < system.today().adddays(BatchCreatedDateDays)) {
                        endCustomerList.add(endCustObj);
                   // }

                    //2nd Condition && 3rd Condition
                    else {
                        /*for (opportunity opp: endCustObj.opportunities__r) {
                            if ((opp.Deal_Registration_Status__c == 'New' && opp.End_Customer__c != NULL && opp.End_Customer__r.CreatedDate < system.today().adddays(BatchCreatedDateDays)) || ((opp.StageName == BatchStageNameLost || opp.StageName == BatchStageNameWin) && opp.Stage_Changed_On__c < system.today().adddays(BatchStageChangedOn))) {
                                endCustomerList.add(endCustObj);
                            }
                        }
                    }*/
                }
                    system.debug('@@@endCustomerList:'+endCustomerList.size()); 
                
                //Update Invalid End Customers   
                List < Database.SaveResult > endCustomerUpdateList = new List < Database.SaveResult >();     
                if (endCustomerList.size() > 0) {
                    for (End_Customer__c endCust: endCustomerList) {
                        endCust.Status__c = 'Inactive';
                    }                
                    endCustomerUpdateList = Database.Update(endCustomerList, false);
                }
                system.debug('@@@@{{{}}}}endCustomerUpdateListSize:'+endCustomerUpdateList.size());
                // Error handling of Failure End Customers
                List< End_Customer__c > UpdateEndCustErrorDescList = new List < End_Customer__c >();
                If(endCustomerUpdateList.size() > 0){
                for (Database.SaveResult endCustomer: endCustomerUpdateList) {
                    if (endCustomer.isSuccess()) {
                        
                        // Operation was successful, so get the ID of the record that was processed
                        System.debug('Successfully inserted account. Account ID: ' + endCustomer.getId());
                        
                        End_Customer__c updateEndCust = new End_Customer__c(id=endCustomer.getID(),IsInactivateBatchClassError__c='');
                        UpdateEndCustErrorDescList.add(updateEndCust);
                        
                    } else {
                        
                        // Operation failed, so get all errors                
                        for(Database.Error err : endCustomer.getErrors()) {
                            
                            String errorDescription = err.getStatusCode() + ': ' + err.getMessage();
                            End_Customer__c updateEndCust = new End_Customer__c(id=endCustomer.getID(),IsInactivateBatchClassError__c=errorDescription);
                            UpdateEndCustErrorDescList.add(updateEndCust);
                            
                            System.debug('The following error has occurred.');                    
                            System.debug(err.getStatusCode() + ': ' + err.getMessage());
                            System.debug('Account fields that affected this error: ' + err.getFields());
                        }
                        
                    }
                }
                }
                // Update End Customer's Error Message.
                system.debug('@@UpdateEndCustErrorDescListSize' + UpdateEndCustErrorDescList.size());
                
                If(UpdateEndCustErrorDescList.size() > 0){
                    Database.update(UpdateEndCustErrorDescList);
                }
                
            } catch (exception ex) {
                system.debug('***Exception: ' + ex.getMessage() + ' at line# ' + ex.getLineNumber());
            }
        }

        global void finish(Database.BatchableContext BC) {}
    }