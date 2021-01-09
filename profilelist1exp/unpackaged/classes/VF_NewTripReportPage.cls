/***************************************************************************************************

Author      : Devika Pujari
Description : Page available to create a Trip Report from Event/AccountPlan/Strategy/Opportunity.

Revision    Name                Date            Description
------------------------------------------------------------
1.0         Devika              18.12.2013      CR 8974/8978
2.0         Sree Prakash        10/09/2014      CR 9555
3.0         Krishnakumar        19/Sep/2016     Update Trip Report Functionality - From Contact page.
4.0         Sriram              08-Jun-2017     CR 14401 - Non SSO Profile Clean Up 
***************************************************************************************************/
public class VF_NewTripReportPage {

    public CustomerInteraction__c tripRecord {get; set;}
    public String selectedObject             {get; set;}
    public Boolean errorFlag                 {get; set;}
    public Boolean editFlag                  {get; set;}
    String retUrl;
    Boolean cloneFlag;
    public String AcName {get; set;} //CR 9555
    public Id existingTripRecordAccount {get;set;}
    
    public VF_NewTripReportPage(ApexPages.StandardController controller) {

      cloneFlag = false;

      retUrl = ApexPages.currentPage().getParameters().get('retURL'); 
      system.debug('***return URL---'+retUrl);
      if(retUrl != null && retUrl.contains('?')){        
        List<String> retUrlList = retUrl.split('\\?');          
        retUrl = retUrlList[0];
      }
      
      Set<string> eventType = new Set<String>{'Cust Conf Call/Live Meeting', 
                                             'Customer Visit' ,
                                             'Event with Customers', 
                                             'Internal Conf Call/Live Meeting',
                                             'Internal Meeting' ,
                                             'Internal Training' ,
                                             'Meeting (at Dell Site)',
                                             'Call' ,
                                             'Internal', 
                                             'Other'};  
      if (!Schema.sObjectType.CustomerInteraction__c.isCreateable()){
        errorFlag = true;
            
      }else{        

        /****** Edit/Clone Trip Report *******/
        //CR 9555 - Added few fields to the query
        
        if(ApexPages.currentPage().getParameters().get('Id') != null){
          tripRecord = [Select Account__c, Action__c, Action_Items__c, Competition_Discussed__c, Customer_Attendee1__c, Customer_Attendee1_DMR1__c, 
                        Customer_Attendee1_Title__c, Customer_Attendee2__c, Customer_Attendee2_DMR2__c, Customer_Attendee2_Title__c, Customer_Attendee3__c, 
                        Customer_Attendee3_DMR3__c, Customer_Attendee3_Title__c, Customer_Attendee4__c, Customer_Attendee4_DMR4__c, Customer_Attendee4_Title__c, 
                        Customer_Attendee5__c, Customer_Attendee5_DMR5__c, Customer_Attendee5_Title__c, Customer_Attendee6__c, Customer_Attendee6_DMR6__c, 
                        Customer_Attendee6_Title__c, Customer_Attendee7__c, Customer_Attendee7_DMR7__c, Customer_Attendee7_Title__c, Customer_Attendee8__c, 
                        Customer_Attendee8_DMR8__c, Customer_Attendee8_Title__c, Customer_Attendees__c, Date__c, Email_1__c, Email_10__c, Email_2__c, Email_3__c, 
                        Email_4__c, Email_5__c, Email_6__c, Email_7__c, Email_8__c, Email_9__c, Goal_Objective__c, LOB_s_Discussed__c, Location__c, Next_Steps__c, 
                        Other_Dell_Attendee1__c, Other_Dell_Attendee2__c, Other_Dell_Attendee3__c, Other_Dell_Attendee4__c, Other_Dell_Attendee5__c, Dell_Attendees__c, 
                        Partner_Attendees__c, Primary_Dell_Attendee__c, Product_Demo__c, Related_Account_Plans__c, Related_Opportunity__c, Related_Strategy__c, Related_To__c, 
                        Secondary_Dell_Attendee__c, Send_Notification_Email__c, Summary__c, Type__c, User_1__c, User_2__c, User_3__c, User_4__c,User_5__c,CreatedById,
                        LastModifiedById,Name,Dell_Executive_Attendee_1__c,Dell_Executive_Attendee_2__c, Related_Account_Plans__r.Name, Related_Opportunity__r.Name, Related_Strategy__r.Name, Primary_Dell_Attendee__r.Name, Account__r.Name From CustomerInteraction__c where Id =: ApexPages.currentPage().getParameters().get('Id') ];
          
          existingTripRecordAccount = tripRecord.Account__c;
          
          if(tripRecord.Related_Account_Plans__c != null ){
            selectedObject = 'Account Plan';       
          }else if(tripRecord.Related_Strategy__c != null ){
            selectedObject = 'Strategy';      
          }else if(tripRecord.Related_Opportunity__c != null ){
            selectedObject = 'Opportunity';      
          }


          if(ApexPages.currentPage().getParameters().get('clone') == '1'){
            editFlag = false;
            cloneFlag = true;
            tripRecord.Id = null;
            tripRecord.CreatedById = null;
            tripRecord.LastModifiedById = null;
              tripRecord.Date__c = System.today();
          }else{ 
            editFlag = true;
          }  
        }else{           
           if(retUrl != null && retUrl != '' ){    
          /*********** New Trip Report ***********/

          tripRecord = new CustomerInteraction__c (); 
          tripRecord.Primary_Dell_Attendee__c = UserInfo.getUserId();
          editFlag = false;
          tripRecord.Date__c = System.today();     
          if(ApexPages.currentPage().getParameters().get('saveNew') == '1'){
            cloneFlag = true;
          }
          /************* New Event Trip Report ***************/

            if(ApexPages.currentPage().getParameters().get('EventId')!= null){
             
              RecordObjectMap recObjMap = new RecordObjectMap();
              Event eventRecord = [Select Id,OwnerId,Subject,WhoId,WhatId,AccountId,EndDateTime,Next_Steps__c,Outcome__c,Description,
                                   Type,End_in_Mind__c,Agenda__c,RecordTypeId From Event Where Id =: ApexPages.currentPage().getParameters().get('EventId')];  
              Id callPlanRecordType = [SELECT Id FROM RecordType WHERE SobjectType = 'Event' AND Name = 'Call Plan'].Id;

              tripRecord.Primary_Dell_Attendee__c = eventRecord.OwnerId;  
              tripRecord.Name = eventRecord.Subject;
              
              if(eventRecord.WhoId != null){
                if(string.ValueOf(eventRecord.WhoId).substring(0,3) == Contact.SObjectType.getDescribe().getKeyPrefix()){
                  tripRecord.Customer_Attendee1__c = eventRecord.WhoId;
                }
              }  
              tripRecord.Date__c = date.newinstance(eventRecord.EndDateTime.year(), eventRecord.EndDateTime.month(), eventRecord.EndDateTime.day());
              tripRecord.Next_Steps__c = eventRecord.Next_Steps__c;
                   
              if(eventRecord.AccountId != null ){ 
                if(eventRecord.WhoId == null){ 
                  tripRecord.Account__c = eventRecord.AccountId; 
                }else if(eventRecord.WhatId != null){
                  Map<String,Related_To_Map__c> relMap = Related_To_Map__c.getAll();               
                  if(relMap.get(string.ValueOf(eventRecord.WhatId).subString(0,3)) == null){                    
                    tripRecord.Account__c = eventRecord.AccountId;                   
                  }else{
                    tripRecord.Account__c = recObjMap.getObjectName(eventRecord.WhatId);
                    if(tripRecord.Account__c == null){
                      tripRecord.Account__c = eventRecord.AccountId; 
                    }
                  }
                }else{
                    tripRecord.Account__c = eventRecord.AccountId;                                   
                }
              }else if(eventRecord.WhatId != null){             
                tripRecord.Account__c = recObjMap.getObjectName(eventRecord.WhatId);
              }else{
                tripRecord.Account__c = eventRecord.AccountId;               
              }
              
              if(eventRecord.WhatId != null){
                if(string.ValueOf(eventRecord.WhatId).substring(0,3) == SFDC_Acct_Plan__c.SObjectType.getDescribe().getKeyPrefix()){
                  tripRecord.Related_Account_Plans__c = eventRecord.WhatId;
                  selectedObject = 'Account Plan'; 
                }else if(string.ValueOf(eventRecord.WhatId).substring(0,3) == SFDC_Strategy__c.SObjectType.getDescribe().getKeyPrefix()){
                  tripRecord.Related_Strategy__c = eventRecord.WhatId;
                  tripRecord.Account__c = [Select SFDC_Acct_Plan__r.Account__c from SFDC_Strategy__c where Id =: eventRecord.WhatId].SFDC_Acct_Plan__r.Account__c;          
                  selectedObject = 'Strategy'; 
                }else if(string.ValueOf(eventRecord.WhatId).substring(0,3) == '006'){
                  tripRecord.Related_Opportunity__c = eventRecord.WhatId;          
                  selectedObject = 'Opportunity'; 
                } 
              }                                  
              if(eventRecord.RecordTypeId != callPlanRecordType ){
                tripRecord.Type__c = 'Dell Visit';
                tripRecord.Summary__c = eventRecord.Description;        
              }else{           
                if(eventType.contains(eventRecord.Type)){
                  tripRecord.Type__c = 'Dell Visit';
                }else if(eventRecord.Type == 'Meeting (at Customer Site)'){
                  tripRecord.Type__c = 'On-Site Customer Visit';
                }else if(eventRecord.Type == 'Partner Meeting'){
                   tripRecord.Type__c ='Partner Meeting';
                }/*else if(eventRecord.Type == 'EBC'){
                   tripRecord.Type__c ='EBC';
                } */ else if(eventRecord.Type == 'EBC (Executive Business Center)'){
                   tripRecord.Type__c ='EBC';
                } else if(eventRecord.Type == 'DSC (Dell Solution Centers)'){
                   tripRecord.Type__c ='Dell Visit-DSC Support';
                } 
                         
              
                if(eventRecord.End_in_Mind__c != null){
                  tripRecord.Summary__c = '<b>End in Mind:</b> <br/>' + eventRecord.End_in_Mind__c + '<br/><br/>';
                }
                if(eventRecord.Agenda__c != null){
                  tripRecord.Summary__c += '<b>Agenda:</b> <br/>'+ eventRecord.Agenda__c + '<br/><br/>';
                }
                if(eventRecord.Outcome__c != null){
                  tripRecord.Summary__c += '<b>Outcome:</b> <br/>'+ eventRecord.Outcome__c+ '<br/><br/>';
                }
              }         
              if(tripRecord.Summary__c != null){
                tripRecord.Summary__c = tripRecord.Summary__c.replaceAll('\n','<br/>');                
              }        
            }else{
            
              /************* New Account Plan Trip Report **********/
              if(retUrl.substring(1,4) == string.valueOf(SFDC_Acct_Plan__c.SObjectType.getDescribe().getKeyPrefix())){
                List<SFDC_Acct_Plan__c> accountPlan = [Select Id,Account__c, Account__r.Name from SFDC_Acct_Plan__c where Id=:retUrl.substring(1) LIMIT 1];
                if(accountPlan.size() > 0){
                  tripRecord.Related_Account_Plans__c = accountPlan[0].Id;
                  AcName = accountPlan[0].Account__r.Name; //CR 9555
                  tripRecord.Primary_Dell_Attendee__c = UserInfo.getUserId();                    
                  tripRecord.Account__c =accountPlan[0].Account__c; 
                  tripRecord.Date__c = System.today(); //3.0  
                  selectedObject = 'Account Plan'; 
                }  
              }
            
              /************* New Strategy Trip Report **********/        
              else if(retUrl.substring(1,4) == string.valueOf(SFDC_Strategy__c.SObjectType.getDescribe().getKeyPrefix())){
                List<SFDC_Strategy__c> strategy = [Select Id,SFDC_Acct_Plan__r.Account__c, Account_Name__c from SFDC_Strategy__c where Id=:retUrl.substring(1) LIMIT 1];
                if(strategy.size() > 0){
                  tripRecord.Related_Strategy__c = strategy[0].Id;
                  AcName = strategy[0].Account_Name__c; //CR 9555
                  tripRecord.Primary_Dell_Attendee__c = UserInfo.getUserId();          
                  tripRecord.Date__c = System.today(); //3.0  
                  if(strategy[0].SFDC_Acct_Plan__c != null){
                    tripRecord.Account__c = strategy[0].SFDC_Acct_Plan__r.Account__c;      
                  }
                  selectedObject = 'Strategy';
                }   
              }
   
              /************* New Opportuntiy Report **********/                
              else if(retUrl.substring(1,4) == '006'){
                List<Opportunity> opp = [Select Id,AccountId, Account.Name from Opportunity where Id=:retUrl.substring(1) LIMIT 1];
                if(opp.size() > 0){
                  tripRecord.Related_Opportunity__c = opp[0].Id;
                  AcName = opp[0].Account.Name; //CR 9555
                  tripRecord.Account__c = opp[0].AccountId;
                  tripRecord.Primary_Dell_Attendee__c = UserInfo.getUserId();  
                  tripRecord.Date__c = System.today(); //3.0  
                  selectedObject = 'Opportunity'; 
                }        
              }
            
              /************* New Account Report **********/                        
              else if(retUrl.substring(1,4) == '001'){
                List<Account> acc = [Select Id, Name from Account where Id =: retUrl.substring(1) LIMIT 1];
                if(acc.size() > 0){
                  tripRecord.Account__c = acc[0].Id;
                  AcName = acc[0].Name; //CR 9555
                  tripRecord.Primary_Dell_Attendee__c = UserInfo.getUserId();
                    tripRecord.Date__c = System.today(); //3.0
                }
              }
                /************* 3.0 -  New Contact Report  **********/        
                else if(retUrl.substring(1,4) == '003'){
                  List<Contact> cont = [Select Id, Name,accountId from Contact where Id =: retUrl.substring(1) LIMIT 1];
                    if(cont !=null && cont.size()>0){
                        tripRecord.Account__c = cont[0].accountId;
                        tripRecord.Customer_Attendee1__c = cont[0].id;
                        tripRecord.Primary_Dell_Attendee__c = UserInfo.getUserId();
                        tripRecord.Date__c = System.today();
                    }                       
              }  //End
            }
          }  
        }
      }    
    }

    public List<SelectOption> getObjectsList() {
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('Opportunity','Opportunity'));
        options.add(new SelectOption('Account Plan','Account Plan'));
        options.add(new SelectOption('Strategy','Strategy'));

        return options;
    }
    
    public void saveRec(){
        
        system.debug('****'+selectedObject);
       
        if(selectedObject == 'Account Plan'){
            tripRecord.Related_Opportunity__c = null;
            tripRecord.Related_Strategy__c    = null;
        }else if(selectedObject == 'Opportunity'){
            tripRecord.Related_Account_Plans__c = null;
            tripRecord.Related_Strategy__c      = null;
        }else if(selectedObject == 'Strategy'){
            tripRecord.Related_Account_Plans__c = null;
            tripRecord.Related_Opportunity__c   = null;
        }
        if(!editFlag){       
            insert tripRecord;
        }else{          
            update tripRecord;      
        }
    }
    
    public PageReference SaveNew() {
        try{
            saveRec();
            PageReference page = new PageReference('/apex/NewTripReportPage?retURL=/'+tripRecord.Id);
            page.setRedirect(true);
            page.getParameters().put('saveNew', '1');
            return page;
        }catch(exception e){
            system.debug('***'+e);
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'Please check the following error :'+e);
            ApexPages.addMessage(myMsg);
            return null;     
        }   
    }

    public PageReference Save() {
        try{               
            //saveRec();
            
            system.debug('****'+selectedObject);
            if(selectedObject == 'Account Plan'){
                tripRecord.Related_Opportunity__c = null;
                tripRecord.Related_Strategy__c    = null;
            }else if(selectedObject == 'Opportunity'){
                tripRecord.Related_Account_Plans__c = null;
                tripRecord.Related_Strategy__c      = null;
            }else if(selectedObject == 'Strategy'){
                tripRecord.Related_Account_Plans__c = null;
                tripRecord.Related_Opportunity__c   = null;
            }
         // mine
            System.debug('***tripRecordAccount Old: '+ existingTripRecordAccount);
            System.debug('***tripRecord.Account__c: '+ tripRecord.Account__c); 
    
    //mine
    Profile p = [select name from Profile where id =:UserInfo.getProfileId()];
   

    
    
    
             If( existingTripRecordAccount != NULL && existingTripRecordAccount != tripRecord.Account__c && (!p.Name.contains('System Administrator') && !p.Name.contains('IT TA User') && !p.Name.contains('IT GBL Data Load') && !p.Name.contains('IT Integration API Only') && !p.Name.contains('Global CRM Support')/*  CR 14401 && !p.Name.contains('Global CRM Support - Non SSO') */ ) )
            
            {
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'Account field cannot be changed after the record is created, please choose cancel to return to the record');
                ApexPages.addMessage(myMsg);
                return null;
            } 
               
         // mine
            if(!editFlag){       
                insert tripRecord;
            }else{          
                update tripRecord;      
            }
          
            PageReference page;
            if(retUrl != null && retUrl != ''){
              if(editFlag){
                page = new PageReference(retUrl);
              }else if(cloneFlag || retUrl.substring(1,4) == string.ValueOf(CustomerInteraction__c.SObjectType.getDescribe().getKeyPrefix())){
                page = new PageReference('/'+tripRecord.Id);           
              }else{
                if(tripRecord.Related_Account_Plans__c != null){
                  page = new PageReference('/'+tripRecord.Related_Account_Plans__c);
                }else if(tripRecord.Related_Opportunity__c != null){
                  page = new PageReference('/'+tripRecord.Related_Opportunity__c);            
                }else if(tripRecord.Related_Strategy__c != null){
                  page = new PageReference('/'+tripRecord.Related_Strategy__c);            
                }
                else{            
                  page = new PageReference('/'+tripRecord.Id);      
                }
              }  
              return page;
            }else{
              ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'An Error Occured.Please try again later.');
              ApexPages.addMessage(myMsg);
              return null;
            }  
        }catch(exception e){
            system.debug('***'+e);
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'Please check the following error :'+e);
            ApexPages.addMessage(myMsg);     
            return null;
        }      
    } 

    public PageReference Cancel(){    
        PageReference page = new PageReference(retUrl);
        page.setRedirect(true);
        return page;
    }
}