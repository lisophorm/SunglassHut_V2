/**
 * Created by gino on 11/09/2014.
 */
package com.alfo.utils {
import flash.events.Event;



public class UploaderEvent extends Event {

    public static const UPDATE:String="update";
    public static const SQLERROR:String="sqlerror";

    public function UploaderEvent(type:String, bubbles:Boolean = false, cancelable:Boolean = false) {
        super(type, bubbles, cancelable);
    }
}
}
