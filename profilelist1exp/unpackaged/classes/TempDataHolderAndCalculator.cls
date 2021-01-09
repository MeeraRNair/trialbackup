/***********************************************************
    * Name          : TempDataHolderAndCalculator
    * Description   : Interface class to store the data and to calculate the result
    * ---------------------------------------------------------
    * Revision  Name             Date         Description
    * 1.0       Jessie Tan       24-Apr-2014  CR 9548  DSG AP Phase 1 - NPS Data Calculations in Account Plan
************************************************************/

global interface TempDataHolderAndCalculator{
    
    void storeSourceData(Set<Id> idSet);
    
    Object calculateResult(String id);
        
}