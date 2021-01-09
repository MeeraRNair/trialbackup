@isTest(SeeAllData = false)
private class Test_faultEnterpriseSoapSforceCom{
  
 
  public static testmethod void controllerMethod(){
            
    
    Test.startTest();
    
    faultEnterpriseSoapSforceCom con = new faultEnterpriseSoapSforceCom();
    faultEnterpriseSoapSforceCom.ApiFault ApiFault = new faultEnterpriseSoapSforceCom.ApiFault();
    faultEnterpriseSoapSforceCom.InvalidSObjectFault  InvalidSObjectFault = new faultEnterpriseSoapSforceCom.InvalidSObjectFault ();
    faultEnterpriseSoapSforceCom.MalformedQueryFault MalformedQueryFault = new faultEnterpriseSoapSforceCom.MalformedQueryFault();    
    faultEnterpriseSoapSforceCom.InvalidIdFault InvalidIdFault = new faultEnterpriseSoapSforceCom.InvalidIdFault();   
    faultEnterpriseSoapSforceCom.InvalidFieldFault InvalidFieldFault = new faultEnterpriseSoapSforceCom.InvalidFieldFault();       
    faultEnterpriseSoapSforceCom.MalformedSearchFault MalformedSearchFault = new faultEnterpriseSoapSforceCom.MalformedSearchFault();           
    faultEnterpriseSoapSforceCom.ApiQueryFault ApiQueryFault = new faultEnterpriseSoapSforceCom.ApiQueryFault(); 
    faultEnterpriseSoapSforceCom.UnexpectedErrorFault UnexpectedErrorFault = new faultEnterpriseSoapSforceCom.UnexpectedErrorFault();     
    faultEnterpriseSoapSforceCom.LoginFault LoginFault = new faultEnterpriseSoapSforceCom.LoginFault(); 
    faultEnterpriseSoapSforceCom.InvalidQueryLocatorFault InvalidQueryLocatorFault = new faultEnterpriseSoapSforceCom.InvalidQueryLocatorFault(); 
    faultEnterpriseSoapSforceCom.InvalidNewPasswordFault InvalidNewPasswordFault = new faultEnterpriseSoapSforceCom.InvalidNewPasswordFault ();                       
             
  }

}