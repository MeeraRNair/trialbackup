@IsTest
private class PartnerConstantsTest {
    private static testmethod void testConstants(){
        //no asserts, purpose of this test is just to get code coverage 100%
        String constant = PartnerConstants.REG_STATUS_DRAFT;
        constant = PartnerConstants.REG_STATUS_OWNED;
        constant = PartnerConstants.REG_STATUS_INCOMPLETE;
        constant = PartnerConstants.REG_STATUS_APPROVED;
        constant = PartnerConstants.REG_STATUS_REJECTED;
        constant = PartnerConstants.REG_STATUS_RESUBMITTED;
        constant = PartnerConstants.REG_STATUS_INREVIEW;
        constant = PartnerConstants.REG_STATUS_DUPLICATE;
        constant = PartnerConstants.REG_STATUS_COMPLETE;
        constant = PartnerConstants.REQUEST_RECORD_TYPE_NEW_PARTNER;
        constant = PartnerConstants.REQUEST_RECORD_TYPE_UPDATE_PARTNER;
        constant = PartnerConstants.REQUEST_RECORD_TYPE_NEW_USER;
        constant = PartnerConstants.REQUEST_RECORD_TYPE_REMOVE_USER;
        constant = PartnerConstants.REQUEST_RECORD_TYPE_UPDATE_USER;
        constant = PartnerConstants.REG_STATUS_INCOMPLETEANDEXPIRED;
        constant = PartnerConstants.REG_STATUS_LEADDRAFT;
        constant = PartnerConstants.REG_STATUS_ACCOUNT_SUGGESTION_SUBMITTED;
        constant = PartnerConstants.REG_STATUS_ACCOUNT_SUGGESTION_COMPLETED;
        constant = PartnerConstants.REG_STATUS_ACCOUNT_SUGGESTION_REJECTED;
        constant = PartnerConstants.REG_STATUS_ACCOUNT_SUGGESTION_CREATED;
        constant = PartnerConstants.REG_STATUS_ACCOUNT_SUGGESTION_PROCESS_ERRORED;
        constant = PartnerConstants.REQUEST_RECORD_TYPE_NEW_PARTNER;
        constant = PartnerConstants.REQUEST_RECORD_TYPE_UPDATE_PARTNER;
        constant = PartnerConstants.REQUEST_RECORD_TYPE_NEW_USER;
        constant = PartnerConstants.REQUEST_RECORD_TYPE_REMOVE_USER;
        constant = PartnerConstants.REQUEST_RECORD_TYPE_UPDATE_USER;
        constant = PartnerConstants.REQUEST_RECORD_TYPE_EXIST_PARTNER;
        constant = PartnerConstants.REQUEST_RECORD_TYPE_NEW_PARTNER_ADMIN;
        constant = PartnerConstants.SSO_LINK_MY_ACCT_URL;
    }
}