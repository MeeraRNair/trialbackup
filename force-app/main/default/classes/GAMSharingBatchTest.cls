/*
Author: Natesh Alagiri

History:
Version Date            Modified By     Description     
--------------------------------------------------------------------------------------
1.0     01-Jul-2011     Natesh Alagiri  Created for CR6236 and CR6238
1.1     21-Dec-2011     Krishna			Kept the sales channel group name in custom label
1.2		10-Jan-2012		Krishna			(CRQ 0257 R13.1)Changed the filter logic on Sales channel Group from Name field to Group Id field
*/
@isTest
private class GAMSharingBatchTest{
	public static Sales_Channel_Group__c SalesChannelGroup;
	public static List<Account> GlobalAccountList = new List<Account>();
	public static List<Account> ChildAccountList = new List<Account>();
	public static List<User> testUserList = new List<User>();
	public static List<AccountTeamMember> testACTList = new List<AccountTeamMember>();
	public static Group GlobalAccountGroup = new Group();
	public static List<GroupMember> grpMemList = new List<GroupMember>();
	public static List<AccountShare> accShareList = new List<AccountShare>();
	public static List<User> SysAdminUserList = createSysAdminUsers();
	public static String GLOBAL_SALES_CHANNEL_GROUP_IDENTIFIER = StringUtils.defaultString(Label.GAM_Global_sales_channel_group_identifier);
	public static Set<Id> ATMIds1 = new Set<Id>();
	public static Set<Id> ATMIds2 = new Set<Id>();
	public static Id AccountId1;
	public static Id AccountId2;
	
	/*
	static testMethod void myUnitTest() {
		//Profile sysAdminProfile = [SELECT Id, Name FROM Profile WHERE Name LIKE 'System Administrator' LIMIT 1];
		//SysAdminUserList = [SELECT Id FROM user WHERE ProfileId=:sysAdminProfile.Id AND IsActive = TRUE LIMIT 3];
		
		createGlobalAccounts();
		createChildAccounts();
		createGroup();
		createAccountTeamMember();
		createGroupMember();
		createAccountShare();
		
		Test.startTest();
		//deleting GAM groups of the accounts which are not global account anymore.
		Map<String,String> GAMgroupNameMap = new Map<String,String>();
		Map<String,Id> GAMGroupNameToIdMap = new Map<String,Id>();
		List<Group> groupListTodelete = new List<Group>();
		Set<Id> GroupIdSet = new Set<Id>();
		String message = '#Started deleting unwanted Groups at :' + DateTime.now() +  '';
		//global account query
		for(Account acc :[SELECT Id, Name, Account_Id__c
						  FROM Account 
						  WHERE Status__c IN ('Active','A')
						  AND Sales_Channel__r.Group_ID__c = :GLOBAL_SALES_CHANNEL_GROUP_IDENTIFIER
						  AND Account_Type_Integration__c = 'PAR Account'
						  AND Account_ID__c like 'Test10101010%']){
			GAMgroupNameMap.put('GAM:' + acc.Account_Id__c,'GAM:' + acc.Account_Id__c);
		}
		for(Group groupItem :[SELECT Id, Name 
							  FROM Group
							  WHERE Name like 'GAM:%']){
			
			if(!GAMgroupNameMap.containsKey(groupItem.Name)){
				groupListTodelete.add(groupItem);
			}
			else{
				GAMGroupNameToIdMap.put(groupItem.Name,groupItem.Id);
				GroupIdSet.add(groupItem.Id);
			}
		}
		if(groupListTodelete.size()>0){
			database.delete(groupListTodelete,false);
		}			
		message += '\n#Finished deleting ' + groupListTodelete.size()+ ' unwanted Group(s) at :' + DateTime.now() +  '';
		GAMbatchJobUtils.sendOptionalNotification('GAM : Starting Account Share manipulation job' , message);
		
		
		GAMSharingBatch batchObj = new GAMSharingBatch();
		batchObj.query = 'SELECT Id, Name, Account_ID__c FROM Account '+ 
						 'WHERE (Status__c = \'Active\' OR Status__c = \'A\') AND '+
						 'Sales_Channel__r.Group_ID__c = \''+ GLOBAL_SALES_CHANNEL_GROUP_IDENTIFIER+'\' AND '+
						 'Account_Type_Integration__c = \'PAR Account\' AND '+
						 'Account_ID__c = \'Test101010101\'';						 
		batchObj.GAMGroupNameToIdMap = GAMGroupNameToIdMap;
		batchObj.GroupIdSet = GroupIdSet;
		batchObj.isTest = True;
		Id batchprocessid = database.executebatch(batchObj,1);
		
		GAMSharingBatch batchObj1 = new GAMSharingBatch();
		batchObj1.query = 'SELECT Id, Name, Account_ID__c FROM Account '+ 
						 'WHERE (Status__c = \'Active\' OR Status__c = \'A\') AND '+
						 'Sales_Channel__r.Group_ID__c = \''+GLOBAL_SALES_CHANNEL_GROUP_IDENTIFIER+'\' AND '+
						 'Account_Type_Integration__c = \'PAR Account\' AND '+
						 'Account_ID__c = \'Test101010102\'';
		batchObj1.GAMGroupNameToIdMap = GAMGroupNameToIdMap;
		batchObj1.GroupIdSet = GroupIdSet;
		batchObj1.isTest = True;
		Id batchprocessid1 = database.executebatch(batchObj1,1);
		
		Test.stopTest();
		
		Group GlobalAccountGroup2 = [SELECT Id FROM Group WHERE Name = 'GAM:Test101010102' LIMIT 1];
		List<Group_Member_Queue__c> grpMemberQ1 = [SELECT Id FROM Group_Member_Queue__c WHERE Group_ID__c=:GlobalAccountGroup.Id AND GAM_User__c IN :ATMIds1];
		List<Group_Member_Queue__c> grpMemberQ2 = [SELECT Id FROM Group_Member_Queue__c WHERE Group_ID__c=:GlobalAccountGroup2.Id AND GAM_User__c IN :ATMIds2];
		System.assertEquals(grpMemberQ1.size(),1);
		System.assertEquals(grpMemberQ2.size(),1);
		
	}*/
	
	static List<User> createSysAdminUsers(){
		List<User> SysAdminUserListTemp = new List<User>();
		for(Integer count=1;count<=10;count++){
			User testUser1 = new User(FirstName='Test Admin'+count, LastName='BatchGAMSharing Test', Title='OEM_SR',UserName='TestAdminU'+count+ System.currentTimeMillis() +'@test.com',Email='TestAdminU'+count+'@dell.com',Alias='TAdm'+count,CommunityNickName='TestAdmin0'+count,ProfileId = UserInfo.getProfileId(), LanguageLocaleKey='en_US', LocaleSidKey='en_US', EmailEncodingKey='UTF-8', TimeZoneSidKey='America/Los_Angeles',Badge_Number__c='tstadmin'+count);
			SysAdminUserListTemp.add(testUser1);
		}
		insert SysAdminUserListTemp;
		return SysAdminUserListTemp;
	}
	
	static void createGlobalAccounts(){
		Id standardAccountId = PageUtils.getRecordTypeId('Account', 'End-User Account', true);
		Account GlobalAccount;
		Sales_Channel_Group__c SCGroup;
		try{
			SCGroup = [SELECT Id,Name FROM Sales_Channel_Group__c WHERE Group_ID__c = :GLOBAL_SALES_CHANNEL_GROUP_IDENTIFIER LIMIT 1];
		}
		catch(Exception e){
			System.debug(e);
			System.runAs(SysAdminUserList[0]){
				SCGroup = new Sales_Channel_Group__c(Group_ID__c = GLOBAL_SALES_CHANNEL_GROUP_IDENTIFIER, Name = '['+ GLOBAL_SALES_CHANNEL_GROUP_IDENTIFIER +'] WW GLOBAL SBU');
				insert SCGroup;
			}
		}
		
		for(Integer count=1; count<=5; count++){
			GlobalAccount = new Account();
			GlobalAccount.RecordTypeId = standardAccountId;
			GlobalAccount.Name = 'GAM Batch Test Global Account '+count;
			GlobalAccount.Status__c = 'Active';
			GlobalAccount.Account_Type_Integration__c = 'PAR Account';
			GlobalAccount.Account_ID__c = 'Test10101010'+count;
			GlobalAccount.Sales_Channel__c = SCGroup.Id;
			GlobalAccountList.add(GlobalAccount);
		} 
		insert GlobalAccountList;
	}
	static void createChildAccounts(){
		Id standardAccountId = PageUtils.getRecordTypeId('Account', 'End-User Account', true);
		Account ChildAccount;
		Integer ItemNumber = 0;
		List<Account> ChildAccountList1 = new List<Account>();
		List<Account> ChildAccountList2 = new List<Account>();
		List<Account> ChildAccountList3 = new List<Account>();
		List<Account> ChildAccountList4 = new List<Account>();
		
		for(Integer count=0; count<15; count++){
			ItemNumber = Math.mod(count,5);
			ChildAccount = new Account();
			ChildAccount.RecordTypeId = standardAccountId;
			ChildAccount.Name = 'GAM Batch Test Child Account '+count;
			ChildAccount.ParentId = GlobalAccountList[ItemNumber].Id;
			ChildAccount.DMU__c = TRUE;
			ChildAccount.Account_Type_Integration__c = 'Account';
			ChildAccount.Status__c = 'Active';
			ChildAccountList.add(ChildAccount);
			ChildAccountList1.add(ChildAccount);
		} 
		insert ChildAccountList1;
		
		for(Integer count=0; count<30; count++){
			ItemNumber = Math.mod(count,15);
			ChildAccount = new Account();
			ChildAccount.RecordTypeId = standardAccountId;
			ChildAccount.Name = 'GAM Batch Test Child Account '+(count+15);
			ChildAccount.ParentId = ChildAccountList[ItemNumber].Id;
			ChildAccount.DMU__c = TRUE;
			ChildAccount.Account_Type_Integration__c = 'Account';
			ChildAccount.Status__c = 'Active';
			ChildAccountList.add(ChildAccount);
			ChildAccountList2.add(ChildAccount);
		}
		insert ChildAccountList2;
		
		for(Integer count=0; count<45; count++){
			ItemNumber = Math.mod(count,15);
			ChildAccount = new Account();
			ChildAccount.RecordTypeId = standardAccountId;
			ChildAccount.Name = 'GAM Batch Test Child Account '+(count+45);
			ChildAccount.ParentId = ChildAccountList[ItemNumber].Id;
			ChildAccount.DMU__c = TRUE;
			ChildAccount.Account_Type_Integration__c = 'Account';
			ChildAccount.Status__c = 'Active';
			ChildAccountList.add(ChildAccount);
			ChildAccountList3.add(ChildAccount);
		}
		insert ChildAccountList3;
		
		for(Integer count=0; count<250; count++){
			ChildAccount = new Account();
			ChildAccount.RecordTypeId = standardAccountId;
			ChildAccount.Name = 'GAM Batch Test Child Account '+(count+90);
			ChildAccount.ParentId = GlobalAccountList[0].Id;
			ChildAccount.DMU__c = TRUE;
			ChildAccount.Account_Type_Integration__c = 'Account';
			ChildAccount.Status__c = 'Active';
			ChildAccountList.add(ChildAccount);
			ChildAccountList4.add(ChildAccount);
		} 
		insert ChildAccountList4;
		
		Id parentId = GlobalAccountList[1].Id; 
		for (integer i=1; i<=13; i++){
			ChildAccount =  new Account(name = 'Child 1 in level '+ i , parentId = parentId,RecordTypeId = standardAccountId,DMU__c = TRUE,Account_Type_Integration__c = 'Sub Account',Status__c = 'Active');
			insert ChildAccount;
			ChildAccountList.add(ChildAccount);
			parentId = ChildAccount.Id;
		}
	}
	static void createGroup(){
		GlobalAccountGroup.Name = 'GAM:' + 'Test101010101';
		insert GlobalAccountGroup;
		Group GAGroup = new Group(Name = 'GAM:Test123456789');
		insert GAGroup;
	}
	static void createGroupMember(){
		for(Integer count=0; count<=10;count++){
			GroupMember grpMem = new GroupMember();
			grpMem.GroupId = GlobalAccountGroup.Id;
			grpMem.UserOrGroupId = testUserList[count].Id;
			If(count!=2 && count!=4){
				grpMemList.add(grpMem);
			}
		}
		System.runAs(SysAdminUserList[1]){
			insert grpMemList;
		}
	}
	static void createAccountShare(){
		for(Integer count=10;count<=20;count++){
			AccountShare acsh = new AccountShare();
			acsh.AccountId = ChildAccountList[count].Id;
			acsh.UserOrGroupId = GlobalAccountGroup.Id;
			acsh.AccountAccessLevel = 'Edit';
			acsh.CaseAccessLevel = 'Edit';
			acsh.OpportunityAccessLevel = 'Edit';
			accShareList.add(acsh);
		}
		System.runAs(SysAdminUserList[2]){
			insert accShareList;
		}
	}
	static void createAccountTeamMember(){
		Profile testProfile = [SELECT Id, Name FROM Profile WHERE Name LIKE '%GBL Sales Mgr - Non SSO' LIMIT 1];
		
		for(Integer count=1;count<=50;count++){
			User testUser1 = new User(FirstName='Test '+count, LastName='BatchGAMSharing Test', Title='OEM_SR',UserName='TestU'+count+ System.currentTimeMillis() +'@test.com',Email='TestU'+count+'@dell.com',Alias='test0'+count,CommunityNickName='Test0'+count,ProfileId = testProfile.Id, LanguageLocaleKey='en_US', LocaleSidKey='en_US', EmailEncodingKey='UTF-8', TimeZoneSidKey='America/Los_Angeles',Badge_Number__c='testtest'+count);
			testUserList.add(testUser1);
		}
        insert testUserList;
		Integer ItemNumber = 1;
        for(Account ChildAccountItem :ChildAccountList){
        	Integer UserItem1 = Math.mod(ItemNumber, 3) + ItemNumber;
        	Integer UserItem2 = Math.mod(ItemNumber, 6) + ItemNumber;
        	Integer UserItem3 = Math.mod(ItemNumber, 9) + ItemNumber;
        	AccountTeamMember testACT1 = new AccountTeamMember(UserId=testUserList[UserItem1].Id, TeamMemberRole='Global Account Manager', AccountId=ChildAccountItem.Id);
        	AccountTeamMember testACT2 = new AccountTeamMember(UserId=testUserList[UserItem2].Id, TeamMemberRole='Global Account Manager', AccountId=ChildAccountItem.Id);
        	AccountTeamMember testACT3 = new AccountTeamMember(UserId=testUserList[UserItem3].Id, TeamMemberRole='Global Account Manager', AccountId=ChildAccountItem.Id);
        	
        	testACTList.add(testACT1);
        	testACTList.add(testACT2);
        	testACTList.add(testACT3);
        	
        	if(ChildAccountItem.Name=='GAM Batch Test Child Account 0'){
        		AccountId1 = ChildAccountItem.Id;
        		ATMIds1.add(testUserList[UserItem1].Id);
        		ATMIds1.add(testUserList[UserItem2].Id);
        		ATMIds1.add(testUserList[UserItem3].Id);
				System.debug('Account Name :'+ChildAccountItem.Name);
	        	System.debug('Account Team Member Ids : '+ATMIds1);
	        	System.debug('Account Team Member Names :1. ' + testUserList[UserItem1].FirstName + ' 2. '+testUserList[UserItem2].FirstName + ' 3. '+testUserList[UserItem3].FirstName);
	        	
        	}
        	if(ChildAccountItem.Name=='GAM Batch Test Child Account 1'){
        		AccountId2 = ChildAccountItem.Id;
        		ATMIds2.add(testUserList[UserItem1].Id);
        		ATMIds2.add(testUserList[UserItem2].Id);
        		ATMIds2.add(testUserList[UserItem3].Id);
				System.debug('Account Name :'+ChildAccountItem.Name);
	        	System.debug('Account Team Member Ids : '+ATMIds2);
	        	System.debug('Account Team Member Names :1. ' + testUserList[UserItem1].FirstName + ' 2. '+testUserList[UserItem2].FirstName + ' 3. '+testUserList[UserItem3].FirstName);
	        	
        	}
        	
        	ItemNumber++;
        	If(ItemNumber>=35){
        		ItemNumber = 1;
        	}
        }
        System.runAs(SysAdminUserList[3]){
        	insert testACTList;
        }
	}
	
	static testMethod void scheduleBatchTest() {
        Test.startTest();
		
		Group GAGroup = new Group(Name = 'GAM:Test123456789');
		insert GAGroup;
		GAGroup = new Group(Name = 'GAM:Test987654321');
		insert GAGroup;
		
		Id standardAccountId = PageUtils.getRecordTypeId('Account', 'End-User Account', true);
		Account GlobalAccount;
		Sales_Channel_Group__c SCGroup;
		try{
			SCGroup = [SELECT Id,Name FROM Sales_Channel_Group__c WHERE Group_ID__c = :GLOBAL_SALES_CHANNEL_GROUP_IDENTIFIER LIMIT 1];
		}
		catch(Exception e){
			System.debug(e);
			System.runAs(SysAdminUserList[0]){
				SCGroup = new Sales_Channel_Group__c(Group_ID__c = GLOBAL_SALES_CHANNEL_GROUP_IDENTIFIER, Name = '['+ GLOBAL_SALES_CHANNEL_GROUP_IDENTIFIER +'] WW GLOBAL SBU');
				insert SCGroup;
			}
		}
		GlobalAccount = new Account(RecordTypeId = standardAccountId,Name = 'GAM Batch Test Global Account',Status__c = 'Active',Account_Type_Integration__c = 'PAR Account',Account_ID__c = 'Test123456789',Sales_Channel__c = SCGroup.Id);
		insert GlobalAccount;
				
        String CRON_EXP = '0 0 0 * * ?';
        GAMSharingSchedule sch = new GAMSharingSchedule();
        sch.isTest = True;
        String jobId = System.schedule('TestScheduledApex',CRON_EXP,sch);
        CronTrigger ct = [SELECT id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId];
        //Verify the expressions are the same
		System.assertEquals(CRON_EXP,ct.CronExpression);
		// Verify the job has not run
		System.assertEquals(0, ct.TimesTriggered);
        test.stopTest();
    }
}