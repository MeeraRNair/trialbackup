/*
Version    CR Number   Release No      Date            Modified By     Description
--------    ---------   ----------      -----------     ------------    -----------
2.0         18388      FY21-DCS-0202   23-Dec-2019     Yamini Kayam    Story 7128749: Lead 2.0 - [LEX] Marketing user should be able to view and access the created GLMI cases
*/
public class CaseSaveNewRedirectController {
 Case cs;
 String csId;
 String csNameSpace;
 Id rectypeId;
//Constructor
 public CaseSaveNewRedirectController(ApexPages.StandardController controller) {
  csId = ApexPages.currentPage().getParameters().get('id');
  cs = [Select Id, RecordTypeId from Case where id = : csId];
  
  // Logic added by Ravindra Babu to skip 7 RTs as a part of LiftnShift
  //rectypeId = ApexPages.currentPage().getParameters().get('RecordType');
 }
    
 public pageReference caseRedirect() {
  String redirectURL;
  pagereference page;

  /* original-- 
   
   redirectURL = '/' + cs.Id + '/e?retURL=%2F' + cs.Id + '&nooverride=1&saveURL=' + cs.Id+'&save_new_url='+ cs.Id +'&save_close_url='+ cs.Id; 
   page = new pagereference(redirectURL);
   page.setRedirect(TRUE);

   system.debug('---URL: ' + redirectURL);
    
   return page; --end of original */
  String recordTypeName = [SELECT id, name, DeveloperName from RecordType where Id = : cs.RecordTypeId].DeveloperName;
  system.debug('@@##recordTypeName@@##'+recordTypeName);
  //if(recordTypeName.contains('CaseRTMigrate')){
  //  CsNameSpace = [Select NamespacePrefix from RecordType where id= : RecTypeId].Namespaceprefix;
  //}

  if (recordTypeName == 'Order_Support') {
   page = new PageReference('/apex/OrderSupportVfPage?id=' + cs.Id);
   page.setRedirect(TRUE);
  } else if (recordTypeName == 'Deal_Registration') {
   page = new PageReference('/apex/DealRegVFPage?id=' + cs.Id);
   page.setRedirect(TRUE);
  }else if (recordTypeName == 'Deal_Registration_Internal_only_case_types') {
   page = new PageReference('/apex/DealRegVFPage?id=' + cs.Id);
   page.setRedirect(TRUE);
  }else if(recordTypeName == 'On_Boarding'){
   page = new PageReference('/apex/OnBoardingVFPage?id=' + cs.Id);
   page.setRedirect(TRUE);

  }else if(recordTypeName == 'On_Boarding_Internal'){
   page = new PageReference('/apex/OnBoardingVFPage?id=' + cs.Id);
   page.setRedirect(TRUE);
  }else if(recordTypeName == 'Distribution'){
    page = new PageReference('/apex/DistributionVFPage?id=' + cs.Id);
    page.setRedirect(TRUE);
  }else if(recordTypeName == 'PartnerDirect_Portal'){
    page = new PageReference('/apex/ApplicationSupportVFPage?id=' + cs.Id);
    page.setRedirect(TRUE);
  }else if(recordTypeName == 'Application_Support_Internal_only_case_types'){
    page = new PageReference('/apex/ApplicationSupportVFPage?id=' + cs.Id);
    page.setRedirect(TRUE);
  }else if(recordTypeName == 'Incentive_Promotion'){
    page = new PageReference('/apex/ApplicationSupportVFPage?id=' + cs.Id);
    page.setRedirect(TRUE);
  }/*Meenu : Story 7059159 added recordtype Channel Services Helpdesk vf page redirection*/
  else if(recordTypeName == 'Channel_Services_Helpdesk' || recordTypeName == 'Channel_Services_Helpdesk_internal_only'){
    page = new PageReference('/apex/ChannelServicesHelpdeskVFPage?id=' + cs.Id);
    page.setRedirect(TRUE);
  }
  /*
  else if(recordTypeName == 'Presales_Quoting' || recordTypeName == 'Presales_Converged' || recordTypeName == 'Presales_Technical_Q_A' || recordTypeName == 'Presales_Technical_Drawings' 
            || recordTypeName == 'Presales_Storage_Sizing'|| recordTypeName == 'Presales_Environmental_Calculator' || recordTypeName == 'Presales_RPQ'){
    page = new PageReference('/apex/ApplicationSupportVFPage?id=' + cs.Id);
    page.setRedirect(TRUE);
  }*/
  
  // Logic added by Ravindra Babu to skip 7 RTs as a part of LiftnShift
  else if(recordTypeName.contains('Presales_')) {
     //redirectURL = '/' + cs.Id + '/e?retURL=%2F' + cs.Id + '&nooverride=1&saveURL=' + cs.Id; + '&save_new_url=' + cs.Id + '&save_close_url=' + cs.Id;
     //To Enable save&Close Button
     redirectURL = '/' + cs.Id + '/e?retURL=%2F' + cs.Id + '&nooverride=1';//'&saveURL=' + cs.Id; + '&save_new_url=' + cs.Id + '&save_close_url=' + cs.Id;
     
     //redirectURL = '/' + cs.Id + '/e?retURL=%2F'+ cs.Id ;
     if(ApexPages.currentPage().getParameters().get('RecordType') != null) {
        string stringRecTypeId = ApexPages.currentPage().getParameters().get('RecordType');
        redirectURL += '&RecordType=' + StringRecTypeId;
     }
     page = new PageReference(redirectURL);
     page.SetRedirect(TRUE);
  }
  else if (cs.RecordTypeId != '012A0000000VlVm' ) {
      String baseUrl = URL.getSalesforceBaseUrl().toExternalForm();
      //V2.0 Added if condition to check if user theme is lightning and redirect to lightning component to edit case
      if(UserInfo.getUiTheme() != 'Theme3'){
               redirectURL = baseUrl + '/apex/CaseEditforlightning?recordId='+cs.Id;
                //page = new pagereference(baseUrl+'/apex/CaseEditforlightning?recordId='+cs.Id);
              page = new pagereference(redirectURL);
            page.setRedirect(TRUE); 
          }
      else{
   //redirectURL = '/' + cs.Id + '/e?retURL=%2F' + cs.Id + '&nooverride=1&saveURL=' + cs.Id + '&save_new_url=' + cs.Id + '&save_close_url=' + cs.Id;
   redirectURL = '/' + cs.Id + '/e?retURL=%2F' + cs.Id + '&nooverride=1&'+cs.Id;
   page = new pagereference(redirectURL);
   page.setRedirect(TRUE); 
      }
  }
      
  system.debug('---URL: ' + redirectURL);
  
  return page;
 }
}