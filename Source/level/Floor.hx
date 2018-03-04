package level;

import openfl.Vector;
import characters.NpcType;
class Floor {
    public var id(default, null):Int;

    public var moving_time(default, null):Float;
    public var stop_time(default, null):Float;

    public var npcs(default, null):Vector<NpcType>;

    public function new(id:Int, moving_time:Float, stop_time:Float, npcs:Vector<NpcType>) {
        this.id = id;

        this.moving_time = moving_time;
        this.stop_time = stop_time;

        this.npcs = npcs;
    }
}
