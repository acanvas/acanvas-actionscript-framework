package com.rockdot.core {
	import org.as3commons.lang.ObjectUtils;

	/**
	 * @author nilsdoehring
	 */
	public class RockdotVO{
		  public  function  RockdotVO(obj:Object = null):void  {  
                for  (var  prop  : * in  obj)  {  
                        if(this.hasOwnProperty(prop) && ObjectUtils.isSimple(obj[prop])) this[prop]  =  obj[prop];   
                }    
            }  
	}
}
