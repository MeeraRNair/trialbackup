@isTest
private class InventoryRequestHelperTest{
    static testmethod void fieldInventoryRequestTC(){
        User systemAdmin = new user();
        systemAdmin = [Select id from User where isActive=true and profile.Name='System Administrator' limit 1];
        
        System.runAs(systemAdmin){
            List<Account> listAcc = new List<Account>();
            Account acc1 = new Account();
            acc1.name = 'TestAccName';
            
            acc1.BillingCountry= 'United Kingdom';
            acc1.BillingCity = 'BLOOMINGTON';
            acc1.BillingStreet = '1663 S LIBERTY DR STE 200';
            //acc1.District_Lookup__c = objDistrictLookup.id;
            acc1.Account_Country_Code__c = 'AL'; 
            //acc1.Dell_Sales_FIM__EMC_Classification__c = 'Commercial'; 
            listAcc.add(acc1);
            insert listAcc;
         
           ID sysid = [ Select id from Profile where name ='System Administrator' limit 1].Id;
            Dell_Sales_FIM__Static_Variable__c staticVar = new Dell_Sales_FIM__Static_Variable__c();
            staticVar.Dell_Sales_FIM__Account_Country_Name_Field_API__c = 'Country_Name__c';
            staticVar.Dell_Sales_FIM__Account_Segment_Biz_Grp_Name_Field_API__c = 'Segment_Business_Group_Name__c';
            //staticVar.Account_Country_Code__c = 'SFDC_Customer_Account_Name__r.Country_Code__c';
            staticVar.Dell_Sales_FIM__Inventory_Request_Object__c= 'Account_Country_Code__c';       
            staticVar.Dell_Sales_FIM__Account_Country_Code__c = 'SFDC_Customer_Account_Name__r.Account_Country_Code__c'; 
            staticVar.Dell_Sales_FIM__IR_Classification__c = 'SFDC_Customer_Account_Name__r.Account_Classification__c'; 
            staticVar.Dell_Sales_FIM__Inventory_Request_Object_Classification__c = 'Account_Classification__c';       
            insert staticVar;    
            System.debug('irFix******* ');
            List<Dell_Sales_FIM__Inventory_Request_Matrix__c> listIRM = new List<Dell_Sales_FIM__Inventory_Request_Matrix__c>();
            Dell_Sales_FIM__Inventory_Request_Matrix__c irm1 = new Dell_Sales_FIM__Inventory_Request_Matrix__c(Name='App1', Dell_Sales_FIM__Amount__c=0,  Dell_Sales_FIM__Country_Code__c = 'RO; GB', Dell_Sales_FIM__Object__c='Req');
            listIRM .add(irm1);
            Dell_Sales_FIM__Inventory_Request_Matrix__c irm2 = new Dell_Sales_FIM__Inventory_Request_Matrix__c(Name='App2', Dell_Sales_FIM__Amount__c=100000, Dell_Sales_FIM__Country_Code__c = 'RO; GB', Dell_Sales_FIM__Object__c='Req');
            listIRM .add(irm2);
            Dell_Sales_FIM__Inventory_Request_Matrix__c irm3 = new Dell_Sales_FIM__Inventory_Request_Matrix__c(Name='App3', Dell_Sales_FIM__Amount__c=500000, Dell_Sales_FIM__Country_Code__c = 'RO; GB', Dell_Sales_FIM__Object__c='Req');
            listIRM .add(irm3);
            insert listIRM;
            
            Id recordTypeId = Schema.SObjectType.Customer_Number__c.getRecordTypeInfosByName().get('GBL_Customer_No_RT').getrecordTypeId();
            Customer_Number__c custNum = new Customer_Number__c(name = '12345',BU_ID__c = 'EMC',Customer_Number_BU_Integ__c = '12345EMC',Account__c = listAcc[0].id,recordTypeId = recordTypeId);
            insert custNum;
            RecordType rtType = [Select Id, Name, DeveloperName from RecordType where DeveloperName = 'Try_It_Form' and Description ='' ];
            Dell_Sales_FIM__Inventory_Request_Record_Type_Id__c recordId = new Dell_Sales_FIM__Inventory_Request_Record_Type_Id__c();
            recordId.name = rtType.Id;
            insert recordId;
            List<Dell_Sales_FIM__Inventory_Request__c> listInvReq = new List<Dell_Sales_FIM__Inventory_Request__c>();
            Dell_Sales_FIM__Inventory_Request__c rec = new Dell_Sales_FIM__Inventory_Request__c(Name='Test',Dell_Sales_FIM__Reason_for_Request__c='Qualification',Dell_Sales_FIM__Detailed_Justification_for_Request__c='test',
                                                                Dell_Sales_FIM__Quote__c = '6789012345',Dell_Sales_FIM__Address__c='test',Dell_Sales_FIM__City__c='test',Dell_Sales_FIM__State__c='test',Dell_Sales_FIM__Ship_To_Country__c='AFGHANISTAN',Dell_Sales_FIM__Business_Unit__c = 'ISG',Dell_Sales_FIM__Business_Segment__c='ACQ',Dell_Sales_FIM__Contract_Start_Date__c=system.today(),Dell_Sales_FIM__Expected_Action__c='Return',Customer_Number__c=custNum.id,Dell_Sales_FIM__Recipient_s_Email__c='tst@g.com',Dell_Sales_FIM__Recipient_s_Job_Title__c='test',Dell_Sales_FIM__Quoting_Tool__c='DSA',Dell_Sales_FIM__Recipient_s_Last_Name__c='test',Dell_Sales_FIM__Recipient_s_First_Name__c = 'test',Dell_Sales_FIM__Quote_Amount__c=123.00,Dell_Sales_FIM__Are_Professional_Services_Needed__c='No',Dell_Sales_FIM__SFDC_Customer_Account_Name__c=listAcc[0].id,Dell_Sales_FIM__Expected_Return_Date__c=Date.Today(),Dell_Sales_FIM__Quote_Version__c='Test Version',recordTypeId = rtType.Id,Dell_Sales_FIM__GPC_Error_Message__c=null,Dell_Sales_FIM__Account_Rep_Email_address__c='test@emc.com');
            listInvReq.add(rec);
            insert listInvReq;
            System.assert (listInvReq.size() >= 1, 'No records inserted');
            }
    }
}