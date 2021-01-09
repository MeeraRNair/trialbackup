/*
History:
Version     Date                Modified By         CR#             Description     
--------------------------------------------------------------------------------------
1.0                                                                 Created
1.1         24-Aug-2019         Abhinav             CR#17870        Separated logic for lex user only
*/
public class LOTOpportunityTriggerHandlerBU implements BeforeUpdate{
    @TestVisible static Boolean bIsInLexUI = (UserInfo.getUiTheme() == 'Theme4d' || UserInfo.getUiTheme() == 'Theme4t' || UserInfo.getUiTheme() == 'Theme4u');
    public void handleBeforeUpdate(List<sObject> listNew, Map<Id, sObject> mapOld) {
        System.debug(UserInfo.getUiTheme() + 'bIsInLexUI = ' + bIsInLexUI);
        //1.1 - BOF
        if(bIsInLexUI) {
            OpportunityQuoteTriggerHelper.validateQuotesAgainstProbability(Trigger.new, (map<Id, Opportunity>)Trigger.oldMap);
        }
        //1.1 - EOF
    }
}