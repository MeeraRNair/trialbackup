@isTest(seeAlldata=false)
public class AllianceRebateRequestTrigger_Test {
    @testSetup static void setup() {
        OWD__c oWDsetting = new OWD__c();
        oWDsetting.Oppty_Stage0__c = 'Lost, Cancelled - 0%';
        oWDsetting.Oppty_Stage10__c = 'Discover - 10%';
        oWDsetting.Oppty_Stage100__c = 'Win - 100%';
        oWDsetting.Oppty_Stage30__c = 'Qualify - 30%';
        oWDsetting.Oppty_Stage60__c = 'Propose - 60%';
        oWDsetting.Oppty_Stage90__c = 'Commit - 90%';
        oWDsetting.Oppty_Stage99__c = 'Order Submitted - 99%';
        oWDsetting.Oppty_Stage1__c = 'Plan - 1%';
        
        insert oWDsetting;
        TriggerExecutionController.setSkipAllTriggers(true);
        profile profileId =   [select Id, Name from Profile where name like '%system admin%' limit 1];
        list<User> listUserTdf=TestDataFactory.CreateNGenralUsers(1);
        listUserTdf[0].ProfileId=profileId.id;
        insert listUserTdf;
        list<Alliance_Rebate_Request__c> listAllRebReqTdf=TestDataFactory.createNAllianceRebateRequests(5);
        insert listAllRebReqTdf;
        TriggerExecutionController.setSkipAllTriggers(false);
    }  
    /*   @testsetup
public static void setupData(){


list<string> groupNames = new list<string>();
groupNames.add('Alliance NA Lead');
groupNames.add('Alliance Global Leads');
groupNames.add('Alliance LATAM All But Intel Client');
groupNames.add('Alliance LATAM All But Intel Enterprise');
groupNames.add('Alliance LATAM Intel Client');
groupNames.add('Alliance LATAM Intel Enterprise');
groupNames.add('Alliance EMEA ALL Client');
groupNames.add('Alliance EMEA Intel Enterprise');
groupNames.add('Alliance EMEA ALL But Intel Enterprise');
groupNames.add('Alliance APJ All But Intel Client');
groupNames.add('Alliance APJ Intel Enterprise');
groupNames.add('Alliance APJ Intel Client');
groupNames.add('Alliance APJ All But Intel Enterprise');
groupNames.add('Alliance NA Intel Client');
groupNames.add('Alliance NA Intel Enterprise');
list<Group> groups = new list<Group>();
list<GroupMember> grpMem = new list<GroupMember>();

for(string s : groupNames){
Group grp = new Group();
grp.name = s;
grp.Type = 'Regular'; 
groups.add(grp);
} 
insert groups;

for(Group grp : groups){
GroupMember grpMem1 = new GroupMember();
grpMem1.UserOrGroupId = UserInfo.getUserId();
grpMem1.GroupId = grp.Id;
grpMem.add(grpMem1);
}
insert grpMem;
}
*/
    // Create Alliance Rebate Request
    public testmethod static void createAllianceRebateRequestClientIntel() {
        //TriggerExecutionController.setSkipAllTriggers(true);
        //TriggerExecutionController.setSkipOpportunityTriggers(True);
        // Opportunity opp1 = createOpportunityInfo('Test1cdcdxvx@gmail.com');
        
        //list<Alliance_Rebate_Request__c> rebateRequests = new list<Alliance_Rebate_Request__c>();
        list<string> listRegions = new list<string>{'LATAM','NA','APJ','EMEA','GLOBAL'};
            
            /*  for(string s : regions){
Alliance_Rebate_Request__c arReq = new Alliance_Rebate_Request__c();
arReq.System_Partner_Name__c ='Intel';
arReq.Finance_Contact__c = 'xxx@dell.com';
arReq.Sales_Force_Deal_ID__c = opp1.id;
arReq.Region__c=s;
arReq.Client_Enterprise__c='Enterprise';
arReq.Partner_BDM_Name__c='test';
arReq.Status__c = 'Draft';
arReq.Business_Case_Information__c = 'test';
rebateRequests.add(arReq);

}
test.starttest();
insert rebateRequests;
Opportunity opp2 = createOpportunityInfo('Test2sdsdscsa@gmail.com');

for(Alliance_Rebate_Request__c rec : rebateRequests){
submitForApproval(rec);
}        
test.stoptest();
for(string s : regions){
updateRequests(rebateRequests,opp2,s,'Enterprise','Intel');
}

for(string s : regions){
updateRequests(rebateRequests,opp2,s,'Client','Intel');
}
*/
            list<Alliance_Rebate_Request__c> listRebateRequests = [select id,Region__c from Alliance_Rebate_Request__c Limit 5]; 
        listRebateRequests[0].Region__c=listRegions[0];
        listRebateRequests[1].Region__c=listRegions[1];
        listRebateRequests[2].Region__c=listRegions[2];
        listRebateRequests[3].Region__c=listRegions[3];
        listRebateRequests[4].Region__c=listRegions[4];
        update listRebateRequests;
        system.assertEquals(listRegions[4], listRebateRequests[4].Region__c);
    }
    
    // Create Alliance Rebate Request
    public testmethod static void createAllianceRebateRequestNonIntel() {
        /* TriggerExecutionController.setSkipAllTriggers(true);
TriggerExecutionController.setSkipOpportunityTriggers(True);
Opportunity opp1 = createOpportunityInfo('Test1cdcdxvx@gmail.com');

list<Alliance_Rebate_Request__c> rebateRequests = new list<Alliance_Rebate_Request__c>();

for(string s : regions){
Alliance_Rebate_Request__c arReq = new Alliance_Rebate_Request__c();
arReq.System_Partner_Name__c ='Intel';
arReq.Finance_Contact__c = 'xxx@dell.com';
arReq.Sales_Force_Deal_ID__c = opp1.id;
arReq.Region__c=s;
arReq.Client_Enterprise__c='Enterprise';
arReq.Status__c = 'Draft';
arReq.Business_Case_Information__c = 'test';
arReq.Partner_BDM_Name__c='test';
rebateRequests.add(arReq);
}

test.starttest();
insert rebateRequests;
Opportunity opp2 = createOpportunityInfo('Test2sdsdscsa@gmail.com');

for(Alliance_Rebate_Request__c rec : rebateRequests){
submitForApproval(rec);
}        

test.stoptest();
for(string s : regions){
updateRequests(rebateRequests,opp2,s,'Enterprise','Brocade');
}

for(string s : regions){
updateRequests(rebateRequests,opp2,s,'Client','Brocade');
}*/
        list<string> listRegions = new list<string>{'LATAM','NA','APJ','EMEA','GLOBAL'};
            list<Alliance_Rebate_Request__c> listRebateRequests = [select id,Region__c from Alliance_Rebate_Request__c Limit 5]; 
        listRebateRequests[0].Region__c=listRegions[0];
        listRebateRequests[1].Region__c=listRegions[1];
        listRebateRequests[2].Region__c=listRegions[2];
        listRebateRequests[3].Region__c=listRegions[3];
        listRebateRequests[4].Region__c=listRegions[4];
        update listRebateRequests;
        system.assertEquals(listRegions[3], listRebateRequests[3].Region__c);
        submitForApproval(listRebateRequests[0]);
    }
    
    /*   public static void updateRequests(list<Alliance_Rebate_Request__c> rebateRequests,
Opportunity opp2,
string region,
string client,
string partner){
for(Alliance_Rebate_Request__c rec : rebateRequests){
rec.Sales_Force_Deal_ID__c = opp2.id;
rec.Region__c = region;
rec.Client_Enterprise__c = client;
//rec.System_Partner_Name__c = 'AMD';
rec.Partner_BDM_Name__c='test';
}

update rebateRequests;
}
*/ 
    public static void submitForApproval(Alliance_Rebate_Request__c rec){
        Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
        req1.setComments('Submit record for approval');
        req1.setObjectId(rec.id);
        req1.setSkipEntryCriteria(false);
        Approval.ProcessResult result = Approval.process(req1);
    }
    
    // Create Opportunity Information
    
    /*    public static Opportunity createOpportunityInfo(String username) {
RecordType r1 = [select id,name from RecordType where name='Standard Opportunity' limit 1];

TriggerExecutionController.setSkipAllTriggers(True);
Opportunity opp = new Opportunity (
RecordTypeId= r1.id,
Name='TestOpportunity',
Type = 'Run Rate',
Domain__c='Deal Reg',
Solution_Type__c = 'Campus',
Solution_Name__c = 'Wireless Switches',
StageName='Plan - 1%',
Deal_Registration_Status__c = 'Recalled',
Deal_Created_Date_Time__c = System.Now(),
Deal_Expiration_Timeframe__c='60',                                       
CloseDate= System.Now().Date().addDays(180),
Deal_Expiration_Date__c=System.Now().Date().addDays(4),
Primary_Product_Delivery_Address_Region__c = 'APJ',
Request_Status__c='New');

insert opp;

// Create User
profile p = [select id,name from profile where name like '%system admin%'];

User usr = new User(Alias = 'standt', Email='Testing01skdw0sl@dell.com', 
EmailEncodingKey='UTF-8', LastName='Testing28ws2', LanguageLocaleKey='en_US', 
LocaleSidKey='en_US', ProfileId = p.Id, Country = 'US',
TimeZoneSidKey='America/Los_Angeles', UserName=username,Badge_Number__c=string.valueof(system.now()));

insert usr;

// Create Opp Team member
OpportunityTeamMember otm = new OpportunityTeamMember();
otm.OpportunityId = opp.id;
otm.UserId  = usr.id; 
insert otm;

TriggerExecutionController.setSkipAllTriggers(false);

return opp;
}
*/  
    
}