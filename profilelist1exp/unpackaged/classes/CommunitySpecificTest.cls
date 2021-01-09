@isTest
private class CommunitySpecificTest {

    static testMethod void testEmployeestormCommunitySpecificsExists() {
        CommunitySpecifics cs = new ideaTestCommunitySpecifics();
    }

    static testMethod void testIdeastormCommunitySpecificsExists() {
        CommunitySpecifics cs = new IdeastormCommunitySpecifics();
    }

    static testMethod void testCommunitySpecificHasCommunityName() {
        CommunitySpecifics cs = new ideaTestCommunitySpecifics();
        System.assertEquals(cs.communityName(), 'Test Community');
        cs = new IdeastormCommunitySpecifics();
        System.assertEquals(cs.communityName(), 'AccountStorm');
    }

    static testMethod void testCommunitySpecificHasUrlPrefix() {
        CommunitySpecifics cs = new ideaTestCommunitySpecifics();
        System.assertEquals(cs.urlPrefix(), '/apex');
        cs = new IdeastormCommunitySpecifics();
        System.assertEquals(cs.urlPrefix(), '/apex');
    }

    static testMethod void testStringCommunitySpecifierWorks() {
        CommunitySpecific.CommunitySpecifier cscs = new CommunitySpecific.StringCommunitySpecifier('AccountStorm');
        System.assertEquals(cscs.communityName(), 'AccountStorm');
    }

    static testMethod void testReturnsAppropriateInstance() {
        CommunitySpecific.CommunitySpecifier cscs = new CommunitySpecific.StringCommunitySpecifier('AccountStorm');
        CommunitySpecifics cs = CommunitySpecific.instance(cscs);
        System.assertEquals(cs.communityName(), 'AccountStorm');

        CommunitySpecific.clearInstance();
        cscs = new CommunitySpecific.StringCommunitySpecifier('Test Community');
        cs = CommunitySpecific.instance(cscs);
        System.assertEquals(cs.communityName(), 'Test Community');
    }

    static testMethod void testCategoryGroups() {
        CommunitySpecifics cs = new IdeastormCommunitySpecifics();
        List<MultiColumnItemGroup> groups = cs.categoryGroups();
        System.assertEquals(4, groups.size());

        cs = new ideaTestCommunitySpecifics();
        groups = cs.categoryGroups();
        System.assertEquals(1, groups.size());
    }

}