package model {
import flash.filesystem.File;
import flash.filesystem.FileMode;
import flash.filesystem.FileStream;

public class Config {

    private static const PI_OVER_180:Number = Math.PI / 180.0;
    private static const _instance:Config = new Config(SingletonLock); // The preferences prefsFile
    public static var access_token:String; // The XML data
    public static var logout:String; // The FileStream object used to read and write prefsFile data.

    /**
     * Use this to return an instance of the singleton
     * @return
     *
     */
    public static function get instance():Config {
        return _instance;
    }

    /**
     * This will initialize the Singleton. It's never publicly called. Use Config.instance instead
     * @param lock
     *
     */
    public function Config(lock:Class) {
        if (lock != SingletonLock) {
            throw new Error("Invalid Config access. Use Config.instance");
        }

        initialize();
    }

    //this is the only instance of the class
    public var prefsFile:File;


    //this will control wither the Singleton is really to be accessed
    [Bindable]
    public var prefsXML:XML;
    public var stream:FileStream;

    private var _initialized:Boolean = false;

    /**
     * Return the current flag
     * @return String
     *
     */

    /**
     * Query the Singleton to see if it's ready to be accessed
     * @return
     *
     */
    public function get initialized():Boolean {
        return _initialized;
    }

    public function  get serverIP():String {
        return prefsXML.serverIP;
    }

    public function set serverIP(val:String):void {
        prefsXML.serverIP = val;
    }

    public function  get localIP():String {
        return prefsXML.localIP;
    }

    public function set localIP(val:String):void {
        prefsXML.localIP = val;
    }

    [Bindable]
    public function  get debugMode():Boolean {
        return (prefsXML.debugMode == "1") ? true : false;
    }

    public function set debugMode(val:Boolean):void {
        prefsXML.debugMode = (val == true ? "1" : "0");
    }

    public function  get facebookAppID():String {
        return prefsXML.facebookAppID;
    }

    public function set facebookAppID(val:String):void {
        prefsXML.facebookAppID = val;
    }

    public function  get urnLength():String {
        return prefsXML.urnLength;
    }

    public function set urnLength(val:String):void {
        prefsXML.urnLength = val;
    }

    public function  get scoreFormat():String {
        return prefsXML.scoreFormat;
    }

    public function set scoreFormat(val:String):void {
        prefsXML.scoreFormat = val;
    }

    public function  get applicationType():String {
        return prefsXML.applicationtype;
    }

    public function set applicationType(val:String):void {
        prefsXML.applicationtype = val;
    }

    public function writeXMLData():void {
        trace("saving xml:");
        var outputString:String = '<?xml version="1.0" encoding="utf-8"?>\n';
        outputString += prefsXML.toXMLString();
        outputString = outputString.replace(/\n/g, File.lineEnding);
        trace("*********" + outputString + "***********");
        try {
            var f:File = new File(prefsFile.nativePath);
            stream = new FileStream();
            stream.open(f, FileMode.WRITE);
            stream.writeUTFBytes(outputString);
            stream.close();
        } catch (error:Error) {
            trace("error saving xml:" + error.message);
        }

    }

    /**
     * This is where you would set up anything the Singleton needed before it should be accessible to the public
     *
     */
    private function initialize():void {
        //we only need to initialize once.
        if (_initialized) {
            trace("CONFIG SINGLETON IS ALREADY INITIALIZED");
            return;
        }
        prefsFile = File.applicationStorageDirectory;
        prefsFile = prefsFile.resolvePath("assets/xml/preferences.xml");
        if (!prefsFile.exists) {
            trace("preferences file does not exists");
        }
        trace("preferences: " + prefsFile.nativePath);
        readXML();

        _initialized = true;
    }

    private function readXML():void {
        stream = new FileStream();
        // If it exists read it
        if (prefsFile.exists) {
            trace("preference file exists");
            stream.open(prefsFile, FileMode.READ);
            processXMLData();
        }
        else //Otherwise make a file and save it
        {
            var tempFile:File = File.applicationDirectory;
            tempFile = tempFile.resolvePath("assets/xml/preferences.xml");
            try {
                tempFile.copyTo(prefsFile, true);
            } catch (error:Error) {
                trace("error saving xml for the first time:" + error.message);
            }
            stream.open(prefsFile, FileMode.READ);
            processXMLData();
        }

    }

    private function createXMLData():void {
        prefsXML = <preferences/>;
        prefsXML.serverIP = "0.0.0.0";
        prefsXML.urnLength = "10";

    }

    private function saveData():void {
        createXMLData();
        writeXMLData();
    }

    private function processXMLData():void {
        trace("file size:" + stream.bytesAvailable);
        prefsXML = XML(stream.readUTFBytes(stream.bytesAvailable));
        stream.close();

        trace("Preferences: (serverIP: '" + serverIP + "' , urnLength: '" + urnLength + "' , applicationType: '" + applicationType + "')");
    }
}
}


//this is used to lock the Singleton
class SingletonLock {
}