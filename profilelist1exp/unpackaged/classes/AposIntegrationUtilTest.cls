public class AposIntegrationUtilTest {
    
    /*
    webservice String  accountID                {set;get;}
        webservice String  firstname                {set;get;} 
        webservice String  lastname                 {set;get;}       
        webservice String  phone                    {set;get;} 
        webservice String  email                    {set;get;} 
        webservice String  preferredContactMethod   {set;get;}  
        webservice String  bestTimeToCall           {set;get;} 
        public     String  status                   {set;get;}
        public     String  decisionMakingRole       {set;get;}
        public     String  purchaseInfOver          {set;get;}
        public     String  jobFunction              {set;get;}
        webservice String  title                    {set;get;}
    
    
    */
    
    
    private static testmethod void testCreateContact(){
        
        Map<String, String> sParams;

        //Create Account
        sParams = new Map<String, String>();
        sParams.put('str_name', 'Test Account');
        Account testAcc = (Account) TestDataGenerator.getObject(new Account(), 1, sParams)[0];
        sParams.clear();    
        
        //Create User
        TriggerExecutionController.setSkipUserTriggers(true);
        User testUser = (User) TestDataGenerator.getObject(new User(), 1, sParams)[0];
        sParams.clear();
    
        //Create Account Team Member
        sParams.put('str_AccountId', testAcc.Id);
        sParams.put('str_UserId', testUser.Id);
        sParams.put('str_TeamMemberRole', 'APOS Inside Sales Rep');
        AccountTeamMember acctTM = (AccountTeamMember) TestDataGenerator.getObject(new AccountTeamMember(), 1, sParams)[0];
        
        
        
        
        AposIntegrationUtil.AposContactObj newContactObj = new AposIntegrationUtil.AposContactObj();
        String tempAccountId = '';
        AposIntegrationUtil.AposResponseObj rsObj = new AposIntegrationUtil.AposResponseObj();  
        Integer recCount = [SELECT count() FROM contact where firstname='APOS' and lastname='TestUser' LIMIT 1];
        if(recCount == 0){          
            newContactObj.firstname='APOS'; 
            newContactObj.lastname ='TestUser';
            newContactObj.email    =''; 
            newcontactObj.phone    = '';
        }
        
        
        
        
        //List<AccountTeamMember> accountTeamMemberRec = [Select userId, accountID From AccountTeamMember WHERE TeamMemberRole='APOS Inside Sales Rep' limit 1];
        List<AccountTeamMember> accountTeamMemberRec = new List<AccountTeamMember>();
        accountTeamMemberRec.add(acctTM);
        
        system.assert(accountTeamMemberRec.size()>0);
        
        if(accountTeamMemberRec.size()>0){
            newContactObj.accountID = accountTeamMemberRec.get(0).accountId;
            tempAccountId = newContactObj.accountID;
        }       
        
        System.assertEquals(AposIntegrationUtil.isExistingContact(newContactObj),false);
        
        
        /*
        if(StringUtils.isBlank(newContactObj.phone) && StringUtils.isBlank(newContactObj.email)){
            rsObj.errorCode = AposConstants.ERROR_CONTACT_CREATION;
            rsObj.errorDesc = AposConstants.ERROR_CONTACT_CREATION_NO_EMAIL_PHONE_DESC;
            
        }*/
        TriggerExecutionController.setSkipContactTriggers(true);
        rsObj = AposIntegrationUtil.doCreateContact(newContactObj);
        System.assert(StringUtils.equalsIgnoreCase(rsObj.errorCode,AposConstants.ERROR_CONTACT_CREATION ));
        System.assert(StringUtils.equalsIgnoreCase(rsObj.errorDesc,AposConstants.ERROR_CONTACT_CREATION_NO_EMAIL_PHONE_DESC ));
        
        
            newContactObj.email    ='mytestuser@web.com'; 
            newcontactObj.phone    = '123123123';   
            newContactObj.accountID = null;
        
        System.debug('### pass here....1');
        TriggerExecutionController.setSkipContactTriggers(true);
        rsObj= AposIntegrationUtil.doCreateContact(newContactObj);
        System.debug('### pass here....1.1.');
        System.debug('### rsObj.errorCode = '+rsObj.errorCode);
        system.debug('### AposConstants.ERROR_CONTACT_CREATION ='+AposConstants.ERROR_CONTACT_CREATION);
        //uncomment by jessie
        //System.assert(StringUtils.equalsIgnoreCase(rsObj.errorCode,AposConstants.ERROR_CONTACT_CREATION ));
        //System.assert(StringUtils.equalsIgnoreCase(rsObj.errorDesc,AposConstants.ERROR_CONTACT_CREATION_DESC ));
        
        System.debug('### pass here....2');
        
        newContactObj.accountID = tempAccountId;
        system.debug('AposIntegrationUtil.isExistingContact(newContactObj):'+AposIntegrationUtil.isExistingContact(newContactObj));
        if(AposIntegrationUtil.isExistingContact(newContactObj) == false){
            system.assertNotEquals(AposIntegrationUtil.doCreateContact(newContactObj), null);
            
            TriggerExecutionController.setSkipContactTriggers(true);
            rsObj= AposIntegrationUtil.doCreateContact(newContactObj);
            
                        
            System.debug('### accountId in testCreateContact :'+newContactObj.accountID);
            System.debug('### errorCode in testCreateContact :'+rsObj.errorCode + ', desc:'+rsObj.errorDesc);
            System.debug('### Oppty ID in testCreateContact :'+rsObj.opptyId );
            //System.assertEquals(StringUtils.isBlank(rsObj.errorCode),false);
            //System.assertEquals(StringUtils.isBlank(rsObj.errorDesc),false);
            //TestUtils.assertNoErrorMessagesExist();
        }                                               
        
        
        
        //Ensure get the Apos inside sales rep role from the account
        if(accountTeamMemberRec.size()>0){
            
        system.assertEquals(AposIntegrationUtil.doGetAccountOwner(rsObj, newContactObj)==null,false);
        
        Map<String, String> sParams2;

        //Create Account
        sParams2 = new Map<String, String>();
        sParams2.put('str_name', 'Test Account2');
        Account testAcc2 = (Account) TestDataGenerator.getObject(new Account(), 1, sParams2)[0];
        sParams2.clear();   
        
        //Create User
        User testUser2 = (User) TestDataGenerator.getObject(new User(), 1, sParams2)[0];
        sParams2.clear();
    
        //Create Account Team Member
        sParams2.put('str_AccountId', testAcc2.Id);
        sParams2.put('str_UserId', testUser2.Id);
        sParams2.put('str_TeamMemberRole', 'Account Executive');
        AccountTeamMember acctTM2 = (AccountTeamMember) TestDataGenerator.getObject(new AccountTeamMember(), 1, sParams2)[0];
        
        
        //List<AccountTeamMember> noneAccountTeamMemberRec = [Select userId, accountID From AccountTeamMember WHERE TeamMemberRole!='APOS Inside Sales Rep' limit 1];
        List<AccountTeamMember> noneAccountTeamMemberRec = new List<AccountTeamMember>();
        noneAccountTeamMemberRec.add(acctTM2);
        
        newcontactObj.accountID = noneAccountTeamMemberRec.get(0).accountId;
        
        System.debug('### newContactObj.accountID = '+newContactObj.accountID);
        System.debug('### rsObj.errorCode = '+rsObj.errorCode);
        rsObj.errorCode = '';
        rsObj.errorDesc = '';
        rsObj = AposIntegrationUtil.doGetAccountOwner(rsObj, newContactObj);
        System.assertEquals(rsObj.errorCode,AposConstants.ERROR_APOS_INSIDE_REP_NOT_EXIST );
        System.assertEquals(rsObj.errorDesc,AposConstants.ERROR_APOS_INSIDE_REP_NOT_EXIST_DESC );   
        
        System.debug('###Error code :' + rsObj.errorCode);
        
        newcontactObj.accountID = tempAccountId;
        rsObj.errorCode = '';
        rsObj.errorDesc = '';
        rsObj = AposIntegrationUtil.doGetAccountOwner(rsObj, newContactObj);
        System.assertEquals(StringUtils.isBlank(rsObj.errorCode),true);
        System.assertEquals(StringUtils.isBlank(rsObj.errorDesc),true);
            
        if(StringUtils.isBlank(rsObj.accountOwner)){
            System.assertEquals(StringUtils.isBlank(rsObj.errorCode),false);
            rsObj.accountOwner = accountTeamMemberRec.get(0).userId;
        }
        System.debug('### rsObj.accountOwner:'+rsObj.accountOwner);
        
        
        if(StringUtils.equalsIgnoreCase(rsObj.errorCode,AposConstants.ERROR_APOS_INSIDE_REP_NOT_EXIST) && StringUtils.isNotBlank(rsObj.accountOwner)){
                rsObj.errorCode = '';               
        }
        
        AposIntegrationUtil.AposOpportunityObj newOppty = new AposIntegrationUtil.AposOpportunityObj(null,  null);          
         Test.startTest();
        rsObj   = AposIntegrationUtil.doCreateOpportunity(rsObj,newOppty);  
        System.debug('### doCreateOpportunity rsObj.errorCode:'+rsObj.errorCode);
        System.assert(StringUtils.equalsIgnoreCase(rsObj.errorCode,AposConstants.ERROR_OPPTY_CREATION ));
        System.assert(StringUtils.equalsIgnoreCase(rsObj.errorDesc,AposConstants.ERROR_OPPTY_CREATION_DESC ));
         
        /* rsObj.errorCode ='';
        rsObj.errorDesc ='';
        newOppty = new AposIntegrationUtil.AposOpportunityObj(rsObj.accountOwner,  newContactObj.accountID);            
        rsObj   = AposIntegrationUtil.doCreateOpportunity(rsObj,newOppty);  
        System.assertEquals(StringUtils.isBlank(rsObj.errorCode),true);
                
        
        system.assert(StringUtils.equalsIgnoreCase(rsObj.errorCode, AposConstants.ERROR_OPPTY_CREATION)==false);    
        System.debug('Contact id in doCreateOppty=='+rsObj.contactId);
        System.assertEquals(StringUtils.isBlank(rsObj.errorCode),true);*/
        
                
        AposIntegrationUtil.AposServiceTagObj paramServiceTag = new  AposIntegrationUtil.AposServiceTagObj();
        paramServiceTag.serviceTagNumber = 'WXYZ123';
        paramServiceTag.domainName = 'Server';
        paramServiceTag.serviceContractType = 'NT';
        paramServiceTag.expirationDate = System.today();
        paramServiceTag.customerNumber = '60148363';
        paramServiceTag.accountID = newContactObj.accountID;
        List<AposIntegrationUtil.AposServiceTagObj> paramServiceTagList = new List<AposIntegrationUtil.AposServiceTagObj>();
        paramServiceTagList.add(paramServiceTag);
        
        System.debug('### doCreateServiceTag oppty id :'+rsObj.opptyId);
        
        String tempOpptyId = rsObj.opptyId;
        /*rsObj.opptyId      = null;        
        rsObj   = AposIntegrationUtil.doCreateServiceTag(rsObj,paramServiceTagList);
        system.debug('### rsObj error:'+rsObj.errorCode);
        System.assert(StringUtils.equalsIgnoreCase(rsObj.errorCode,AposConstants.ERROR_SERVICETAG_CONTRACTS_CREATION ));
        System.assert(StringUtils.equalsIgnoreCase(rsObj.errorDesc,AposConstants.ERROR_SERVICETAG_CONTRACTS_CREATION_DESC ));
        */
        rsObj.opptyId      = tempOpptyId;
        rsObj.errorCode ='';
        rsObj.errorDesc ='';
        
       
        rsObj   = AposIntegrationUtil.doCreateServiceTag(rsObj,paramServiceTagList);
        System.assertEquals(StringUtils.isBlank(rsObj.errorCode),true);
        
        System.debug('###Oppty id :'+rsObj.opptyId + ', rsObj.contactId :'+rsObj.contactId);
        Test.stopTest();
        
        rsObj.opptyId      = null;      
        rsObj = AposIntegrationUtil.doCreateOppContactRole(rsObj,rsObj.opptyId,rsObj.contactId);
        System.debug('### doCreateOppContactRole errorcode:'+rsObj.errorCode);          
        System.assert(StringUtils.equalsIgnoreCase(rsObj.errorCode,AposConstants.ERROR_CONTACT_ROLE_NO_OPPTY_CONTACT_ID ));
        System.assert(StringUtils.equalsIgnoreCase(rsObj.errorDesc,AposConstants.ERROR_CONTACT_ROLE_NO_OPPTY_CONTACT_ID_DESC ));
            
        rsObj.opptyId      = tempOpptyId;
        rsObj.errorCode ='';
        rsObj.errorDesc ='';    
        rsObj = AposIntegrationUtil.doCreateOppContactRole(rsObj,rsObj.opptyId,rsObj.contactId);
        
        //System.assertEquals(StringUtils.isBlank(rsObj.errorCode),true); 
        system.assertNotEquals(rsObj==null, true);
        system.assertNotEquals(rsObj.errorCode, Aposconstants.ERROR_APOS_INSIDE_REP_NOT_EXIST);
        
        
        
        }
    }
    
    private static testmethod void testUpdateContact(){
        AposIntegrationUtil.AposResponseObj rsObj = new AposIntegrationUtil.AposResponseObj();
        List<contact> record = [SELECT firstname, lastname, email, phone, accountId FROM contact LIMIT 1];
        AposIntegrationUtil.AposContactObj existingContactObj = new AposIntegrationUtil.AposContactObj();
        
        rsObj = AposIntegrationUtil.doUpdateContact(existingContactObj);
        system.debug('### testUpdateContact rsObj error:' + rsObj.errorCode);
        System.assert(rsObj!=null);
        
        existingContactObj.accountId=record.get(0).accountId; 
        existingContactObj.firstname=record.get(0).firstname;
        existingContactObj.lastname=record.get(0).lastname;
        existingContactObj.email=record.get(0).email;   
        existingContactObj.phone=record.get(0).phone;       
        
        System.debug('### AccountId:'+existingContactObj.accountId);
        System.debug('### firstname:'+existingContactObj.firstname);  
        System.debug('### lastname:'+existingContactObj.lastname);
                    
        System.assertEquals(AposIntegrationUtil.isExistingContact(existingContactObj),true);    
        if(AposIntegrationUtil.isExistingContact(existingContactObj)){
            if(!StringUtils.equalsIgnoreCase(existingContactObj.phone, '1234567')){existingContactObj.phone='1234567';}
            if(!StringUtils.equalsIgnoreCase(existingContactObj.email, 'acme@web.com')){existingContactObj.email='acme@web.com';}
            if(!StringUtils.equalsIgnoreCase(existingContactObj.title, 'DR')){existingContactObj.title='DR';}
            
            
            String tempFirstName         = existingContactObj.firstname; 
            existingContactObj.firstname = null;            
            rsObj= AposIntegrationUtil.doUpdateContact(existingContactObj);
            System.assert(StringUtils.equalsIgnoreCase(rsObj.errorCode,AposConstants.ERROR_CONTACT_UPDATE_NO_FIRSTLAST_NAME ));
            System.assert(StringUtils.equalsIgnoreCase(rsObj.errorDesc,AposConstants.ERROR_CONTACT_UPDATE_NO_FIRSTLAST_NAME_DESC ));
        
            existingContactObj.firstname = tempFirstName;   
            rsObj.errorCode ='';
            rsObj.errorDesc ='';
            rsObj= AposIntegrationUtil.doUpdateContact(existingContactObj);                     
//          System.assertEquals(StringUtils.isBlank(rsObj.errorCode),true);
        }               
        
        /*
        System.assertEquals(AposIntegrationUtil.doGetAccountOwner(rsObj, existingContactObj)!=null, true);
        rsObj = AposIntegrationUtil.doGetAccountOwner(rsObj, existingContactObj);
        */          
    }
    
     private static testmethod void testCreateOpportunity(){
        AposIntegrationUtil.AposResponseObj rsObj = new AposIntegrationUtil.AposResponseObj();
        //List<contact> record = [SELECT firstname, lastname, email, phone, accountId FROM contact LIMIT 1];
        AposIntegrationUtil.AposContactObj existingContactObj = new AposIntegrationUtil.AposContactObj();
        
        Map<String, String> mapParams;

        //Create Account
        mapParams = new Map<String, String>();
        mapParams.put('str_name', 'Test Account');
        Account testAcc = (Account) TestDataGenerator.getObject(new Account(), 1, mapParams)[0];
        mapParams.clear();  
        
        TriggerExecutionController.setSkipContactTriggers(true);
        rsObj = AposIntegrationUtil.doCreateContact(existingContactObj);
        existingContactObj.email    ='mytestuser@web.com'; 
        existingContactObj.phone    = '123123123';   
        existingContactObj.accountID = testAcc.id;
        
        AposIntegrationUtil.AposServiceTagObj paramServiceTag = new  AposIntegrationUtil.AposServiceTagObj();
        paramServiceTag.serviceTagNumber = 'WXYZ123';
        paramServiceTag.domainName = 'Server';
        paramServiceTag.serviceContractType = 'NT';
        paramServiceTag.expirationDate = System.today();
        paramServiceTag.customerNumber = '60148363';
        paramServiceTag.accountID = existingContactObj.accountID;
        List<AposIntegrationUtil.AposServiceTagObj> listParamServiceTag = new List<AposIntegrationUtil.AposServiceTagObj>();
        listParamServiceTag.add(paramServiceTag);
        
        test.startTest();
            AposIntegrationUtil.createOpportunity(existingContactObj,listParamServiceTag);
        test.stoptest();
         
     }
     
     
    
    
    
    
    
}