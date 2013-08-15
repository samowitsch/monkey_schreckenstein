Class Jump
	Field currentFrame:Int = 0
	Field delayFrame:Int = 0
	Field delayEnd:Int = 2
	'Field jumpX:Int[]=[8,8,8,8,8]
	'Field jumpY:Int[]=[4,4,0,-4,-4]

	Field jumpX:Int[]=[22,20,20,18,16,8,8,8,8,4,4]
	Field jumpY:Int[]=[12,12,10,4,4,0,-4,-4,-10,-12,-12]

	Method New()
	End Method
	
	Method Update:Bool()
		If Self.currentFrame < Self.jumpX.Length() Then
			If Self.delayFrame = 0 Then
				Self.currentFrame += 1
			End If
			Self.delayFrame += 1
			If Self.delayFrame >= Self.delayEnd Then Self.delayFrame = 0
			Return True
		Endif
		Return False
	End Method
	
	Method Reset:Void()
		Self.currentFrame = 0
		Self.delayFrame = 0
	End Method
	
	Method GetJumpX:Int()
		If Self.delayFrame = 0 Then
			Return Self.jumpX[Self.currentFrame]
		Else
			Return 0
		Endif
		
	End Method
	
	Method GetJumpY:Int()
		If Self.delayFrame = 0 Then
			Return Self.jumpY[Self.currentFrame]
		Else
			Return 0
		Endif
	End Method

End Class

