'buildopt: html5
'buildopt: release
'buildopt: run

Strict

Import mojo
Import diddy
Import gamescreen
Import menuscreen

Global menuScreen:MenuScreen
Global gameScreen:GameScreen
Global currentLevel:String = ""
Global game:Schreckenstein


Function Main:Int()
        game = New Schreckenstein()
        Return 0
End


Class Schreckenstein Extends DiddyApp
	Method OnCreate:Int()
		SetUpdateRate(60)
		Super.OnCreate()
		
		gameScreen = New GameScreen
		
		menuScreen = New MenuScreen
		menuScreen.PreStart()

		SetScreenSize(1024, 768) 'diddys VirtualResolution, maybe a solution for retina issues
		Return 0
	End	
End

