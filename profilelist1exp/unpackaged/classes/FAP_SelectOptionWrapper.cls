/* ============================================================
 * Find a Partner Utility Class
 * ============================================================
 */
 
/*
 * NOTE: created this class as a workaround to issue in Winter with casting Object to SelectOption.
 * See http://community.salesforce.com/sforce/board/message?board.id=apex&thread.id=24143
 */
global class FAP_SelectOptionWrapper{
  global SelectOption selectOption{get;set;}
  global FAP_SelectOptionWrapper(SelectOption selectOption){
    this.selectOption = selectOption;
  }
}