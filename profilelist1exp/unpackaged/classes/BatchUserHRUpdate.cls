/*
Revision    CR Number   Release No      Date            Modified By     Description
--------    ---------   ----------      -----------     ------------    -----------
2.0         13243       FY17-DCS-0703   15-May-2016     Sarah           Adding "Acquisition Code" field for field extraction and mapping in PeopleSoft User View object
3.0         14468       FY18-DCS-1001   29-May-2017     Krishna         Adding "HR Region" field for field extraction and mapping in PeopleSoft User View object
3.1			14595		FY18-DCS-1001	04-Jul-2017		Gan				Adding "EMC Employee Number" field for field extraction and mapping in PeopleSoft User View object
4.0                     FY19-DCS-0802   02-July-2018    Rahul           Code Reduce!
5.0			16956		FY20-DCS-0202	26-Dec-2018		Gan				Adding "HR_Job_Title__c" field
*/   




global class BatchUserHRUpdate implements Database.Batchable<sObject>, Database.Stateful {
    
    public Boolean isTest = False;
    public String query;
    Public List<Exception__c> listOfException = new List<Exception__c>();
    
    global database.querylocator start(Database.BatchableContext BC){
        return Database.getQueryLocator(query);
    }
    global void execute(Database.BatchableContext BC, List<sObject> scope){
        set<string>  allBadgeidSet = new set<string>();
        Map<string, User> userMap = new Map<string, USer>();
        Map<string, peoplesoft_user_view__c> peopleSoftMap = new Map<string, peoplesoft_user_view__c>();
        peoplesoft_user_view__c peopleSoftRec; 
        List<User> userListToUpdate   = new List<User>();
        
        try{
            for(sObject obj :scope){
                peopleSoftRec = (peoplesoft_user_view__c)obj;
                allBadgeIdSet.add(peopleSoftRec.badge_number__c);
                allBadgeIdSet.add(peopleSoftRec.Direct_Manager_Badge_Number__c);
                peopleSoftMap.put(peopleSoftRec.Badge_Number__c, peopleSoftRec);
            }

            if(allBadgeidSet.Size() > 0){
                For(User userList :[select username,email,id,title,isactive, badge_number__c,Acquisition_Code__c,HR_Region__c,ManagerId,Name,HR_Director_Name__c,HR_Job_Function_Desc__c,HR_Location_City__c,HR_Manager_Badge__c,HR_Manager_Email__c,
                                    EMC_Employee_Number__c //3.1   
                                    from user 
                                    where badge_number__c IN :allBadgeidSet]){//2.0
                    userMap.put(userList.Badge_Number__c, userList);
                }
            }
            
            if(peopleSoftMap.Size() > 0){
                
                for(Peoplesoft_User_view__c ps :peopleSoftMap.Values()){
                   if(userMap.get(ps.Badge_Number__c) != NUll){ 
                    
                            userMap.get(ps.Badge_Number__c).HR_Director_Name__c  = peopleSoftMap.get(ps.Badge_Number__c).HR_Director_Name__c;
                            userMap.get(ps.Badge_Number__c).HR_Job_Function_Desc__c  = peopleSoftMap.get(ps.Badge_Number__c).HR_Job_Function_Desc__c;
                            userMap.get(ps.Badge_Number__c).HR_Location_City__c  = peopleSoftMap.get(ps.Badge_Number__c).HR_Location_City__c;
                            userMap.get(ps.Badge_Number__c).HR_Location_Country_Desc__c  = peopleSoftMap.get(ps.Badge_Number__c).HR_Location_Country_Desc__c;
                            userMap.get(ps.Badge_Number__c).HR_Location_Long_Desc__c  = peopleSoftMap.get(ps.Badge_Number__c).HR_Location_Long_Desc__c;
                            userMap.get(ps.Badge_Number__c).HR_Location_State_Desc__c  = peopleSoftMap.get(ps.Badge_Number__c).HR_Location_State_Desc__c;
                            userMap.get(ps.Badge_Number__c).HR_Manager_Badge__c  = peopleSoftMap.get(ps.Badge_Number__c).HR_Manager_Badge__c;
                            userMap.get(ps.Badge_Number__c).HR_Manager_Email__c  = peopleSoftMap.get(ps.Badge_Number__c).HR_Manager_Email__c;
                            userMap.get(ps.Badge_Number__c).HR_Manager_Name__c  = peopleSoftMap.get(ps.Badge_Number__c).HR_Manager_Name__c;
                            userMap.get(ps.Badge_Number__c).HR_People_Manager__c  = peopleSoftMap.get(ps.Badge_Number__c).HR_People_Manager__c;
                            userMap.get(ps.Badge_Number__c).HR_Sales_Indicator__c  = peopleSoftMap.get(ps.Badge_Number__c).HR_Sales_Indicator__c;
                            userMap.get(ps.Badge_Number__c).HR_Second_Level_Manager_Name__c  = peopleSoftMap.get(ps.Badge_Number__c).HR_Second_Level_Manager_Name__c;
                            userMap.get(ps.Badge_Number__c).HR_Senior_VP_Name__c  = peopleSoftMap.get(ps.Badge_Number__c).HR_Senior_VP_Name__c;
                            userMap.get(ps.Badge_Number__c).HR_Third_Level_Manager_Name__c = peopleSoftMap.get(ps.Badge_Number__c).HR_Third_Level_Manager_Name__c;
                            userMap.get(ps.Badge_Number__c).HR_VP_Name__c  = peopleSoftMap.get(ps.Badge_Number__c).HR_VP_Name__c;
                            userMap.get(ps.Badge_Number__c).Acquisition_Code__c = peopleSoftMap.get(ps.Badge_Number__c).Acquisition_Code__c;//2.0
                            userMap.get(ps.Badge_Number__c).HR_Region__c= peopleSoftMap.get(ps.Badge_Number__c).HR_Region__c;//3.0
                            userMap.get(ps.Badge_Number__c).EMC_Employee_Number__c= peopleSoftMap.get(ps.Badge_Number__c).EMC_Employee_Number__c;//3.1
                       		if(peopleSoftMap.get(ps.Badge_Number__c).Integrated_User__c == 'No') {
                       			userMap.get(ps.Badge_Number__c).Title= (peopleSoftMap.get(ps.Badge_Number__c).HR_Job_Title__c != null && peopleSoftMap.get(ps.Badge_Number__c).HR_Job_Title__c.length() > 80) ? peopleSoftMap.get(ps.Badge_Number__c).HR_Job_Title__c.Left(80) : peopleSoftMap.get(ps.Badge_Number__c).HR_Job_Title__c;//5.0  
                       		}
                            userListToUpdate.add(userMap.get(ps.Badge_Number__c));
                           
                    }
                        
                    }
                }

            if(userListToUpdate.Size() > 0){
                database.SaveResult[] updateResults;
                updateResults = database.update(userListToUpdate, false);

       
                List<String> errorCodeDelList = new List<String>();
                List<String> errorMessageDelList = new List<String>();
                for(integer i = 0; i< updateResults.size();i++){       
                    if(updateResults[i].isSuccess()!=true){
                        Exception__c exceptionVar = new Exception__c();        
                        exceptionVar.Object_type__c = 'User';
                        exceptionVar.Object_ID__c = userListToUpdate[i].Id;
                        exceptionVar.Operation__c = 'Update';
                        exceptionVar .Notes__c = 'Badge Number : '+userListToUpdate[i].Badge_number__c;
                        exceptionVar.Process_Name__c = 'User Manager Update';
                        exceptionVar.Email__c = userListToUpdate[i].Email;
                        
                        Database.Error [] errors = updateResults[i].getErrors();
                        errorCodeDelList.clear();
                        errorMessageDelList.clear();
                        // Cycle through the errors
                        for (Database.Error error :errors){
                            errorCodeDelList.add(''+error.getStatusCode());
                            errorMessageDelList.add(''+error.getMessage());
                        }            
                        exceptionVar.Error_Codes__c = StringUtils.joinStrings (errorCodeDelList, ',');
                        string errMsg = StringUtils.joinStrings (errorMessageDelList, ',');
                        if(errMsg.length() > 255) {                       
                            exceptionVar.Error_Messages__c =  errMsg.SubString(0,254);
                        }
                        else{
                            exceptionVar.Error_Messages__c =  errMsg;
                        }
                        
                        listOfException.add(exceptionVar);  

                    } 
                }
            }
    }
       
       catch (System.DmlException e){
            //system.debug('----Exception Occured--'+e);
            system.debug('Exception-'+e);
       }  
    }
    global void finish(Database.BatchableContext info){  
        if(listOfException.size() > 0 ){
            insert listOfException;
        }
        
    } 
}