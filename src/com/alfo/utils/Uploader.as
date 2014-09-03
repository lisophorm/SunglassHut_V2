package com.alfo.utils
{
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

public class Uploader extends EventDispatcher
    {

        private static var _totalFiles:Number;
        private static var isRunning:Boolean;
        private static var _currentID:Number;
        private static var _status:String;
        private var files:Array;
        private var totalSize:uint;
        private var uploadedSoFar:uint;
        private var currentFile:File;


        private static const SINGLETON_INSTANCE:Uploader = new Uploader(SingletonLock);

        public static function get instance():Uploader
        {
            return SINGLETON_INSTANCE;
        }


        public function Uploader(lock:Class):void
        {
            trace("initialization of uploader");
            var dir:File=File.documentsDirectory.resolvePath("specsavers_print");
            if(dir.exists) {var files:Array=dir.getDirectoryListing();}

            trace("files content:");
            if(lock != SingletonLock){
                throw new Error("Class Cannot Be Instantiated: Use SQLConnectionWrapper.instance");
            }
            SQLConnectionWrapper.instance.connection.addEventListener(SQLEvent.OPEN,countRecords);
            SQLConnectionWrapper.instance.connection.open();
            _totalFiles=0;
            totalSize = 0;


        }
        public function init():void {
            trace("uploader initialized");
        }
        private function countRecords(e:SQLEvent=null):void {
            trace("sending count records");
            var statement:SQLStatement = SQLConnectionWrapper.instance.totalRecords("userdata");
            statement.execute(-1,new Responder(handleRecordCount,handleFailure));
        }
        /*
         * This function starts the uploading process of all files that were not uploaded yet
         */
        public function addFile(file:String,vars:String,url:String):void
        {
            trace("adding file into uploader");
            var statement:SQLStatement = SQLConnectionWrapper.instance.insertRecord(vars,url,file);
            statement.execute(-1,new Responder(handleInsert,handleFailure));
        }
       private function handleInsert(result:SQLResult):void {

        trace("insert ok!"+result);
           _totalFiles+=result.rowsAffected;
         }
        private function handleRecordCount(result:SQLResult):void {
            _totalFiles=result.data[0].totalrows;
            trace("result count!"+_totalFiles);
            if(_totalFiles>0) {
                start();
            }
        }
        private function handleFailure(error:SQLError):void
        {
            trace("Epic Fail: " + error.message);
        }
        /*
         * Starts uploading the files.
         */
        public function start():void
        {
            if(!isRunning) {
                isRunning=true;
                queryNextRecord();
            }

        }
        private function queryNextRecord() {
            var statement:SQLStatement = SQLConnectionWrapper.instance.getNextRecord();
            statement.execute(-1,new Responder(uploadNext,handleFailure));
        }
        /*
         * Upload the next file in the list. Only one file is uploaded at a time.
         */
        private function uploadNext(result:SQLResult):void
        {
            trace("uploadNext");
            _totalFiles=result.data.length;
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
        /*
         * Calls the upload() method for one File object
         */
        private function uploadFile(nativePath:String,jsonData:String,url:String):void
        {
            var file:File=File.documentsDirectory.resolvePath("specsavers_print"+File.separator+nativePath);

            if(file.exists) {
                trace("the file is here!");
            } else {
                trace("no file found!!!"+file.nativePath);
            }

            var vars:URLVariables=new URLVariables();
            vars.jsonData=jsonData;
            trace("sending uploadfile");
            var urlRequest:URLRequest = new URLRequest(url);
            urlRequest.method = URLRequestMethod.POST;
            urlRequest.data=vars;
            file.addEventListener(ProgressEvent.PROGRESS, uploadProgress);
            file.addEventListener(Event.COMPLETE, uploadComplete);
            file.addEventListener(DataEvent.UPLOAD_COMPLETE_DATA , uploadServerData);
            file.addEventListener(SecurityErrorEvent.SECURITY_ERROR, uploadError);
            file.addEventListener(HTTPStatusEvent.HTTP_STATUS, uploadError);
            file.addEventListener(IOErrorEvent.IO_ERROR, uploadError);
            file.upload(urlRequest, "Filedata");
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
            trace("server data callback");
            trace(event.data);
        }
        /*
         * Complete callback.
         */
        private function uploadComplete(event:Event):void
        {
            trace("current file uploaded");


            // UPDATE THE CURRENT RECORD
        }
        /*
         * Upload error callback.
         */
        private function uploadError(event:SecurityErrorEvent):void
        {
            var errorStr:String = event.toString();
            trace("Error uploading: " + currentFile.nativePath + "\n  Message: " + errorStr);
            dispatchEvent(event);
        }

    }
}

class SingletonLock{}