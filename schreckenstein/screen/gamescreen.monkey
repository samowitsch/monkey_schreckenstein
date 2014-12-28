Strict

Import monkey.map

Import diddy.base64
Import diddy.collections
Import diddy.framework
Import diddy.xml
Import diddy.tile

Import fantomEngine.cftFont		'needed for font drawing

Import schreckenstein.tilemap.customtilemap
Import schreckenstein.screen.menuscreen
Import schreckenstein.ui.virtualstick
Import schreckenstein.ui.buttons
Import schreckenstein.sprite.animation
Import schreckenstein.sprite.jump
Import schreckenstein.sprite.playersprite
Import schreckenstein.tools.controlpixel

Class GameScreen Extends Screen

	Field backButton:SimpleButton = New SimpleButton()

	Field font:ftFont = New ftFont()				' fantomEngine font class ftFont
	Field tilemap:CustomTileMap		' extended Diddy TileMap class, no local modified Diddy FW anymore ;o)
	
	Field toolbarlayer:Image
	
	Field tilemapOffset:Int = 128
	Field tbounds:TileMapRect

	Field startOffsetTilemapX:Int = -416, startOffsetTilemapY:Int = -160	'offset for tilemap
	Field startOffsetPlayer1X:Int = 96, startOffsetPlayer1Y:Int = 128		'offset player1
	Field diffX:Int = 480, diffY:Int = 287

	Field offsetTilemapX:Int, offsetTilemapY:Int	'offset for tilemap
	Field offsetPlayer1X:Int, offsetPlayer1Y:Int	'offset player1

	Field scrollSpeedX:Int = 7
	Field scrollSpeedY:Int = 4
	
	Field player:PlayerSprite = New PlayerSprite()
  Field controlPixel:ControlPixel = New ControlPixel()
	
	Field joyLeft:Bool = False
	Field joyRight:Bool = False
	Field joyUp:Bool = False
	Field joyDown:Bool = False
	Field joyFire:Bool = False
	Field joyJump:Bool = False
	Field analogLeft:Bool = False
	Field analogRight:Bool = False
	Field analogUp:Bool = False
	Field analogDown:Bool = False
	
	' our virtual stick and buttons
	Field mystick:MyStick = New MyStick
	Field buttons:Buttons = New Buttons

  Method New()
    name = "GameScreen"
	End

  Method Start:Void()
    Self.LoadMap()
    'Self.LoadHunter()		

    'startpoint tilemap
    offsetTilemapX = startOffsetTilemapX
    offsetTilemapY = startOffsetTilemapY
    
    'startpoint player1
    offsetPlayer1X = startOffsetPlayer1X
    offsetPlayer1Y = startOffsetPlayer1Y
    
    toolbarlayer = LoadImage("toolbar.png")
    SetMusicVolume(0.75)
    PlayMusic("beat.mp3", 1)
    
    font.Load("atd_font")
    
    backButton.Load("btn-home.png","btn-home.png","","")
    backButton.MoveTo(10,50)
    backButton.Update()
    
    game.screenFade.Start(50, False)
  End
       
  Method Render:Void()
    Cls
    ' !!!!  render subpart of tilemap for Controlpixel only if a ramp tile is located !!!!
    If 	(Self.tilemap.tilenamebehind = "ramp" Or Self.tilemap.tilenamebottom = "ramp") Then
      tilemap.CustomRenderMap(offsetTilemapX+512, offsetTilemapY + 286, 10, 40, 414, 512, True)
      
      Local rampOffset:Int = controlPixel.CheckControlPixel()	'get pixel offset to ramp ground if needed
      If rampOffset <> 0 Then
        Self.offsetPlayer1Y += rampOffset; Self.offsetTilemapY = Self.offsetPlayer1Y - Self.diffY
      End If
    End If

    
    ' !!!! render real tilemap
    #If CONFIG="release"
      Cls
      tilemap.CustomRenderMap(offsetTilemapX, offsetTilemapY, SCREEN_WIDTH, SCREEN_HEIGHT - 256, tilemapOffset)
    #End

    player.Draw()
    
    DrawImage(toolbarlayer, 0, 0)				
    
    Self.ShowDebugInfo()
    
    mystick.Render()
    buttons.RenderButtons()
    FPSCounter.Draw(10,0)
    backButton.Draw()
  End

	Method ExtraRender:Void()
	End Method


	Method Update:Void()
		Self.Controls()
		player.Update()
		tilemap.UpdateAnimation(dt.frametime)
		backButton.Update()

		If KeyHit(KEY_ESCAPE) Or backButton.clicked = 1 Then
			StopMusic()
			game.screenFade.Start(50, True)
			game.nextScreen = menuScreen
		End If
	End	

	
	Method Controls:Void()
		
		Self.ResetControls()
		Self.UpdateControls()
		
		player.hunterClimbing.stopped = True
		If Self.joyLeft Or Self.joyRight Or Self.joyUp Or Self.joyDown Then
			player.hunterClimbing.stopped = False
		Endif

		tilemap.CheckCurrentTiles(offsetPlayer1X,offsetPlayer1Y)
		
		player.currentAnimation = player.hunterStandingRight
		If tilemap.tilenamebehind = "ladder" Or tilemap.tilenamebottom = "ladder" Then
			Self.joyJump = False
			player.currentAnimation = player.hunterClimbing
		Endif
		
		If player.hunterIsFalling = True Then Self.joyJump = False
		
		'jumping
		If Self.joyJump Then
			
			'jump left
			If Self.joyLeft Then

				player.currentAnimation = player.hunterJumpLeft
				'jump routine left
				offsetPlayer1X -= player.hunterJumpControl.GetJumpX(); offsetTilemapX = offsetPlayer1X - diffX
				offsetPlayer1Y -= player.hunterJumpControl.GetJumpY(); offsetTilemapY = offsetPlayer1Y - diffY
				
				If  tilemap.CheckCollisionTop(offsetPlayer1X,offsetPlayer1Y) = True Then
					Repeat
						offsetPlayer1Y += 1; offsetTilemapY = offsetPlayer1Y - diffY
					Until tilemap.CheckCollisionTop(offsetPlayer1X,offsetPlayer1Y) = False
				End If
				If tilemap.CheckCollisionBottom(offsetPlayer1X,offsetPlayer1Y) = True Then
					player.hunterIsFalling = False
					Self.joyJump = False
					player.hunterJumpControl.Reset()
					Repeat
						offsetPlayer1Y -= 1; offsetTilemapY = offsetPlayer1Y - diffY
					Until tilemap.CheckCollisionBottom(offsetPlayer1X,offsetPlayer1Y) = False
				Endif
				If  tilemap.CheckCollisionLeft(offsetPlayer1X,offsetPlayer1Y) = True Then
					Self.joyJump = False
					player.hunterJumpControl.Reset()
					player.hunterIsFalling = True
					Repeat
						offsetPlayer1X += 1; offsetTilemapX = offsetPlayer1X - diffX
					Until tilemap.CheckCollisionLeft(offsetPlayer1X,offsetPlayer1Y) = False
				End If
			
			'jump right
			Elseif Self.joyRight Then

				player.currentAnimation = player.hunterJumpRight
				'jump routine right
				offsetPlayer1X += player.hunterJumpControl.GetJumpX(); offsetTilemapX = offsetPlayer1X - diffX 
				offsetPlayer1Y -= player.hunterJumpControl.GetJumpY(); offsetTilemapY = offsetPlayer1Y - diffY
				

				If  tilemap.CheckCollisionTop(offsetPlayer1X,offsetPlayer1Y) = True Then
					Repeat
						offsetPlayer1Y += 1; offsetTilemapY = offsetPlayer1Y - diffY
					Until tilemap.CheckCollisionTop(offsetPlayer1X,offsetPlayer1Y) = False
				End If
				If  tilemap.CheckCollisionBottom(offsetPlayer1X,offsetPlayer1Y) = True Then
					player.hunterIsFalling = False
					Self.joyJump = False
					player.hunterJumpControl.Reset()
					Repeat
						offsetPlayer1Y -= 1; offsetTilemapY = offsetPlayer1Y - diffY
					Until tilemap.CheckCollisionBottom(offsetPlayer1X,offsetPlayer1Y) = False
				Endif
				If  tilemap.CheckCollisionRight(offsetPlayer1X,offsetPlayer1Y) = True Then
					Self.joyJump = False
					player.hunterJumpControl.Reset()
					player.hunterIsFalling = True
					Repeat
						offsetPlayer1X -= 1; offsetTilemapX = offsetPlayer1X - diffX
					Until tilemap.CheckCollisionRight(offsetPlayer1X,offsetPlayer1Y) = False
				End If

			End If


			If player.hunterJumpControl.Update() = False Then
				Self.joyJump = False
				player.hunterJumpControl.Reset()
			End If
		Else
			
			If player.hunterStolen = True Then
				player.currentAnimation = player.hunterStolenItem
			Elseif player.hunterHit = True Then
				player.currentAnimation = player.hunterWasHit
			Else
				If tilemap.CheckFalling(offsetPlayer1X,offsetPlayer1Y) Then
					player.hunterIsFalling = True
					player.currentAnimation = player.hunterStandingRight
					offsetPlayer1Y += 5; offsetTilemapY = offsetPlayer1Y - diffY
					If  tilemap.CheckCollisionBottom(offsetPlayer1X,offsetPlayer1Y) = True Then
						Repeat
							offsetPlayer1Y -= 1; offsetTilemapY = offsetPlayer1Y - diffY
						Until tilemap.CheckCollisionBottom(offsetPlayer1X,offsetPlayer1Y) = False
						player.hunterIsFalling = False
					End If
					
				'climbing up?
				Elseif Self.joyUp Then
					If tilemap.tilenamebehind = "ladder" Then	
						offsetPlayer1Y -= scrollSpeedY; offsetTilemapY = offsetPlayer1Y - diffY
						If  tilemap.CheckCollisionTop(offsetPlayer1X,offsetPlayer1Y) = True Then
							Repeat
								offsetPlayer1Y += 1; offsetTilemapY = offsetPlayer1Y - diffY
							Until tilemap.CheckCollisionTop(offsetPlayer1X,offsetPlayer1Y) = False
						End If
					End If
					
				'climbing down
				Else If Self.joyDown Then
					offsetPlayer1Y += scrollSpeedY; offsetTilemapY = offsetPlayer1Y - diffY
					If  tilemap.CheckCollisionBottom(offsetPlayer1X,offsetPlayer1Y) = True Then
						Repeat
							offsetPlayer1Y -= 1; offsetTilemapY = offsetPlayer1Y - diffY
						Until tilemap.CheckCollisionBottom(offsetPlayer1X,offsetPlayer1Y) = False
					End If
				
				'running left
				Else If Self.joyLeft Then
					player.hunterIsFalling = False
					If tilemap.tilenamebehind <> "ladder" Then 
            player.currentAnimation = player.hunterWalkingLeft
          End If
					offsetPlayer1X -= scrollSpeedX; offsetTilemapX = offsetPlayer1X - diffX
					If  tilemap.CheckCollisionLeft(offsetPlayer1X,offsetPlayer1Y) = True Then
						Repeat
							offsetPlayer1X += 1; offsetTilemapX = offsetPlayer1X - diffX
						Until tilemap.CheckCollisionLeft(offsetPlayer1X,offsetPlayer1Y) = False
					End If
					
				'running right
				Else If Self.joyRight Then
					player.hunterIsFalling = False
					If tilemap.tilenamebehind <> "ladder" Then 
            player.currentAnimation = player.hunterWalkingRight
					End If
					offsetPlayer1X += scrollSpeedX; offsetTilemapX = offsetPlayer1X - diffX
					If  tilemap.CheckCollisionRight(offsetPlayer1X,offsetPlayer1Y) = True Then
						Repeat
							offsetPlayer1X -= 1; offsetTilemapX = offsetPlayer1X - diffX
						Until tilemap.CheckCollisionRight(offsetPlayer1X,offsetPlayer1Y) = False
					End If
				End If		
			End If
		End If
		
		
		'test keys ;o)
		If KeyDown( KEY_S ) Then
			player.hunterStolen = True
			player.hunterStolenItem.ResetAnim()
		Elseif KeyHit( KEY_A ) Then
			Print "GetDX:" + mystick.GetDX() + "     GetDY:" + mystick.GetDY()
		Elseif KeyDown( KEY_R ) Then
			Print "UpdateRate:" + GetUpdateRate()
			player.hunterHit = False
			player.hunterStolen = False
		Elseif KeyDown( KEY_H ) Then
			player.hunterHit = True 
			player.hunterWasHit.ResetAnim()
		End If
		
		
		tilemap.CheckCurrentTiles(offsetPlayer1X,offsetPlayer1Y)
		
	End Method
		
	Method ResetControls:Void()
		Self.joyLeft = False
		Self.joyRight = False
		Self.joyUp = False
		Self.joyDown = False
		Self.joyFire = False
		'Self.joyJump = False
	End Method

	Method UpdateControls:Void()
		' update the stick usage
		Self.UpdateStick()
		buttons.UpdateButtons()

		'If mystick.GetVelocity() <> 0 Then
		'	offsetPlayer1X += mystick.GetDX() * scrollSpeed; offsetTilemapX = offsetPlayer1X - diffX
		'	offsetPlayer1Y -= mystick.GetDY() * scrollSpeed; offsetTilemapY = offsetPlayer1Y - diffY
		'End
		
		'joypad touch
		
		'GetDX positiv ist rechts
		'GetDX negativ ist links
		'GetDY positiv ist oben
		'GetDY negativ ist unten
		If mystick.GetDX() > 0 Then			'rechts
			If mystick.GetDY() > 0 Then 	'oben
				If mystick.GetDY() > mystick.GetDX() Then 
					Self.joyUp = True
				Else
					Self.joyRight = True
				End If 
			Elseif mystick.GetDY() < 0 Then	'unten
				If (mystick.GetDY() * -1) > mystick.GetDX() Then 
					Self.joyDown = True
				Else
					Self.joyRight = True
				End If 
			End If
		Elseif mystick.GetDX() < 0 Then		'links
			If mystick.GetDY() > 0 Then 	'oben
				If mystick.GetDY() > (mystick.GetDX() * -1) Then 
					Self.joyUp = True
				Else
					Self.joyLeft = True
				End If 
			Elseif mystick.GetDY() < 0 Then	'unten
				If (mystick.GetDY() * -1) > (mystick.GetDX() * -1) Then 
					Self.joyDown = True
				Else
					Self.joyLeft = True
				End If 
			End If
		End If
		
		If (Self.joyLeft And Self.buttons.jump) Then
			Self.joyJump = True
		Elseif (Self.joyRight And Self.buttons.jump) Then
			Self.joyJump = True
		Endif

		If ( KeyDown(KEY_LEFT) And KeyDown(KEY_X) ) Then
			Self.joyLeft = True
			Self.joyJump = True
		Else If ( KeyDown(KEY_RIGHT) And KeyDown(KEY_X) ) Then
			Self.joyRight = True
			Self.joyJump = True
		Else If ( KeyDown(KEY_LEFT) And KeyDown(KEY_Y) ) Then
			Self.joyLeft = True
			Self.joyFire = True
		Else If ( KeyDown(KEY_RIGHT) And KeyDown(KEY_Y) ) Then
			Self.joyRight = True
			Self.joyFire = True
		Else If KeyDown(KEY_UP) Then
			Self.joyUp = True
		Else If KeyDown(KEY_DOWN) Then
			Self.joyDown = True
		Else If KeyDown(KEY_LEFT) Then
			Self.joyLeft = True
		Else If KeyDown(KEY_RIGHT) Then
		 	Self.joyRight = True
		End If
	End Method
	
	Method UpdateStick:Void()
		If mystick.GetTouchNumber() < 0 Then
			#if TARGET="android" Or TARGET="ios" Then
				For Local i:Int = 0 To 31
					If TouchHit(i) And mystick.GetTouchNumber() < 0 Then
						mystick.StartTouch(TouchX(i), TouchY(i), i)
					End
				End
			#else
				If MouseHit(0) Then
					mystick.StartTouch(MouseX(), MouseY(), 0)
				End
			#endif
		End
		
		If mystick.GetTouchNumber() >= 0 Then
			#if TARGET="android" Or TARGET="ios" Then
				If TouchDown(mystick.GetTouchNumber()) Then
					mystick.UpdateTouch(TouchX(mystick.GetTouchNumber()), TouchY(mystick.GetTouchNumber()))
				Else
					mystick.StopTouch()
				End
			#else
				If MouseDown(0) Then
					mystick.UpdateTouch(MouseX(), MouseY())
				Else
					mystick.StopTouch()
				End
			#endif
		End
	End
	
	Method LoadMap:Void()
		Local reader:MyTiledTileMapReader = New MyTiledTileMapReader
		Local tm:TileMap = reader.LoadMap(currentLevel)
		tilemap = CustomTileMap(tm)
		tilemap.CheckHitInit()
		tbounds = tilemap.GetBounds()
	End Method

	Method ShowDebugInfo:Void()
		Local stat1:String = "offTM: " + offsetTilemapX + "," +offsetTilemapY + "  controlPixelFeet rgb: " + Self.controlPixel.controlPixelFeet[0] + "," + Self.controlPixel.controlPixelFeet[1] + "," + Self.controlPixel.controlPixelFeet[2]  + "  controlPixelGround rgb: " + Self.controlPixel.controlPixelGround[0] + "," + Self.controlPixel.controlPixelGround[1] + "," + Self.controlPixel.controlPixelGround[2]
		font.Draw(stat1, 10, 10)
		Local stat2:String = "offsetPlayer:   "+offsetPlayer1X+ "," +offsetPlayer1Y + "  tilenameBehind: " + tilemap.tilenamebehind + "  tilenameBottom: " + tilemap.tilenamebottom
		font.Draw(stat2, 10, 30)
		
		#If CONFIG="debug"
			DrawText "X: " + MouseX() + ", Y: " + MouseY(), MouseX(), MouseY()
		#End	
	End
End

