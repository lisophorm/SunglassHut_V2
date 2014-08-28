package com.alfo.utils
{
import events.UploadResultEvent;

import flash.events.DataEvent;
import flash.events.Event;
import flash.events.IOErrorEvent;
import flash.events.ProgressEvent;
import flash.filesystem.File;
import flash.net.URLRequest;

import mx.core.UIComponent;

public class FTPCopy extends UIComponent
	{
		
		private var _username:String;
		private var _pass:String;
		private var _file:File;
		
		public var complete:Boolean=false;
		
		private var urlRequest:URLRequest;
		
		public function FTPCopy(file:File,url:String)
		{
			complete=false;
			_file=new File(file.nativePath);
			urlRequest=new URLRequest(url);
			_file.addEventListener(DataEvent.UPLOAD_COMPLETE_DATA,uploadDataCompleteHandler);
			_file.addEventListener(Event.COMPLETE,uploadCompleteHandler);
			_file.addEventListener(ProgressEvent.PROGRESS,updateProgress);
			_file.addEventListener(IOErrorEvent.IO_ERROR,onFileError);
			_file.addEventListener(IOErrorEvent.NETWORK_ERROR,onFileError);
			
		}
		
		public function start():void {
			_file.upload(urlRequest);
		}
		
		private function uploadDataCompleteHandler(event:DataEvent):Boolean {
			trace("data event upload");
			
			try {
				var result:XML = new XML(event.data);
			} catch (e:Error) {
				dispatchEvent(new UploadResultEvent(UploadResultEvent.ERROR,"ERROR","Malformed XML result:"+e.message+"\r\n"+event.data.toString()));
				return false;
			}
			trace("result from upload:"+result.toString());
			trace("message:"+result.message);
			trace("status:"+result.status);
			if(result.status!="OK") {
				dispatchEvent(new UploadResultEvent(UploadResultEvent.ERROR,"ERROR","Problem after file upload: "+result.message+"\r\n"+event.data.toString()));

				return true;
			} else {
				dispatchEvent(new UploadResultEvent(UploadResultEvent.SUCCESS));
				return true;
				}
			return true;
		}
		
		private function uploadCompleteHandler(e:Event):void {
			trace("local upload complete");
			complete=true;
			var e:Event=new Event(Event.COMPLETE);
			dispatchEvent(e);
		}

		private function updateProgress(e:ProgressEvent):void {
			complete=false;
		}
		
		private function onFileError(e:IOErrorEvent):void {
			complete=true;
			trace("local error uploading"+e.text);
			var e:IOErrorEvent = new IOErrorEvent(IOErrorEvent.IO_ERROR);
			dispatchEvent(e);
		}
		
	}
}