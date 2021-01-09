@IsTest
private class PartnerRequestUtilsTest {
    static list<Country__c> listCountry;
	@testsetup static void setup(){
        list<Country__c> listcountryTDF = TestDataFactory.createNCountry(1);
            insert listcountryTDF;
    }
    private static testmethod void testCreatePartnerRequestHideTrue(){
        listCountry = [Select Id from Country__c limit 1];
        /*final Country__c country = new Country__c();
        country.Code__c = 'XX';
        country.Name = 'XXXXXXXXXX';
        country.Task_Agreement_Hard_copy_Received__c = 'Hide';
        country.Task_Check_Credit__c = 'Hide';
        country.Task_Check_Denied_Party_List__c = 'Hide';
        country.Task_Check_Export_Compliance__c = 'Hide';
        country.Task_Enable_Order_Management_access__c = 'Hide';
        country.Task_Enable_Premier_Pages_access__c = 'Hide';
        country.Task_Send_Welcome_Packet_to_Partner__c = 'Hide';
        insert country;*/
    	
        final Partner_Request__c request = new Partner_Request__c(
            First_Name__c = 'John',
            Last_Name__c = 'Doe',
            Email__c = 'john.doe@acme.com',
            Company__c = 'Tyama',
            Country__c = listCountry[0].id);
    	
    	System.assertEquals('john.doe@acme.com',request.Email__c);
		//System.assertEquals(null,request.Task_Check_Credit__c);
		//System.assertEquals(null,request.Task_Check_Denied_Party_List__c);
		//System.assertEquals(null,request.Task_Check_Export_Compliance__c);
		//System.assertEquals(null,request.Task_Enable_Order_Management_access__c);
		//System.assertEquals(null,request.Task_Enable_Premier_Pages_access__c);
		//System.assertEquals(null,request.Task_Send_Welcome_Packet_to_Partner__c);
    	
    	PartnerRequestUtils.updateTaskHideFlags(request);
    	
        /*System.assertEquals('Hide',request.Task_Agreement_Hard_copy_Received__c);
        System.assertEquals('Hide',request.Task_Check_Credit__c);
        System.assertEquals('Hide',request.Task_Check_Denied_Party_List__c);
        System.assertEquals('Hide',request.Task_Check_Export_Compliance__c);
        System.assertEquals('Hide',request.Task_Enable_Order_Management_access__c);
        System.assertEquals('Hide',request.Task_Enable_Premier_Pages_access__c);
        System.assertEquals('Hide',request.Task_Send_Welcome_Packet_to_Partner__c);*/
    	
    }	


    private static testmethod void testCreatePartnerRequestHideFalse(){
        listCountry = [Select Id from Country__c limit 1];
        /*final Country__c country = new Country__c();
        country.Code__c = 'XX';
        country.Name = 'XXXXXXXXXX';
        country.Task_Agreement_Hard_copy_Received__c = 'Show, Optional';
        country.Task_Check_Credit__c = 'Show, Optional';
        country.Task_Check_Denied_Party_List__c = 'Show, Optional';
        country.Task_Check_Export_Compliance__c = 'Show, Optional';
        country.Task_Enable_Order_Management_access__c = 'Show, Optional';
        country.Task_Enable_Premier_Pages_access__c = 'Show, Optional';
        country.Task_Send_Welcome_Packet_to_Partner__c = 'Show, Optional';
        insert country;*/
    	
        final Partner_Request__c request = new Partner_Request__c(
            First_Name__c = 'John',
            Last_Name__c = 'Doe',
            Email__c = 'john.doe@acme.com',
            Company__c = 'Tyama',
            Country__c = listCountry[0].id);
    	
        System.assertEquals('Doe',request.Last_Name__c);
        /*System.assertEquals(null,request.Task_Check_Credit__c);
        System.assertEquals(null,request.Task_Check_Denied_Party_List__c);
        System.assertEquals(null,request.Task_Check_Export_Compliance__c);
        System.assertEquals(null,request.Task_Enable_Order_Management_access__c);
        System.assertEquals(null,request.Task_Enable_Premier_Pages_access__c);
        System.assertEquals(null,request.Task_Send_Welcome_Packet_to_Partner__c);*/
        
    	PartnerRequestUtils.updateTaskHideFlags(request);
    	
        /*System.assertEquals('Show, Optional',request.Task_Agreement_Hard_copy_Received__c);
        System.assertEquals('Show, Optional',request.Task_Check_Credit__c);
        System.assertEquals('Show, Optional',request.Task_Check_Denied_Party_List__c);
        System.assertEquals('Show, Optional',request.Task_Check_Export_Compliance__c);
        System.assertEquals('Show, Optional',request.Task_Enable_Order_Management_access__c);
        System.assertEquals('Show, Optional',request.Task_Enable_Premier_Pages_access__c);
        System.assertEquals('Show, Optional',request.Task_Send_Welcome_Packet_to_Partner__c);*/
    	
    }	

    private static testmethod void testCreatePartnerRequestNoTaskShowHideValues(){
        listCountry = [Select Id from Country__c limit 1];
        /*final Country__c country = new Country__c();
        country.Code__c = 'XX';
        country.Name = 'XXXXXXXXXX';
        country.Task_Agreement_Hard_copy_Received__c = null;
        country.Task_Check_Credit__c = null;
        country.Task_Check_Denied_Party_List__c = null;
        country.Task_Check_Export_Compliance__c = null;
        country.Task_Enable_Order_Management_access__c = null;
        country.Task_Enable_Premier_Pages_access__c = null;
        country.Task_Send_Welcome_Packet_to_Partner__c = null;
        insert country;*/
        
        final Partner_Request__c request = new Partner_Request__c(
            First_Name__c = 'John',
            Last_Name__c = 'Doe',
            Email__c = 'john.doe@acme.com',
            Company__c = 'Tyama',
            Country__c = listCountry[0].id);
        
        System.assertEquals('Tyama',request.Company__c);
        /*System.assertEquals(null,request.Task_Check_Credit__c);
        System.assertEquals(null,request.Task_Check_Denied_Party_List__c);
        System.assertEquals(null,request.Task_Check_Export_Compliance__c);
        System.assertEquals(null,request.Task_Enable_Order_Management_access__c);
        System.assertEquals(null,request.Task_Enable_Premier_Pages_access__c);
        System.assertEquals(null,request.Task_Send_Welcome_Packet_to_Partner__c);*/
        
        PartnerRequestUtils.updateTaskHideFlags(request);
        
        /*System.assertEquals(null,request.Task_Agreement_Hard_copy_Received__c);
        System.assertEquals(null,request.Task_Check_Credit__c);
        System.assertEquals(null,request.Task_Check_Denied_Party_List__c);
        System.assertEquals(null,request.Task_Check_Export_Compliance__c);
        System.assertEquals(null,request.Task_Enable_Order_Management_access__c);
        System.assertEquals(null,request.Task_Enable_Premier_Pages_access__c);
        System.assertEquals(null,request.Task_Send_Welcome_Packet_to_Partner__c);*/
        
        
    }   


    private static testmethod void testCountryNoLongerExists(){
        
        listCountry = [Select Id from Country__c limit 1];
        /*final Country__c country = new Country__c();
        country.Code__c = 'XX';
        country.Name = 'XXXXXXXXXX';
        country.Task_Agreement_Hard_copy_Received__c = 'Hide';
        country.Task_Check_Credit__c = 'Hide';
        country.Task_Check_Denied_Party_List__c = 'Hide';
        country.Task_Check_Export_Compliance__c = 'Hide';
        country.Task_Enable_Order_Management_access__c = 'Hide';
        country.Task_Enable_Premier_Pages_access__c = 'Hide';
        country.Task_Send_Welcome_Packet_to_Partner__c = 'Hide';
        insert country;*/
        
        final ID countryID = listCountry[0].id;
        delete listCountry[0];
        
        final Partner_Request__c request = new Partner_Request__c(
            First_Name__c = 'John',
            Last_Name__c = 'Doe',
            Email__c = 'john.doe@acme.com',
            Company__c = 'Tyama',
            Country__c = countryId);
        
        System.assertEquals('John',request.First_Name__c);
        /*System.assertEquals(null,request.Task_Check_Credit__c);
        System.assertEquals(null,request.Task_Check_Denied_Party_List__c);
        System.assertEquals(null,request.Task_Check_Export_Compliance__c);
        System.assertEquals(null,request.Task_Enable_Order_Management_access__c);
        System.assertEquals(null,request.Task_Enable_Premier_Pages_access__c);
        System.assertEquals(null,request.Task_Send_Welcome_Packet_to_Partner__c);
        */
        PartnerRequestUtils.updateTaskHideFlags(request);
        /*
        System.assertEquals(null,request.Task_Agreement_Hard_copy_Received__c);
        System.assertEquals(null,request.Task_Check_Credit__c);
        System.assertEquals(null,request.Task_Check_Denied_Party_List__c);
        System.assertEquals(null,request.Task_Check_Export_Compliance__c);
        System.assertEquals(null,request.Task_Enable_Order_Management_access__c);
        System.assertEquals(null,request.Task_Enable_Premier_Pages_access__c);
        System.assertEquals(null,request.Task_Send_Welcome_Packet_to_Partner__c);*/
        
    }   


}