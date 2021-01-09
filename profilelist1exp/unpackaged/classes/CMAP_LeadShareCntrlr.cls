/* 
REVISION HISTORY
================
Version     Author      Date            Release#    CR#              Description
-------     ------      ----            --------    ---             -----------
1.0         Annie        08-Aug-2013     14.10      8603 FR 8.3     Controller To enable sharing.
2.0         Jiji         25-Sep-2013     14.10      0808 CRQ        Adding of User Lookup and Error Message when Share button is clicked
3.0         Jiji         26-Sep-2013     14.10      8603            Defect: 81468
3.1         Josie        13-Oct-2015     16.10      12085           Adding Profile "GBL Marketing Operations Admin" for Channel Lead 2.0
*/

public class CMAP_LeadShareCntrlr {
    public Lead leadRecord {get;set;} 
    public String leadId {get;set;}
    List<LeadShare> ShareList = new List<LeadShare>();
    
    //2.0 CRQ code Added
    List<Group> groupId =new List<Group>();
    List<GroupMember> grpMemList = new List<GroupMember>();
    GroupMember grpMem;
    Lead leadRec = new Lead();
    string profileName;     
    List<profile> profile = new List<Profile>();
    string strOwner;    
    User user;
    public boolean showPage {get;set;}
    public boolean showPage2 {get;set;}
    //2.0 CRQ code end
    
    public CMAP_LeadShareCntrlr (ApexPages.StandardController stdController) {
         leadRecord = new Lead();
         leadId = ApexPages.currentPage().getParameters().get('Id');
         showPage = false;
         showPage2 = false;
         //2.0 CRQ code Added
         leadRec = [Select Name, Owner.Name,Owner.Type,ownerId,CreatedById from Lead where Id =:leadId];
         strOwner = leadRec.ownerId;
         Id profileId = UserInfo.getProfileId();         
         Id userId= UserInfo.getUserId();
         user = [Select Id,Name,Profile_Name__c from User where Id = :userId];                
         profile = [Select Name from Profile where Id = :profileId Limit 1];
         profileName = profile[0].Name;
         If(strOwner.startsWith('00G') && leadRec.owner.Name.Contains('Allocation')){
             grpMemList = [select UserOrGroupId from GroupMember where GroupId = :LeadRec.OwnerId and UserOrGroupId = :userId];
         }
         //strOwner = leadRec.ownerId;         
         //2.0 CRQ code end
    }
    
    //2.0 CRQ code Added
    public PageReference Redirect() {
        try {
            // v3.1 - Added "|| profileName.contains('GBL Marketing Operations Admin')" in the below if condition.
            if(user.Id == leadRec.ownerId || user.Id == leadRec.CreatedById || profileName.contains('GBL Channel Marketing') || profileName.contains('GBL Marketing Operations Admin')) {
                 showPage = true;
            }
            else {
                if(strOwner.startsWith('00G') && leadRec.Owner.Name.Contains('Allocation')) {
                    // Check current user is a member of that queue                    
                    if(grpMemList.size() == 0){
                        PageUtils.AddError('Only Lead owner, submitter, Channel Marketing user or a member of the assigned queue will be able to share the Lead record');
                        showPage2 = true;
                    }
                    //Ver 3.0: Defect: 81468
                    else {
                        showPage = true;
                    }
                    //Ver 3.0: Defect: 81468
                }
            }       
        }
        catch(Exception ex){
            ApexPages.addMessages(ex);
        }
        return null;        
    }
    //2.0 CRQ code end
    
    public PageReference save() {        
        try {
            //check user type
            //2.0 CRQ code Added
            //User userRecord = [Select Id, UserType from User where Id = :leadRecord.Partner_User__c];    
            User userRecord = [Select Id, UserType from User where Id = :leadRecord.User__c];   
            //2.0 CRQ code end
            
            if(userRecord.Usertype == 'Standard') {
                LeadShare ldShare = new LeadShare();
                ldShare.LeadId = leadId;
                //2.0 CRQ code Added
                //ldShare.UserOrGroupId = leadRecord.Partner_User__c;
                ldShare.UserOrGroupId = leadRecord.User__c;
                //2.0 CRQ code end
                ldShare.LeadAccessLevel = 'read';                
                ShareList.add(ldShare);
                Database.SaveResult[] ShareInsertResult = Database.insert(ShareList,false);  
                return (PageUtils.redirect('/'+leadId)); 
            }
            else {               
                PageUtils.AddError('Sharing is not available for partner users. Please use the “reassign” option if you wish to assign this lead to a new partner user.');              
            }
        }
        catch(Exception ex){
            ApexPages.addMessages(ex);
        }         
        return null;
    }
    
    public PageReference Cancel() {
        return(PageUtils.redirect('/'+leadId)); 
    }
    
}