public class CreateNewLobController {

  public final LOB_Registration__c lobRecord;
  public SelectOption[] selectedLobRecords{get;set;}
  public SelectOption[] allLobRecords{get;set;}
  
  public CreateNewLobController(ApexPages.StandardController controller) {
    this.lobRecord = (LOB_Registration__c)controller.getRecord();
    lobRecord.Registered_End_User__c =[Select Id From Account Where Id=: ApexPages.currentPage().getParameters().get('accid')].Id;
    lobRecord.LOB_registration_status__c ='Partner(submit for approval)';
    selectedLobRecords = new List<SelectOption>();
    allLobRecords = new List<SelectOption>();
    List<LOB_Administration__c> lobAdminList = [Select Id,LOB_Administration_Name_Unique__c,Name From LOB_Administration__c where Active__c= true];  
    for(LOB_Administration__c lobAdminRecord : lobAdminList){
      allLobRecords.add(new SelectOption(lobAdminRecord.Id,lobAdminRecord.LOB_Administration_Name_Unique__c));   
    }
  }
  
  public PageReference Save(){
    List<LOB_Registration__c> lobRecordList = new List<LOB_Registration__c>();
    if(selectedLobRecords.size()>0){
      /*
      if(lobRecord.LOB_Award_Type__c == 'Location' && (lobRecord.City__c == null || lobRecord.State_Province_Region__c == null)){
        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Please fill both City and State/Province/Region'));
        return null;
      }else if((lobRecord.LOB_Award_Type__c == 'Local Subsidiary' || lobRecord.LOB_Award_Type__c == 'All Subsidiary Locations')
                 && lobRecord.Subsidiary_Name__c == null){
        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Please fill Subsidiary Name'));
        return null;
      }
      */
      for ( SelectOption so : selectedLobRecords) {  
        LOB_Registration__c newLobRecord = new LOB_Registration__c();
        newLobRecord= lobRecord.clone(false,false,false,false);
        newLobRecord.LOB_Name__c = so.getLabel();
        lobRecordList.add(newLobRecord);
      }
      
      try{
          Database.insert(lobRecordList);
          PageReference pageRedirect = new PageReference('/'+lobRecord.Registered_End_User__c);
          return pageRedirect;
      }catch(System.DmlException  e){
          ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getDmlMessage(0)));
          return null;
      }catch(SObjectException e) {
          ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Error'+e));
          return null;    
      } catch(Exception e){
          ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Error'+e));
          return null;      
      }
    }else{
       ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Please select at least one LOB Name.'));
      return null;       
    } 
  }
  
  public PageReference cancel(){
    PageReference pageRedirect = new PageReference('/'+lobRecord.Registered_End_User__c);
    return pageRedirect;
  }
}