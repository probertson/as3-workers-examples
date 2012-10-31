package
{
	import com.adobe.test.view.ProgressBar;
	import com.adobe.test.vo.CountResult;
	
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.net.registerClassAlias;
	import flash.system.MessageChannel;
	import flash.system.Worker;
	import flash.system.WorkerDomain;
	import flash.system.WorkerState;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	import flash.utils.Timer;
	import flash.utils.getTimer;
	
	public class NonWorkerDemo extends Sprite
	{
		private var _statusText:TextField;
		private var _progressBar:ProgressBar;
		
		private var bgWorker:Worker;
		private var bgWorkerCommandChannel:MessageChannel;
		private var progressChannel:MessageChannel;
		private var resultChannel:MessageChannel;
		
		
		public function NonWorkerDemo()
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
			
			registerClassAlias("com.adobe.test.vo.CountResult", CountResult);
			
			var timer:Timer = new Timer(1000);
			timer.addEventListener(TimerEvent.TIMER, timer_timer);
			timer.start();
		}
		
		protected function timer_timer(event:TimerEvent):void
		{
			var timer:Timer = event.target as Timer;
			timer.stop();
			timer.removeEventListener(TimerEvent.TIMER, timer_timer);
			
			countTo(100000000);
		}		

		
		private function countTo(targetValue:uint):void
		{
			var startTime:int = getTimer();
			var onePercent:uint = uint(Math.ceil(targetValue / 100));
			var oneHalfPercent:Number = onePercent / 2;
			
			var i:uint = 0;
			while (i < targetValue)
			{
				i++;
				// only send progress messages every so often
				// to avoid flooding the message channel
				if (i % oneHalfPercent == 0)
				{
					handleProgressMessage(i / onePercent);
				}
			}
			
			var elapsedTime:int = getTimer() - startTime;
			var result:CountResult = new CountResult(targetValue, elapsedTime / 1000);
			handleResultMessage(result);
			
			trace("counted to", targetValue.toString(), "in", elapsedTime, "milliseconds");
		}
		
		
		private function handleProgressMessage(percentComplete:Number):void
		{
			_progressBar.setPercentComplete(percentComplete);
			_statusText.text = Math.round(percentComplete).toString() + "% complete";
		}
		
		
		private function handleResultMessage(result:CountResult):void
		{
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