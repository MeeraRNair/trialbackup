global class FAP_DateFormula implements FAP_Soqlable{

    private String literal = null;
    
    global String toSoql(){ return this.toSoql(FAP_SoqlOptions.defaultOptions); }
    
    global String toSoql(final FAP_SoqlOptions options){
      if(FAP_StringUtils.isBlank(literal)){
        throw new FAP_IllegalStateException();
      }
      return literal;
    }

    global FAP_DateFormula yesterdayx(){ this.literal = 'YESTERDAY'; return this;}
    global FAP_DateFormula todayx(){     this.literal = 'TODAY'; return this;}
    global FAP_DateFormula tomorrowx(){  this.literal = 'TOMORROW'; return this;}
    global FAP_DateFormula thisx(FAP_UnitOfTime unit){
      if(unit == FAP_UnitOfTime.Day){
        return todayx();
      } 
      this.literal = 'THIS_' + unitToLabel(unit); 
      return this;
    }

    global FAP_DateFormula last90Days(){ return last(90,FAP_UnitOfTime.Day); }
    global FAP_DateFormula next90Days(){ return next(90,FAP_UnitOfTime.Day); }

    global FAP_DateFormula last(FAP_UnitOfTime unit){ return last(1,unit); }
    global FAP_DateFormula next(FAP_UnitOfTime unit){ return next(1,unit); }
    
    global FAP_DateFormula last(Integer n, FAP_UnitOfTime unit){ this.literal = 'LAST_' + toUnitAndAmount(n,unit); return this;}
    global FAP_DateFormula next(Integer n, FAP_UnitOfTime unit){ this.literal = 'NEXT_' + toUnitAndAmount(n,unit); return this;}
    
    private String toUnitAndAmount(Integer n, FAP_UnitOfTime unit){
      String unitAndAmount = '';
      if(n < 0){
            throw new FAP_IllegalArgumentException('n cannot be negative');
      } else if(n == 90 && unit == FAP_UnitOfTime.Day){
          unitAndAmount += '90_' + unitToLabel(FAP_UnitOfTime.Day) + 'S'; 
        } else if(n == 1 && unit != FAP_UnitOfTime.Day){
            unitAndAmount += unitToLabel(unit);
        } else if(unit == FAP_UnitOfTime.Week || unit == FAP_UnitOfTime.Month){
          throw new FAP_IllegalArgumentException('N_WEEKS and N_MONTHS are not supported');
        } else {
            unitAndAmount += 'N_' + unitToLabel(unit) + 'S:' + n;
        }
        return unitAndAmount;
    }
    
    private static String unitToLabel(FAP_UnitOfTime unit){
      String label = '';
        if(     unit == FAP_UnitOfTime.Day){           label = 'DAY';            }
        else if(unit == FAP_UnitOfTime.Week){          label = 'WEEK';           }
        else if(unit == FAP_UnitOfTime.Month){         label = 'MONTH';         }
        else if(unit == FAP_UnitOfTime.Quarter){       label = 'QUARTER';        } 
        else if(unit == FAP_UnitOfTime.FiscalQuarter){ label = 'FISCAL_QUARTER'; }
        else if(unit == FAP_UnitOfTime.Year){          label = 'YEAR';           }
        else if(unit == FAP_UnitOfTime.FiscalYear){    label = 'FISCAL_YEAR';    }  
        return label;
    }
    

}