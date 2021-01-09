public class FAP_RenderFilterField {
  public FAP_RenderField filterField1{get; set;}
  public FAP_RenderField filterField2{get; set;}
  public FAP_RenderField filterField3{get; set;}
  
  public static List<FAP_RenderFilterField> putFilterFieldList(List<FAP_RenderField> renderFields){
    List<FAP_RenderFilterField> fields = new List<FAP_RenderFilterField>();
    Integer rowCount = Math.ceil(renderFields.size() / 3.0).intValue();
    //PageUtils.addInfo('Filter Size :' + renderFields.size() );
    for(Integer i=0;i<rowCount;i++){
      FAP_RenderFilterField field = new FAP_RenderFilterField();
      fields.add(field);
      field.filterField1=renderFields[i*3];
      if(i==(rowCount-1)){
        if((i*3) + 1 >= renderFields.size()){
          break;
        } else {
          field.filterField2=renderFields[i*3+1];
          if(((i*3) + 2 >= renderFields.size())){
            break;
          } else {
            field.filterField3=renderFields[i*3+2];
          }
        }
      } else {
        field.filterField2=renderFields[(i*3) + 1];
        field.filterField3=renderFields[(i*3) + 2];
      }
    }
    return fields;
  }
}