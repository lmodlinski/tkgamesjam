package level;

class Floor {
    public var id(default, null):Int;

    public var moving_time(default, null):Float;
    public var stop_time(default, null):Float;

    public var npc_min(default, null):Int;
    public var npc_max(default, null):Int;

    public function new(id:Int, moving_time:Float, stop_time:Float, npc_min:Int, npc_max:Int) {
        this.id = id;

        this.moving_time = moving_time;
        this.stop_time = stop_time;

        this.npc_min = npc_min;
        this.npc_max = npc_max;
    }

    public function randomize():Int {
        return this.npc_min + Std.int(Math.random() * (this.npc_max - this.npc_min));
    }
}
