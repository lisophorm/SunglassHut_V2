/**
 * Created by gino on 11/09/2014.
 */
package com.alfo.utils {
import flash.events.Event;

public class UploaderErrorEvent extends Event {

    public static const ERROR:String = "error";

    public var message:String;
    public var details:String;


    public function UploaderErrorEvent(type:String, message:String, details:String = null, bubbles:Boolean = false, cancelable:Boolean = false) {
        super(type, bubbles, cancelable);
        this.message = message;
        this.details = details;
    }
}
}