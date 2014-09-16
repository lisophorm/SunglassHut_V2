/**
 * Created by gino on 11/09/2014.
 */
package com.alfo.utils {
import flash.data.SQLResult;
import flash.events.Event;

public class UploaderEvent extends Event {

    public static const UPDATE:String = "update";
    public static const ALL_RECORDS:String = "allrecords";
    public static const SQLERROR:String = "sqlerror";

    public var result:SQLResult;

    public function UploaderEvent(type:String, result:SQLResult, bubbles:Boolean = false, cancelable:Boolean = false) {
        super(type, bubbles, cancelable);
        this.result = result;
    }
}
}
