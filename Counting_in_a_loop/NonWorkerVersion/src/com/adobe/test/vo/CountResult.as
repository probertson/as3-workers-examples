package com.adobe.test.vo
{
	import flash.net.registerClassAlias;

	public class CountResult
	{
//		private static var initialized:Boolean = initClass();
//		private static function initClass():Boolean
//		{
//			if (initialized)
//				return true;
//			registerClassAlias("com.adobe.test.vo.CountResult", CountResult);
//			return true;
//		}
		
		public function CountResult(countTarget:uint=0, countTime:Number=0)
		{
			this.countTarget = countTarget;
			this.countDurationSeconds = countTime;
		}
		
		public var countTarget:uint;
		public var countDurationSeconds:Number;
	}
}