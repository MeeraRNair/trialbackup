@isTest
global class Channel_Manager_and_Profile_Test {
    static testmethod void testMethod1(){
        Channel_Manager_and_Profile.fetchAccountdetails();
        Channel_Manager_and_Profile.fetchDistiRelationDetails(null);
        System.assertNotEquals(null, Channel_Manager_and_Profile.fetchAccountdetails());
    }
}