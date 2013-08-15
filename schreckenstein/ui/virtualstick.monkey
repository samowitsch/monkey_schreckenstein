Import mojo


' ###############  virtualStick ####################

Class MyStick Extends VirtualStick
	Method RenderRing:Void(x:Float, y:Float)
		SetColor 255, 255, 255
		SetAlpha 0.3
		Super.RenderRing(x, y)
		SetAlpha 1
	End
	
	Method RenderStick:Void(x:Float, y:Float)
		SetColor 255, 255, 255
		SetAlpha 0.7
		Super.RenderStick(x, y)
		SetAlpha 1
	End
	
	Method Render:Void()
		Self.DoRenderRing()
		Self.DoRenderStick()
	End
End




' ############ the virtualstick base class ##############

Class VirtualStick
Private
	' the coordinates and dimensions for the virtual stick's ring (where the user will first touch)
	Field ringX:Float
	Field ringY:Float
	Field ringRadius:Float
	
	' the coordinates and dimensions for the stick (what the user is pushing around)
	' X/Y is relative to the centre of the ring, and positive Y points up
	Field stickX:Float = 0
	Field stickY:Float = 0
	Field stickRadius:Float
	Field stickAngle:Float
	Field stickPower:Float
	
	' where the user first touched
	Field firstTouchX:Float
	Field firstTouchY:Float
	
	' power must always be >= this, or we return 0
	Field deadZone:Float
	
	' we need to move the stick this much before it triggers
	Field triggerDistance:Float = -1
	Field triggered:Bool = False
	
	' the index of the touch event that initiated the stick movement
	Field touchNumber:Int = -1
	
	Method New()
		Self.SetRing(150, DeviceHeight()-150, 50)
		Self.SetStick(0, 0, 20)
		Self.SetDeadZone(0.2)
		Self.SetTriggerDistance(5)	
	End Method
	
	' clips the stick to be within the ring, and updates angles, etc.
	Method UpdateStick:Void()
		If touchNumber>=0 Then
			Local length:Float = Sqrt(stickX*stickX+stickY*stickY)
			stickPower = length/ringRadius
			If stickPower > 1 Then stickPower = 1
			
			If stickPower < deadZone Then
				stickPower = 0
				stickAngle = 0
				stickX = 0
				stickY = 0
			Else
				If stickX = 0 And stickY = 0 Then
					stickAngle = 0
					stickPower = 0
				Elseif stickX = 0 And stickY > 0 Then
					stickAngle = 90
				Elseif stickX = 0 And stickY < 0 Then
					stickAngle = 270
				Elseif stickY = 0 And stickX > 0 Then
					stickAngle = 0
				Elseif stickY = 0 And stickX < 0 Then
					stickAngle = 180
				Elseif stickX > 0 And stickY > 0 Then
					stickAngle = ATan(stickY/stickX)
				Elseif stickX < 0 Then
					stickAngle = 180+ATan(stickY/stickX)
				Else
					stickAngle = 360+ATan(stickY/stickX)
				End
				If length > ringRadius Then
					stickPower = 1
					stickX = Cos(stickAngle) * ringRadius
					stickY = Sin(stickAngle) * ringRadius
				End
			End
		End
	End
	
Public

	Method GetTouchNumber:Int()
		Return touchNumber
	End
	
	' the angle in degrees that the user is pushing, going counter-clockwise from right
	Method GetAngle:Float()
		Return stickAngle
	End
	
	' the strength of the movement (0 means dead centre, 1 means at the edge of the ring (or past it)
	Method GetVelocity:Float()
		Return stickPower
	End
	
	' based on the angle and velocity, get the DX
	Method GetDX:Float()
		Return Cos(stickAngle) * stickPower
	End
	
	' based on the angle and velocity, get the DY
	Method GetDY:Float()
		Return Sin(stickAngle) * stickPower
	End
	
	' we just touched the screen at point (x,y), so start "controlling" if we touched inside the ring
	Method StartTouch:Void(x:Float, y:Float, touchnum:Int)
		If touchNumber < 0 Then
			If (x-ringX)*(x-ringX) + (y-ringY)*(y-ringY) <= ringRadius*ringRadius Then
				touchNumber = touchnum
				firstTouchX = x
				firstTouchY = y
				triggered = False
				If triggerDistance <= 0 Then
					triggered = True
					stickX = x-ringX
					stickY = ringY-y
				End
				UpdateStick()
			End
		End
	End
	
	' a touch just moved, so we may need to update the stick
	Method UpdateTouch:Void(x:Float, y:Float)
		If touchNumber>=0 Then
			If Not triggered Then
				If (x-firstTouchX)*(x-firstTouchX)+(y-firstTouchY)*(y-firstTouchY) > triggerDistance*triggerDistance Then
					triggered = True
				End
			End
			If triggered Then
				stickX = x - ringX
				stickY = ringY - y
				UpdateStick()
			End
		End
	End
	
	' we just released a touch, which may have been this one
	Method StopTouch:Void()
		If touchNumber>=0 Then
			touchNumber = -1
			stickX = 0
			stickY = 0
			stickAngle = 0
			stickPower = 0
			triggered = False
		End
	End
	
	Method DoRenderRing:Void()
		RenderRing(ringX, ringY)
	End
	
	Method DoRenderStick:Void()
		RenderStick(ringX+stickX, ringY-stickY)
	End
	
	' draws the stick (may be overridden to do images, etc.)
	Method RenderStick:Void(x:Float, y:Float)
		DrawCircle(x, y, stickRadius)
	End
	
	' draws the outside ring (may be overridden to do images, etc.)
	Method RenderRing:Void(x:Float, y:Float)
		DrawCircle(x, y, ringRadius)
	End
	
	' set the location and radius of the ring
	Method SetRing:Void(ringX:Float, ringY:Float, ringRadius:Float)
		Self.ringX = ringX
		Self.ringY = ringY
		Self.ringRadius = ringRadius
	End
	
	' set the location and radius of the stick
	Method SetStick:Void(stickX:Float, stickY:Float, stickRadius:Float)
		Self.stickX = stickX
		Self.stickY = stickY
		Self.stickRadius = stickRadius
	End
	
	Method SetDeadZone:Void(deadZone:Float)
		Self.deadZone = deadZone
	End
	
	Method SetTriggerDistance:Void(triggerDistance:Float)
		Self.triggerDistance = triggerDistance
	End
End

Function DrawOutlineRect:Void(x:Float, y:Float, width:Float, height:Float)
	DrawLine(x, y, x+width, y)
	DrawLine(x, y, x, y+height)
	DrawLine(x+width, y, x+width, y+height)
	DrawLine(x, y+height, x+width, y+height)
End