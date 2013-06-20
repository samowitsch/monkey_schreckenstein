Import monkey.map

Import diddy.base64
Import diddy.collections
Import diddy.framework
Import diddy.xml
Import diddy.tile

Import customtilemap
Import fantomEngine.cftFont		'needed for font drawing
Import virtualstick
Import animation
Import buttons
Import jump
Import menuscreen


Class GameScreen Extends Screen

	Field backButton:SimpleButton = New SimpleButton()

	Field fnt:ftFont				' fantomEngine font class ftFont
	Field tilemap:CustomTileMap		' extended Diddy TileMap class, no local modified Diddy FW anymore ;o)
	
	Field toolbarlayer:Image
	
	Field tilemapOffset:Int = 128
	Field tbounds:TileMapRect

	Field startOffsetTilemapX:Int = -416, startOffsetTilemapY:Int = -160	'offset for tilemap
	Field startOffsetPlayer1X:Int = 97, startOffsetPlayer1Y:Int = 127		'offset player1
	Field diffX:Int = 480, diffY:Int = 287

	Field offsetTilemapX:Int, offsetTilemapY:Int	'offset for tilemap
	Field offsetPlayer1X:Int, offsetPlayer1Y:Int	'offset player1

	Field str$
	Field scrollSpeedX:Int = 7
	Field scrollSpeedY:Int = 4

	Field hunterWalkingLeft:Animation
	Field hunterWalkingRight:Animation
	Field hunterStandingRight:Animation
	Field hunterStandingLeft:Animation
	Field hunterClimbing:Animation
	Field hunterJumpLeft:Animation
	Field hunterJumpRight:Animation
	Field hunterStolenItem:Animation
	Field hunterWasHit:Animation
	Field hunterHit:Bool = False
	Field hunterIsFalling:Bool = False
	Field hunterIsClimbing:Bool = False
	Field hunterStolen:Bool = False
	Field hunterJumpControl:Jump = New Jump
	
	Field controlPixelFeet:Int[3]		'controlPixelFeet for ramp tilemaps
	Field controlPixelGround:Int[3]		'controlPixelGround for ramp tilemaps

	
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
	
	Field currentAnimation:Animation
	Field hunter:Image

	' our virtual stick and buttons
	Field mystick:MyStick
	Field buttons:Buttons

    Method New()
    	name = "GameScreen"
	End

    Method Start:Void()
		Self.LoadMap()
		Self.LoadHunter()

		'startpoint tilemap
		offsetTilemapX = startOffsetTilemapX
		offsetTilemapY = startOffsetTilemapY
		
		'startpoint player1
		offsetPlayer1X = startOffsetPlayer1X
		offsetPlayer1Y = startOffsetPlayer1Y
		
		toolbarlayer = LoadImage("toolbar.png")
		SetMusicVolume(0.75)
		PlayMusic("beat.mp3", 1)
		
		fnt = New ftFont()	'use fantomEngine class ftFont for text drawing
		fnt.Load("atd_font")

		mystick = New MyStick
		buttons = New Buttons
		
		backButton.Load("btn-home.png","btn-home.png","","")
		backButton.MoveTo(10,50)
		backButton.Update()

		
		game.screenFade.Start(50, False)
    End
       
    Method Render:Void()

		Cls
		' !!!!  render subpart of tilemap for Controlpixel ;o(  !!!!
		tilemap.CustomRenderMap(offsetTilemapX+511, offsetTilemapY + 286, 10, 10, 414, 512, True)
		
		Local pixelOffset:Int = Self.CheckControlPixel()	'get pixel offset to ramp ground if needed
		If pixelOffset <> 0 Then
			Self.offsetPlayer1Y += pixelOffset; Self.offsetTilemapY = Self.offsetPlayer1Y - Self.diffY
			#rem
			If tilemap.CheckCollisionBottom(offsetPlayer1X,offsetPlayer1Y) = True Then				
				Repeat
					offsetPlayer1Y -= 1; offsetTilemapY = offsetPlayer1Y - diffY
				Until tilemap.CheckCollisionBottom(offsetPlayer1X,offsetPlayer1Y) = False
				
			Endif
			#End
		End If
		
		
		' !!!! render real tilemap
		Cls
		tilemap.CustomRenderMap(offsetTilemapX, offsetTilemapY, SCREEN_WIDTH, SCREEN_HEIGHT - 256, tilemapOffset)

		currentAnimation.display(SCREEN_WIDTH/2 - 28, SCREEN_HEIGHT/2 - 32)
		DrawImage(toolbarlayer, 0, 0)				
								
		
		Self.ShowDebugInfo()
		
		mystick.Render()
		buttons.RenderButtons()
		FPSCounter.Draw(10,0)
		backButton.Draw()
    End

	Method ExtraRender:Void()

	End Method


	Method ShowDebugInfo:Void()
		Local stat1:String = "offTM: " + offsetTilemapX + "," +offsetTilemapY + "  controlPixelFeet rgb: " + controlPixelFeet[0] + "," + controlPixelFeet[1] + "," + controlPixelFeet[2]  + "  controlPixelGround rgb: " + controlPixelGround[0] + "," + controlPixelGround[1] + "," + controlPixelGround[2]
		fnt.Draw(stat1, 10, 10)
		Local stat2:String = "offsetPlayer:   "+offsetPlayer1X+ "," +offsetPlayer1Y + "  tilenameBehind: " + tilemap.tilenamebehind + "  tilenameBottom: " + tilemap.tilenamebottom
		fnt.Draw(stat2, 10, 30)
	End
        
	Method Update:Void()
	
		Self.Controls()
		currentAnimation.update()
				
		tilemap.UpdateAnimation(dt.frametime)
		
		backButton.Update()
		If backButton.clicked = 1 Then
			StopMusic()
			game.screenFade.Start(50, True)
			game.nextScreen = menuScreen
		End If

	 End

	
	Method Controls:Void()
		
		Self.ResetControls()
		Self.UpdateControls()
		
		hunterClimbing.stopped = True
		If Self.joyLeft Or Self.joyRight Or Self.joyUp Or Self.joyDown Then
			hunterClimbing.stopped = False
		Endif

		tilemap.CheckCurrentTiles(offsetPlayer1X,offsetPlayer1Y)
		If tilemap.tilenamebehind = "ladder" Then
			Self.joyJump = False
		End If
		
		currentAnimation = hunterStandingRight
		If tilemap.tilenamebehind = "ladder" Or tilemap.tilenamebottom = "ladder" Then
			currentAnimation = hunterClimbing
		Endif

		If KeyHit(KEY_ESCAPE)
	        game.screenFade.Start(50, True)
	        game.nextScreen = menuScreen
		End
		
		If Self.hunterIsFalling = True Then Self.joyJump = False
		
		'jumping
		If Self.joyJump Then
			
			'jump left
			If Self.joyLeft Then

				currentAnimation = hunterJumpLeft
				'jump routine left
				offsetPlayer1X -= Self.hunterJumpControl.GetJumpX(); offsetTilemapX = offsetPlayer1X - diffX
				offsetPlayer1Y -= Self.hunterJumpControl.GetJumpY(); offsetTilemapY = offsetPlayer1Y - diffY
				
				If  tilemap.CheckCollisionTop(offsetPlayer1X,offsetPlayer1Y) = True Then
					Repeat
						offsetPlayer1Y += 1; offsetTilemapY = offsetPlayer1Y - diffY
					Until tilemap.CheckCollisionTop(offsetPlayer1X,offsetPlayer1Y) = False
				End If
				If tilemap.CheckCollisionBottom(offsetPlayer1X,offsetPlayer1Y) = True Then
					Self.hunterIsFalling = False
					Self.joyJump = False
					Self.hunterJumpControl.Reset()
					Repeat
						offsetPlayer1Y -= 1; offsetTilemapY = offsetPlayer1Y - diffY
					Until tilemap.CheckCollisionBottom(offsetPlayer1X,offsetPlayer1Y) = False
				Endif
				If  tilemap.CheckCollisionLeft(offsetPlayer1X,offsetPlayer1Y) = True Then
					Self.joyJump = False
					Self.hunterJumpControl.Reset()
					Self.hunterIsFalling = True
					Repeat
						offsetPlayer1X += 1; offsetTilemapX = offsetPlayer1X - diffX
					Until tilemap.CheckCollisionLeft(offsetPlayer1X,offsetPlayer1Y) = False
				End If
			
			'jump right
			Elseif Self.joyRight Then

				currentAnimation = hunterJumpRight
				'jump routine right
				offsetPlayer1X += Self.hunterJumpControl.GetJumpX(); offsetTilemapX = offsetPlayer1X - diffX 
				offsetPlayer1Y -= Self.hunterJumpControl.GetJumpY(); offsetTilemapY = offsetPlayer1Y - diffY
				

				If  tilemap.CheckCollisionTop(offsetPlayer1X,offsetPlayer1Y) = True Then
					Repeat
						offsetPlayer1Y += 1; offsetTilemapY = offsetPlayer1Y - diffY
					Until tilemap.CheckCollisionTop(offsetPlayer1X,offsetPlayer1Y) = False
				End If
				If  tilemap.CheckCollisionBottom(offsetPlayer1X,offsetPlayer1Y) = True Then
					Self.hunterIsFalling = False
					Self.joyJump = False
					Self.hunterJumpControl.Reset()
					Repeat
						offsetPlayer1Y -= 1; offsetTilemapY = offsetPlayer1Y - diffY
					Until tilemap.CheckCollisionBottom(offsetPlayer1X,offsetPlayer1Y) = False
				Endif
				If  tilemap.CheckCollisionRight(offsetPlayer1X,offsetPlayer1Y) = True Then
					Self.joyJump = False
					Self.hunterJumpControl.Reset()
					Self.hunterIsFalling = True
					Repeat
						offsetPlayer1X -= 1; offsetTilemapX = offsetPlayer1X - diffX
					Until tilemap.CheckCollisionRight(offsetPlayer1X,offsetPlayer1Y) = False
				End If

			End If


			If Self.hunterJumpControl.Update() = False Then
				Self.joyJump = False
				Self.hunterJumpControl.Reset()
			End If
		Else
			
			If Self.hunterStolen = True Then
				currentAnimation = hunterStolenItem
			Elseif Self.hunterHit = True Then
				currentAnimation = hunterWasHit
			Else
				If tilemap.CheckFalling(offsetPlayer1X,offsetPlayer1Y) Then
					Self.hunterIsFalling = True
					currentAnimation = hunterStandingRight
					offsetPlayer1Y += 5; offsetTilemapY = offsetPlayer1Y - diffY
					If  tilemap.CheckCollisionBottom(offsetPlayer1X,offsetPlayer1Y) = True Then
						Repeat
							offsetPlayer1Y -= 1; offsetTilemapY = offsetPlayer1Y - diffY
						Until tilemap.CheckCollisionBottom(offsetPlayer1X,offsetPlayer1Y) = False
						Self.hunterIsFalling = False
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
					Self.hunterIsFalling = False
					If tilemap.tilenamebehind <> "ladder" Then currentAnimation = hunterWalkingLeft	
					offsetPlayer1X -= scrollSpeedX; offsetTilemapX = offsetPlayer1X - diffX
					If  tilemap.CheckCollisionLeft(offsetPlayer1X,offsetPlayer1Y) = True Then
						Repeat
							offsetPlayer1X += 1; offsetTilemapX = offsetPlayer1X - diffX
						Until tilemap.CheckCollisionLeft(offsetPlayer1X,offsetPlayer1Y) = False
					End If
					
				'running right
				Else If Self.joyRight Then
					Self.hunterIsFalling = False
					If tilemap.tilenamebehind <> "ladder" Then currentAnimation = hunterWalkingRight
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
			Self. hunterStolen = True
			hunterStolenItem.ResetAnim()
		Elseif KeyHit( KEY_A ) Then
			Print "GetDX:" + mystick.GetDX() + "     GetDY:" + mystick.GetDY()
		Elseif KeyDown( KEY_R ) Then
			Print "UpdateRate:" + GetUpdateRate()
			Self.hunterHit = False
			Self.hunterStolen = False
		Elseif KeyDown( KEY_H ) Then
			Self.hunterHit = True 
			hunterWasHit.ResetAnim()
		End If
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

	#rem
	CheckControlPixel and "calculate" offset to the ramp ground
	
	@return Int pixelOffset
	#end
	
	Method CheckControlPixel:Int()
		Local pixelOffset:Int = 0
		Local check1:Int = 31
		Local check2:Int = 32
		controlPixelFeet = CustomGetPixel(SCREEN_WIDTH/2, SCREEN_HEIGHT/2 + check1)
		controlPixelGround = CustomGetPixel(SCREEN_WIDTH/2, SCREEN_HEIGHT/2 + check2)
		
		If 	(Self.tilemap.tilenamebehind = "ramp" Or Self.tilemap.tilenamebottom = "ramp") Then
			'over ramp ground
			If Self.controlPixelFeet[0] = 0 And Self.controlPixelGround[0] = 0 Then
				Repeat
					check1 += 1 ; check2 += 1 ; pixelOffset += 1
					controlPixelFeet = CustomGetPixel(SCREEN_WIDTH/2, SCREEN_HEIGHT/2 + check1)
					controlPixelGround = CustomGetPixel(SCREEN_WIDTH/2, SCREEN_HEIGHT/2 + check2)
				Until Self.controlPixelFeet[0] = 0 And Self.controlPixelGround[0] <> 0
			Endif
			'below the ramp ground
			If Self.controlPixelFeet[0] <> 0 And Self.controlPixelGround[0] <> 0 Then
				Repeat
					check1 -= 1 ; check2 -= 1 ; pixelOffset -= 1
					controlPixelFeet = CustomGetPixel(SCREEN_WIDTH/2, SCREEN_HEIGHT/2 + check1)
					controlPixelGround = CustomGetPixel(SCREEN_WIDTH/2, SCREEN_HEIGHT/2 + check2)
				Until Self.controlPixelFeet[0] = 0 And Self.controlPixelGround[0] <> 0
			Endif
		Endif
		Return pixelOffset
	End Method
	
	
	
	' replace the diddy GetPixel with the mojo ReadPixels
	Method CustomGetPixel:Int[](x:Int, y:Int)
		Local Pixels:Int[]
		ReadPixels(Pixels, x, y, 1, 1)
		
		Local a : Int = ( Pixels[0] Shr 24 ) & $ff
		Local r : Int = ( Pixels[0] Shr 16 ) & $ff
		Local g : Int = ( Pixels[0] Shr 8 ) & $ff
		Local b : Int = Pixels[0] & $ff
		
		Local PixelValues:Int[] = [r,g,b]
		Return PixelValues
	End Method
	
	
	
	Method LoadHunter:Void()
		hunter = LoadImage("hunter.png",56,64,49)
		hunterWalkingRight = New Animation(0,6,3,hunter)'first frame, last frame ,duration, animated image set
		hunterWalkingLeft = New Animation(7,13,3,hunter)
		hunterStandingRight = New Animation(14,14,4,hunter)
		hunterStandingLeft = New Animation(14,14,4,hunter)
		hunterClimbing = New Animation(15,23,4,hunter)
		hunterClimbing.stopped = True
		hunterJumpRight = New Animation(24,24,4,hunter)
		hunterJumpLeft = New Animation(25,25,4,hunter)
		hunterStolenItem = New Animation(26,29,20,hunter,False)
		hunterWasHit = New Animation(30,46,6,hunter,False)
		currentAnimation = hunterStandingRight
	End Method
End

