/****************************************************************************
R 14.5: User Termination
Ver 1: Batch Apex to Terminate Users
Ver 2: To prevent exception if email contains'.Terminated'
Ver 3: To avaoid exception during duplicate email during termination in case of rehire
Ver 4: To process Chatter user termination first and then take care of Sales user termination CR9406

* Revision CR Number   Release No      Date            Modified By     Description
 * -------- ---------   ----------      -----------     ------------    -----------
 * 1.0
 * 2.0     15073       FY18-DCS-0102   07-Dec-2017     Gan             Modify existing one so we only freeze user and terminate chatter user. 
 * 																	   A flag is updated so that other job pick up the non chatter user 
 * 																	   Fix existing error and also exclude test users from being freeze or terminated
 * 3.0     15736       FY19-DCE-0602   04-May-2018     Gan			   Fix the error where integration user being terminated due to data error
*****************************************************************************/
global class BatchUserTermination implements Database.Batchable<sObject>, Database.Stateful {
    public Boolean isTest = False;
    public String query;
    Public List<Exception__c> listOfException = new List<Exception__c>();
    //Ver4
    public Boolean reschedule;
    public Boolean freezeUser;
    public String nextQuery;
    
    global database.querylocator start(Database.BatchableContext BC){
        system.debug('---11111----'+Database.getQueryLocator(query));
        //DBUtils.flushOutTheJobsQueue();
        return Database.getQueryLocator(query);
    }
    global void execute(Database.BatchableContext BC, List<sObject> scope){
        Id roleId;
        set<string>  badgeidSet = new set<string>();
        set<string> emailIdset = new set<string>();
        set<string> userNameset = new set<string>();
        peoplesoft_user_view__c peopleSoftRec;
        Map<String, peoplesoft_user_view__c> peopleSoftMap =  new Map<String, peoplesoft_user_view__c>();
        //Ver 3
        Map<String, User> userMap =  new Map<String, user>();
        //ver3
        Set<String> emailString = new Set<String>();
        List<User> UserToUpdateList = new List<User>();
        set<string> userIdSet = new set<string>();

        try{
            for(UserRole userRoleList :[select Id 
                                        From UserRole
                                        where Name Like '%INTEGRATION TEMP%']){
                roleId = userRoleList.Id; 
            }
            for(sObject obj :scope){
                peopleSoftRec = (peoplesoft_user_view__c)obj;
                peopleSoftMap.put(peopleSoftRec.Badge_Number__c, peopleSoftRec);
                badgeidSet.add(peopleSoftRec.Badge_Number__c);
            }
                            
            if(badgeidSet.Size() > 0){
                For(User u :[select Badge_Number__c, username,email,id,title,isactive 
                             from user 
                             where badge_number__c in :badgeidSet and IsActive = TRUE
                             //3.0
                             AND License_Used__c in ('Salesforce','Chatter Only')]){
                        emailIdset.add(u.email);
                        //Ver3
                        String uName = u.username+'.terminated';
                        userNameset.add(uName);
                        System.Debug('---userNameset---'+userNameSet);
                        //Ver3
                        if(peopleSoftMap.get(u.Badge_Number__c).Integrated_User__c == 'Yes' &&
                           peopleSoftMap.get(u.Badge_Number__c).Due_to_Deactivate_SFDC_Access__c != NULL &&
                           peopleSoftMap.get(u.Badge_Number__c).Due_to_Deactivate_SFDC_Access__c <= system.Today() ){
                            emailString.add(u.email);
                         }
                         System.Debug('---emailString---'+emailString);
                  }
            }       
            //Ver3
            if(userNameset.size() > 0){
                for(User u :[select License_Used__c, Badge_Number__c,email,
                                 username, Title, userRoleId, IsActive 
                             from user 
                             where username in :userNameset]){
                    userMap.put(u.username, u);
                    
                 }
            }
            //Ver3                      
            if(emailIdset.size() > 0){
                for(User u :[select License_Used__c, Badge_Number__c,email,username, Title, userRoleId, IsActive, Due_to_Deactivate__c, Alias //2.0
                                  from user 
                                  where email in :emailIdset and IsActive = TRUE
                                  //3.0
                             	  AND License_Used__c in ('Salesforce','Chatter Only')]){
                	//2.0
                    if(freezeUser){
                    	System.Debug('------- before set up the date: ' + u.Due_to_Deactivate__c);
                    	if(u.Due_to_Deactivate__c == null){
                        	u.Due_to_Deactivate__c = Date.today();
                    	}
                	}
                    else {
                        //2.0 //3.0
                        if(emailString.contains(u.email)){
                            u.userRoleId = roleId;
                        }
                        String s1 = u.email;
                        String s2 = s1.SubstringafterLast('@');
                        Integer dotCount = s2.countMatches('.');
                        if(Environment.isSandbox() && dotCount >= 2){
                            String s3 = s1.Substringbeforelast('.');
                            u.email = s3 + '.terminated';   
                        }
                        else{
                            //Ver2
                             String s4 = s1.Substringafterlast('.');
                             if(s4.toLowerCase().contains('terminated')){
                                 //string s5 = s1.Substringbeforelast('.');
                                 //u.email = s5 + '.terminated';
                             }
                             else{
                                u.email = u.email + '.terminated';
                             }
                             //Ver2
                        }
                        
                        //Ver3
                        string uName = u.username+'.terminated';
                        if(userMap.size() > 0 && 
                           userMap.get(uName) != NULL ){
                            u.username = u.username +'.'+u.Badge_Number__c+'.terminated';
                        }
                        else{
                            u.username = u.username + '.terminated';
                        }
                                        
                        //Ver3
                        u.isactive = false;
                        u.title = 'Terminated';
                        //2.0
                        u.Due_to_Deactivate__c = null;
                    }  
                    
                    //3.0
                    string strAlias = u.Alias;
                    
                    //2.0 exclude test user //3.0
                    if(!strAlias.equals('x1d3g433')  && !strAlias.startsWith('1nt_')) {                 
                    	UserToUpdateList.add(u); 
                    }
                }
            }
            System.Debug('---UserToUpdateList---'+UserToUpdateList); 
               
            if(UserToUpdateList.Size() > 0){
                //Ver4
                if (freezeUser){
                    for(integer i = 0; i<UserToUpdateList.size(); i++){
                        userIdSet.add(UserToUpdateList[i].Id);      
                    }
                    System.Debug('---userIdSet---'+userIdSet);
                    
                    //update UserLogin object
                    List<UserLogin> foundUserLogins = [SELECT UserId, IsFrozen FROM UserLogin WHERE UserId in :userIdSet];
                    for(UserLogin userLogin: foundUserLogins){
                        if (userLogin.IsFrozen == FALSE){
                            userLogin.IsFrozen = TRUE;
                        }   
                    }                    
                    System.Debug('---foundUserLogins---'+foundUserLogins);
                    update foundUserLogins;
                    
                    //update User object
                    List<User> foundUsers = [SELECT Login_Freezed__c FROM User WHERE Id in :userIdSet];
                    for(User user: foundUsers){
                        if (user.Login_Freezed__c == FALSE){
                            user.Login_Freezed__c = TRUE;
                        }   
                    }
                    System.Debug('---foundUsers---'+foundUsers);
                    update foundUsers;
                }
                
                database.SaveResult[] updateResults;
                GlobalVariables.BYPASS_FUTURE_CALLS = true;
                    
                //ver4
                try{
                    //2.0
                    if (freezeUser){
                        TriggerExecutionController.setSkipUserTriggers(true);
                    }
                	system.debug('----START updating user----');
                    updateResults = database.update(UserToUpdateList, false);
                    system.debug('----END updating user----');      
                }
                catch (Exception ex){
                    system.debug('----Exception Occured--'+ex);
                }
                finally{
                    //2.0
                    if (freezeUser){
                        TriggerExecutionController.setSkipUserTriggers(false);
                    }
                    GlobalVariables.BYPASS_FUTURE_CALLS = false;
                    
                    List<String> errorCodeDelList = new List<String>();
                    List<String> errorMessageDelList = new List<String>();
                    
                    for(integer i = 0; i< updateResults.size();i++){       
                        if(updateResults[i].isSuccess()!=true){
                            Exception__c exceptionVar = new Exception__c();        
                            exceptionVar.Object_type__c = 'User';
                            exceptionVar.Object_ID__c = UserToUpdateList[i].Id;
                            exceptionVar.Operation__c = 'Update';
                            exceptionVar.Notes__c = 'Badge Number : '+UserToUpdateList[i].Badge_number__c;
                            exceptionVar.Process_Name__c = 'User Termination';
                            exceptionVar.Email__c = UserToUpdateList[i].Email;
                            
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
                            }listOfException.add(exceptionVar);  
                            system.debug('-----listOfException----'+listOfException);
                        } 
                    }   
                }    
            }
       }
       catch (System.DmlException e){
           system.debug('----Exception Occured--'+e);
          
       }         
    }
    global void finish(Database.BatchableContext info){  
        if(listOfException.size() > 0 ){
                  insert listOfException;
        }
        
        //Ver4
        if (reschedule){
            //datetime systime = system.today();
            datetime systime = system.now();
            integer dueHours = integer.ValueOf(System.Label.userTerminationLabel);
            system.debug('----1111111111----: systime---'+systime);
            
            //please Specify the time delay in minutes between User termination 
            //and User manager update in the custom label userTerminationLabel
            String seconds, minutes, hours, dayOfMonth, month, dayOfWeek, year;
            datetime TodayPlusSec = systime.addMinutes(dueHours); 
            seconds = string.valueOf(TodayPlusSec.second());
            minutes = string.valueOf(TodayPlusSec.minute()); 
            hours = string.valueOf(TodayPlusSec.hour());      
            dayOfMonth = string.valueOf(TodayPlusSec.day());
            month = string.valueOf(TodayPlusSec.month());
            dayOfWeek = '?';
            year = string.valueOf(TodayPlusSec.year()); 
            String schTime = seconds + ' ' + minutes + ' ' + hours + ' ' + dayOfMonth + ' ' + month + ' ' + dayOfWeek + ' ' + year;
            system.debug('----44444444444444----: TodayPlusSec---'+TodayPlusSec);
            system.debug('----33333333333333----: schTime---'+schTime);
            
            systime = systime.addHours(dueHours);
            system.debug('----22222222222----: dueHours---'+dueHours);
            system.debug('----33333333333333----: systime---'+systime);
            
            BatchUserTerminationScheduler u = new BatchUserTerminationScheduler();
            if (reschedule && freezeUser){
                //2.0 stop the reschedule
                u.reschedule = false;
            }
            if (reschedule && !freezeUser){
                u.reschedule = false;
            }
            u.freezeUser = false;
            u.sql = nextQuery;          
            system.debug('----55555555555555----: nextQuery---' + nextQuery);
            system.schedule('BatchUserTermination' + string.valueof(systime), schTime, u); //reschedule UserTermination job to run next query
        }
    } 
}