Strict

Import mojo
Import schreckenstein.sprite.animation
Import schreckenstein.sprite.jump
Import schreckenstein.sprite.basicsprite
Import schreckenstein.sprite.weaponsprite
Import diddy.framework

Class PlayerSprite Extends BasicSprite

	Field hunter:Image
	
	'the player can throw a maximum of two axes at a time, till they hit an enemy or an background tile
	'they would be reflected from ground and ceiling
	Field weapons:WeaponSprite[2]   

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
	Field currentAnimation:Animation


  Method New()
		Self.hunter = LoadImage("hunter.png",56,64,49)
		Self.hunterWalkingRight = New Animation(0,6,3,hunter)'first frame, last frame ,duration, animated image set
		Self.hunterWalkingLeft = New Animation(7,13,3,hunter)
		Self.hunterStandingRight = New Animation(14,14,4,hunter)
		Self.hunterStandingLeft = New Animation(14,14,4,hunter)
		Self.hunterClimbing = New Animation(15,23,4,hunter)
		Self.hunterClimbing.stopped = True
		Self.hunterJumpRight = New Animation(24,24,4,hunter)
		Self.hunterJumpLeft = New Animation(25,25,4,hunter)
		Self.hunterStolenItem = New Animation(26,29,20,hunter,False)
		Self.hunterWasHit = New Animation(30,46,6,hunter,False)
		currentAnimation = hunterStandingRight
  End Method
  
  
  Method Draw:Void()
    Self.currentAnimation.Draw(SCREEN_WIDTH2 - 28, SCREEN_HEIGHT2 - 32)
  End Method
  
  
  Method Update:Void()
    Self.currentAnimation.Update()
  End Method
  
End Class