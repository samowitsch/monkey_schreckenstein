Import mojo
Import diddy
Import schreckenstein
Import schreckenstein.screen.gamescreen


Global startMenu:SimpleMenu			'start menu


Class MenuScreen Extends Screen
	Field lastTime:Int = -1
	Field thisTime:Int = -1
	Field deltaTime:Int = -1

	Field tween:Tween
      Method New()
      	name = "MenuScreen"
      End
        
      Method Start:Void()

       	game.screenFade.Start(50, False)
		gameScreen = New GameScreen
		
		startMenu = New SimpleMenu("","",SCREEN_WIDTH2/2,100,50,True)
		startMenu.AddButton("btn-level1.png","btn-level1.png","level1")
		startMenu.AddButton("btn-level2.png","btn-level2.png","level2")
		startMenu.AddButton("btn-level3.png","btn-level3.png","level3")
		startMenu.AddButton("btn-level4.png","btn-level4.png","level4")
		startMenu.AddButton("btn-level5.png","btn-level5.png","level5")

	End
        
	Method Render:Void()
		Cls
		startMenu.Draw()
		
	End
        
	Method Update:Void()
		startMenu.Update()
		If startMenu.Clicked("level1")
			currentLevel = "maps/schreck-lvl1.xml"
			game.screenFade.Start(50, True)
			game.nextScreen = gameScreen
		End
		If startMenu.Clicked("level2")
			currentLevel = "maps/schreck-lvl2.xml"
			game.screenFade.Start(50, True)
			game.nextScreen = gameScreen
		End
		If startMenu.Clicked("level3")
			currentLevel = "maps/schreck-lvl3.xml"
			game.screenFade.Start(50, True)
 			game.nextScreen = gameScreen
		End
		#rem
		If startMenu.Clicked("level4")
			currentLevel = "maps/schreck-lvl1.xml"
			game.screenFade.Start(50, True)
			game.nextScreen = gameScreen
		End
		If startMenu.Clicked("level5")
			currentLevel = "maps/schreck-lvl1.xml"
			game.screenFade.Start(50, True)
			game.nextScreen = gameScreen
		End
		#end
		
		
		If KeyHit(KEY_ESCAPE)
			game.screenFade.Start(50, True)
			game.nextScreen = gameScreen
		End
	End
End
