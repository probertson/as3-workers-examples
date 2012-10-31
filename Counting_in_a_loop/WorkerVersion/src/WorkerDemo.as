package
{
	import com.adobe.test.view.ProgressBar;
	import com.adobe.test.vo.CountResult;
	
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.net.registerClassAlias;
	import flash.system.MessageChannel;
	import flash.system.Worker;
	import flash.system.WorkerDomain;
	import flash.system.WorkerState;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	
	public class WorkerDemo extends Sprite
	{
		private var _statusText:TextField;
		private var _progressBar:ProgressBar;
		
		private var bgWorker:Worker;
		private var bgWorkerCommandChannel:MessageChannel;
		private var progressChannel:MessageChannel;
		private var resultChannel:MessageChannel;
		
		
		public function WorkerDemo()
		{
			initialize();
		}
		
		
		private function initialize():void
		{
			stage.align = StageAlign.TOP_LEFT;
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.stageWidth = 800;
			stage.stageHeight = 600;
			stage.color = 0xffffff;
			
			// create status text
			createStatusText();
			// create progress bar
			createProgressBar();
			
			// start worker
			registerClassAlias("com.adobe.test.vo.CountResult", CountResult);
			
			bgWorker = WorkerDomain.current.createWorker(Workers.BackgroundWorker);
			
			bgWorkerCommandChannel = Worker.current.createMessageChannel(bgWorker);
			bgWorker.setSharedProperty("incomingCommandChannel", bgWorkerCommandChannel);
			
			progressChannel = bgWorker.createMessageChannel(Worker.current);
			progressChannel.addEventListener(Event.CHANNEL_MESSAGE, handleProgressMessage)
			bgWorker.setSharedProperty("progressChannel", progressChannel);
			
			resultChannel = bgWorker.createMessageChannel(Worker.current);
			resultChannel.addEventListener(Event.CHANNEL_MESSAGE, handleResultMessage);
			bgWorker.setSharedProperty("resultChannel", resultChannel);
			
			bgWorker.addEventListener(Event.WORKER_STATE, handleBGWorkerStateChange);
			bgWorker.start();
		}
		
		
		private function handleBGWorkerStateChange(event:Event):void
		{
			if (bgWorker.state == WorkerState.RUNNING) 
			{
				_statusText.text = "Background worker started";
				bgWorkerCommandChannel.send(["startCount", 100000000]);
			}
		}
		
		
		private function handleProgressMessage(event:Event):void
		{
			var percentComplete:Number = progressChannel.receive();
			_progressBar.setPercentComplete(percentComplete);
			_statusText.text = Math.round(percentComplete).toString() + "% complete";
		}
		
		
		private function handleResultMessage(event:Event):void
		{
			var result:CountResult = resultChannel.receive() as CountResult;
			_statusText.text = "Counted to " + result.countTarget + " in " + (Math.round(result.countDurationSeconds * 10) / 10) + " seconds";
			_progressBar.setPercentComplete(100);
		}		
		
		
		// ------- Create UI -------
		
		private function createStatusText():void
		{
			_statusText = new TextField();
			_statusText.width = 400;
			_statusText.height = 25;
			_statusText.x = (stage.stageWidth - _statusText.width) / 2;
			_statusText.y = 250;
			
			var statusTextFormat:TextFormat = new TextFormat();
			statusTextFormat.color = 0xeeeeee;
			statusTextFormat.font = "Verdana";
			statusTextFormat.align = TextFormatAlign.CENTER;
			statusTextFormat.size = 16;
			_statusText.defaultTextFormat = statusTextFormat;
			_statusText.wordWrap = false;
			_statusText.opaqueBackground = 0x999999;
			_statusText.selectable = false;
			
			_statusText.text = "Initializing...";
			
			addChild(_statusText);
		}
		
		
		private function createProgressBar():void
		{
			_progressBar = new ProgressBar();
			
			_progressBar.x = (stage.stageWidth - _progressBar.width) / 2;
			_progressBar.y = 200;
			
			addChild(_progressBar);
		}
	}
}