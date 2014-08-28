package com.alfo.res
{
	public final class Resource
	{
		[Embed (source="/assets/images/splash_background_home.png" )]
		[Bindable]
		public static var BACKGROUND_HOME:Class;
		
		[Embed (source="/assets/images/splash_background.png" )]
		[Bindable]
		public static var BACKGROUND:Class;
		
		[Embed (source="/assets/images/splash_background_landscape.png" )]
		[Bindable]
		public static var BACKGROUND_PORTRAIT:Class;

        [Embed(source="/assets/images/nophoto.jpg")]
        [Bindable]
        public static var NO_PHOTO : Class;

        [Embed(source="/assets/images/logo.png")]
    [Bindable]
    public static var LOGO : Class;

        [Embed(source="/assets/images/button/button_normal.png")]
        [Bindable]
        public static var BUTTON_NORMAL : Class;

        [Embed(source="/assets/images/button/button_pressed.png")]
        [Bindable]
        public static var BUTTON_PRESSED : Class;
	}
}