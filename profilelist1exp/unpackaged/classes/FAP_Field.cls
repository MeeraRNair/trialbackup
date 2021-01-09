global class FAP_Field implements FAP_Soqlable{

    private String name;
    private Boolean toLabelx;
    
    global FAP_Field(String name){
        this.name = name;
        this.toLabelx = false;
    }

    global FAP_Field toLabelx(){
        this.toLabelx = true;
        return this;
    }

    global String toSoql(){ return this.toSoql(null); }
    
    global String toSoql(FAP_SoqlOptions options){
        if(options == null){
            options = FAP_SoqlOptions.defaultOptions;
        }
      return (toLabelx ? 'toLabel(' : '') + name + (toLabelx ? ')' : '');
    }
    
}