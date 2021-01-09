/* 
History:
Version Date            Modified By     Description     
--------------------------------------------------------------------------------------
1.0     
2.0		30-JAN-2012		MenMee			CR6689 
*/

@isTest
private class VFCntrlr_OnePagerAccountPlan_Test {   
   	static User salesMgr;
 	static Account acct;
   	static SFDC_Acct_Plan__c acctPlan;
 
    static TestMethod void test_initializeController() {
           
        VFCntrlr_OnePagerAccountPlan controller;
                    
        System.debug('DEBUG: ***************** START test_initializeController *****************');
        
        CreateTestData(); //Rev 2.0
        
        System.debug('DEBUG: ACCOUNT PLAN ID= ' + acctPlan.Id);
         
        PageReference pr = Page.OnePagerAccountPlan;
        
        Test.setCurrentPage(pr);
        
        System.debug('DEBUG: Current Page URL: ' + ApexPages.currentPage().getUrl());
        System.assert(ApexPages.currentPage().getUrl().toLowerCase().contains('/apex/onepageraccountplan'));
        
        //Testing initialization without passing in 'id' parameter
        System.debug('DEBUG: TESTING INITIALIZATION WITHOUT ID PARAMETER.');
        
        try
        {
            controller = new VFCntrlr_OnePagerAccountPlan(new ApexPages.StandardController(acctPlan) );   
        }
        catch(Exception e)
        {           
            //Should throw an error 
            System.assert(e.getMessage().contains('There was a problem retrieving Account Plan.'));
        }
        
        //Testing initialization with a invalid 'id' parameter
        System.debug('DEBUG: TESTING INITIALIZATION WITH INVALID ID PARAMETER.');

        ApexPages.currentPage().getParameters().put('id', '0000000'); 
        
        try
        {
            controller = new VFCntrlr_OnePagerAccountPlan(new ApexPages.StandardController(acctPlan) );
        }
        catch(Exception e)
        {
            //Should throw an error 
            System.assert(e.getMessage().contains('Invalid id'));
        }
        
        //Testing initialization with a valid 'id'
        System.debug('DEBUG: TESTING INITIALIZATION WITH ID PARAMETER.');

        ApexPages.currentPage().getParameters().put('id', acctPlan.Id); 
        //ApexPages.currentPage().getParameters().put('format', 'pdf'); 
        
        controller = new VFCntrlr_OnePagerAccountPlan(new ApexPages.StandardController(acctPlan) );
        
        System.debug('DEBUG: ACCOUNT PLAN ID = ' + controller.getAccntPlanId() + ', ACCOUNT PLAN NAME = ' + controller.getAccntPlanName());
        
        //Check if Account Plan Name is retrieved
        System.assert(controller.getAccntPlanName() != '');
        
        System.debug('DEBUG: ***************** END test_initializeController *****************');
    }
    
    static testMethod void test_outputPageFunctions()
    {
        //This test method mainly executes the getter functions to get code-coverage
        System.debug('DEBUG: ***************** START test_outputPageFunctions *****************');
        
        CreateTestData(); //Rev 2.0
       
        System.debug('DEBUG: ACCOUNT PLAN ID= ' + acctPlan.Id);
        
        PageReference pr = Page.OnePagerAccountPlan;
        
        Test.setCurrentPage(pr);
        
        ApexPages.currentPage().getParameters().put('id', acctPlan.Id); 
        
        VFCntrlr_OnePagerAccountPlan controller = new VFCntrlr_OnePagerAccountPlan(new ApexPages.StandardController(acctPlan) );
        
        System.debug('DEBUG: RETRIEVING ACCOUNT PLAN OBJECT - ' + controller.getAccntPlan());
        System.assert(controller.getAccntPlan() != null);
        
        //No roles are selected
        controller.getContacts();
        
        //Set to select all roles for display
        controller.addAllRoles();
        controller.getContacts();
        
        
        System.debug('DEBUG: EXECUTING GETTER-FUNCTIONS');
        controller.getFormat();
        controller.getSelectedRptType();
        controller.getSelectedRptTypeDesc();
        
        
        controller.getAccntPlanName();
        controller.getAccntPlanId();
        controller.getAccntPlan();
        controller.getAccnt();
        controller.getAccntTeamMember();
        controller.getNumOfCon();
        controller.getAccntGoals();
        controller.getProdStrategies();
        controller.getRisks();
        controller.getProjects();
        controller.getTasks();
        controller.getOppty();
        controller.getCompetitiveInfo();
        controller.getContacts();
        
        controller.getDisplayProperty();
        
        controller.setSelectedRptType('INTERNAL');
        controller.getDisplayProperty();
        
        System.debug('DEBUG: ***************** END test_outputPageFunctions *****************');    
        

    }
    
    static testMethod void test_outputPageExceptions()
    {       
        //This test method force the controller to throw exception to get code coverage for try-catch blocks
        System.debug('DEBUG: ***************** START test_outputPageExceptions *****************');
        
        CreateTestData(); //Rev 2.0
      
        System.debug('DEBUG: ACCOUNT PLAN ID= ' + acctPlan.Id);
        
        PageReference pr = Page.OnePagerAccountPlan;
        
        Test.setCurrentPage(pr);
        
        ApexPages.currentPage().getParameters().put('id', acctPlan.Id); 
        
        VFCntrlr_OnePagerAccountPlan controller = new VFCntrlr_OnePagerAccountPlan(new ApexPages.StandardController(acctPlan) );
        controller.addAllRoles();  
        controller.setIsExceptionTest(true);
        
        try
        {
            controller.getAccnt();
        }
        catch(dellUtil.DellException e)
        {
            System.debug(e.getMessage());
        }
        
        try
        {
            controller.getAccntTeamMember();        
        }
        catch(dellUtil.DellException e)
        {
            System.debug(e.getMessage());
        }
                
        try
        {
            controller.getNumOfCon();
        }
        catch(dellUtil.DellException e)
        {
            System.debug(e.getMessage());   
        }
        
        try
        {
            controller.getAccntGoals();
        }
        catch(dellUtil.DellException e)
        {
            System.debug(e.getMessage());
        }
        
        try
        {
            controller.getProdStrategies();
        }
        catch(dellUtil.DellException e)
        {
            System.debug(e.getMessage());
        }
        
        try
        {
            controller.getRisks();
        }
        catch(dellUtil.DellException e)
        {
            System.debug(e.getMessage());
        }
        
        try
        {
            controller.getProjects();
        }
        catch(dellUtil.DellException e)
        {
            System.debug(e.getMessage());
        }
        
        try
        {
            controller.getTasks();
        }
        catch(dellUtil.DellException e)
        {
            System.debug(e.getMessage());
        }
        
        try
        {
            controller.getOppty();
        }
        catch(dellUtil.DellException e)
        {
            System.debug(e.getMessage());
        }
        
        try
        {
            controller.getCompetitiveInfo();
        }
        catch(dellUtil.DellException e)
        {
            System.debug(e.getMessage());
        }
        
        try
        {       
            controller.getContacts();
        }
        catch(dellUtil.DellException e)
        {
            System.debug(e.getMessage());
        }
        
        try
        {
            controller.initializeRoles();   
        }
        catch(dellUtil.DellException e)
        {
            System.debug(e.getMessage());
        }
        
        /*
        try
        {
            controller.initializeAccntPlan();   
        }
        catch(dellUtil.DellException e)
        {
            System.debug(e.getMessage());
        }
        */
        System.debug('DEBUG: ***************** END test_outputPageExceptions *****************');
    }
    
    
    
    static testMethod void test_optionPageFunctions()
    {
        //This test method simulates the actions done in the Option page    
        System.debug('DEBUG: ***************** START test_optionPageFunctions *****************');
        
        CreateTestData(); //Rev 2.0
        
        PageReference pr = Page.OnePagerAccountPlan;
        
        Test.setCurrentPage(pr);
        ApexPages.currentPage().getParameters().put('id', acctPlan.Id); 
        VFCntrlr_OnePagerAccountPlan controller = new VFCntrlr_OnePagerAccountPlan(new ApexPages.StandardController(acctPlan) );
        
        //Retrieving pick list values
        List<Schema.PicklistEntry> rolesPicklist = Contact.Decision_Making_Role__c.getDescribe().getPicklistValues();
        
        //The number of records in the role list should be the same as the total number of values available in the picklist
        System.debug('DEBUG: TOTAL NUMBER OF PICKLIST VALUES= ' + rolesPicklist.size());
        
        //Simulating "Add All Available Roles" button
        System.debug('DEBUG: TESTING addAllRoles');
        controller.addAllRoles();   
        
        //Selected roles should have the full list of roles, count should be the same
        System.assertEquals(rolesPicklist.size(),controller.getSelectedRoles().size());
        
        //Number of available roles should be empty as all moved to selected roles
        System.assertEquals(0,controller.getAvailableRoles().size());
        
        //Simulating "Remove All Selected Roles" button
        System.debug('DEBUG: TESTING removeAllRoles');
        controller.removeAllRoles();
        
        //Number of selected roles should be empty as all moved to available roles
        System.assertEquals(0,controller.getSelectedRoles().size());
        
        //Available roles should have the full list of roles, count should be the same
        System.assertEquals(rolesPicklist.size(),controller.getAvailableRoles().size());
        
        
        //Simulating "Add to list" button
        System.debug('DEBUG: SIMULATING ADD TO SELECTED LIST BUTTON');
        //now availableRoles should be a full list, selectedRoles empty
        List<String> addList = new List<String>();
        
        List<SelectOption> ar = controller.getAvailableRoles();
        List<SelectOption> sr = controller.getSelectedRoles();
        
        Integer arCountBefore = ar.size();
        Integer srCountBefore = sr.size();
        Integer arCountAfter = 0;
        Integer srCountAfter = 0;
        
        Integer offsetNum = 2;
        
        //To prevent error when if there is only one role in the list
        if (ar.size() == 1)
        {
            offsetNum = 1;        
        }
                
        //Will not execute if there are no roles for selection.
        //!!!WARNING!!!: If there are no roles in the list, the coverage of the testing will drop
        if(ar.size() > 0)
        {           
            
            for(Integer i = 0; i < offsetNum; i ++)
            {
                addList.add(ar.get(i).getValue());
            }           
            
            controller.setRolesToAdd(addList);
            System.assertEquals(addList.size(), controller.getRolesToAdd().size());
            controller.addRoles();
            
            arCountAfter = controller.getAvailableRoles().size();
            srCountAfter = controller.getSelectedRoles().size();
            
            System.debug('DEBUG: AVAILABLE ROLES COUNT - BEFORE=' + arCountBefore + ', AFTER=' + arCountAfter);
            System.debug('DEBUG: SELECTED ROLES COUNT - BEFORE=' + srCountBefore + ', AFTER=' + srCountAfter);
            
            System.assert(arCountBefore == arCountAfter + offsetNum);
            System.assert(srCountBefore == srCountAfter - offsetNum);
        }
        
        
        //Simulating 'Remove from list" button
        System.debug('DEBUG: SIMULATING REMOVE FROM SELECTED LIST BUTTON');
        //now availableRoles should  not be a full list, selectedRoles should have something
        List<String> removeList = new List<String>();
        
        ar = controller.getAvailableRoles();
        sr = controller.getSelectedRoles();
        
        arCountBefore = ar.size();
        srCountBefore = sr.size();
        arCountAfter = 0;
        srCountAfter = 0;
        
        offsetNum = 1;    
        
        if(sr.size() > 0)
        {
            for(Integer i = 0; i < offsetNum; i ++)
            {
                removeList.add(sr.get(i).getValue());
            }           
            
            controller.setRolesToRemove(removeList);
            System.assertEquals(removeList.size(), controller.getRolesToRemove().size());
            controller.removeRoles();
            
            arCountAfter = controller.getAvailableRoles().size();
            srCountAfter = controller.getSelectedRoles().size();
            
            System.debug('DEBUG: AVAILABLE ROLES COUNT - BEFORE=' + arCountBefore + ', AFTER=' + arCountAfter);
            System.debug('DEBUG: SELECTED ROLES COUNT - BEFORE=' + srCountBefore + ', AFTER=' + srCountAfter);
            System.assert(arCountAfter == arCountBefore + offsetNum);
            System.assert(srCountAfter == srCountBefore - offsetNum);
        }
        
        System.debug('DEBUG: SIMULATING THE SETTING OF REPORT TYPE');
        
        List<SelectOption> types = controller.getReportTypes();
        
        for(SelectOption t : types)
        {
            controller.SetSelectedRptType(t.getValue());    
            
            System.debug('DEBUG: REPORT TYPE= ' + controller.getSelectedRptType() + ', DESCRIPTION= ' + controller.getSelectedRptTypeDesc());
            System.assertEquals(controller.getSelectedRptType(), t.getValue());
            
            System.debug('DEBUG: CONFIDENTIAL MESSAGE=' + controller.getConfidentialDesc());
            System.assertNotEquals(controller.getConfidentialDesc(), '');
        }
        
        System.debug('DEBUG: SIMULATING GENERATE PDF BUTTON');
        System.assert(controller.openPDF().getUrl().toLowerCase().contains('/apex/onepageraccountplan'));
        
        
    }
    
    //Rev 2.0
    private static void CreateTestData() {    	
		
		List<Profile> userProfile= [select id,name from profile where name like '%Sales%' order by name limit 2 ];        
        salesMgr = new User(
            Username='testUser1'+System.currentTimeMillis()+'@test.com',
            Alias = 'test', 
            Email='test1@dell.com', 
            FirstName='Tfirst A', 
            LastName='TLast',
            ProfileId = userProfile[0].Id, 
            LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', 
            EmailEncodingKey='UTF-8', 
            TimeZoneSidKey='America/Los_Angeles',
            Badge_Number__c='TEST12345',
            Title = 'Test Title'
        );
        insert salesMgr;
        
        //Creating new Acccount
        acct = new Account(name='TestMethodAccount01');
        insert acct;

        System.debug('DEBUG: ACCOUNT ID = ' + acct.Id);
         
        //Creating new Account Plan
        acctPlan = new SFDC_Acct_Plan__c(name='TestPlan01',Account__c=acct.Id, Sales_Manager__c = salesMgr.Id);
        insert acctPlan;
    }
}