/***********************************************************************

Author      : Devika Pujari
Description : Page available to create a Call Log for a Call Plan Record.

Revision  Name            Date            Description
------------------------------------------------------------
*1.0      Devika          18.12.2013      CR 8974 - OMGO WF 15.03


************************************************************************/

public class VF_NewLogACallPage {

  public Task callRecord1 {get;set;}
  public Task callRecord2 {get;set;}
  public String Phone {get;set;}
  public String Email {get;set;}
  public string whoType {get; set;}  
  public Boolean sendNotificationEmail1 {get;set;}
  public Boolean sendNotificationEmail2 {get;set;}
  public Boolean leadFlag {get;set;}
  public Boolean reminderCheck {get;set;}
  public Date reminderDate {get;set;}
  Id eventId;

  public VF_NewLogACallPage(){     
    
    eventId = ApexPages.currentPage().getParameters().get('Eventid');
    if(eventId != null){
    
      callRecord1 = new Task();
      callRecord2 = new Task();
      Event eventRecord = [Select Id,OwnerId,Subject,WhoId,WhatId,Outcome__c,EndDateTime 
                                  From Event Where Id =: ApexPages.currentPage().getParameters().get('Eventid')]; 
      Id recordTypeId = [SELECT Id FROM RecordType WHERE SobjectType = 'Task' AND Name = 'Standard Task'].Id; 
      
      callRecord1.OwnerId = eventRecord.OwnerId;
      callRecord1.Subject = eventRecord.Subject;
      callRecord1.WhoId = eventRecord.WhoId;
      callRecord1.WhatId = eventRecord.WhatId;
      callRecord1.ActivityDate = date.newinstance(eventRecord.EndDateTime.year(), eventRecord.EndDateTime.month(), eventRecord.EndDateTime.day());
      callRecord1.RecordTypeId = recordTypeId;
      callRecord1.Description = eventRecord.Outcome__c;
      callRecord1.Status = 'Completed';
      callRecord1.Type = 'Call Customer';
      callRecord1.Priority = 'Normal';
      
      callRecord2.OwnerId = eventRecord.OwnerId;
      callRecord2.WhoId = eventRecord.WhoId;
      callRecord2.WhatId = eventRecord.WhatId;
      callRecord2.Status = 'Not Started';
      callRecord2.RecordTypeId = recordTypeId;

      if(eventRecord.WhoId != null){
        if(string.valueOf(eventRecord.WhoId).substring(0,3) == '003'){
          Contact con = [Select Phone,Email From Contact where Id =:eventRecord.WhoId];
          Phone = con.Phone;
          Email = con.Email;
          leadFlag = false;
 
        }else{
          Lead lead= [Select Phone,Email From Lead where Id =: eventRecord.WhoId];
          Phone = lead.Phone;
          Email = lead.Email;
          leadFlag = true;

        } 
      }   
    }
  }
  
  
  public PageReference Cancel() {
    PageReference page = new PageReference('/'+eventId);
    return page;
  }

  public PageReference Save() {
   
   try{ 
      PageReference page;   
      Database.DMLOptions dlo = new Database.DMLOptions();
      dlo.EmailHeader.triggerUserEmail = true;
      
      /*** Check Follow Up Task Creation Criteria **/
      if(callRecord2.Subject != null){
        
        if(callRecord2.ActivityDate == null || callRecord2.Type == '--None--' || callRecord2.Type == null){
          if(callRecord2.Type == null || callRecord2.Type == '--None--'){
            callRecord2.Type.addError('You must enter a value');
          }
          if(callRecord2.ActivityDate == null){
            callRecord2.ActivityDate.addError('You must enter a value');
          }
          return null;
        }else{
          if(sendNotificationEmail2){
            database.insert(callRecord2, dlo);         
          }else{
            insert callRecord2;
          }  
        }  
      }
      
      if(sendNotificationEmail1){
            database.insert(callRecord1, dlo);               
      }else{
        insert callRecord1;
      }  
      
      if(callRecord1.WhatId != null ){
        page = new PageReference('/'+callRecord1.WhatId);      
      }else{
        page = new PageReference('/'+eventId);
      }
      
      return page; 
    }catch(exception e){
      system.debug('***'+e);
      ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'Please check the following error :'+e);
      ApexPages.addMessage(myMsg);     
      return null;
    }    
  }
  
  public PageReference RefreshWhoType(){
    if (whoType == 'Lead')
      leadFlag = true;
    else{
      leadFlag = false;
    }
    return null;
  }
}