#rem

CustomTileMap that extends the diddy TileMap

#end


Strict

Import diddy.tile
Import diddy.base64
Import monkey.map
Import diddy.collections
Import diddy.framework
Import diddy.xml



' TileMap
' The main Map class.
Class CustomTileMap Extends TileMap 

	'check player position
	Field stat:TilePlayerStatus = New TilePlayerStatus
	Field tile:TileMapTile = New TileMapTile
	Field tileproperties:TileMapProperties = New TileMapProperties
	
	Field tilenamebehind:String = ""
	Field tilenamebottom:String = ""
	
	Field layer:TileMapLayer
	Field tl:TileMapTileLayer
	Field px:Int	'xpos of player
	Field py:Int	'ypos of player
	Field pc:Int	'cell number of tile to check
	Field collTop:Bool = False
	Field collRight:Bool = False
	Field collBottom:Bool = False
	Field collFloor:Bool = False
	Field collLeft:Bool = False
	Field tileFloor:String = ""
	Field tileBody:String = ""
	Field tilekeyname:String = "name"	'key name of the values in the properties in tile editor
	
	' bx,by,bw,bh = render bounds (screen)
	' sx,sy = scale x/y (float, defaults to 1) i'll do this later
	' wx,wy = wrap x/y (boolean, defaults to false)
	' in Diddy => Method RenderMap:Void(bx%, by%, bw%, bh%, sx# = 1, sy# = 1)
	Method CustomRenderMap:Void(bx%, by%, bw%, bh%, topoffset% = 0, leftoffset% = 0, checkpixel:Bool = False, sx# = 1, sy# = 1)
		PreRenderMap()
		Local x%, y%, rx%, ry%, mx%, my%, mx2%, my2%, modx%, mody%
		For Local layer:TileMapLayer = Eachin layers
			If layer.visible And TileMapTileLayer(layer) <> Null Then
				Local tl:TileMapTileLayer = TileMapTileLayer(layer)
				Local mapTile:TileMapTile, gid%
				PreRenderLayer(layer)
				' ortho
				If orientation = MAP_ORIENTATION_ORTHOGONAL Then
					modx = (bx * tl.parallaxScaleX) Mod tileWidth
					mody = (by * tl.parallaxScaleY) Mod tileHeight
					y = by + tileHeight - tl.maxTileHeight
					my = Int(Floor(Float(by * tl.parallaxScaleY) / Float(tileHeight)))
					While y < by + bh + tl.maxTileHeight
						x = bx + tileWidth - tl.maxTileWidth
						mx = Int(Floor(Float(bx * tl.parallaxScaleX) / Float(tileWidth)))
						While x < bx + bw + tl.maxTileWidth
							If (wrapX Or (mx >= 0 And mx < width)) And (wrapY Or (my >= 0 And my < height)) Then
								mx2 = mx
								my2 = my
								While mx2 < 0
									mx2 += width
								End
								While mx2 >= width
									mx2 -= width
								End
								While my2 < 0
									my2 += height
								End
								While my2 >= height
									my2 -= height
								End
								gid = tl.mapData.cells[mx2 + my2*tl.mapData.width].gid
								If gid > 0 Then
									mapTile = tiles[gid - 1]
									Local tileprop:TileMapProperties = mapTile.Properties()
									Local tilename:String = tileprop.Get(Self.tilekeyname).GetString()
									
									If modx < 0 Then modx += tileWidth
									If mody < 0 Then mody += tileHeight
									rx = x - modx - bx
									ry = y - mody - by
									If tilename <> "back" And tilename <> "ladder" And checkpixel = True Then
										DrawTile(tl, mapTile, rx + leftoffset, ry + topoffset)
									Elseif checkpixel = False Then
										DrawTile(tl, mapTile, rx + leftoffset, ry + topoffset)
									Endif								
								End
							End
							x += tileWidth
							mx += 1
						End
						y += tileHeight
						my += 1
					End

				' iso
				Elseif orientation = MAP_ORIENTATION_ISOMETRIC Then
					' TODO: wrapping
					For y = 0 Until tl.width + tl.height
						ry = y
						rx = 0
						While ry >= tl.height
							ry -= 1
							rx += 1
						Wend
						While ry >= 0 And rx < tl.width
							gid = tl.mapData.cells[rx + ry*tl.mapData.width].gid
							If gid > 0 Then
								mapTile = tiles[gid - 1]
								DrawTile(tl, mapTile, (rx - ry - 1) * tileWidth / 2 - bx, (rx + ry + 2) * tileHeight / 2 - mapTile.height - by)
							Endif
							ry -= 1
							rx += 1
						End
					Next
				End
				PostRenderLayer(layer)
			End
		Next
		PostRenderMap()
	End

        Method ConfigureLayer:Void(tileLayer:TileMapLayer)
                SetAlpha(tileLayer.opacity)
        End
        
        Method DrawTile:Void(tileLayer:TileMapTileLayer, mapTile:TileMapTile, x:Int, y:Int)
                mapTile.image.DrawTile(x, y, mapTile.id, 0, 1, 1)
        End
	
	
		Method CheckFalling:Bool(x:Int,y:Int)
		Self.py = (y + 1) / 32	'check for tile under the feets ;o)
		Self.px = (x + 32) / 32
		Self.pc = Self.py * 126 + Self.px 'plus offset center of bottom
		'Self.layer = Self.layers.GetFirst()
		'Self.tl = TileMapTileLayer(layer)
		Local lgid:Int = Self.tl.mapData.cells[Self.pc].gid - 1
			
		If lgid < 0 Then 
			Return True
		Else
			Self.tile = Self.tiles[ Self.tl.mapData.cells[Self.pc].gid - 1 ]
			Self.tileproperties = tile.Properties()
			Local tilename:String = Self.tileproperties.Get(Self.tilekeyname).GetString()
			'If tilename = "back" Then
			If tilename <> "ground" And tilename <> "wall" And tilename <> "ladder" And tilename <> "ramp"  Then 
				Return True
			Endif
		Endif
		
		Return False
	End Method
	
	
	
	Method CheckCurrentTiles:Void(x:Int,y:Int)
		Local gid:Int
	
		'check for tile standing in front of
		Self.py = y / 32
		Self.px = (x + 32) / 32
		Self.pc = Self.py * 126 + Self.px 'plus offset center of bottom
		'Self.layer = Self.layers.GetFirst()
		'Self.tl = TileMapTileLayer(layer)
		gid = Self.tl.mapData.cells[Self.pc].gid - 1
		If gid < 0 Then
			Self.tilenamebehind = ""
		Else
			Self.tile = Self.tiles[ Self.tl.mapData.cells[Self.pc].gid - 1 ]
			Self.tileproperties = tile.Properties()
			Self.tilenamebehind = Self.tileproperties.Get(Self.tilekeyname).GetString()
		Endif
		
		'check for tile standing on top
		Self.py = (y + 1) / 32
		Self.px = (x + 32) / 32
		Self.pc = Self.py * 126 + Self.px 'plus offset center of bottom
		gid = Self.tl.mapData.cells[Self.pc].gid - 1
		If gid < 0 Then
			Self.tilenamebottom = ""
		Else
			Self.tile = Self.tiles[ Self.tl.mapData.cells[Self.pc].gid - 1 ]
			Self.tileproperties = tile.Properties()
			Self.tilenamebottom = Self.tileproperties.Get(Self.tilekeyname).GetString()
		Endif		
	End Method
	
	
	

	Method CheckCollisionTop:Bool(x:Int,y:Int)
		'reference point top middle
		'Self.py = (y-64) / 32
		Self.py = (y - 50) / 32
		Self.px = (x + 32) / 32
		Self.pc = Self.py * 126 + Self.px 'plus offset center of bottom
		Return Self.CheckHitOfReferencePoint()
	End Method
	
	
	Method CheckCollisionBottom:Bool(x:Int,y:Int)
		'reference point bottom left
		Self.py = y / 32
		Self.px = (x + 32) / 32
		Self.pc = Self.py * 126 + Self.px 'plus offset center of bottom
		Return Self.CheckHitOfReferencePoint()
	End Method
	
	
	Method CheckCollisionLeft:Bool(x:Int,y:Int)
		'reference point bottom left
		Self.py = y / 32
		Self.px = (x + 12) / 32
		Self.pc = Self.py * 126 + Self.px 'plus plus offset center of bottom
		If Self.CheckHitOfReferencePoint() Then
			Return True
		End If
		'reference point top left
		Self.py = (y - 30) / 32
		Self.px = (x + 8) / 32
		Self.pc = Self.py * 126 + Self.px 'plus plus offset center of bottom
		If Self.CheckHitOfReferencePoint() Then
			Return True
		End If
		Return False
	End Method
	Method CheckCollisionRight:Bool(x:Int,y:Int)
		'reference point bottom right
		Self.py = y / 32
		Self.px = (x + 52) / 32
		Self.pc = Self.py * 126 + Self.px 'plus plus offset center of bottom
		If Self.CheckHitOfReferencePoint() Then
			Return True
		End If
		'reference point top right
		Self.py = (y - 30) / 32
		Self.px = (x + 56) / 32
		Self.pc = Self.py * 126 + Self.px 'plus plus offset center of bottom
		If Self.CheckHitOfReferencePoint() Then
			Return True
		End If
		Return False
	End Method
	
	'get layer for collision checking
	Method CheckHitInit:Void()
		Self.layer = Self.layers.GetFirst()
		Self.tl = TileMapTileLayer(layer)
	End Method 
	
	'do the check ;o)
	Method CheckHitOfReferencePoint:Bool()
		Local lgid:Int = Self.tl.mapData.cells[Self.pc].gid - 1
		If lgid >= 0 Then 
			Self.tile = Self.tiles[ Self.tl.mapData.cells[Self.pc].gid - 1 ]
			Self.tileproperties = tile.Properties()
			Local tilename:String = Self.tileproperties.Get(Self.tilekeyname).GetString()
			If tilename <> "ground" And tilename <> "wall" Then
				Return False
			End If
			Return True
		Endif
		Return False
	End	

End


'check tiles around the player sprite
Class TilePlayerStatus
	Field top:Bool
	Field right:Bool
	Field bottom:Bool
	Field left:Bool
	Field middle:Bool
End Class



' ############## extend some diddy tile stuff #############

Class MyTiledTileMapReader Extends TiledTileMapReader
        Method CreateMap:TileMap()
                Return New CustomTileMap
        End
End