/*
Author: P Praveen Babu
History:
Version Date             Modified By           Description
--------------------------------------------------------------------------------------
1.0     21-May-2014      P Praveen Babu        CR 9551 - Show Customer Technology Initiatives with max 5 textboxes
2.0     28-June-2018     Rahul Ms=ishra        Code Reduce!
*/

public class AccntPlanMultipleCustTechInitCtrl{

    public String accountPlanId {get;set;}
    public List<String> fieldNames {get;set;}
    private Integer noOfFilledFields = 1;
    public Integer maxOfFields {get;set;}
    public SFDC_Acct_Plan__c accountPlan {get;set;} 
    public boolean canProceed = true;
    public String removedFieldName {get;set;} 
    
    public boolean getCanProceed(){
        return canProceed;        
    }
    
    public Integer getnoOfFilledFields (){
        return noOfFilledFields ;        
    }
    
    public AccntPlanMultipleCustTechInitCtrl(){
    
        try{
            initialize();
        }catch (Exception e){
            handleError(e);
        } 
        
    }
    
    private void initialize(){
    
        obtainMaxOfFields(); 
        obtainParameter();  
        queryAccountPlan(accountPlanId);           
        identifyNoOfFilledFields();
        
    }
    
    private void obtainMaxOfFields(){
        maxOfFields = Integer.valueOf(System.Label.AccntPlan_CustTechInit_MaxFieldCount);
    }
    
    private void obtainParameter(){
        accountPlanId = ApexPages.currentPage().getParameters().get('accountPlanId');
    }
    
    private void identifyNoOfFilledFields(){
        
        for (integer i=1; i<=maxOfFields-1; i++){
            if(String.isBlank((String)accountPlan.get(getFieldName(i)))){
                return;                
            }   
            ++noOfFilledFields;         
        }
        
    }
    
    private String getFieldName(integer index){
      return 'Large_Scale_Related_Initiatives_Planned' + (index==0?'':String.valueOf(index+1)) + '__c';
    }
    

    private void queryAccountPlan(String accountPlanId){
        
        String queryString = '';
        fieldNames = new List<String>();
        
        for (integer i=0; i<=maxOfFields-1; i++){
            String fieldName = getFieldName(i);
            
            if(i!=0)
                queryString+=', ';
            queryString+=fieldName;
            fieldNames.add(fieldName);
        
        }
        
        queryString = 'Select ' + queryString  + ' from SFDC_Acct_Plan__c where Id = \'' + accountPlanId + '\'';
        accountPlan = Database.query(queryString);
    }
    
    
    //create error message to be displayed at VF UI
    private void createError(boolean canProceedBool, String errMsg){
    
        apexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,errMsg)); 
        canProceed = canProceedBool;
        
    }
   
    //handle different exception (to display error message) 
    private void handleError(Exception e){
        
        String errMsg;
        if (e instanceOf EmptyValueException ){
            createError(true,System.Label.AccntPlan_CustTechInit_MandatoryErrMessage);
            return;
        }
            
        createError(false,System.Label.AccntPlan_CustTechInit_GeneralErrMessage);

    }
    
    private void createMessage(String msg){
        
        apexPages.addmessage(new ApexPages.message(ApexPages.severity.INFO, msg));
        canProceed = false;
        
    }
    
    public PageReference add(){
    
        try{
            
            ++noOfFilledFields;

        }catch (Exception e){
            handleError(e);
            return null;
        }
        
        return null;
        
    }
    
    public PageReference remove(){
    
        try{
            
            removeField();
            --noOfFilledFields;
        }catch (Exception e){
            handleError(e);
            return null;
        }
        
        return null;
        
    }
    
    private void removeField(){
        eliminateCurrentField(findFieldIndex());
    
    }
    
    private Integer findFieldIndex(){
        
        Integer j=0;
        
        for(; j<=noOfFilledFields-1; j++){
            if (removedFieldName == getFieldName(j))
                break;    
        }
       
        return j;
       
    }
    
    private void eliminateCurrentField(integer removedFieldIndex){
    
        for(integer j=removedFieldIndex; j<=noOfFilledFields-2; j++){
            accountPlan.put(getFieldName(j), accountPlan.get(getFieldName(j+1)));
        }
        accountPlan.put(getFieldName(noOfFilledFields-1), '');    
    }
        
    public PageReference save(){
    
        try{
            
            validate();
            update accountPlan;
            
        }catch (Exception e){
            handleError(e);
            return null;
        }
        
        return cancel();
        
    }
    
    private void validate(){
        if(noOfFilledFields==1)
            return;
        
        for (integer i=0; i<=noOfFilledFields-1; i++){
        
            if(String.isBlank((String)accountPlan.get(getFieldName(i)))){
                throw new EmptyValueException ();
            }
                
        }
    }
            
    public PageReference cancel(){
       return PageUtils.redirect ('/' + accountPlanId);
    }
    
    public class EmptyValueException extends Exception {}     
}