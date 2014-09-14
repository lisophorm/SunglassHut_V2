package com.alfo {
import flash.display.Sprite;
import flash.filesystem.File;

public class UserObject extends Sprite {

    private static const SINGLETON_INSTANCE:UserObject = new UserObject(SingletonLock);
    public static var userDataObj:Object;

    public static function get instance():UserObject {
        return SINGLETON_INSTANCE;
    }

    public function UserObject(lock:Class) {
        if (lock != SingletonLock) {
            throw new Error("Invalid Config access. Use Config.instance");
        }
        trace("inside instance of userObject");

    }

    public var batchPath:String = "specsavers_jpg_xml/";
    public var spoolerPath:String = "specsavers_print/"
    public var tempPath:String = "specsavers_temp_jpg/";

    private var _photo1:String;

    public function get photo1():String {
        return userDataObj.photo1;
    }

    public function set photo1(value:String):void {
        userDataObj.photo1 = value;
    }

    private var _photo2:String;

    public function get photo2():String {
        return userDataObj.photo2;
    }

    public function set photo2(value:String):void {
        userDataObj.photo2 = value;
    }

    private var _photo3:String;

    public function get photo3():String {
        return userDataObj.photo3;
    }

    public function set photo3(value:String):void {
        userDataObj.photo3 = value;
    }

    public function get hometown():String {
        return userDataObj.hometown;
    }

    public function set hometown(town:String):void {
        userDataObj.hometown = town;
    }

    public function get extraterms():Boolean {
        if (userDataObj.extraterms == "1") {
            return true;
        } else {
            return false;
        }
    }

    public function set extraterms(value:Boolean):void {
        if (value) {
            userDataObj.extraterms = "1";
        } else {
            userDataObj.extraterms = "0";
        }

    }

    public function get current_location():String {
        return userDataObj.current_location;
    }

    public function set current_location(value:String):void {
        userDataObj.current_location = value;
    }

    public function get location():String {
        return userDataObj.location;
    }

    public function set location(value:String):void {
        userDataObj.location = value;
    }

    public function get urn():String {
        return userDataObj.uuid;
    }

    public function set urn(theURN:String):void {
        userDataObj.uuid = theURN;
    }


    public function get token():String {
        return userDataObj.token;
    }

    public function set token(thetoken:String):void {
        userDataObj.token = thetoken;
    }

    public function get firstname():String {
        return userDataObj.firstName;
    }

    public function set firstname(thefirstname:String):void {
        userDataObj.firstName = thefirstname;
    }

    public function set lastname(thelastname:String):void {
        userDataObj.lastName = thelastname;
    }

    public function get lastname():String {
        return userDataObj.lastName;
    }

    public function set mobile(themobile:String):void {
        userDataObj.postcode = themobile;
    }

    public function set email(theemail:String):void {
        userDataObj.emailAddress = theemail;
    }

    public function get email():String {
        return userDataObj.emailAddress;
    }


    public function set fb_id(thefb_id:String):void {
        userDataObj.fb_id = thefb_id;
    }

    public function set data_saved(thedata_saved:Boolean):void {
        userDataObj.data_saved = thedata_saved ? "1" : "0";
    }

    public function set facebook(thefacebook:Boolean):void {
        userDataObj.facebook = thefacebook ? "1" : "0";
    }

    public function get facebook():Boolean {
        return userDataObj.facebook == "1" ? true : false;
    }

    public function set hasphoto(thehasphoto:Boolean):void {
        userDataObj.hasphoto = thehasphoto ? "1" : "0";
    }

    public function get isConnected():Boolean {
        if (userDataObj.isConnected == "1") {
            return true;
        } else {
            return false;
        }
        return false;
    }

    public function set isConnected(theconnection:Boolean):void {
        userDataObj.isConnected = theconnection ? "1" : "0";
    }

    public function get destFileName():String {
        return userDataObj.destFileName;
    }

    public function set destFileName(thedestFileName:String):void {
        userDataObj.destFileName = thedestFileName;
    }

    public function get JSONobject():String {
        trace("current jsonobject:" + JSON.stringify(userDataObj));
        return JSON.stringify(userDataObj);
    }

    public function init():void {
        trace("***** init userobject");
        userDataObj = new Object();
        var now:Date = new Date();
        userDataObj.creationdate = convertASDateToMySQLTimestamp(now);
        userDataObj.extraterms = "1";
        trace("new userobject");
        var workDirectory:File = File.documentsDirectory.resolvePath(batchPath);
        trace("directory url:" + workDirectory.url);
        if (!workDirectory.exists) {
            trace("directory does not exists");
            //try {
            workDirectory.createDirectory();
            //} catch (e:Error) {
            trace("Failed creating working directory!");
            //}
        } else {
            trace("work dir exists");
        }
        trace("end of init userobject")
    }

    public function eject():void {
        trace("XML:");
        trace(userDataObj.toXMLString());
    }

    private function convertASDateToMySQLTimestamp(d:Date):String {
        var s:String = d.fullYear + '-';
        s += prependZero(d.month + 1) + '-';
        s += prependZero(d.date) + ' ';

        s += prependZero(d.hours) + ':';
        s += prependZero(d.minutes) + ':';
        s += prependZero(d.seconds);

        return s;
    }

    private function prependZero(n:Number):String {
        var s:String = ( n < 10 ) ? '0' + n : n.toString();
        return s;
    }

}
}


//this is used to lock the Singleton
class SingletonLock {
}