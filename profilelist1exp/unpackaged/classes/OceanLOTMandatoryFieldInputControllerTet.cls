/* 
* Revision   Release No       Modified By               Description
* --------   ---------        -----------               ------------               
*            0202             Venugopalachary k         Implement Test Data Factory                               
*/ 
/* 12-Dec-2018  Hari A  STORY 5907651 Removed reference for the field total_aggregated_volume__c */
@isTest
Private Class OceanLOTMandatoryFieldInputControllerTet{
    public boolean btoPursue = false;
    private boolean bnoPursueOption = false;
    public static list<Opportunity> listOpp;
    //8.0 - BOF
    //Making list for Skip VRs
    static List<String> listObjAPINames = new List<String>{'Opportunity'};
        //Added custom settings to populate StageName values.
        @testSetup static void setup() {
            // Create common test OWD settings
            OWD__c owdSetting = new OWD__c();
            owdSetting.Oppty_Stage1__c = 'Plan - 1%';
            owdSetting.Oppty_Stage10__c = 'Discover - 10%';
            owdSetting.Oppty_Stage30__c = 'Qualify - 30%';
            owdSetting.Oppty_Stage60__c = 'Propose - 60%';
            owdSetting.Oppty_Stage90__c = 'Commit - 90%';
            owdSetting.Oppty_Stage99__c = 'Order Submitted - 99%';
            owdSetting.Oppty_Stage100__c = 'Win - 100%';
            owdSetting.Oppty_Stage0__c = 'Lost, Cancelled - 0%';
            Insert owdSetting;
            TriggerExecutionController.setSkipAllTriggers(true);
            
            list<Opportunity> listOppTdf=TestDataFactory.createNOpportunities(3,'Standard Opportunity');
            for(Opportunity opp : listOppTdf){
                opp.Name = 'TEST Oppty';
                opp.CloseDate=System.Today() + 30;
                opp.StageName = 'Qualify - 30%';
                opp.Region__c='APJ';
                opp.Competitor_Lost_To__c='Unknown';
                opp.Primary_Competitor_Product_Type__c='Object';
            }
            insert listOppTdf;
            TriggerExecutionController.setSkipAllTriggers(false);
        }
    //8.0 - EOF
    static testmethod void testDoCancel() {
        System_Behavior_Bypasser__c vr  = new System_Behavior_Bypasser__c();
        vr.Bypass_Opportunity_VRs__c = true;
        insert vr;
        //Pricebook2 standardPB = [SELECT Id FROM Pricebook2 Limit 1];
        TriggerExecutionController.setSkipAllTriggers(true);
        //Datetime DT=System.Today() + 30;
        //string calcDeliveryDate = DT.format('d MMMM yyyy');
        /* Opportunity oppty = new Opportunity(Quote_Numbers__c='123456',
LOT_Mandatory_Fields__c=true,
Do_you_want_to_pursue_Ocean__c='No',
Customer_Requested_Delivery_Date__c=System.today()+30,
How_many_shipments__c=5,
Name = 'TEST Oppty', 
CloseDate=System.Today() + 15,
Ocean_Opportunity_Notification_Pop_Up__c=true,
StageName = 'Qualify - 30%',
Region__c='APJ',
Competitor_Lost_To__c='Unknown');
insert oppty;*/
        listOpp=[select id,stageName from Opportunity Limit 1];
        listOpp[0].LOT_Mandatory_Fields__c=true;
        listOpp[0].Do_you_want_to_pursue_Ocean__c='No';
        listOpp[0].How_many_shipments__c=5;
        listOpp[0].Ocean_Opportunity_Notification_Pop_Up__c=true;
        listOpp[0].StageName='Commit - 90%';
        update listOpp;
        OceanLOTMandatoryFieldInputController controller = new OceanLOTMandatoryFieldInputController(new ApexPages.StandardController(listOpp[0]));
        controller.doCancel();
        // controller.getCalcDeliveryDate();
        Opportunity resultOppty = [SELECT LOT_Mandatory_Fields__c, Do_you_want_to_pursue_Ocean__c,Ocean_Opportunity_Notification_Pop_Up__c FROM Opportunity WHERE Id=:listOpp[0].Id];
        
        system.assert(!resultOppty.LOT_Mandatory_Fields__c);
        system.assert(resultOppty.Do_you_want_to_pursue_Ocean__c == 'No');      
        system.assert(!resultOppty.Ocean_Opportunity_Notification_Pop_Up__c);
        TriggerExecutionController.setSkipAllTriggers(false); 
    }
    static testmethod void testDoSave() {
        System_Behavior_Bypasser__c vr  = new System_Behavior_Bypasser__c();
        vr.Bypass_Opportunity_VRs__c = true;
        insert vr;
        
        TriggerExecutionController.setSkipAllTriggers(true);
        
        /* Opportunity oppty = new Opportunity(Quote_Numbers__c='123456',
Eligible_for_Ocean__c = 'Yes', 
LOT_Mandatory_Fields__c=true,
Do_you_want_to_pursue_Ocean__c='No',
Customer_Requested_Delivery_Date__c=System.today()+30,
How_many_shipments__c=5,
Name = 'TEST Oppty', 
CloseDate=System.Today() + 30,
Ocean_Opportunity_Notification_Pop_Up__c=true,
StageName = 'Qualify - 30%',
Primary_Product_Delivery_Address_Country__c = 'UNITED STATES',
Region__c='APJ',
Competitor_Lost_To__c='Unknown');
//insert oppty;

Opportunity oppty2 = new Opportunity(Quote_Numbers__c=null,
Eligible_for_Ocean__c = 'Yes', 
LOT_Mandatory_Fields__c=true,
Do_you_want_to_pursue_Ocean__c='No',
Customer_Requested_Delivery_Date__c=null,
How_many_shipments__c=null,
Name = 'TEST Oppty',
CloseDate=System.Today() + 30,
Ocean_Opportunity_Notification_Pop_Up__c=true,
StageName = 'Qualify - 30%',
Region__c='APJ',
Competitor_Lost_To__c='Unknown');
//insert oppty2;        

List<Opportunity> opptyList = new List<Opportunity>();
opptyList.add(oppty);
opptyList.add(oppty2);

insert opptyList;
*/
        listOpp=[select id,LOT_Mandatory_Fields__c,Ocean_Opportunity_Notification_Pop_Up__c,stageName,Competitor_Lost_To__c,Name,Region__c,CloseDate from Opportunity Limit 2];
        /*for(Opportunity opp : listOpp){
opp.LOT_Mandatory_Fields__c=true;
opp.Eligible_for_Ocean__c = 'Yes';
opp.Do_you_want_to_pursue_Ocean__c='No';
opp.Ocean_Opportunity_Notification_Pop_Up__c=true;
opp.Name = 'TEST Oppty';
opp.CloseDate=System.Today() + 30;
}
listOpp[0].How_many_shipments__c=5;
listOpp[0].Primary_Product_Delivery_Address_Country__c = 'UNITED STATES';
listOpp[1].Quote_Numbers__c=null;
listOpp[1].Customer_Requested_Delivery_Date__c=null;
listOpp[1].How_many_shipments__c=null;
update listOpp;
*/
        listOpp[0].Quote_Numbers__c='123456';
        listOpp[0].Eligible_for_Ocean__c = 'Yes';
        listOpp[0].LOT_Mandatory_Fields__c=true;
        listOpp[0].Do_you_want_to_pursue_Ocean__c='No';
        listOpp[0].Customer_Requested_Delivery_Date__c=System.today()+30;
        listOpp[0].How_many_shipments__c=5;
        listOpp[0].Name = 'TEST Oppty';
        listOpp[0].CloseDate=System.Today() + 30;
        listOpp[0].Ocean_Opportunity_Notification_Pop_Up__c=true;
        listOpp[0].StageName = 'Qualify - 30%';
        listOpp[0].Primary_Product_Delivery_Address_Country__c = 'UNITED STATES';
        listOpp[0].Region__c='APJ';
        listOpp[0].Competitor_Lost_To__c='Unknown';
        
        listOpp[1].Quote_Numbers__c=null;
        listOpp[1].Eligible_for_Ocean__c = 'Yes'; 
        listOpp[1].LOT_Mandatory_Fields__c=true;
        listOpp[1].Do_you_want_to_pursue_Ocean__c='No';
        listOpp[1].Customer_Requested_Delivery_Date__c=null;
        listOpp[1].How_many_shipments__c=null;
        listOpp[1].Name = 'TEST Oppty';
        listOpp[1].CloseDate=System.Today() + 30;
        listOpp[1].Ocean_Opportunity_Notification_Pop_Up__c=true;
        listOpp[1].StageName = 'Qualify - 30%';
        listOpp[1].Region__c='APJ';
        listOpp[1].Competitor_Lost_To__c='Unknown';
        Test.setCurrentPage(Page.OceanLOTMandatoryFieldsInput);
        
        OceanLOTMandatoryFieldInputController controller = new OceanLOTMandatoryFieldInputController(new ApexPages.StandardController(listOpp[0]));
        controller.toPursue = true;
        controller.noPursueOption = false;
        controller.doSave();
        Opportunity resultOppty = [SELECT LOT_Mandatory_Fields__c, Do_you_want_to_pursue_Ocean__c,Ocean_Opportunity_Notification_Pop_Up__c, LOT_Large_Opportunity__c FROM Opportunity WHERE Id=:listOpp[0].Id];
        //system.assert(!resultOppty.LOT_Mandatory_Fields__c);
        //system.assert(resultOppty.LOT_Large_Opportunity__c);
        //system.assert(resultOppty.Do_you_want_to_pursue_Ocean__c == 'Yes');     
        //system.assert(!resultOppty.Ocean_Opportunity_Notification_Pop_Up__c);
        
        OceanLOTMandatoryFieldInputController controller2 = new OceanLOTMandatoryFieldInputController(new ApexPages.StandardController(listOpp[1]));
        controller2.doSave();
        
        System.debug('###DEBUG### Returned Messages = ' + ApexPages.getMessages() );
        system.assert(ApexPages.hasMessages());
        TriggerExecutionController.setSkipAllTriggers(false);
    }
    static testmethod void testGetEligibleToMessage() {
        /*  List<Opportunity> opptyList = new List<Opportunity>();

Opportunity oppty = new Opportunity(Quote_Numbers__c='123456',
Eligible_for_Ocean__c = 'No', 
LOT_Mandatory_Fields__c=true,
Do_you_want_to_pursue_Ocean__c='Yes',
Customer_Requested_Delivery_Date__c=System.today()+30,
How_many_shipments__c=1,
Name = 'TEST Oppty', 
CloseDate=System.Today() + 30,
Ocean_Opportunity_Notification_Pop_Up__c=true,
StageName = 'Qualify - 30%',
Region__c='APJ',
Competitor_Lost_To__c='Unknown');
//insert opptyList;

Opportunity oppty2 = new Opportunity(Quote_Numbers__c='123456',
Eligible_for_Ocean__c = 'Yes',
LOT_Mandatory_Fields__c=false,
Do_you_want_to_pursue_Ocean__c='Yes',
//Customer_Requested_Delivery_Date__c=System.today()+30,
How_many_shipments__c=1,
Name = 'TEST Oppty',
CloseDate=System.Today() + 30, 
Ocean_Opportunity_Notification_Pop_Up__c=true,
StageName = 'Qualify - 30%',
Region__c='APJ',
Competitor_Lost_To__c='Unknown');
//insert oppty2;

Opportunity oppty3 = new Opportunity(Quote_Numbers__c='123456',
Eligible_for_Ocean__c = 'Yes',
LOT_Mandatory_Fields__c=true,
Do_you_want_to_pursue_Ocean__c='Yes',
Customer_Requested_Delivery_Date__c=System.today()+30,
How_many_shipments__c=1,
Name = 'TEST Oppty', 
CloseDate=System.Today() + 30,
Ocean_Opportunity_Notification_Pop_Up__c=true,
StageName = 'Qualify - 30%',
Region__c='APJ',
Competitor_Lost_To__c='Unknown');
//insert oppty3;

opptyList.add(oppty);
opptyList.add(oppty2);
opptyList.add(oppty3);               
*/
        listOpp=[select id,Name,CloseDate,StageName,Region__c,Competitor_Lost_To__c from Opportunity Limit 3];
        for(Opportunity opp : listOpp){
            opp.Quote_Numbers__c='123456';
            opp.Eligible_for_Ocean__c = 'Yes';
            opp.Ocean_Opportunity_Notification_Pop_Up__c=true;
            opp.How_many_shipments__c=1;
        }
        listOpp[0].LOT_Mandatory_Fields__c=false;
        listOpp[0].Do_you_want_to_pursue_Ocean__c='Yes';
        listOpp[1].LOT_Mandatory_Fields__c=false;
        listOpp[1].Do_you_want_to_pursue_Ocean__c='Yes';
        listOpp[2].LOT_Mandatory_Fields__c=true;
        listOpp[2].Do_you_want_to_pursue_Ocean__c='Yes';
        update listOpp;
        OceanLOTMandatoryFieldInputController controller = new OceanLOTMandatoryFieldInputController(new ApexPages.StandardController(listOpp[0]));
        String strmsg = controller.getEligibleToMessage();
        
        System.assert(strmsg != '');           
        
        OceanLOTMandatoryFieldInputController controller2 = new OceanLOTMandatoryFieldInputController(new ApexPages.StandardController(listOpp[1]));
        String strmsg2 = controller2.getEligibleToMessage();
        OceanLOTMandatoryFieldInputController controller3 = new OceanLOTMandatoryFieldInputController(new ApexPages.StandardController(listOpp[2]));
        String strmsg3 = controller3.getEligibleToMessage();
        
        System.assert(strmsg3 != '');
    }
}