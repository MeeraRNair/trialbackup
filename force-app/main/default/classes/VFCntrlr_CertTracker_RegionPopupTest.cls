@isTest
private class VFCntrlr_CertTracker_RegionPopupTest{

    public static testmethod void testRegionPopup(){
        PageReference pageRef = Page.CertTracker_RegionPopup;
        Test.setCurrentPageReference(pageRef);
        VFCntrlr_CertTracker_RegionPopup certRegPopup = new VFCntrlr_CertTracker_RegionPopup();
        certRegPopup.go();
        certRegPopup.cancel();
        certRegPopup.getItems();
        
        PageReference pageRef1 =  new PageReference('/apex/CertTracker_RegionPopup?frompg=Eval');
        Test.setCurrentPageReference(pageRef1);
        VFCntrlr_CertTracker_RegionPopup certRegPopup1 = new VFCntrlr_CertTracker_RegionPopup();
        certRegPopup1.go();
        certRegPopup1.cancel();
        certRegPopup1.getItems();
        
    }
}