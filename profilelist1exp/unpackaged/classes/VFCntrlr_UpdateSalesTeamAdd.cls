/*
Description: Apex controller Class which contains the methods which help in adding new sales team members using VF page : "addSalesTeamMembers"
Version: 2.0

History:

1.0 - 18-Aug-2008 :  Creation
2.0 - 02-Sept-2008:  Updated ::  Added more test methods & comments
3.0 - 22-May-2014 : removed test method to new test class VFCntrlr_UpdateSalesTeamAddTest.
Author: Meera Nair/Krishnaprasad P
*/
/*
Revision    CR Number   Release No      Date            Modified By     Description
--------    ---------   ----------      -----------     ------------    -----------
1.0         13274       Sprint 13       22-Jul-2016    Carrie            To separate test method in a test class from UpdateSalesTeamAdd main class and change logic of the OpportunityShare to OpportunityTeamMember for OpportunityAccess
*/   


public class VFCntrlr_UpdateSalesTeamAdd {


/*  ---   VARIABLE DECLARATIONS   ---   */
    private List<Opportunity> CurrentOppList;
    private boolean DataAvailable=True;
    
    private List<OpportunityTeamMember> teamMemberList=new List<OpportunityTeamMember>();
    private List<OpportunityShare> shareList=new List<OpportunityShare>(); 
    
    private List<String> accessList=new String[]{};
    private String access;
    private string OppId= ApexPages.currentPage().getParameters().get('oid');
    
/*  ---   CONSTRUCTOR   ---   */
    
    public  VFCntrlr_UpdateSalesTeamAdd(){
        //getting current opportunity
        CurrentOppList=  [select id,Name,ownerid from Opportunity where Id = :OppId limit 1];  
        if(CurrentOppList.size()>0){        
            OppId=CurrentOppList[0].Id;
            //calls the method for creating a list of Team Members
            createTeamList();
        }
        else{
            DataAvailable=False;
        }    
     }
     
/*  ---   GET METHODS   ---   */
    public Opportunity getOpportunity(){
        return CurrentOppList[0];
    }
    public List<OpportunityTeamMember>  getOpportunityTeamMemberList(){
        
        /*
        system.debug('##KP: Limits.getDMLStatements()-'+ Limits.getDMLStatements());
        system.debug('##KP: Limits.getLimitDMLStatements()-'+Limits.getLimitDMLStatements());
        system.debug('##KP: Limits.getDMLRows()-'+ Limits.getDMLRows());
        system.debug('##KP: Limits.getLimitDMLRows()-'+ Limits.getLimitDMLRows());
        system.debug('##KP: Limits.getQueries()-'+ Limits.getQueries());
        system.debug('##KP: Limits.getLimitQueries()-'+ Limits.getLimitQueries());
        system.debug('##KP: Limits.getQueryRows()-'+ Limits.getQueryRows());
        system.debug('##KP: Limits.getLimitQueryRows()-'+ Limits.getLimitQueryRows());        
        */
        return teamMemberList;
    }
   /* public List<OpportunityShare> getOpportunityShareList(){
        return shareList;
    } */
    
    //Custom pick-list for OpportunityAccesslevel    
    public List<SelectOption> getItems(){
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('Read','Read Only'));
        options.add(new SelectOption('Edit','Read/Write'));
        return options;
    }
    
    public boolean getDataAvailable() {
        return DataAvailable;
    }
    
/*  ---   SET METHODS   ---   */
    public String getAccess(){
        return access;
    }
    public void setAccess(String accessLevel){
        System.debug(accessLevel);
        this.access=accessLevel;
        accessList.add(access);
    }
    
/*  ---   ACTION METHODS   ---   */  

    public pageReference Save(){
      
       boolean status=insertnewMembers();
       
       System.debug('#MN: After Insert : teamMemberList.size()='+teamMemberList.size()+'\n#MN: teamMemberList:'+teamMemberList);
       System.debug('#MN: After Insert : shareList.size()='+shareList.size()+'\n#MN: shareList:'+shareList);

       if(status==false){
           return null;
       }
       else{
           String url='/apex/Update_Sales_Team_Main?id='+ OppId;
           PageReference pageref=new PageReference(url);
           return pageref;
       }
    }   
    
    public pageReference Cancel() {
        if(!DataAvailable){  
            // Implies current opportunity is not available, navigates to the Opportunity HOME page 
            String url='/006/o';
            PageReference pageref=new PageReference(url);
            return pageref;
        }
            
        String url='/apex/Update_Sales_Team_Main?id='+ OppId;
        PageReference pageref=new PageReference(url);
        return pageref;
    }
    
    
    
    
    public pageReference SaveandMore() {
        
        //calling method to add new Team members
        boolean status=insertnewMembers();
        
        System.debug('#MN: After Insert : teamMemberList.size()='+teamMemberList.size()+'\n#MN: teamMemberList:'+teamMemberList);
        System.debug('#MN: After Insert : shareList.size()='+shareList.size()+'\n#MN: shareList:'+shareList);
        
        if(status==true){
            //clearing the team member & share lists
            teamMemberList.clear();
            shareList.clear();
            
            //recreating a fresh team member list
            createTeamList();               
            
        }
        else{
            CurrentOppList=  [select id,Name,ownerid from Opportunity where Id = :OppId limit 1];
        
            if(CurrentOppList.size()==0){
                DataAvailable=False;
            }
        }    
        return null;
    }
    
    
/*  ---   AUXILIARY METHODS   ---   */ 
    
    public boolean insertnewMembers(){
    
        //validates the input
        if(ValidateTeamMemberList()==false){
            return false;
        }
        else{
            Integer accessCount=0;
            System.debug('#MN:before removing nulls :teamMemberList.size():'+teamMemberList.size());
            
            try{
                if(teamMemberList.size()>0){
                    for(Integer index=0;index<teamMemberList.size();index++){
                        
                        //removes team member entries which do not have valid UserIds 
                        if(teamMemberList[index].userId==null){
                            teamMemberList.remove(index);
                            index--;
                            accessCount++;
                        }
                        
                        
                        else{
                            teamMemberList[index].opportunityId=OppId;
                            //Adds curresponding OpportunityShare entry only if the added user not the Opp Owner
                            if(teamMemberList[index].userId!=CurrentOppList[0].ownerid){
                                OpportunityShare shareMember=new OpportunityShare(opportunityId=OppId,OpportunityAccessLevel=accessList[accessCount],userorgroupid=teamMemberList[index].userId);
                                shareList.add(shareMember);
                            }
                            accessCount++;
                        }
                   
                    } //end of for loop
                    
                    System.debug('#MN: teamMemberList.size()='+teamMemberList.size()+'\n#MN: teamMemberList:'+teamMemberList);
                    System.debug('#MN: shareList.size()='+shareList.size()+'\n#MN: shareList:'+shareList);
                    
                    if(teamMemberList.size()>0)   
                        insert teamMemberList;
                    if(shareList.size()>0)
                        insert shareList;
                    
                }//end of if(teamMemberList.size()>0) block
            }//end of try block
            
            catch(Exception e){
                System.debug(e.getMessage());                      
                ApexPages.addMessages(e);                
                return False;                
            }
        return True;
        }        
    }      
    
    public void createTeamList(){
       
       OpportunityTeamMember teamMember;
       for(integer index=teamMemberList.size();index<5;index++){
            teamMember=new OpportunityTeamMember();
            /* 1.0 Start
            teamMember.OpportunityAccessLevel = 'Edit';     
            1.0 End */              
            teamMemberList.add(teamMember);
       }
    }
    
    public boolean ValidateTeamMemberList(){
        if(teamMemberList.size()>0){
            for(Integer index=0;index<teamMemberList.size();index++){
                if(teamMemberList[index].userId!=null){
                    if(teamMemberList[index].TeamMemberRole==null){
                        System.debug('inside ValidateTeamMemberList method'+teamMemberList[index]);
                        
                        //teamMemberList[index].TeamMemberRole.addError('You must enter a value');
                                               
                        ApexPages.Message msg = new ApexPages.Message(ApexPages.severity.ERROR,'[Row No:'+(index+1)+']  You must enter a valid value for the field: [Team Role]');
                        ApexPages.addMessage(msg);
                        return false; 
                    }                               
                }
            }
        } 
        return true;           
    }    

}//end of class VFCntrlr_UpdateSalesTeamAdd