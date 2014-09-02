package com.alfo.utils
{
import flash.events.DataEvent;
import flash.events.EventDispatcher;
import flash.events.HTTPStatusEvent;
import flash.events.IOErrorEvent;
import flash.events.ProgressEvent;
import flash.events.SecurityErrorEvent;
import flash.filesystem.File;
import flash.events.Event;
import flash.net.URLRequest;
import flash.net.URLRequestMethod;

public class Uploader extends EventDispatcher
    {

        private static var files:Array;
        private var totalSize:uint;
        private var uploadedSoFar:uint;
        private var currentFile:File;
        public var url:String;

        private static const SINGLETON_INSTANCE:Uploader = new Uploader(SingletonLock);

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

            totalSize = 0;
            files = new Array();
        }
        /*
         * This function starts the uploading process of all files that were not uploaded yet
         */
        public function addFile(file:File):void
        {
            files.push(file);
        }

        /*
         * Starts uploading the files.
         */
        public function start(url:String):void
        {
            this.url = url;
            uploadedSoFar = 0;
            for (var i:uint; i < files.length; i++)
            {
                var file:File = files[i] as File;
                totalSize += file.size;
            }
            uploadNext();
        }
        /*
         * Upload the next file in the list. Only one file is uploaded at a time.
         */
        private function uploadNext():void
        {
            if (files.length > 0)
            {
                currentFile = files.pop() as File;
                uploadFile(currentFile);
            }
            else
            {
                dispatchEvent(new Event(Event.COMPLETE));
            }
        }
        /*
         * Calls the upload() method for one File object
         */
        private function uploadFile(file:File):void
        {
            trace("sending uploadfile");
            var urlRequest:URLRequest = new URLRequest(url);
            urlRequest.method = URLRequestMethod.POST;
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
            uploadedSoFar += currentFile.size;
            var newLocation:File = currentFile.parent.resolvePath("uploaded/" + currentFile.name);
            uploadNext();
        }
        /*
         * Upload error callback.
         */
        private function uploadError(event:Event):void
        {
            var errorStr:String = event.toString();
            trace("Error uploading: " + currentFile.nativePath + "\n  Message: " + errorStr);
            dispatchEvent(event);
        }

    }
}

class SingletonLock{}