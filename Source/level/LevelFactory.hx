package level;

import characters.NpcType;
import haxe.Json;
import openfl.Assets;
import openfl.Vector;
class LevelFactory {
    public function new() {
    }

    public function createLevel(json_path:String = 'assets/levels/test_level2.json'):Level {
        var floors:Vector<Floor> = new Vector<Floor>();
        var json = Json.parse(Assets.getText(json_path));

        for (floor_raw in cast(json.floors, Array<Dynamic>)) {
            var npcs:Vector<NpcType> = new Vector<NpcType>();

            for (npc_type_raw in cast(floor_raw.npcs, Array<Dynamic>)) {
                npcs.push(Type.createEnum(NpcType, npc_type_raw));
            }

            floors.push(new Floor(floor_raw.id, floor_raw.moving_time, floor_raw.stop_time, npcs));
        }

        return new Level(floors, json.shame_limit, json.fart_limit);
    }
}
