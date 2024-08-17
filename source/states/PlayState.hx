package states;

import flixel.math.FlxPoint;
import entities.Reticle;
import entities.Item;
import flixel.util.FlxColor;
import debug.DebugLayers;
import achievements.Achievements;
import flixel.addons.transition.FlxTransitionableState;
import signals.Lifecycle;
import entities.Player;
import flixel.FlxSprite;
import flixel.FlxG;
import bitdecay.flixel.debug.DebugDraw;
import echo.FlxEcho;

using states.FlxStateExt;

class PlayState extends FlxTransitionableState {
	var player:FlxSprite;
	var reticle:FlxSprite;

	override public function create() {
		super.create();
		Lifecycle.startup.dispatch();

		FlxG.camera.pixelPerfectRender = true;

		FlxEcho.init({
			// TODO: This needs to be the size of the world as we load it from LDTK (or whatever we use)
			width: FlxG.width,
			height: FlxG.height,
		});

		player = new Player();
		add(player);

		// We want the reticle to likely live on the UI camera for ease of tracking the mouse?
		// Or do we just want to project the mouse position into the game world cam?
		reticle = new Reticle();
		add(reticle);
		
		// add(Achievements.ACHIEVEMENT_NAME_HERE.toToast(true, true));

		// QuickLog.error('Example error');
	}
	
	var tmp = FlxPoint.get();
	var tmp2 = FlxPoint.get();

	override public function update(elapsed:Float) {
		super.update(elapsed);

		// var cam = FlxG.camera;
		// DebugDraw.ME.drawCameraRect(cam.getCenterPoint().x - 5, cam.getCenterPoint().y - 5, 10, 10, DebugLayers.RAYCAST, FlxColor.RED);

		reticle.getPosition(tmp);
		player.getPosition(tmp2);
		
		tmp.addPoint(tmp2).scale(.5);
		camera.focusOn(tmp);
	}

	override public function onFocusLost() {
		super.onFocusLost();
		this.handleFocusLost();
	}

	override public function onFocus() {
		super.onFocus();
		this.handleFocus();
	}
}
