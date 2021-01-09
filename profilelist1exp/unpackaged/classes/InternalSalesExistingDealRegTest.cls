/* 
    * Revision CR Number   Release No      Date            Created By     Description
    * -------- ---------   ----------      -----------     ------------    -----------
    * 2.0 -    16676     FY20-DCS-0202   26-Nov-2018      Raveena Bhagat   Removed unused Variables.
*/

@isTest (seeAlldata = true)
private class  InternalSalesExistingDealRegTest
{
    
public static testmethod void testOSCSales()
    {
        
        OWD__c obj = OWD__c.getOrgDefaults();
            
        String strplan = obj.Oppty_Stage1__c;    
        String strdiscover = obj.Oppty_Stage10__c;                
        String strqualify = obj.Oppty_Stage30__c;    
        String strpropose = obj.Oppty_Stage60__c;    
        String strcomit = obj.Oppty_Stage90__c;    
        String strordersubmitted = obj.Oppty_Stage99__c;
        User usr;
        Profile p = [SELECT id from Profile where name LIKE 'System Administrator' limit 1 ];
        usr = new User(
                    Username='testsSale@dll.com',
                    Alias = 'test1', 
                    Email='testS3445@dell.com', 
                    FirstName='John', 
                    LastName='Doe', 
                    ProfileId = p.Id, 
                    LanguageLocaleKey='en_US', 
                    LocaleSidKey='en_US', 
                    EmailEncodingKey='UTF-8', 
                    TimeZoneSidKey='America/Los_Angeles',
                    Badge_Number__c='SUser1', 
                    isActive = TRUE
                    );
        insert usr; 
         System.AssertNotEquals(usr.Alias,'test');
        Id accRTId= IdLookupUtils.getRecordTypeId('End-User Account','Account',true);
        Account accountObj;
        accountObj = new Account(name='Test', RecordtypeId = accRTId);
        insert accountObj;
        
        system.debug('AAAAA22');
       List<List<opportunity>> listlst = new List<List<opportunity>>();
       list<Opportunity> listls = new list<Opportunity>();
       
        system.debug('-----------ls0000000000000000'+listls);
        for(Opportunity oppo:[SELECT Name, End_User_Account_Name__c,Account.Name, CloseDate, StageName, Deal_Registration_Status__c FROM Opportunity 
             Limit 500]){
             listls.add(oppo);
             listlst.add(listls);
        }       
       
        system.debug('lsttttt:'+listlst.size());
        System.runas(usr){
        System.debug('@@USer: '+usr);
       
       
        Pagereference pr = new Pagereference('/apex/InternalSalesExistingdealregistration');
        Test.setcurrentpagereference(pr);
        Apexpages.currentpage().getparameters().put('oscid','EU:675645342312.1');
        InternalSalesExistingDealRegistrationCls edr = new InternalSalesExistingDealRegistrationCls(); 
          
        edr.pgIndex = 0;
        edr.pageNumber= 2;
        edr.pageSize = 5;
        edr.oppid = listls[0].Id;       
        edr.lstOppMainList = listlst;
        edr.lstopp = listls;
        edr.searchOppName = 'TestOpp';
        edr.searchStage = strplan;
        edr.searchEndUserAccName = accountObj.name;
        edr.searchOpp.Decision_Date__c = System.today();
        
        edr.PageAction();
        
        edr.vr8 = false;
        edr.vr1 = true; 
        edr.vr2 = false;
         edr.vr3 = false;
         edr.vr4 = false;
         edr.vr5 = false;
         edr.vr9 = false;
        edr.SearchAction();
         edr.vr8 = true;
        edr.vr1 = false; 
        edr.SearchAction();
        edr.vr2 = true;
        edr.SearchAction();
        edr.vr1 = false; 
        edr.SearchAction();
         edr.vr3 = true; 
         edr.SearchAction();
         edr.vr1 = true; 
         edr.vr3 = false;
         edr.SearchAction();
         edr.vr3 = true;
         edr.SearchAction();
         edr.vr1 = false;
         edr.vr2 = false;
         edr.SearchAction();
         edr.vr4 = true;
        
         edr.SearchAction();
         edr.vr3 = false;
         edr.SearchAction();
         edr.vr2 = true;
        edr.vr4 = false;
        edr.SearchAction();
        edr.vr4 = true;
        edr.vr5 = true;
        edr.SearchAction();
        edr.vr2 = false;
        edr.vr3 = false;
        edr.SearchAction();
        edr.vr5 = true;
        edr.vr2 = true;
        edr.SearchAction();
        edr.vr2 = false;
        edr.vr4 = false;
         edr.SearchAction();
          edr.vr2 = true;
          edr.SearchAction();      
       edr.vr2 = false;
       edr.vr5 = false;
       edr.SearchAction();
       edr.vr2 = true;       
       edr.SearchAction();
       edr.vr2 = false;
       edr.SearchAction();      
       edr.vr8 = true;
        edr.vr1 = true; 
        edr.vr2 = true;
         edr.vr3 = true;
         edr.vr4 = true;
         edr.vr5 = true;         
         edr.vr9 = true;
        edr.SearchAction();
       edr.searchOppName = '';
       edr.searchEndUserAccName = '';
       edr.temperr = true ;
       edr.SearchAction();
              
        edr.lstOppMainList = listlst;
        edr.showNext();
        edr.showPrevious();
        
       edr.showFirst();
        edr.showLast();      
        edr.associate();
      }
      }   
  
    public static testmethod void sendSol(){
        OSCWebServiceCallout.sendSolutionWithDealInfoHttpResponse(new List<String>{
            'teste1','test2','test3'
        });
         Exception__c exceptionRec = new Exception__c(Object_Type__c = 'Opportunity',Error_Messages__c = 'Error message test',
                                                     Operation__c = 'Webservice Request',Process_Name__c = 'OSCWebservice Callout',
                                                     Email__c = 'no_reply@dell.com');
        insert exceptionRec; 
        HttpResponse res = new HTTPResponse();
        res.setHeader('Content-Type', 'text/xml;charset=UTF-8');
        res.setStatusCode(200);
      //return res;
    }
}