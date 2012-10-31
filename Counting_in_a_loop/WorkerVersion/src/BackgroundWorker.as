package
{
	import com.adobe.test.vo.CountResult;
	
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.net.registerClassAlias;
	import flash.system.MessageChannel;
	import flash.system.Worker;
	import flash.utils.getTimer;
	
	public class BackgroundWorker extends Sprite
	{
		private var commandChannel:MessageChannel;
		private var progressChannel:MessageChannel;
		private var resultChannel:MessageChannel;
		
		
		public function BackgroundWorker()
		{
			initialize();
		}
		
		
		private function initialize():void
		{
			registerClassAlias("com.adobe.test.vo.CountResult", CountResult);
			
			commandChannel = Worker.current.getSharedProperty("incomingCommandChannel") as MessageChannel;
			commandChannel.addEventListener(Event.CHANNEL_MESSAGE, handleCommandMessage);
			progressChannel = Worker.current.getSharedProperty("progressChannel") as MessageChannel;
			resultChannel = Worker.current.getSharedProperty("resultChannel") as MessageChannel;
		}		
		
		
		private function handleCommandMessage(event:Event):void
		{
			if (!commandChannel.messageAvailable)
				return;
			
			var message:Array = commandChannel.receive() as Array;
			
			if (message != null && message[0] == "startCount")
			{
				countTo(uint(message[1]));
			}
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
					progressChannel.send(i / onePercent);
				}
			}
			
			var elapsedTime:int = getTimer() - startTime;
			var result:CountResult = new CountResult(targetValue, elapsedTime / 1000);
			resultChannel.send(result);
			
			trace("counted to", targetValue.toString(), "in", elapsedTime, "milliseconds");
		}
	}
}