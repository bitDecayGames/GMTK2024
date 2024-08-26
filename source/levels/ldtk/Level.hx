package levels.ldtk;

import entities.SimpleEnemy;
import entities.TrashCan;
import entities.Unibody;
import entities.ScrapCollector;
import entities.GroundFire;
import entities.Scrap;
import entities.PracticeTarget;
import entities.Tink;
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

	public var tinks:Array<Tink> = [];
	public var doors:Array<DoorTop> = [];
	public var doorsBottom:Array<DoorBottom> = [];

	public var targets:Array<PracticeTarget> = [];
	public var simpleEnemies:Array<SimpleEnemy> = [];
	public var hazards:Array<GroundFire> = [];

	public var scrap:Array<Scrap> = [];
	public var collectors:Array<ScrapCollector> = [];

	public var rawTerrainLayer:levels.ldtk.LDTKProject.Layer_Ground;
	public var rawTerrainTopLayer:levels.ldtk.LDTKProject.Layer_Top;
	public var rawWallsLayer:levels.ldtk.LDTKProject.Layer_Collision;

	public var enemies:Array<Unibody> = [];

	public var playerSpawnPoint:FlxPoint;

	public function new(nameOrIID:String) {
		var level = project.all_worlds.Default.getLevel(nameOrIID);
		raw = level;

		var rawSpawnPoint = level.l_Entities.all_PlayerSpawn[0];
		playerSpawnPoint = FlxPoint.get(rawSpawnPoint.pixelX, rawSpawnPoint.pixelY);

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
			var doorTop = new DoorTop(d.iid, d.pixelX, d.pixelY+3, d.f_DoorName);
			var bottom = new DoorBottom(d.iid, d.pixelX, d.pixelY+15, d.f_DoorName);
			doorTop.bottom = bottom;
			doors.push(doorTop);
			doorsBottom.push(bottom);

			if (d.f_startOpen) {
				doorTop.open(true);
			}
		}

		for (s in level.l_Entities.all_RecepticalSpawn) {
			collectors.push(new ScrapCollector(s.pixelX, s.pixelY, s.f_ScrapToActivate, s.iid));
		}

		for (tcSpawn in level.l_Entities.all_TrashCanSpawn) {
			var trigger = FlxPoint.get(tcSpawn.f_xTrigger.cx * 16, tcSpawn.f_xTrigger.cy * 16);
			var trash = new TrashCan(tcSpawn.iid, tcSpawn.pixelX, tcSpawn.pixelY, trigger);
			trash.shutDoorTop = doors.filter((d) -> {d.iid == tcSpawn.f_shutDoor.entityIid;})[0];
			// trash.openDoorTop = doors.filter((d) -> {d.iid == tcSpawn.f_openDoor.entityIid;})[0];
			enemies.push(trash);
		}
		
		if (level.l_Entities.all_TinkSpawn.length > 0) {
			for (tinkSpawn in level.l_Entities.all_TinkSpawn) {
				var top:DoorTop = null;
				var bottom:DoorBottom = null;
				var collector:ScrapCollector = null;
				if (tinkSpawn.f_door != null) {
					top = doors.filter((d) -> {return d.iid == tinkSpawn.f_door.entityIid;})[0];
					bottom = doorsBottom.filter((d) -> {return d.iid == tinkSpawn.f_door.entityIid;})[0];
				}
				if (tinkSpawn.f_Collector != null) {
					collector = collectors.filter((d) -> {return d.id == tinkSpawn.f_Collector.entityIid;})[0];
				}
				
				var tink = new Tink(tinkSpawn.pixelX, tinkSpawn.pixelY, tinkSpawn.f_TinkSpawnName, top, bottom, tinkSpawn.f_ActivationRadius, collector);
				if (tinkSpawn.f_Boss != null) {
					var bossMatches:Array<Unibody> = enemies.filter((e) -> e.iid == tinkSpawn.f_Boss.entityIid);
					for (b in bossMatches) {
						tink.readyTriggers.push(b);
					}
				}
				
				tinks.push(tink);
			}
		}

		for (t in level.l_Entities.all_PracticeTarget) {
			var target = new PracticeTarget(t.pixelX, t.pixelY);
			targets.push(target);
		}

		for (t in level.l_Entities.all_SimpleEnemy) {
			var simpleEnemy = new SimpleEnemy(t.pixelX, t.pixelY);
			simpleEnemies.push(simpleEnemy);
		}

		for (t in level.l_Entities.all_Fire) {
			var fire = new GroundFire(t.pixelX+8, t.pixelY);
			hazards.push(fire);
		}

		for (s in level.l_Entities.all_ScrapSpawn) {
			scrap.push(new Scrap(s.pixelX, s.pixelY, 0));
		}

		rawTerrainTopLayer = level.l_Top;
		terrainTopGfx = rawTerrainTopLayer.render();

		// TODO: handle all this crap
		// level.l_Entities.all_Recepticle
		// level.l_Entities.all_Door
		// level.l_Entities.all_TinkShop

	}
}