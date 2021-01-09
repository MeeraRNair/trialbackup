@istest

public class GAMASuggestionReq_Test {
static list<Campaign> listCamp;
    static list<lead> listlead;
    @testsetup static void setup(){
        list<Campaign> listCampTDF = TestDataFactory.createNCampaign(1, 'Campaign 2.0');
        insert listCampTDF;
        list<lead> listleadTDF = TestDataFactory.createNLeads(1, 'Channel Lead 2.0');
        listleadTDF[0].Campaign__c = listCampTDF[0].id;
        TriggerExecutionController.setSkipLeadTriggers(True);
        insert listleadTDF;
    }
public static testmethod void suggestionInformation(){
GAMASuggestionReq maincontrol = new GAMASuggestionReq();
//GAMASuggestionReq.AddressInformation addressControl = maincontrol.new AddressInformation(('street1','street2',124256,'vzg','retste','us','4353627','tg');
GAMASuggestionReq.AddressInformation address= new GAMASuggestionReq.AddressInformation('street1','street2',124256,'vzg','retste','us','4353627','tg');
 /*   
    Campaign campaignObj=new Campaign(Name='Campaign',
                Campaign_Objective__c='Acquisition/Site Development',
                Type='Advisory Councils',Segment_Business_Unit__c='SMB',
                //Region__c='ABU',                        
                Follow_Up_Role__c='Account Executive',
                Description='Test',StartDate=system.today(),EndDate=system.today(),
                status='In Progress',
                Total_Targets__c = 12.0,  
                IsActive = true);
        insert campaignObj; 
        System.assertEquals(true,campaignObj.IsActive); 
    Lead suggestionLead = new lead();
        suggestionLead.Status = 'Open';
         suggestionLead.LastName='test';
         suggestionLead.Company ='dell';
        suggestionLead.Email = 'test@test.com';
        suggestionLead.MobilePhone = '21441242421'; 
        suggestionLead.Fax = '3737433'; 
        suggestionLead.Lead_Type__c = 'Inbound';
         suggestionLead.Campaign__c=listCamp[0].id;
        suggestionLead.Country_Code__c = 'US';
        //suggestionLead.Organization_Country__c = 'United States';
        suggestionLead.Website = 'www.testing.com';
       // suggestionLead.Validated_DUNS__c= '7573485';
        suggestionLead.DMU_Flag__c = true;
        suggestionLead.Location_Number__c=23;
        suggestionLead.LeadSource='Web';
    insert suggestionLead;

*/
  //  listCamp = [select id from Campaign limit 1];
    listlead = [select id,Master_Group_Affinity_ID__c,Mg_Name__c,Mg_Local_Name__c,Number_of_Branches_Subsidiaries__c,Account_Owner__c,SM_country_code__c,Partner_Program_Track__c,
                GU_Duns_number__c,Mg_Website__c,Mg_Address_Line_1__c,Mg_Address_Line_2__c,Account_Owner__r.Badge_Number__c,Postal_Address_1__c,Postal_Address_2__c,Questions_Comments__c,
                Mg_City__c,Mg_Country_Code__c,Mg_Postal_Code__c,Mg_State__c,Account_Owner__r.FirstName,Account_Owner__r.LastName,Postal_City__c,Postal_State__c,
                Mg_Local_Address_Line_1__c,Mg_Local_Address_Line_2__c,Mg_Local_City__c,Territory_Assignment__r.Group_ID__c,Postal_PostalCode__c,Legal_Local_Address_1__c,
                Mg_Local_Postal_Code__c, Mg_Local_State__c,Track_Affinity_ID__c,Partner_Track_Affinity_ID__c,Disable_Rounding__c,Distribution_All_Country_Price__c,
                Distribution_Incumbent_Partner__c, Enabled_for_Services__c,Partner_Profiled_Account_Flag__c,Partner_Program_Tier__c,Fiscal_Year_End__c,Legal_Local_City__c,
                Partner_Storage_Purchasing_Path__c,Primary_Sales_Motion_Affinity_ID__c,Relationship_Type__c,Reporting_Segmentation__c,Legal_Local_Address_2__c,Legal_Local_Company_Name__c,
                SPL_Distribution_Pricing__c, SPL_Partner_Recommend_Pricing__c, VCE_Approved_Partner__c,Partner_Request__c,Partner_Track__c,Std_Quote_Numbers__c,Legal_Local_Postal_Code__c,
                Partner_Track_Account_Local_Name__c,Multi_Track_Parent_ID__c,MUP_Company_Profile_ID__c,Distributor_Authorized_Countries__c,Premier_Page_URL__c,Legal_Local_Postal_State__c,
                Purchase_Path__c,Account_Category__c,Company,Function_Category_Code__c,NDA_Flag__c,Marketing_Class_Code__c,CompanyLocal,National_ID__c,NumberOfEmployees,
                Organization_Country__r.Code__c,Organization_Country__r.User_Currency_Iso_Code__c,Program_Type__c,Retail_Flag__c,CaseRTMigrate__SICCode__c,Sales_Model_Code__c, 
                Sub_Market_Code__c, Segmentation__c,Selling_Motion__c,Partner_Quoting_Account__c,Quoting_Freight_Terms__c,Quoting_Payment_Terms__c,Date_Founded__c,FIN_GEO__c,
                Partner_Quoting_Account_Name__c,Partner_Quoting_Account_SAP_UCID__c,Quoting_Auto_book_Enabled__c,RTM__c,Quoting_EPOA_Flag__c,Quoting_FOB_Incoterms__c,CFI_Project_Numbers__c,
                Universal_Customer_ID_UCID__c from lead limit 1];
                
    for(Lead suggestionLead : listlead){
       //  suggestionLead.Campaign__c=listCamp[0].id;
        suggestionLead.Country_Code__c = 'US';
        //suggestionLead.Organization_Country__c = 'United States';
        suggestionLead.Website = 'www.testing.com';
       // suggestionLead.Validated_DUNS__c= '7573485';
        suggestionLead.DMU_Flag__c = true;
        suggestionLead.Location_Number__c=23;
        suggestionLead.LeadSource='Web';
    }
    TriggerExecutionController.setSkipLeadTriggers(True);
    update listlead;
    system.assertEquals(23, listlead[0].Location_Number__c);
  GAMASuggestionReq.MasterGroupInformation master= new GAMASuggestionReq.MasterGroupInformation(listlead[0]);
  
  GAMASuggestionReq.TrackInformation track = new GAMASuggestionReq.TrackInformation(listlead[0]);
  GAMASuggestionReq.PartnerTrackInformation partner = new GAMASuggestionReq.PartnerTrackInformation(listlead[0]);
  GAMASuggestionReq.BasicInformation basic= new GAMASuggestionReq.BasicInformation(listlead[0]);
  GAMASuggestionReq.SalesRepInformation saleRep= new GAMASuggestionReq.SalesRepInformation(listlead[0]);
  GAMASuggestionReq.TerritoryInformation  territoryInfo= new GAMASuggestionReq.TerritoryInformation(listlead[0]);
  GAMASuggestionReq.UDAInformation uadInfo= new GAMASuggestionReq.UDAInformation(75844532,8734236,'76328');
  GAMASuggestionReq.CustomerInformation  customerInfo= new GAMASuggestionReq.CustomerInformation(4324,'54646',true);
  GAMASuggestionReq.ExternalEntityInformation  externalInfo= new GAMASuggestionReq.ExternalEntityInformation('764237','test','testaction');
  GAMASuggestionReq.LinkNumberInformation  linkInfo= new GAMASuggestionReq.LinkNumberInformation('7634','09/08/2018','4876253','01/02/2019');
  GAMASuggestionReq.SellingMotion  sell= new GAMASuggestionReq.SellingMotion(listlead[0],true);
  GAMASuggestionReq.suggestionInformation sugg= new GAMASuggestionReq.suggestionInformation(listlead[0]);
  
}
    
public static testmethod void testReq(){
/*
Campaign campaignObj=new Campaign(Name='Campaign',
                Campaign_Objective__c='Acquisition/Site Development',
                Type='Advisory Councils',Segment_Business_Unit__c='SMB',
                //Region__c='ABU',                        
                Follow_Up_Role__c='Account Executive',
                Description='Test',StartDate=system.today(),EndDate=system.today(),
                status='In Progress',
                Total_Targets__c = 12.0,  
                IsActive = true);
        insert campaignObj;  
    Lead suggestionLead = new lead();
        suggestionLead.Status = 'Open';
         suggestionLead.LastName='test';
         suggestionLead.Company ='dell';
        suggestionLead.Email = 'test@test.com';
        suggestionLead.MobilePhone = '21441242421'; 
        suggestionLead.Fax = '3737433'; 
        suggestionLead.Lead_Type__c = 'Inbound';
         suggestionLead.Campaign__c=campaignObj.id;
        suggestionLead.Country_Code__c = 'US';
        //suggestionLead.Organization_Country__c = 'United States';
        suggestionLead.Website = 'www.testing.com';
       // suggestionLead.Validated_DUNS__c= '7573485';
        suggestionLead.DMU_Flag__c = true;
        suggestionLead.Location_Number__c=23;
        suggestionLead.LeadSource='Web';
    insert suggestionLead; */
    listlead = [select id,Master_Group_Affinity_ID__c,Mg_Name__c,Mg_Local_Name__c,Number_of_Branches_Subsidiaries__c,Account_Owner__c,SM_country_code__c,Partner_Program_Track__c,
                GU_Duns_number__c,Mg_Website__c,Mg_Address_Line_1__c,Mg_Address_Line_2__c,Account_Owner__r.Badge_Number__c,Postal_Address_1__c,Postal_Address_2__c,Questions_Comments__c,
                Mg_City__c,Mg_Country_Code__c,Mg_Postal_Code__c,Mg_State__c,Account_Owner__r.FirstName,Account_Owner__r.LastName,Postal_City__c,Postal_State__c,
                Mg_Local_Address_Line_1__c,Mg_Local_Address_Line_2__c,Mg_Local_City__c,Territory_Assignment__r.Group_ID__c,Postal_PostalCode__c,Legal_Local_Address_1__c,
                Mg_Local_Postal_Code__c, Mg_Local_State__c,Track_Affinity_ID__c,Partner_Track_Affinity_ID__c,Disable_Rounding__c,Distribution_All_Country_Price__c,
                Distribution_Incumbent_Partner__c, Enabled_for_Services__c,Partner_Profiled_Account_Flag__c,Partner_Program_Tier__c,Fiscal_Year_End__c,Legal_Local_City__c,
                Partner_Storage_Purchasing_Path__c,Primary_Sales_Motion_Affinity_ID__c,Relationship_Type__c,Reporting_Segmentation__c,Legal_Local_Address_2__c,Legal_Local_Company_Name__c,
                SPL_Distribution_Pricing__c, SPL_Partner_Recommend_Pricing__c, VCE_Approved_Partner__c,Partner_Request__c,Partner_Track__c,Std_Quote_Numbers__c,Legal_Local_Postal_Code__c,
                Partner_Track_Account_Local_Name__c,Multi_Track_Parent_ID__c,MUP_Company_Profile_ID__c,Distributor_Authorized_Countries__c,Premier_Page_URL__c,Legal_Local_Postal_State__c,
                Purchase_Path__c,Account_Category__c,Company,Function_Category_Code__c,NDA_Flag__c,Marketing_Class_Code__c,CompanyLocal,National_ID__c,NumberOfEmployees,
                Organization_Country__r.Code__c,Organization_Country__r.User_Currency_Iso_Code__c,Program_Type__c,Retail_Flag__c,CaseRTMigrate__SICCode__c,Sales_Model_Code__c, 
                Sub_Market_Code__c, Segmentation__c,Selling_Motion__c,Partner_Quoting_Account__c,Quoting_Freight_Terms__c,Quoting_Payment_Terms__c,Date_Founded__c,FIN_GEO__c,
                Partner_Quoting_Account_Name__c,Partner_Quoting_Account_SAP_UCID__c,Quoting_Auto_book_Enabled__c,RTM__c,Quoting_EPOA_Flag__c,Quoting_FOB_Incoterms__c,CFI_Project_Numbers__c,
                Universal_Customer_ID_UCID__c,Location_Number__c,Website from lead limit 1];
    listlead[0].DMU_Flag__c = true;
    TriggerExecutionController.setSkipLeadTriggers(True);
    update listlead;
    System.assertEquals(true,listlead[0].DMU_Flag__c); 
    GAMASuggestionReq sugg = new GAMASuggestionReq();
    sugg.generateReq(listlead[0],true);
    }
}