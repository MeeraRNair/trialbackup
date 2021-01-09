@IsTest
private class ApprovalRequestCommentsController_TC {

    @IsTest
    private static void testgetcomments() {

       
       ApprovalRequestCommentsController contr = new ApprovalRequestCommentsController();
       // PMD Fixes, modify method name and used assert
       system.assert(String.isBlank(contr.strComments));

    }
    
}