public interface AfterUpdate {
    void handleAfterUpdate(List<sObject> listNew, Map<Id, sObject> mapOld);
}