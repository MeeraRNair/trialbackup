public virtual without sharing class DAMGLMICaseCreationBaseCls {
    
    public String strIsBlankEmail {get;set;}
    public String strIsBlankSubject {get;set;}
    public String strIsBlankDescription {get;set;}
    public String strInvalidEmailError {get;set;}
    
    public case objcase;
    public Boolean isError = false;
    public PageReference pageRef = null;
    
    public DAMGLMICaseCreationBaseCls() {
        
        initializeVar();
    }
    
    public void validateEmailSubjectDesc(){
        
        if(String.isBlank(objCase.SuppliedEmail)){
                strIsBlankEmail = 'display:block';
                strInvalidEmailError=' You must enter a value';
                isError = true;
        }
        else{
                if (!validateEmail(objCase.SuppliedEmail)){
                    strIsBlankEmail = 'display:block';   
                    isError = true;
                    strInvalidEmailError=' Invalid Email Address';
                }
        }
        if(String.isBlank(objCase.Subject)){
                strIsBlankSubject = 'display:block';
                isError = true;
        }
        if(String.isBlank(objCase.Description)){
                strIsBlankDescription = 'display:block';
                isError = true;
        }
    }
    
    public void saveCase() {
        
        if(isError && fileBody != null){
             
            fileBody = null;
            ApexPages.Message errorMsg = new ApexPages.Message(ApexPages.Severity.Error,'Please correct the errors and upload the file again.');
            ApexPages.addMessage(errorMsg);
            
        }//2.0
        try{
            if(objCase !=null && ! isError){
                insert objCase;    
                UploadFile(objCase.id);
                pageRef = new PageReference('/apex/Thankyou');
               
            }
        }catch(DmlException excp){
            
            ApexPages.addMessages(excp);
            pageRef = null;
        }
    }
    
    
    public void initCase(boolean isGLMI) {
        
        Id idDevRecordType;
        if(isGLMI) {
            idDevRecordType = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Global Lead Management Intake').getRecordTypeId();
        }
        else {
            idDevRecordType = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Digital Asset Management').getRecordTypeId();
        }
        objCase.recordtypeId = idDevRecordType;
        objCase.origin ='Web';
        objCase.status='Open';
       
    }
    public  void initializeVar() {
        
        strIsBlankEmail = 'display:none';
        strIsBlankSubject = 'display:none';
        strIsBlankDescription = 'display:none';
        isError = false;
        pageRef = null;
    }
    
    public string fileName 
    {    get;set;    }
    
    public Blob fileBody 
    {    get;set;    }
    
    public void UploadFile(Id parentId)
    {
        
        if(fileBody != null && fileName != null)
        {
            Attachment myAttachment  = new Attachment();
            myAttachment.Body = fileBody;
            myAttachment.Name = fileName;
            myAttachment.ParentId = parentId;  
            myAttachment.IsPrivate = false;
            insert myAttachment;
        }
    }    
    
    //Code to validate Email
    public Boolean validateEmail(String email) {
        Boolean bres = true;
        
        String emailRegex = '^[a-zA-Z0-9._|\\\\%#~`=?&/$^*!}{+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,4}$';
        Pattern MyPattern = Pattern.compile(emailRegex);
        Matcher MyMatcher = MyPattern.matcher(email);
        
        if (!MyMatcher.matches()) 
            bres = false;
        return bres;	
    }
   
}