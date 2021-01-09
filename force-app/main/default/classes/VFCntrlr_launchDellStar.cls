/*
Revision    CR Number   Release No      Date            Modified By     			 Description
--------    ---------   ----------      -----------     ------------   				 -----------
1.0                                     26-Feb-2009     Krishnaprasad P/Meera Nair   Apex controller Class which contains the methods which help in displaying and manipulating VF page : "launchDellStar"  
2.0         16136       FY19-DCE-0802   12-July-2018    Venkat Sharan   			 Removed debug statements and made code genric as part of code Reduce for the story 5240538
*/ 
public class VFCntrlr_launchDellStar {

    /*---------Variable Declaration-----------*/ 
    
    private List<Opportunity> currentOppList=new List<Opportunity>();
    private List<Account> partnerAccountList=new List<Account>();
    private List<User> userList=new List<User>();
    private String oppId;
    private String partnerAccId;
    private String langeLocalKey; 
    private String currentUserId;
    
    /*---------Constructor--------------------*/
    
    public VFCntrlr_launchDellStar(){        
        //Gets id of current User
        currentUserId=UserInfo.getUserId();
        
        //queries for user data
        userlist=[select id,LanguageLocaleKey,Contact.Accountid from User where id=:currentUserId];
        
        //Get opportunity id ,passed as a parameter
        oppId=ApexPages.currentPage().getParameters().get('oid');                
        
        //if id exists
        if(oppId!=null){            
                //Get details of current opportunity
                currentOppList=[Select id,Deal_Id__c,Deal_Registration_Status__c,PartnerAccountId from Opportunity where id=:oppId];
                
                //If opportunity has a partner account get account details
                if(currentOppList.size()>0 && currentOppList[0].PartnerAccountId!=null){
                    partnerAccountList=[Select id,Account_Country_Code__c,Account_Id__c,Partner_Relationship__c From Account Where id=:currentOppList[0].PartnerAccountId];
                }//end if               
        }//end if        
                
        //if the link was executed from the DealReg Home page
        if(partnerAccountList.size()==0){            
            //Get partner account id of current user            
            partnerAccId=userlist[0].Contact.Accountid;            
            
            //Get partner user account details
            if(partnerAccId!=null)
               partnerAccountList=[Select id,Account_Country_Code__c,Account_Id__c,Partner_Relationship__c from Account where id=:partnerAccId];
        }
    } //end of constructor
    
    /*------------GET Methods---------------*/
    public Opportunity getCurrentOpp(){
        if(currentOppList.size()==0){
            return (new Opportunity());
        }
        //else
        return currentOppList[0];
    }
    
    public Account getPartnerAccount(){
        if(partnerAccountList.size()==0){
            return (new Account()); 
        }
        //else
        return partnerAccountList[0];
    }
    
    public User getUserDetails(){
        return userlist[0];
    }  
}