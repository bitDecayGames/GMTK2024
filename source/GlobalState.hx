package;

import states.PlayState;
import entities.Player.GunHas;

class GlobalStateConfig {
    public var gunHas:GunHas;
    public var scrapCount:Int;

    public function new() {}
}

class GlobalState {
    public static function SetGameState(config:GlobalStateConfig) {
        if (config.gunHas != null) {
            PlayState.me.player.setGun(config.gunHas);
        }
        if (config.scrapCount != 0){
            PlayState.me.player.scrapCount = config.scrapCount;
        }
    }

    public static function SetGameStateByLevelName(levelName:String) {
        var globalStateConfig = new GlobalStateConfig();
        if (levelName == "Level_2") {
            globalStateConfig.gunHas = PISTOL;
            globalStateConfig.scrapCount = 5;
            PlayState.me.level.getTinkBySpawnPoint("Adds").dialogIndex = 1;
        }

        SetGameState(globalStateConfig);
    }
}


