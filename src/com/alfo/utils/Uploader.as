package com.alfo.utils
{
import events.UploadResultEvent;

import flash.data.SQLResult;
import flash.data.SQLStatement;
import flash.errors.SQLError;
import flash.events.DataEvent;
import flash.events.EventDispatcher;
import flash.events.HTTPStatusEvent;
import flash.events.IOErrorEvent;
import flash.events.ProgressEvent;
import flash.events.SQLEvent;
import flash.events.SecurityErrorEvent;
import flash.filesystem.File;
import flash.events.Event;
import flash.net.Responder;
import flash.net.URLRequest;
import flash.net.URLRequestMethod;
import com.alfo.utils.SQLConnectionWrapper;

import flash.net.URLVariables;
import flash.utils.setTimeout;

public class Uploader extends EventDispatcher
{

    private static const SINGLETON_INSTANCE:Uploader = new Uploader(SingletonLock);
    private static var _totalFiles:Number;
    private static var _queuedFiles:Number;
    private static var _completedFiles:Number;
    private static var _failedFiles:Number;
    private static var isRunning:Boolean;
    private static var _currentID:Number;
    private static var _status:String;

    public static function get instance():Uploader
    {
        return SINGLETON_INSTANCE;
    }

    public function Uploader(lock:Class):void
    {
        trace("initialization of uploader");



        if(lock != SingletonLock){
            throw new Error("Class Cannot Be Instantiated: Use SQLConnectionWrapper.instance");
        }

        initialize();

    }
    public var maxRetry:Number=5;
    private var retryCount:Number=0;
    private var files:Array;
    //this will control wither the Singleton is really to be accessed
    private var totalSize:uint;
    private var uploadedSoFar:uint;
    private var currentFile:File;

    private var _initialized:Boolean = false;

    public function get initialized() : Boolean {
        return _initialized;
    }

    public function addFile(file:String,vars:String,url:String):void
    {
        trace("adding file into uploader");
        var statement:SQLStatement = SQLConnectionWrapper.instance.insertRecord(vars,url,file);
        statement.execute(-1,new Responder(handleInsert,handleFailure));
    }

    public function start():void
    {
        if(!isRunning) {
            isRunning=true;
            queryNextRecord();
        }

    }


    public function close():void {
        SQLConnectionWrapper.instance.connection.close(new Responder(onCloseDB,handleFailure));
    }

    public function countRecords(e:Object=null):void {
        trace("sending count records");
        var statement:SQLStatement = SQLConnectionWrapper.instance.totalRecords("userdata");
        statement.execute(-1,new Responder(handleRecordCount,handleFailure));
    }

    private function initialize() : void {
        trace("initializa");
        //we only need to initialize once.
        if(_initialized) {
            return;
        }


        _initialized = true;

        SQLConnectionWrapper.instance.connection.addEventListener(SQLEvent.OPEN,countRecords);
        SQLConnectionWrapper.instance.connection.open();
        _totalFiles=0;
        totalSize = 0;
    }

    private function handleInsert(result:SQLResult):void {

        trace("insert ok!"+result);
        start();
    }
    /*
     * Starts uploading the files.
     */

    private function handleRecordCount(result:SQLResult):void {

        dispatchEvent(new UploaderEvent(UploaderEvent.UPDATE,result));

        trace("got new records");
        _totalFiles=0;
        _failedFiles=0; // failed count sums everything that is not QUEUED os Succsess
        _queuedFiles=0;
        if(result.data!=null) {
            for (var i:int=0;i<result.data.length;i++) {
                _totalFiles+=result.data[i].totalrows;
                switch (result.data[i].status) {
                    case "QUEUED":
                        _queuedFiles=result.data[i].totalrows;
                        break;
                    case "Succsess":
                        _completedFiles=result.data[i].totalrows;
                        break;
                    default:
                        _failedFiles+=result.data[i].totalrows;
                        break;

                }
            }
        }

        trace("result count!"+_totalFiles);
        if(_queuedFiles>0) {
            setTimeout(function() {
                start();
            },3000)

        }
    }

    private function handleFailure(error:SQLError):void
    {

        trace("Epic Fail: " + error.message);
    }
    /*
     * Upload the next file in the list. Only one file is uploaded at a time.
     */

    private function queryNextRecord(result:SQLResult=null) {
        trace("queryNextRecord Statement");
        var statement:SQLStatement = SQLConnectionWrapper.instance.getNextRecord();
        statement.execute(-1,new Responder(uploadNext,handleFailure));
    }

    private function uploadNext(result:SQLResult):void
    {
        trace("uploadNext");
        if(result.data) {
            _totalFiles=result.data.length;
        } else {
            _totalFiles=0;
            dispatchEvent(new Event(Event.COMPLETE));
            return;
        }

        if (result.data.length>0)
        {
            _currentID=result.data[0].id;
            uploadFile(result.data[0].filename,result.data[0].vars,result.data[0].url);
        }
        else
        {
            dispatchEvent(new Event(Event.COMPLETE));
        }
    }

    private function onCloseDB(e:Object=null):void {
        trace("database closed");
        dispatchEvent(new Event(Event.EXITING));
    }
    /*
     * Calls the upload() method for one File object
     */
    private function uploadFile(nativePath:String,jsonData:String,url:String):void
    {
        trace("start upload"+nativePath);
        var file:File=File.documentsDirectory.resolvePath("specsavers_print"+File.separator+nativePath);

        if(file.exists) {
            trace("the file is here!");
        } else {
            trace("no file found!!!"+file.nativePath);
            trace("no file found!!!"+file.nativePath);
        }

        var vars:URLVariables=new URLVariables();
        vars.jsonData=jsonData;
        trace("sending uploadfile");
        var urlRequest:URLRequest = new URLRequest(url);
        urlRequest.method = URLRequestMethod.POST;
        urlRequest.data=vars;
        urlRequest.idleTimeout=5000;
        file.addEventListener(ProgressEvent.PROGRESS, uploadProgress);
        file.addEventListener(Event.COMPLETE, uploadComplete);
        file.addEventListener(DataEvent.UPLOAD_COMPLETE_DATA , uploadServerData);
        file.addEventListener(SecurityErrorEvent.SECURITY_ERROR, uploadSecError);
        //file.addEventListener(HTTPStatusEvent.HTTP_STATUS, onStatus);
        file.addEventListener(HTTPStatusEvent.HTTP_RESPONSE_STATUS, onResponseStatus);
        file.addEventListener(IOErrorEvent.IO_ERROR, uploadError);
        file.addEventListener(IOErrorEvent.NETWORK_ERROR, uploadError);
        try { file.upload(urlRequest, "file");} catch (error:Error) {
            trace("TRYCACHMOFO"+error.message);
        }

    }
    private function onStatus(e:HTTPStatusEvent) {
        trace("MADONA PUTTANA onStatus");
    }

    private function onResponseStatus(e:HTTPStatusEvent) {
        trace("MADONA PUTTANA onResponseStatus");
    }
    /*
     * ProgressEvent callback.
     */
    private function uploadProgress(event:ProgressEvent):void
    {
        var uploadedAmt:uint = uploadedSoFar + event.bytesLoaded;
        var progressEvt:ProgressEvent = event;
        event.bytesLoaded = uploadedAmt;
        event.bytesTotal = totalSize;
        trace("uppload progress "+event.bytesLoaded);
        dispatchEvent(event);
    }

    /*
     * Server data callback.
     */
    private function uploadServerData(event:DataEvent):void
    {
        isRunning=false;
        trace("server data callback");
        trace(event.data);
        try {
            var returnData:Object=JSON.parse(event.data.toString());
        } catch (e:Error) {
            var returnData:Object=new Object();
            returnData.status="Json perse error";
            returnData.message=event.data.toString();
        }

        var statement:SQLStatement = SQLConnectionWrapper.instance.updateRecord(returnData.status,returnData.message,_currentID.toString());
        statement.execute(-1,new Responder(countRecords,handleFailure));

    }

    /*
     * Complete callback.
     */
    private function uploadComplete(event:Event):void
    {
        trace("current file uploaded");
        isRunning=false;

        // UPDATE THE CURRENT RECORD
    }
    private function uploadSecError(event:IOErrorEvent):void
    {
        isRunning=false;
        var statement:SQLStatement = SQLConnectionWrapper.instance.updateRecord("QUEUED",event.text,_currentID.toString());
        statement.execute(-1,new Responder(countRecords,handleFailure));
        trace("upload errro!");
        var errorStr:String = event.toString();
        trace("Error uploading   Message: " + errorStr);
        dispatchEvent(event);
    }
    /*
     * Upload error callback.
     */
    private function uploadError(event:IOErrorEvent):void
    {
        isRunning=false;
        var statement:SQLStatement = SQLConnectionWrapper.instance.updateRecord("QUEUED",event.text,_currentID.toString());
        statement.execute(-1,new Responder(countRecords,handleFailure));
        trace("upload errro!");
        var errorStr:String = event.toString();
        trace("Error uploading   Message: " + errorStr);
        //dispatchEvent(event);
    }

}
}

class SingletonLock{}