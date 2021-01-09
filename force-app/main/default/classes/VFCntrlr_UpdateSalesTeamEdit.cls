/* 
Description: Apex controller Class which contains the methods which help in editting a sales team member using VF page : "edit_salesteammember"
Version: 2.0

History:

1.0 - 18-Aug-2008 :  Creation
2.0 - 02-Sept-2008:  Updated ::  Added more test methods & comments

Author: Meera Nair/Krishnaprasad P
*/

/*
Revision    CR Number   Release No      Date            Modified By     Description
--------    ---------   ----------      -----------     ------------    -----------
1.0         13358       Sprint 13       27-July-2016    Syidah          To separate test method in a test class from VFCntrlr_UpdateSalesTeamEdit main class and change logic to disable the method of creation of OpportunityShare record manually and set OpportunityAccess = Edit when OpportunityTeamMember is added as OpportunityShare record is to be created automatically. 
*/   

public class VFCntrlr_UpdateSalesTeamEdit{
    
    /*  ---   VARIABLE DECLARATIONS   ---   */
    private List<Opportunity> CurrentOppList;
    private List<OpportunityTeamMember> currentTeamMemberList;    
    private boolean IsOwner=False;
    private boolean DataAvailable=True;
    private String access;
    // STORY 7581005
    private String strPrimarySecondarySpecialtySE;
    private String TeamMemberId = ApexPages.currentPage().getParameters().get('id');
    private String OppId = ApexPages.currentPage().getParameters().get('oid');
    
    /*  ---   CONSTRUCTOR   ---   */
    public VFCntrlr_UpdateSalesTeamEdit() {    
        
        currentTeamMemberList=[select id,OpportunityId, TeamMemberRole,UserId,OpportunityAccessLevel,
                               Primary_Secondary_Specialty_SE__c
                               from OpportunityTeamMember where Id = :TeamMemberId];
        
        if(currentTeamMemberList.size()>0){ 
            
            //reassigning the actual OpportunityId for ensuring the correct OpportunityId
            OppId= currentTeamMemberList[0].OpportunityId;
            CurrentOppList = [select id,OwnerId from Opportunity where Id= :OppId limit 1];                     
            
            system.debug('#KP-TeamMemeber -'+currentTeamMemberList);
            system.debug('#KP-TeamMemeber Id-'+TeamMemberId);            
            
            if(currentTeamMemberList[0].UserId == CurrentOppList[0].OwnerId){
                IsOwner=True;
            }
            access=currentTeamMemberList[0].OpportunityAccessLevel;
            
        }
        else{
            DataAvailable=False;
        }
    }
    
    
    /*  ---   GET METHODS   ---   */    
    
    public List<SelectOption> getAccessLevels() {
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('Read','Read Only'));
        options.add(new SelectOption('Edit','Read/Write'));
        return options;
    }
    public List<SelectOption> getPrimarySecondarySEAccess() {
        List<SelectOption> listOptions = new List<SelectOption>();
        listOptions.add(new SelectOption('Primary','Primary'));
        listOptions.add(new SelectOption('Secondary','Secondary'));
        return listOptions;
    }
    
    public String getAccess() {
        return access;
    }
    public String getPrimarySecondarySpecialtySE() {
        return strPrimarySecondarySpecialtySE ;
    }
    
    public OpportunityTeamMember getCurrentTeamMember() {
        return currentTeamMemberList[0];      
    }
    
    public boolean getIsOwner() {
        return IsOwner;
    }
    public boolean getDataAvailable() {
        return DataAvailable;
    }
    
    /*  ---   SET METHODS   ---   */
    
    public void setAccess(String accessLevel) {
        System.debug('#MN-In setAccess method: Accesslevel='+  accessLevel);
        this.access=accessLevel;
    }
    public void setPrimarySecondarySpecialtySE(String strPrimarySecondary) {
        this.strPrimarySecondarySpecialtySE = strPrimarySecondary ;
    }
        
        public void setOwner(boolean value){
            IsOwner=value;
        }
    public void setDataAvailable(boolean value){
        DataAvailable=value;
    }    
    
    /*  ---   ACTION METHODS   ---   */  
    
    public PageReference save() {
        try{
            
            OpportunityTeamMember tempTeamMember=new OpportunityTeamMember(UserID=currentTeamMemberList[0].UserId,
                                                                           OpportunityId=OppId,
                                                                           Primary_Secondary_Specialty_SE__c = currentTeamMemberList[0].Primary_Secondary_Specialty_SE__c,
                                                                           TeamMemberRole=currentTeamMemberList[0].TeamMemberRole);
            
            //Rev1.0 set OpportunityAccessLevel to Edit
            tempTeamMember.OpportunityAccessLevel = 'Edit';
            
            system.debug('#MN-Team Member to be inserted-'+tempTeamMember);                     
            
            //inserting the OpportunityTeamMember record
            insert tempTeamMember;
            
            system.debug('#### Opportunity Team Member record inserted successfully . . .');      
            
            /* Rev 1.0
// check whether the user is the owner of the current opportunity
if(IsOwner==False){

OpportunityShare temOpShare= new OpportunityShare(OpportunityId=OppId,
UserOrGroupId=currentTeamMemberList[0].UserId,
OpportunityAccessLevel=access); 

//Rev 1.0
temOpShare.OpportunityAccessLevel = 'Edit';

system.debug('#MN-Opportunity Share record to be inserted-'+temOpShare);
//inserting the OpportunityShare record
insert temOpShare;

}
*/
        }catch(System.DMLException e) {
            ApexPages.addMessages(e);
            system.debug('#MN-Exception -'+e.getMessage());
            
            CurrentOppList = [select id from Opportunity where Id= :OppId limit 1];
            if(CurrentOppList.size()==0){
                DataAvailable=false;
            }  
            return null;
        }
        
        // After Save, navigates to the main page        
        String url='/apex/Update_Sales_Team_Main?id='+OppId;
        PageReference pageref=new PageReference(url);
        return pageref;
        
    }
    
    public PageReference Cancel() {
        if(!DataAvailable){         
            CurrentOppList = [select id from Opportunity where Id= :OppId limit 1]; 
            if(CurrentOppList.size()==0){
                // Implies current opportunity is not available, navigates to the Opportunity HOME page 
                String url='/006/o';
                PageReference pageref=new PageReference(url);
                return pageref;
            }
        }   
        
        //navigates to the main page
        String url='/apex/Update_Sales_Team_Main?id='+OppId ;
        PageReference pageref=new PageReference(url);
        return pageref;             
        
    }
}