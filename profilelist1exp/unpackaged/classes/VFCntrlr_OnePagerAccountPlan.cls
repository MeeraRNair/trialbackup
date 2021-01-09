/***********************************************************
* Name          : VFCntrlr_OnePagerAccountPlan
* Description   : Controller for VisualForce page OnePagerAccountPlan
*                 and OnePagerAccountPlanOption
* ---------------------------------------------------------
* Revision  Name      Date          Description
* 1.0       Ray                     Created
* 2.0       Ray       23-Jun-2009   CR1402,1405-1411. Replaced getConfidentialDesc 
*                                    and getSelectedRptTypeDesc to return value from Custom Label
* 3.0    Nooryati  04-Apr-2011    Add Project Start QTR, Project End QTR, Project Start Year, Project End Year fields in 
*                    the PDF output if the Customer Project fields are in the PDF
* 2.4       Azwanti 17/06/2011  R12.7 CR6227:added "Closed Objective Details" field for Account Goals
*
*
************************************************************/

public class VFCntrlr_OnePagerAccountPlan{

    Boolean isExceptionTest = false;
    boolean hasError = false;
    boolean isValidAccntPlan = false;

    String format = 'pdf';
    Id accntPlanId; 

    Id accntId;
    Integer numOfCon;
    SFDC_Acct_Plan__c accntPlan;
    Account accnt;
    Account_Goal__c[] accntGoals;
    AccountTeamMember[] accntTeamMember;
    SFDC_Strategy__c[] ProdStrategies;
    Risks_and_Mitigations__c[] risks;    
    Task[] tasks;    
    SFDC_Strategy2Oppty__c[] projects;
    Install_Base__c[] competitiveInfo;
    Opportunity[] oppty;
    Contact[] contacts;
            
    List<SelectOption> availableRoles = new List<SelectOption>();
    List<SelectOption> selectedRoles = new List<SelectOption>();
    List<SelectOption> fullAvailableRoles = new List<SelectOption>();
    
    String[] rolesToRemove = new String[]{}; //Used to capture highlighted roles to be removed
    String[] rolesToAdd = new String[]{}; //Used to capture highlighted roles to add
    
    String selectedRptType = 'CUSTOMER'; //default type is 'CUSTOMER'. At this stage it can be either 'INTERNAL' or 'CUSTOMER'
    List<SelectOption> reportTypes = new List<SelectOption> {new SelectOption('CUSTOMER','Print preview – Customer'),
                                                             new SelectOption('INTERNAL','Print preview – Internal')};
    
    //Ray 20090623: Commented in v2.0. Value are now retrieved from Custom Labels
    /* 
    //Usage note for Customer and Internal version
    //String CUSTOMER_RPT_DESC = 'FOR DELL AND CUSTOMER USE ONLY';
    //String INTERNAL_RPT_DESC = 'FOR DELL INTERNAL USE ONLY';
    
    //Confidential messages for Customer and Internal version
    //String CUSTOMER_CONFIDENTIAL_DESC = 'CONFIDENTIAL - DO NOT DISTRIBUTE TO ANY THIRD PARTY';
    //String INTERNAL_CONFIDENTIAL_DESC = 'DELL CONFIDENTIAL - DO NOT DISTRIBUTE EXTERNALLY';
    */
    
    public VFCntrlr_OnePagerAccountPlan (ApexPages.StandardController controller)
    {
        try {                
             //this.accntPlanId = System.currentPageReference().getParameters().get('id');
             isValidAccntPlan = true; 
             //Retrieves Account Plan information. This is initialized first to get information like Account ID
             //initializeAccntPlan();
             accntPlan = (SFDC_Acct_Plan__c)controller.getRecord()    ; 
                //this.accntPlanName = accntPlanName = [SELECT Name FROM SFDC_Acct_Plan__c WHERE Id = :accntPlanId].Name;
            accntPlanId = accntPlan.Id;
            initializeRoles();
            
            //Populate availableRoles with full list of available roles
            removeAllRoles();
        }
        catch(Exception e) {
            hasError = true;
            dellUtil.DellException de = new dellUtil.DellException('There was a problem initializing the page. ' + ' (' + e.getMessage() + ')');
            ApexPages.addMessages(de);
        }
    
    }    
    
    public boolean getHasError()
    {
        return hasError;        
    
    }
    
    /*
    public void initializeAccntPlan()
    {
        
        try
        {  
            throwTestException(isExceptionTest);  
                          
            List<SFDC_Acct_Plan__c> temp = [SELECT 
                                                            Account__c,
                                                            Description_Comments__c,
                                                            Growth_Plan_Margin__c,
                                                            Growth_Plan_Revenue__c,
                                                            Plan_Status__c,
                                                            Last_4Q_Revenue__c,
                                                            Last_4Q_Margin__c,
                                                            X4Q_Revenue_Plan__c,
                                                            X4Q_Margin_Plan__c,
                                                            Power_Sponsor_Decision_Maker__r.FirstName,
                                                            Power_Sponsor_Decision_Maker__r.LastName,
                                                            Power_Sponsor_Decision_Maker__r.Name,
                                                            Sponsor_Champion__r.FirstName,
                                                            Sponsor_Champion__r.LastName,
                                                            Sponsor_Champion__r.Name,
                                                            Name,
                                                            Plan_Starting_Fiscal_Year__c,
                                                            Plan_Starting_Quarter__c
                                                       FROM
                                                            SFDC_Acct_Plan__c
                                                       WHERE
                                                            Id=:accntPlanId];
                                                        
                
                if(temp.size() == 1)
                {
                    accntPlan = temp[0];
                }
                else
                {
                    isValidAccntPlan = false;
                    hasError = true;
                    throw new dellUtil.DellException('Unable to retrieve Account Plan ' + this.accntPlanId + '.');
                }               
        }
        catch(Exception e)
        {     
                System.debug('DEBUG:  Exception while retrieving Account Plan - ' + e.getMessage());         
                //throw new dellUtil.DellException('There was a problem retrieving Account Plan. Please contact the administrators.' + ' (' + e.getMessage() + ')');
                dellUtil.DellException de = new dellUtil.DellException('There was a problem retrieving Account Plan. The Account Plan may be invalid or you have insufficient access to view it. ' + ' (' + e.getMessage() + ')');
                ApexPages.addMessages(de);
         
        }   

    } 
    */
    
    public SFDC_Acct_Plan__c getAccntPlan()
    {
        return accntPlan;   
    }
   
   
    public String getAccntPlanName()
    {
        return accntPlan.Name;
    }
    
    
    public String getAccntPlanId()
    {
        return accntPlanId;
    }
    
    //On submit, set the selected report type
    public void setSelectedRptType(String rpttype)
    {
        selectedRptType = rpttype;
    }
    
    //Returns the usage note according to the report type
    public String getSelectedRptTypeDesc()
    {        
        //Ray 20090623: Modified to retrieve values from Custom Labels
        return selectedRptType == 'Customer' ? System.Label.Note_Usage_Customer : System.Label.Note_Usage_Internal;
    }
    
    //Returns the confidential message according to the report type
    public String getConfidentialDesc()
    {        
        //Ray 20090623: Modified to retrieve values from Custom Labels
        return selectedRptType == 'Customer' ? System.Label.Note_Confidential_Customer : System.Label.Note_Confidential_Internal;        
    }
        
    public String getSelectedRptType()
    {
        return selectedRptType;
    }
    
    //Return the list of available report types for selection
    public List<SelectOption> getReportTypes()
    {
        return reportTypes ;
    }
    
    public void initializeRoles()
    {       
        try
        {
            throwTestException(isExceptionTest);      

            fullAvailableRoles.clear();
            
            Schema.DescribeFieldResult rolesField = Contact.Decision_Making_Role__c.getDescribe();
            
            List<Schema.PicklistEntry> pickList = rolesField .getPicklistValues();
            
            for(Schema.PicklistEntry entry : pickList )
            {
                fullAvailableRoles.add(new SelectOption(entry .getValue(),entry .getLabel()));
            }  
        }   
        catch(Exception e)
        {
            System.debug('DEBUG:  Exception while retrieving Roles - ' + e.getMessage()); 
            hasError = true;
            //throw new dellUtil.DellException('There was a problem initializing Roles. Please contact the administrators.' + ' (' + e.getMessage() + ')'); 
            dellUtil.DellException de = new dellUtil.DellException('There was a problem initializing Roles. ' + ' (' + e.getMessage() + ')');
            ApexPages.addMessages(de);
        }     
    }
    
    public PageReference openPDF()
    {
        return Page.OnePagerAccountPlan;
    }

    public String[] getRolesToAdd()
    {
        return rolesToAdd;
    }

    public String[] getRolesToRemove()
    {
        return rolesToRemove;
    }
    
    //On submit, capture the selected roles to add
    public void setRolesToAdd(String[] rolesSelected)
    {
        rolesToAdd = rolesSelected;
    }
    
    //On submit, capture the selected roles to remove
    public void  setRolesToRemove(String[] rolesSelected)
    {
        rolesToRemove = rolesSelected;        
    }   
    
    //Remove selected roles to add from available roles list, add to selected roles list
    public void addRoles()
    {
        selectedRoles = addToList(selectedRoles, rolesToAdd  );
        availableRoles = removeFromList(availableRoles, rolesToAdd );    
    }
    
    //Clear available roles list, reinitialize selected roles list with full list
    public void addAllRoles()
    {
        availableRoles.clear();
        selectedRoles.clear();
        selectedRoles.addAll(fullAvailableRoles);
    }

    //Remove selected roles to remove from selected roles list, add to available roles list
    public void removeRoles()
    {
        availableRoles = addToList(availableRoles, rolesToRemove );
        selectedRoles = removeFromList(selectedRoles, rolesToRemove );
    }
    
    //Clear selected roles list, reinitialize available roles list with full list
    public void removeAllRoles()
    {
        availableRoles.clear();
        selectedRoles.clear();
        availableRoles.addAll(fullAvailableRoles);
    }
    
    public List<SelectOption> getAvailableRoles() {
        return availableRoles ;
    }  
       
    public List<SelectOption> getSelectedRoles() {
        return selectedRoles ;
    }
    
    //Generic function to remove items in <theRoles> from <theList>
    private List<SelectOption> removeFromList(List<SelectOption> theList, String[] theRoles)
    {
        boolean toRemove = false;
        
        Map<String, String> tempTheRoles = new Map<String, String> {};
        
        for (String role : theRoles)
        {
            tempTheRoles.put(role,role);
        }        
       
        List<SelectOption> newList = new List<SelectOption>();
        for(SelectOption listItem: theList)
        {
            if(!tempTheRoles.containsKey(listItem.getValue()))
            {
                newList.add(new SelectOption(listItem.getValue(), listItem.getLabel()));
            }            

        }
        
        return newList;
    }
    
    //Generic function to add items in <theRoles> to <theList>
    private List<SelectOption> addToList(List<SelectOption> theList, String[] theRoles)
    {
        boolean toAdd = true;
        
        List<SelectOption> newList = new List<SelectOption>();
        newList.addAll(theList);
        for(String role : theRoles)
        {
            newList.add(new SelectOption(role, role));   
        }       
        return newList;
    }
      
    public String getFormat()
    {
                
        return format;
        /*
        if(format != null)
        {
            return format;
        }
        else
        {
            return null;
        }
        */
    }
          
    public SFDC_Strategy2Oppty__c[] getProjects()
    {     
        if(!isValidAccntPlan)
        {
            return null;
        }
        
        try
        {
                throwTestException(isExceptionTest);

                projects = [SELECT 
                                Name,
                                Related_Opportunity__r.Name,
                                Comments__c, 
                                Project_Start_QTR__c,
                                Project_End_QTR__c, 
                                Project_Start_Year__c, 
                                Project_End_Year__c 
                            FROM
                                SFDC_Strategy2Oppty__c 
                            WHERE Acct_Plan__c = :accntPlan.Id
                            ORDER BY CreatedDate];                                
        }
        catch(Exception e)
        {        
                System.debug('DEBUG:  Exception while retrieving Projects - ' + e.getMessage());
                //throw new dellUtil.DellException('There was a problem retrieving Projects. Please contact the administrators.' + ' (' + e.getMessage() + ')');
                dellUtil.DellException de = new dellUtil.DellException('There was a problem retrieving Projects. Please contact the administrators.' + ' (' + e.getMessage() + ')');
                ApexPages.addMessages(de);  
                
            
        }   
        return projects;
    }
    
    public Task[] getTasks()
    {
        if(!isValidAccntPlan)
        {
            return null;
        }
        
        try
        {
        
                throwTestException(isExceptionTest);
                
                tasks = [SELECT
                            Subject,
                            ActivityDate,
                            Owner.FirstName,
                            Owner.LastName,
                            Owner.Name 
                         FROM
                             Task 
                         WHERE
                             What.Id=:accntPlan.Id
                         ORDER BY CreatedDate];
        }
        catch(Exception e)
        {        
                System.debug('DEBUG:  Exception while retrieving Activities - ' + e.getMessage());
                //throw new dellUtil.DellException('There was a problem retrieving Activities. Please contact the administrators.' + ' (' + e.getMessage() + ')');
                dellUtil.DellException de = new dellUtil.DellException('There was a problem retrieving Activities. Please contact the administrators.' + ' (' + e.getMessage() + ')');
                ApexPages.addMessages(de);  
        }   

        return tasks;
    }
    
    public Risks_and_Mitigations__c[] getRisks()
    {
        if(!isValidAccntPlan)
        {
            return null;
        }
            
        try
        {
            throwTestException(isExceptionTest);
            
            risks = [SELECT
                       Name,
                       Due_Date__c,
                       Mitigation__c,
                       Status__c
                   FROM
                       Risks_and_Mitigations__c
                   WHERE
                       Acct_Plan__c = :accntPlan.Id
                   ORDER BY CreatedDate];
                    
        }
        catch(Exception e)
        {        
                System.debug('DEBUG:  Exception while retrieving Risks - ' + e.getMessage());
                //throw new dellUtil.DellException('There was a problem retrieving Risks. Please contact the administrators.' + ' (' + e.getMessage() + ')');
                dellUtil.DellException de = new dellUtil.DellException('There was a problem retrieving Risks. Please contact the administrators.' + ' (' + e.getMessage() + ')');
                ApexPages.addMessages(de);  
        }   
         
        return risks;
    } 
    
    public SFDC_Strategy__c[] getProdStrategies()
    {
        if(!isValidAccntPlan)
        {
            return null;
        }
        
        try
        {
            throwTestException(isExceptionTest);
            
            ProdStrategies = [SELECT
                            Name,
                            Sponsor_Champion__r.FirstName,
                            Sponsor_Champion__r.LastName,
                            Sponsor_Champion__r.Name,
                            Power_Sponsor_Decision_Maker__r.FirstName,
                            Power_Sponsor_Decision_Maker__r.LastName,
                            Power_Sponsor_Decision_Maker__r.Name,
                            Enterprise_Business_Issue__c,
                            Enterprise_Solution_Goal__c,
                            X12_Month_Server_Revenue_Plan__c,
                            X12_Month_Storage_Revenue_Plan__c,
                            X12_Month_Notebooks_Revenue_Plan__c,
                            X12_Month_Workstation_Revenue_Plan__c,
                            X12_Month_Desktops_Revenue_Plan__c,
                            Clients_Business_Issue__c,
                            Clients_Solution_Goal__c,
                            Services_Solution_Goal__c,
                            Services_Business_Issue__c,
                            X12_Month_MDS_Revenue_Plan__c,
                            X12_Month_GICS_Revenue_Plan__c,
                            X12_Month_Software_Revenue_Plan__c,
                            X12_Month_Peripherals_Revenue_Plan__c,
                            Peripherals_Business_Issue__c,
                            Peripherals_Solution_Goal__c,
                            Description_Comments__c,
                            CreatedBy.FirstName,
                            CreatedBy.LastName,
                            CreatedBy.Name,
                            LastModifiedBy.FirstName,
                            LastModifiedBy.LastName,
                            LastModifiedBy.Name,
                            SFDC_Acct_Plan__r.Name,
                            X12_Month_ProSupport_Revenue_Plan__c,
                            X12_Month_ProManage_Revenue_Plan__c,
                            X12_Month_ProConsult_Revenue_Plan__c,
                            Customer_Business_Challenges_Objectives__c,
							IT_Implications__c,
							Sponsor_Champion__c,
							Business_Priority__c,
							Technology_Priority__c,
							Dell_s_Strategy_Response__c,
							When_do_you_plan_to_realize_Strategy__c,
							Region__c,
							Which_LOB_will_you_offer__c,
							What_Dell_Services_will_you_offer__c,
							Strategy_Potential_Product_Revenue__c,
							Strategy_Potential_Service_Revenue__c,
							Is_Dell_the_Incumbent_Vendor__c,
							Incumbent_Vendor__c,
							Top_Competitor_name_1__c,
							Top_Competitor_Strategy_1__c,
							Top_Competitor_name_2__c,
							Top_Competitor_Strategy_2__c,
							Strengths__c,
							Weaknesses__c,
							Opportunities__c,
							Threats__c
                            //Strategy_Starting_Fiscal_Year__c,
                            //Strategy_Starting_Month__c
                           FROM
                               SFDC_Strategy__c
                           WHERE
                               SFDC_Acct_Plan__c=:accntPlan.Id
                           ORDER BY CreatedDate];
        }
        catch(Exception e)
        {        
                System.debug('DEBUG:  Exception while retrieving Product Strategies - ' + e.getMessage());
                //throw new dellUtil.DellException('There was a problem retrieving Product Strategies. Please contact the administrators.' + ' (' + e.getMessage() + ')');
                dellUtil.DellException de = new dellUtil.DellException('There was a problem retrieving Product Strategies. Please contact the administrators.' + ' (' + e.getMessage() + ')');
                ApexPages.addMessages(de);  
        }                                        
 
        return ProdStrategies;
    }
    
    public Integer getNumOfCon()
    {
        if(!isValidAccntPlan)
        {
            return null;
        }
            
        numOfCon  = 0;
        
        
        try
        {
            throwTestException(isExceptionTest);
            
            numOfCon = [SELECT Count() FROM Contact WHERE AccountId=:accntPlan.Account__c];
        }
        catch(Exception e)
        {        
                System.debug('DEBUG:  Exception while retrieving Num. of Contacts - ' + e.getMessage());
                //throw new dellUtil.DellException('There was a problem retrieving Number of Contacts. Please contact the administrators.' + ' (' + e.getMessage() + ')');
                dellUtil.DellException de = new dellUtil.DellException('There was a problem retrieving Number of Contacts. Please contact the administrators.' + ' (' + e.getMessage() + ')');
                ApexPages.addMessages(de);  
        }
          
        return numOfCon;
    }
    
    
    public AccountTeamMember[] getAccntTeamMember()
    {
        if(!isValidAccntPlan)
        {
            return null;
        }
        
        try
        {
                        
            throwTestException(isExceptionTest);
        
            accntTeamMember = [SELECT
                                Id,
                                AccountTeamMember.User.LastName,
                                AccountTeamMember.User.FirstName,
                                AccountTeamMember.User.Name,
                                AccountTeamMember.TeamMemberRole
                              FROM
                                  AccountTeamMember, AccountTeamMember.User
                              WHERE
                                  AccountId=:accntPlan.Account__c
                              ORDER BY AccountTeamMember.User.FirstName];
        }
        catch(Exception e)
        {        
                System.debug('DEBUG:  Exception while retrieving Account Team Members - ' + e.getMessage());
                //throw new dellUtil.DellException('There was a problem retrieving Account Team Members. Please contact the administrators.' + ' (' + e.getMessage() + ')');
                dellUtil.DellException de = new dellUtil.DellException('There was a problem retrieving Account Team Members. Please contact the administrators.' + ' (' + e.getMessage() + ')');
                ApexPages.addMessages(de);
        }                                             
                    
     
        return accntTeamMember;
    }
 
    public Account getAccnt()
    {
        if(!isValidAccntPlan)
        {
            return null;
        }
        
        try
        {
            throwTestException(isExceptionTest);
            
            accnt = [SELECT
                        Id,
                        Name,
                        Does_Business_As__c,
                        NumberOfEmployees,
                        Segment_Description__c,
                        Est_Buying_Power__c,
                        RAD_Code__c,
                        Description
                    FROM
                        Account
                    WHERE
                        Id=:accntPlan.Account__c];
        }
        catch(Exception e)
        {        
                System.debug('DEBUG:  Exception while retrieving Account - ' + e.getMessage());
                //throw new dellUtil.DellException('There was a problem retrieving Account. Please contact the administrators.' + ' (' + e.getMessage() + ')');
                dellUtil.DellException de = new dellUtil.DellException('There was a problem retrieving Account. Please contact the administrators.' + ' (' + e.getMessage() + ')');
                ApexPages.addMessages(de);   
        }             
        
        return accnt;
    }
    
    public Account_Goal__c[] getAccntGoals()
    {
        if(!isValidAccntPlan)
        {
            return null;
        }        
        
        try
        {
            throwTestException(isExceptionTest);
                
            accntGoals = [SELECT
                            Name,
                            Account_Goal__c,
                            Key_Business_Problem__c,
                            Strengths_to_Leverage__c,
                            Potential_Barriers__c,
                            Dell_Account_Objective_Achieved__c,
                            Closed_Objective_Details__c //R2.4
                         FROM
                             Account_Goal__c
                         WHERE
                             Acct_Plan__c = :accntPlan.Id
                         ORDER BY CreatedDate]; 
        }
        catch(Exception e)
        {        
                System.debug('DEBUG:  Exception while retrieving Account Goals - ' + e.getMessage());
                //throw new dellUtil.DellException('There was a problem retrieving Account Goals. Please contact the administrators.' + ' (' + e.getMessage() + ')');
                dellUtil.DellException de = new dellUtil.DellException('There was a problem retrieving Account Goals. Please contact the administrators.' + ' (' + e.getMessage() + ')');
                ApexPages.addMessages(de);   
        }                           

        return accntGoals ;
    }
       
    public Install_Base__c[] getCompetitiveInfo()
    {
        if(!isValidAccntPlan)
        {
            return null;
        }
                   
        try
        {
                        
            throwTestException(isExceptionTest);
                
            competitiveInfo= [SELECT
                            Account__r.name,
                            Comments__c,
                            Dell_Penetration__c,
                            Fourth_Incumbent__c,
                            Fourth_Quantity__c,
                            LOB__c,
                            LOB_hyperlink__c,
                            LOB_text__c,
                            Primary_Incumbent__c,
                            Primary_Quantity__c,
                            Secondary_Incumbent__c,
                            Secondary_Quantity__c,
                            Third_Incumbent__c,
                            Third_Quantity__c,
                            Total_Dell_Quantity__c,
                            Total_Quantity__c,
                            CreatedBy.FirstName,
                            CreatedBy.LastName,
                            CreatedBy.Name,
                            LastModifiedBy.FirstName,
                            LastModifiedBy.LastName,
                            LastModifiedBy.Name     
                         FROM
                             Install_Base__c
                         WHERE
                             Account__c = :accntPlan.Account__c
                         ORDER BY LOB__c, CreatedDate];
        }
        catch(Exception e)
        {        
                System.debug('DEBUG:  Exception while retrieving Competitive Information - ' + e.getMessage());
                //throw new dellUtil.DellException('There was a problem retrieving Competitive Information. Please contact the administrators.' + ' (' + e.getMessage() + ')');
                dellUtil.DellException de = new dellUtil.DellException('There was a problem retrieving Competitive Information. Please contact the administrators.' + ' (' + e.getMessage() + ')');
                ApexPages.addMessages(de);   
        }             
        
         
        return competitiveInfo ;
    } 

    public Opportunity[] getOppty()
    {
        if(!isValidAccntPlan)
        {
            return null;
        }
            
        try
        {
            throwTestException(isExceptionTest);
                
            oppty = [ SELECT
                        Account.name,
                        Name,
                        StageName,
                        Total_Margin__c,
                        Amount,
                        ExpectedRevenue                         
                     FROM
                         Opportunity
                     WHERE
                         Account.Id = :accntPlan.Account__c and StageName!='Win - 100%' and StageName!='Lost, Cancelled - 0%'
                     ORDER BY CreatedDate];
        }
        catch(Exception e)
        {        
                System.debug('DEBUG: Exception while retrieving Opportinities - ' + e.getMessage());
                //throw new dellUtil.DellException('There was a problem retrieving Opportunities. Please contact the administrators.' + ' (' + e.getMessage() + ')');
                dellUtil.DellException de = new dellUtil.DellException('There was a problem retrieving Opportunities. Please contact the administrators.' + ' (' + e.getMessage() + ')');
                ApexPages.addMessages(de);    
        }                  
                       
        return oppty;
    }
    
    
    public Contact[] getContacts()
    {
        if(!isValidAccntPlan)
        {
            return null;
        }
            
        if(selectedRoles.size() <= 0)
        {
            return null;
        }
 
        String[] roles = new String[]{};

        try
        {
                        
            throwTestException(isExceptionTest);
                
            for(Integer i=0; i < selectedRoles.size(); i++)
            {
                roles.add(selectedRoles.get(i).getValue());
            }

             contacts=[SELECT name,
                             FirstName,
                             LastName,
                             Decision_Making_Role__c                     
                         FROM 
                              contact
                        WHERE 
                             Account.Id=:accntPlan.Account__c 
                         AND
                             Decision_Making_Role__c IN :roles
                         ORDER BY FirstName];
        }
        catch(Exception e)
        {        
                System.debug('DEBUG: Exception while retrieving Contacts - ' + e.getMessage());
                //throw new dellUtil.DellException('There was a problem retrieving Contacts. Please contact the administrators.' + ' (' + e.getMessage() + ')');
                dellUtil.DellException de = new dellUtil.DellException('There was a problem retrieving Contacts. Please contact the administrators.' + ' (' + e.getMessage() + ')');
                ApexPages.addMessages(de);       
        }          


        return contacts; 
   }
   
   //This function is called from the Test class only to force exceptions.
   public void setIsExceptionTest(Boolean b)
   {
        this.isExceptionTest = b;
   }   
   
   //Used to hide fields that need to be hidden from Customer version
   //Only support CUSTOMER version for now
   public String getDisplayProperty()
   {   
       return selectedRptType == 'CUSTOMER' ? 'none' : ''; 
   }
   
   private void throwTestException(boolean bool)
   {
        if(bool)
        {
                throw new dellUtil.DellException('TESTMETHOD EXCEPTION TESTING.');
        }       
   }
   
    public string formatCurrency(string curr , Double value){
   	if(value != null && value != 0)
   		return curr + string.valueOf(value);
   	else 
   		return '';
   	
   }
}