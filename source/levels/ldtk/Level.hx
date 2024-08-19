package levels.ldtk;

import js.html.Console;
import entities.DoorBottom;
import entities.DoorTop;
import flixel.FlxBasic;
import flixel.group.FlxGroup;
import ldtk.Project;
import states.PlayState;
import bitdecay.flixel.spacial.Cardinal;
import flixel.math.FlxRect;
import entities.Player;
import flixel.effects.particles.FlxEmitter;
import flixel.FlxObject;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxPoint;
import flixel.group.FlxSpriteGroup;

class Level {
	// private static inline var WORLD_ID = "ded66c41-3b70-11ee-9c97-27b856925a1e";
	public static var project = new LDTKProject();

	public var raw:LDTKProject.LDTKProject_Level;
	
	public var bounds = FlxRect.get();
	public var terrainGfx = new FlxSpriteGroup();
	public var terrainTopGfx = new FlxSpriteGroup();
	public var terrainDecorGfx = new FlxSpriteGroup();
	public var rawCollisionInts = new Array<Int>();
	public var rawTerrainTilesWide = 0;
	public var rawTerrainTilesTall = 0;

	public var doors:Array<DoorTop> = [];
	public var doorsBottom:Array<DoorBottom> = [];

	public var rawTerrainLayer:levels.ldtk.LDTKProject.Layer_Ground;
	public var rawTerrainTopLayer:levels.ldtk.LDTKProject.Layer_Top;
	public var rawWallsLayer:levels.ldtk.LDTKProject.Layer_Collision;

	public var playerSpawnPoint:FlxPoint;
	public var tinkSpawnPoint:FlxPoint;

	public function new(nameOrIID:String) {
		var level = project.all_worlds.Default.getLevel(nameOrIID);
		raw = level;

		var rawSpawnPoint = level.l_Entities.all_PlayerSpawn[0];
		playerSpawnPoint = FlxPoint.get(rawSpawnPoint.pixelX, rawSpawnPoint.pixelY);

		if (level.l_Entities.all_TinkSpawn.length > 0) {
			var tinkRawSpawnPoint = level.l_Entities.all_TinkSpawn[0];
			tinkSpawnPoint = FlxPoint.get(tinkRawSpawnPoint.pixelX, tinkRawSpawnPoint.pixelY);
		}

		bounds.width = level.pxWid;
		bounds.height = level.pxHei;

		rawTerrainLayer = level.l_Ground;
		terrainGfx = rawTerrainLayer.render();

		rawWallsLayer = level.l_Collision;

		rawCollisionInts = new Array<Int>();
		rawTerrainTilesWide = rawTerrainLayer.cWid;
		rawTerrainTilesTall = rawTerrainLayer.cHei;
		for (ch in 0...rawWallsLayer.cHei) {
			for (cw in 0...rawWallsLayer.cWid) {
				if (rawWallsLayer.hasAnyTileAt(cw, ch)) {
					var tileStack = rawWallsLayer.getTileStackAt(cw, ch);
					rawCollisionInts.push(tileStack[0].tileId);
				} else {
					rawCollisionInts.push(-1);
				}
			}
		}

		for (d in level.l_Entities.all_Door) {
			doors.push(new DoorTop(d.pixelX, d.pixelY+3, d.f_DoorName));
			doorsBottom.push(new DoorBottom(d.pixelX, d.pixelY+15, d.f_DoorName));
		}
		
		rawTerrainTopLayer = level.l_Top;
		terrainTopGfx = rawTerrainTopLayer.render();

		// TODO: handle all this crap
		// level.l_Entities.all_Recepticle
		// level.l_Entities.all_Door
		// level.l_Entities.all_TinkShop

	}
}