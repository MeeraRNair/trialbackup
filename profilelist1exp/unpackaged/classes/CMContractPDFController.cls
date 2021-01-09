public class CMContractPDFController {

    Contract contractObj{get;set;}
    boolean isNotCM = true;
    boolean showAddendum = false;
    boolean addendumMessage =  false;
    List<Addendum_Data__c> addendumList = new List<Addendum_Data__c>();   
    public CMVFTermsandConditionsViewController viewContract{get;set;}
    public CMContractPDFController(ApexPages.StandardController controller) {
        contractObj = (Contract)controller.getRecord();
        viewContract=new CMVFTermsandConditionsViewController(controller);
        checkProfile();
    }
    
    public void checkProfile(){
        id profileID = userInfo.getProfileID();
        String userProfileName;
        for( Profile profileObj : [select name from profile where id=: profileID]){
            userProfileName = profileObj.Name;
        }
        if(userProfileName == 'R12.1 CSMB Contract Manager'){
            isNotCM = false;
        }else{
            addendumList=[select id,name,Addendum_status__c,Addendum_Contract_Relation__c,Addendum_Effective_Date__c,Addendum_Expiration__c,Addendum_Form_Version__c, Addendum_Non_Standard__c,Addendum_Summary__c from Addendum_Data__c where Addendum_Contract_Relation__c =: contractObj.id];
        }
        if(addendumList.size()>0 ||addendumList== null ){
            showAddendum =true;
        }else{
            addendumMessage =true;
        }
            
    }
    
    public boolean getisNotCM(){
        return isNotCM;
    }
    public void setisNotCM(boolean isNotCM){
        this.isNotCM = isNotCM;
    }
    public boolean getshowAddendum(){
        return showAddendum;
    }
    public void setshowAddendum(boolean showAddendum){
        this.showAddendum= showAddendum;
    }
    public boolean getaddendumMessage(){
        return addendumMessage;
    }
    public void setaddendumMessage(boolean addendumMessage){
        this.addendumMessage= addendumMessage;
    }
    public List<Addendum_Data__c> getaddendumList(){
        return addendumList;
    }
    public void setaddendumList(List<Addendum_Data__c> addendumList){
        this.addendumList=addendumList;
    }

}