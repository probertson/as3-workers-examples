package com.adobe.test.view
{
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.Event;
	
	public class ProgressBar extends Sprite
	{
		private var _currentPercentComplete:int = 0;
		private var _needsValidation:Boolean = false;
		private var _progressBar:Shape;
		
		public function ProgressBar()
		{
			_initialize();
		}
		
		
		private function _initialize():void
		{
			_drawBorder();
			_drawProgressBar();
		}
		
		private function _drawBorder():void
		{
			graphics.beginFill(0x000000, 0);
			graphics.lineStyle(2, 0x000000);
			graphics.drawRect(0, 0, 400, 30);
			graphics.endFill();
		}
		
		private function _drawProgressBar():void
		{
			_progressBar = new Shape();
			_progressBar.graphics.beginFill(0x0000ee);
			_progressBar.graphics.drawRect(0, 0, width - 10, height - 10);
			_progressBar.x = 4;
			_progressBar.y = 4;
			addChild(_progressBar);
			_progressBar.scaleX = 0;
		}
		
		
		public function setPercentComplete(percentComplete:int):void
		{
			if (_currentPercentComplete == percentComplete)
				return;
			
			_currentPercentComplete = percentComplete;
			_invalidateValue();
		}
		
		
		private function _invalidateValue():void
		{
			if (_needsValidation)
				return;
			
			_needsValidation = true;
			addEventListener(Event.EXIT_FRAME, _validate);
		}
		
		private function _validate(event:Event):void
		{
			removeEventListener(Event.EXIT_FRAME, _validate);
			_needsValidation = false;
			
			_redrawProgressBar();
		}
		
		private function _redrawProgressBar():void
		{
			_progressBar.scaleX = _currentPercentComplete / 100;
		}
	}
}