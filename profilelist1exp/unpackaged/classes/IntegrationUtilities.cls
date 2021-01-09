public class IntegrationUtilities{
/*
 * Author   : Niveda
 * Purpose  : This is an utility class to build an xml
 *
*/
    
    public static XmlStreamWriter startElement(XmlStreamWriter w, String tagName,String startTag, String startUrl){
        w.writeStartElement(startTag, tagName, startUrl);
        return w;
    }

    public static XmlStreamWriter addElementAndValueString(XmlStreamWriter w, String tagName, String value, String startTag, String startUrl){
        w.writeStartElement(startTag, tagName, startUrl);
        if(value == null){
            w.writeCharacters('');  
        }
        else{
            w.writeCharacters(value);
        }
        
        w.writeEndElement();
        return w;
    }

    //Method to add elemenet and value of type String to the XmlStreamWriter
    public static XmlStreamWriter addElementFromMap(XmlStreamWriter w, String tagName, Map<String, String> parameterMap,String startTag, String startUrl){       
        w.writeStartElement(startTag, tagName, startUrl);      
            w.writeCharacters(StringUtils.defaultString(parameterMap.get(tagName)));         
        w.writeEndElement();
        return w;
    }
   
    //Method to add elemenet and value to the XmlStreamWriter
    public static XmlStreamWriter addElementAndValue(XmlStreamWriter w, string tagName, sObject record, string fieldName, String startTag, String startUrl){
    
        String valueToBeAdded = '';     
            
        if(record.get(fieldName)!=null){
                valueToBeAdded += record.get(fieldName);
        }
        system.debug('## tagName :' + tagName + '## value : ' + valueToBeAdded);
        
        w.writeStartElement(startTag, tagName, startUrl); 
        if(valueToBeAdded != ''){
            w.writeCharacters(valueToBeAdded);
        }
        w.writeEndElement();
        return w;
    }

}