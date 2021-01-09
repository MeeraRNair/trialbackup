/**********************************************************************************************
 * Name         : NewInstallBaseCtrl_test
 * Description  : Code coverage for NewInstallBaseCtrl class
 * Created      : 11-June-2014
 * Created By   : Samridh Manucha
 ************************************************************************************************/

@isTest
public class NewInstallBaseCtrl_test{
static testmethod void newinsttest(){
string RTId ;
string ret ='01pA0000001FVI5';
List<RecordType> RT=[select id from RecordType where SobjectType='Install_Base__c' and name='Software LOB' limit 1];
 for(RecordType r:RT)
    {
      RTId=r.Id;
    }
    
    Account acc = new Account();
    acc.Name = 'testAccount';
    acc.NumberOfEmployees = 14 ;
    insert acc; 
    
    Install_Base__c insbase = new Install_Base__c(
    Account__c = acc.id,
    of_Employees__c = 14,
    LOB__c = 'software',
    RecordTypeid = RTId
    );
    insert insbase;
    
    
   PageReference pageRef = Page.NewInstallBase;
   Test.setCurrentPage(pageRef);
 
   ApexPages.StandardController  stdCon = new ApexPages.StandardController(insbase);
   NewInstallBaseCtrl Lobf = new NewInstallBaseCtrl(stdCon) ;
  
    ApexPages.currentPage().getParameters().put('retURL', 'yyyyyyyyyyyyyyyyyyyy');
   
    Lobf.getAccount();
    Lobf.constructUrl();
    Lobf.redirect();
    
    
    
    }
    
    static testmethod void Anewinsttest(){
string RTId ;
List<RecordType> RT=[select id from RecordType where SobjectType='Install_Base__c' and name='All Other LOB' limit 1];
 for(RecordType r:RT)
    {
      RTId=r.Id;
    }
    
    Account acc = new Account();
    acc.Name = 'testAccount';
    acc.NumberOfEmployees = 14 ;
    insert acc; 
    
    Install_Base__c insbase = new Install_Base__c(
    Account__c = acc.id,
    of_Employees__c = 14,
    LOB__c = 'software',
    RecordTypeid = RTId
    );
    insert insbase;
    
   PageReference pageRef = Page.NewInstallBase;
   Test.setCurrentPage(pageRef);
 
    
   ApexPages.StandardController  stdCon = new ApexPages.StandardController(insbase);
    NewInstallBaseCtrl Lobf = new NewInstallBaseCtrl(stdCon) ;

    ApexPages.currentPage().getParameters().put('retURL', 'yyyyyyyyyyyyyyyyyyyy');
    
    Lobf.getAccount();
     Lobf.constructUrl();
    Lobf.redirect();
    
    
    
    }
}