Strict

Import mojo

Global sndShot:Sound
Global sndJump:Sound

Class Buttons
	Field fire:Bool = False
	Field jump:Bool = False
	Field tx:Int = 0
	Field ty:Int = 0
	Field alpha:Float = 0.5
	
	Field firebuttonsize:Int = 100
	Field firebuttonoffset:Int = 100
	
	Field triggerid:Int = -1
	Field triggered:Bool = False
	
	Field sndShot:Sound
	Field sndJump:Sound
	
	Method New()
		sndShot = LoadSound("Laser_Shoot.mp3")
		sndJump = LoadSound("Jump.mp3")
	End Method
	
	Method UpdateButtons:Void()
		For Local i:Int = 0 To 31
			If TouchDown(i) And TouchX(i) > DeviceWidth()/2 And Self.triggered = False Then
					Self.tx = TouchX(i)
					Self.ty = TouchY(i)
					Self.triggered = True
					Self.triggerid = i
				 	
					'fire button
					If (Self.tx > (DeviceWidth() - Self.firebuttonoffset - Self.firebuttonsize) And Self.tx < (DeviceWidth() - Self.firebuttonoffset)) And (Self.ty > (DeviceHeight() - Self.firebuttonoffset - Self.firebuttonsize) And Self.ty < (DeviceHeight() - Self.firebuttonoffset)) Then
						Self.fire = True
						Self.alpha = 0.8
						PlaySound(sndShot)
						'Print "Firebutton"
					Else If (Self.tx < (DeviceWidth() - Self.firebuttonoffset - Self.firebuttonsize) Or Self.tx > (DeviceWidth() - Self.firebuttonoffset)) Or (Self.ty < (DeviceHeight() - Self.firebuttonoffset - Self.firebuttonsize) Or Self.ty > (DeviceHeight() - Self.firebuttonoffset)) Then
						Self.jump = True
						PlaySound(sndJump)
						'Print "Jump"
					End If
			End If
		End For
		
		If TouchDown(Self.triggerid) = False And Self.triggered = True
			Self.fire = False
			Self.jump = False
			Self.triggered = False
			Self.triggerid = -1
			Self.alpha = 0.5
			'Print "Button released"
		End If
	End Method
	
	Method RenderButtons:Void()
		SetAlpha Self.alpha
		DrawRect(DeviceWidth() - Self.firebuttonsize - Self.firebuttonoffset, DeviceHeight() - Self.firebuttonsize - Self.firebuttonoffset, Self.firebuttonsize, Self.firebuttonsize)
		SetAlpha 1
	End Method
End