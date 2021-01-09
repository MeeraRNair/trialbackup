public interface BeforeUpdate {
    void handleBeforeUpdate(List<sObject> listNew, Map<Id, sObject> mapOld);
}