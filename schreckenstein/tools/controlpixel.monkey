Strict

Import mojo
Import diddy.framework

Class ControlPixel
  Field pixelValues:Int[]
  Field controlPixelFeet:Int[]
  Field controlPixelGround:Int[]

  Method CheckControlPixel:Int()
    Local pixelOffset:Int = 0
    Local check1:Int = 31
    Local check2:Int = 32
    
    Self.controlPixelFeet = Self.CustomGetPixel(SCREEN_WIDTH2, (SCREEN_HEIGHT2 + check1))
    Self.controlPixelGround = Self.CustomGetPixel(SCREEN_WIDTH2, (SCREEN_HEIGHT2 + check2))

      'over ramp ground
      If Self.controlPixelFeet[0] = 0 And Self.controlPixelGround[0] = 0 Then
        Repeat
          pixelOffset += 1
          Self.controlPixelFeet = CustomGetPixel(SCREEN_WIDTH2, (SCREEN_HEIGHT2 + check1 + pixelOffset))
          Self.controlPixelGround = CustomGetPixel(SCREEN_WIDTH2, (SCREEN_HEIGHT2 + check2 + pixelOffset))
        Until controlPixelFeet[0] = 0 And controlPixelGround[0] <> 0

      'below the ramp ground
      Else If (Self.controlPixelFeet[0] <> 0 And Self.controlPixelGround[0] <> 0) Or 
        (Self.controlPixelFeet[0] <> 0 And Self.controlPixelGround[0] = 0) Then
        Repeat
          pixelOffset -= 1
          Self.controlPixelFeet = CustomGetPixel(SCREEN_WIDTH2, (SCREEN_HEIGHT2 + check1 + pixelOffset))
          Self.controlPixelGround = CustomGetPixel(SCREEN_WIDTH2, (SCREEN_HEIGHT2 + check2 + pixelOffset))
        Until controlPixelFeet[0] = 0 And controlPixelGround[0] <> 0
      Endif
    Return pixelOffset
  End Method

  Method CustomGetPixel:Int[](x:Int, y:Int)
    Local Pixels:Int[1] 'store 1 pixel
    ReadPixels(Pixels, x, y, 1, 1)
    
    Local a : Int = ( Pixels[0] Shr 24 ) & $ff
    Local r : Int = ( Pixels[0] Shr 16 ) & $ff
    Local g : Int = ( Pixels[0] Shr 8 ) & $ff
    Local b : Int = Pixels[0] & $ff
    
		Local PixelValues:Int[] = [r,g,b,a]
		Return PixelValues
  End Method
  
End Class
