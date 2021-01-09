public class FAP_PreviewLogoFromAccountPageLayoutExt extends FAP_PartnerFinderBaseController {
   
  public static String nORECORDERROR {get{return 'NO_RECORD_ERROR';}}
  public String error{get;private set;}
  public Boolean errorOccurred{get{return FAP_StringUtils.isNotBlank(error);}}

  private SObject record;
  public ID logoRecordID {get;private set;}
  public ID logoAttachmentID {get;private set;}
    
  public FAP_PreviewLogoFromAccountPageLayoutExt(ApexPages.StandardController controller){
    this.record = controller.getRecord();
  }

  public PageReference doOnLoad(){

if(record != null && (record instanceof Account)){
      
  
      try{
        logoRecordID = ((Account) record).Logo__c;
        Attachment logoBlob = [select id from Attachment where parentid = :logoRecordID];
        logoAttachmentID = logoBlob.id;
      }catch(QueryException e){
        error = nORECORDERROR;
      }
   
    return null;
}
else if (record != null && (record instanceof Partner_Track__c))
{
    
              try{
              logoRecordID = ((Partner_Track__c) record).Logo__c;
              Attachment logoBlob = [select id from Attachment where parentid = :logoRecordID];
              logoAttachmentID = logoBlob.id;
              }catch(QueryException e){
               error = nORECORDERROR;
              }
           
          return null;
    
}
else{
error = nORECORDERROR; 
return null;
}
  }
}