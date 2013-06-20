Import mojo

Class Animation

	Field firstFrame:Int	'first frame in atlas
	Field lastFrame:Int		'last frame in atlas
	Field duration:Int		'duration for frame to display
	Field delay:Int			'delay counter for duration
	Field index:Int			'index of current frame
	Field images:Image		'frames
	Field loop:Bool			'restart loop at after last frame
	Field stopped:Bool = False
	Field x:Int
	Field y:Int
	
	Method New(first:Int,last:Int,dur:Int,img:Image,lp:Bool = True)
		firstFrame = first
		lastFrame = last
		duration = dur
		images = img
		index = first
		loop = lp
		delay = 0
	End Method

	Method update:Int()
		If Self.stopped = False Then
			delay = delay + 1
			If delay > duration
				index  = index + 1
				
				If index > lastFrame And loop = False Then
					index = lastFrame
					Return 0
				Elseif index > lastFrame
					index = firstFrame
				Endif
				delay = 0
			Endif
		Endif
		Return 0
	End Method
	
	Method ResetAnim:Void()
		Self.index = Self.firstFrame
	End
	
	Method display:Int(x:Int,y:Int)
		Self.x = x
		Self.y = y
		DrawImage images,x,y,index
		
		'#If CONFIG="debug"
			Self.DrawBounds()
		'#End			
		
		Return 0
	End Method
	
	Method DrawBounds:Void()
		SetColor(255,0,0)
		DrawCircle Self.x+28,Self.y+32,2 'mitte
		DrawCircle Self.x-4,Self.y,2
		DrawCircle Self.x-4,Self.y+64,2
		DrawCircle Self.x+60,Self.y,2
		DrawCircle Self.x+60,Self.y+64,2
		
		SetColor(255,255,0)
		DrawCircle Self.x+28,Self.y,2
		DrawCircle Self.x+28,Self.y+64,2
		DrawCircle Self.x-4,Self.y+32,2
		DrawCircle Self.x+60,Self.y+32,2
		
		
		SetColor(255,255,255)
		SetAlpha(0.8)
		
		DrawLine(Self.x,Self.y,Self.x+56,Self.y)
		DrawLine(Self.x+56,Self.y,Self.x+56,Self.y+64)
		DrawLine(Self.x+56,Self.y+64,Self.x,Self.y+64)
		DrawLine(Self.x,Self.y+64,Self.x,Self.y)
				
		SetAlpha(1)
	End Method
	
End Class