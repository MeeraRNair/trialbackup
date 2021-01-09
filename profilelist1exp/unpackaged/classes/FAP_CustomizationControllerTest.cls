@IsTest
private class FAP_CustomizationControllerTest {
    
    private static testMethod void testHidden(){
        FAP_Customization__c fapCustObj = new FAP_Customization__c(
            Field_label__c = 'Distance',
            Location__c = 'Hidden',
            Field_Order__c = 1,
            User_type__c = 'Un-authenticated',
            Region__c = 'NA',
            Is_Active__c = true);
            
            insert fapCustObj;
            
            FAP_CustomizationController controller = new FAP_CustomizationController();
            controller.fapCustObj.Region__c = 'NA';
            controller.fapCustObj.User_type__c = 'Un-authenticated';
            controller.fapCustObj.Is_Active__c =  true;
            
            system.AssertEquals(controller.fapCustObj.Is_Active__c,true);
            controller.doquery();
            controller.gethiddenSelectOptions();
            controller.selectToRegular();
           
    }    
    
     private static testMethod void tesRegular(){
         
         List<FAP_Customization__c> lstFAPCust = new List<FAP_Customization__c>{new FAP_Customization__c (Field_label__c = 'Competencies', Location__c = 'Regular',Field_Order__c = 1,User_type__c = 'Un-authenticated', Region__c = 'NA', Is_Active__c = true ),
                                                                            new FAP_Customization__c (Field_label__c = 'Industry', Location__c = 'Regular',Field_Order__c = 2,User_type__c = 'Authenticated', Region__c = 'LATAM', Is_Active__c = true )};
                                                                                
           insert lstFAPCust ;
           
           FAP_CustomizationController controller = new FAP_CustomizationController();
            controller.fapCustObj.Region__c = lstFAPCust[1].Region__c;
            controller.fapCustObj.User_type__c = lstFAPCust[1].User_type__c;
            controller.fapCustObj.Is_Active__c =  lstFAPCust[1].Is_Active__c;
            controller.doquery();
            system.AssertEquals(controller.fapCustObj.Region__c,lstFAPCust[1].Region__c);
            controller.getregularSelectOptions();
            controller.MoveUpRegular();
            controller.selectToRegular();
            controller.MoveDownRegular();
            controller.unSelectFromRegular();
            controller.save();
           
         }
         
         private static testMethod void tesRegularHidden(){
             
            List<FAP_Customization__c> lstFAPCust = new List<FAP_Customization__c>{new FAP_Customization__c (Field_label__c = 'Location', Location__c = 'Hidden',Field_Order__c = 1,User_type__c = 'Authenticated', Region__c = 'LATAM', Is_Active__c = true ),
                                                                                new FAP_Customization__c (Field_label__c = 'Distance', Location__c = 'Regular',Field_Order__c = 2,User_type__c = 'Authenticated', Region__c = 'LATAM', Is_Active__c = true ),
                                                                                new FAP_Customization__c (Field_label__c = 'Industry', Location__c = 'Regular',Field_Order__c = 3,User_type__c = 'Authenticated', Region__c = 'LATAM', Is_Active__c = true ),
                                                                                new FAP_Customization__c (Field_label__c = 'Competencies', Location__c = 'Regular',Field_Order__c = 4,User_type__c = 'Authenticated', Region__c = 'LATAM', Is_Active__c = true ),
                                                                                new FAP_Customization__c (Field_label__c = 'Find a Reseller', Location__c = 'Regular',Field_Order__c = 5,User_type__c = 'Authenticated', Region__c = 'LATAM', Is_Active__c = true )
            };
                                                                                
           insert lstFAPCust ;
            FAP_CustomizationController controller = new FAP_CustomizationController();
            controller.fapCustObj.Region__c = lstFAPCust[1].Region__c;
            controller.fapCustObj.User_type__c = lstFAPCust[1].User_type__c;
            controller.fapCustObj.Is_Active__c =  lstFAPCust[1].Is_Active__c;
            controller.doquery();
            controller.selectedRegular = new List<string>{lstFAPCust[0].Field_label__c,lstFAPCust[1].Field_label__c};
            system.Assert(controller.selectedRegular.contains(lstFAPCust[0].Field_label__c));
            controller.MoveUpRegular();
            controller.MoveDownRegular();
            controller.unSelectFromRegular();
            
            //controller.save();
            
           
           
         }
     
}