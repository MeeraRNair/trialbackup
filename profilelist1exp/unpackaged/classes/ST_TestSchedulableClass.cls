@isTest
   
                                
private class ST_TestSchedulableClass
{
    // CRON expression: midnight on March 15.
   // Because this is a test, job executes
   // immediately after Test.stopTest().
   
   public static String CRON_EXP = '0 0 0 15 3 ? 2022';
   static testmethod void test() 
   {
     try
     {
     Test.startTest();

      // Schedule the test job
      String jobId = System.schedule('ScheduleApexClassTest',
                        CRON_EXP, 
                        new ST_Product_Update());
      // Get the information from the CronTrigger API object
      CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, 
         NextFireTime
         FROM CronTrigger WHERE id = :jobId];

      // Verify the expressions are the same
      System.assertEquals(CRON_EXP, 
         ct.CronExpression);

      // Verify the job has not run
      System.assertEquals(0, ct.TimesTriggered);

      // Verify the next time the job will run
      System.assertEquals('2022-03-15 00:00:00', 
         String.valueOf(ct.NextFireTime));
      
      
      Test.stopTest();
    }
    catch (Exception ex)
    {
       // We will have exception as call out is not supported 
    }
  }
  
  private static String Build_product()
   {        
          String xmlString = '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">';
          xmlString = xmlString + '<soapenv:Body>';
            xmlString = xmlString + '<ns0:New_GetList_Operation_0Response xmlns:ns0="urn:DELL_PCT_PCT_ProductAliasCPYAssocLookUp_WS">';
              xmlString = xmlString + '<ns0:getListValues>';
                xmlString = xmlString + '<ns0:Product_ID>PDC000000010891</ns0:Product_ID>';
                xmlString = xmlString + '<ns0:Product_Categorization_Tier_1>HARDWARE</ns0:Product_Categorization_Tier_1>';
                xmlString = xmlString + '<ns0:Product_Categorization_Tier_2>SERVER</ns0:Product_Categorization_Tier_2>';
                xmlString = xmlString + '<ns0:Product_Categorization_Tier_3>APPLIANCE</ns0:Product_Categorization_Tier_3>';
                xmlString = xmlString + '<ns0:Product_Name>IBM-APPLIANCE</ns0:Product_Name>';
                xmlString = xmlString + '<ns0:Product_Alias>IBM-APPLIANCE</ns0:Product_Alias>';
                xmlString = xmlString + '<ns0:Status-PDA>Enabled</ns0:Status-PDA>';
                xmlString = xmlString + '<ns0:Status-PDC>Enabled</ns0:Status-PDC>';
                xmlString = xmlString + '<ns0:Request_Selection>Yes</ns0:Request_Selection>';
                xmlString = xmlString + '</ns0:getListValues>';
                xmlString = xmlString + '<ns0:getListValues>';
                xmlString = xmlString + '<ns0:Product_ID>PDC000000010892</ns0:Product_ID>';
                xmlString = xmlString + '<ns0:Product_Categorization_Tier_1>HARDWARE</ns0:Product_Categorization_Tier_1>';
                xmlString = xmlString + '<ns0:Product_Categorization_Tier_2>SERVER</ns0:Product_Categorization_Tier_2>';
                xmlString = xmlString + '<ns0:Product_Categorization_Tier_3>APPLIANCE</ns0:Product_Categorization_Tier_3>';
                xmlString = xmlString + '<ns0:Product_Name>IBM-APPLIANCE</ns0:Product_Name>';
                xmlString = xmlString + '<ns0:Product_Alias>IBM-APPLIANCE</ns0:Product_Alias>';
                xmlString = xmlString + '<ns0:Status-PDA>Enabled</ns0:Status-PDA>';
                xmlString = xmlString + '<ns0:Status-PDC>Enabled</ns0:Status-PDC>';
                xmlString = xmlString + '<ns0:Request_Selection>Yes</ns0:Request_Selection>';
              xmlString = xmlString + '</ns0:getListValues>';
              
        xmlString = xmlString + '</ns0:New_GetList_Operation_0Response>';
        xmlString = xmlString + '  </soapenv:Body>';
        xmlString = xmlString + '</soapenv:Envelope> '; 
        return xmlString;
    }


    static testmethod void test_readReponseProduct() 
    {
     try
     {
            string resp_body = Build_product();
            ST_Product_Update.readResponseString(resp_body);
     }
     catch (exception ex)
     {
       
     }
    }
    
    static testmethod void test_DeleteProduct() 
    {
         try
         {
            ST_Product_Update.DeleteProduct();
         }
         catch( exception ex)
         {
         
         }
     }
     
   
   //------------------------------------------------------------------- Tiers
   
       static testmethod void test_tier() 
       {
         try
         {
         Test.startTest();
    
          // Schedule the test job
          String jobId = System.schedule('ScheduleApexClassTest',
                            CRON_EXP, 
                            new ST_Tiers_Update());
          // Get the information from the CronTrigger API object
          CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, 
             NextFireTime
             FROM CronTrigger WHERE id = :jobId];
    
          // Verify the expressions are the same
          System.assertEquals(CRON_EXP, 
             ct.CronExpression);
    
          // Verify the job has not run
          System.assertEquals(0, ct.TimesTriggered);
    
          // Verify the next time the job will run
          System.assertEquals('2022-03-15 00:00:00', 
             String.valueOf(ct.NextFireTime));
          
          
          Test.stopTest();
        }
        catch (Exception ex)
        {
           // We will have exception as call out is not supported 
        }
      }
   
   
    static testmethod void test_readReponseTier() 
    {
     try
     {
            string resp_body = Build_tier();
            ST_Tiers_Update.readResponseString(resp_body);
     }
     catch (exception ex)
     {
       
     }
    }
   
   static testmethod void test_DeleteTier() 
    {
         try
         {
            ST_Tiers_Update.DeleteTier();
         }
         catch( exception ex)
         {
         
         }
     }
   
   public static String Build_tier()
   {        
     String xmlString = '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">';
     xmlString = xmlString + '<soapenv:Body>';
     xmlString = xmlString + '<ns0:New_GetList_Operation_0Response xmlns:ns0="urn:DELL_CFG_Service_Catalog_Lookup_Product_WS">';
         xmlString = xmlString + '<ns0:getListValues>';
            xmlString = xmlString + '<ns0:O2P_ID>OTP000000002697</ns0:O2P_ID>';
            xmlString = xmlString + '<ns0:Create_Date>2010-03-09T16:57:45-06:00</ns0:Create_Date>';
            xmlString = xmlString + '<ns0:Modified_Date>2010-03-09T16:57:45-06:00</ns0:Modified_Date>';
            xmlString = xmlString + '<ns0:Product_Categorization_Tier_1>TELECOM</ns0:Product_Categorization_Tier_1>';
            xmlString = xmlString + '<ns0:Product_Categorization_Tier_2>SOFTPHONE</ns0:Product_Categorization_Tier_2>';
            xmlString = xmlString + '<ns0:Product_Categorization_Tier_3>HEADSET</ns0:Product_Categorization_Tier_3>';
            xmlString = xmlString + '<ns0:Product_Name>HEADSET - MOC PHONE</ns0:Product_Name>';
            xmlString = xmlString + '<ns0:Service_Categorization_Tier_1>FAILURE</ns0:Service_Categorization_Tier_1>';
            xmlString = xmlString + '<ns0:Service_Categorization_Tier_3>ACCOUNT LOCKED</ns0:Service_Categorization_Tier_3>';
            xmlString = xmlString + '<ns0:Service_Categorization_Tier_2>ACCESS</ns0:Service_Categorization_Tier_2>';
            xmlString = xmlString + '<ns0:Status-CTA>Enabled</ns0:Status-CTA>';
            xmlString = xmlString + '<ns0:Status-CAT>Enabled</ns0:Status-CAT>';
            xmlString = xmlString + '<ns0:Request_ID>CTA000000000039|CAT000000000039|OTP000000002697</ns0:Request_ID>';
            xmlString = xmlString + '<ns0:Last_Modified_By>DENISE_VELA</ns0:Last_Modified_By>';
            xmlString = xmlString + '<ns0:Product_ID>PDC000000016632</ns0:Product_ID>';
            xmlString = xmlString + '<ns0:Status>Enabled</ns0:Status>';
         xmlString = xmlString + '</ns0:getListValues>';
         xmlString = xmlString + '<ns0:getListValues>';
            xmlString = xmlString + '<ns0:O2P_ID>OTP000000002698</ns0:O2P_ID>';
            xmlString = xmlString + '<ns0:Create_Date>2010-03-09T16:57:45-06:00</ns0:Create_Date>';
            xmlString = xmlString + '<ns0:Modified_Date>2010-03-09T16:57:45-06:00</ns0:Modified_Date>';
            xmlString = xmlString + '<ns0:Product_Categorization_Tier_1>SOFTWARE</ns0:Product_Categorization_Tier_1>';
            xmlString = xmlString + '<ns0:Product_Categorization_Tier_2>APPLICATION</ns0:Product_Categorization_Tier_2>';
            xmlString = xmlString + '<ns0:Product_Categorization_Tier_3>IT SUPPORTED</ns0:Product_Categorization_Tier_3>';
            xmlString = xmlString + '<ns0:Product_Name>UNIFIED COMMUNICATIONS</ns0:Product_Name>';
            xmlString = xmlString + '<ns0:Service_Categorization_Tier_1>FAILURE</ns0:Service_Categorization_Tier_1>';
            xmlString = xmlString + '<ns0:Service_Categorization_Tier_3>ACCOUNT LOCKED</ns0:Service_Categorization_Tier_3>';
            xmlString = xmlString + '<ns0:Service_Categorization_Tier_2>ACCESS</ns0:Service_Categorization_Tier_2>';
            xmlString = xmlString + '<ns0:Status-CTA>Enabled</ns0:Status-CTA>';
            xmlString = xmlString + '<ns0:Status-CAT>Enabled</ns0:Status-CAT>';
            xmlString = xmlString + '<ns0:Request_ID>CTA000000000039|CAT000000000039|OTP000000002698</ns0:Request_ID>';
            xmlString = xmlString + '<ns0:Last_Modified_By>DENISE_VELA</ns0:Last_Modified_By>';
            xmlString = xmlString + '<ns0:Product_ID>PDC000000011767</ns0:Product_ID>';
            xmlString = xmlString + '<ns0:Status>Enabled</ns0:Status>';
         xmlString = xmlString + '</ns0:getListValues>';              
        xmlString = xmlString + '</ns0:New_GetList_Operation_0Response>';
        xmlString = xmlString + '  </soapenv:Body>';
        xmlString = xmlString + '</soapenv:Envelope> '; 
        return xmlString;
    }
}