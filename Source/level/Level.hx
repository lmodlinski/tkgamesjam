package level;

import characters.talks.SmalltalkView;
import openfl.display.Sprite;
import characters.NpcType;
import room.RoomField;
import characters.Npc;
import characters.NpcFactory;
import level.LevelResult;
import openfl.Vector;
import room.Room;
import characters.Player;

class Level extends Sprite {
    private static inline var ROOM_X:Float = 389.0;
    private static inline var ROOM_Y:Float = 164.0;

    private static inline var SMALLTALK_X:Float = 20.0;
    private static inline var SMALLTALK_Y:Float = 125.0;

    private var asset(null, null):LevelAsset;
    private var smalltalk(null, null):SmalltalkView;

    public var player(default, null):Player;
    public var room(default, null):Room;

    public var floor(default, null):Floor;
    public var floor_moving_time(default, null):Float;
    public var floor_stop_time(default, null):Float;
    public var floor_next_available(get, never):Bool;

    public var shame_limit(default, null):Float;
    public var shame_limit_percentage(get, never):Int;
    public var shamed(get, never):Bool;

    public var fart_limit(default, null):Float;
    public var fart_limit_percentage(get, never):Int;
    public var farted(get, never):Bool;

    public var is_moving(get, never):Bool;
    public var has_stopped(get, never):Bool;

    public var floors(default, null):Vector<Floor>;

    public var result(default, null):LevelResult;

    public function new(floors:Vector<Floor>, shame_limit:Float, fart_limit:Float) {
        super();

        this.addChild(this.asset = new LevelAsset());

        this.addChild(this.smalltalk = new SmalltalkView());
        this.smalltalk.x = SMALLTALK_X;
        this.smalltalk.y = SMALLTALK_Y;

        this.floors = floors;

        this.shame_limit = shame_limit;
        this.fart_limit = fart_limit;

        this.result = LevelResult.IDLE;
    }

    public function start():Void {
        if (null != this.player && null != this.room && this.floor_next_available) {
            this.nextFloor();

            this.result = LevelResult.ONGOING;
        }
    }

    public function addPlayer(player:Player, field_x:Int, field_y:Int):Void {
        this.player = player;

        this.room.add(this.player, this.room.fields.get(field_x).get(field_y));
    }

    public function addRoom(room:Room):Void {
        this.addChild(this.room = room);
        this.room.x = ROOM_X;
        this.room.y = ROOM_Y;
    }

    public function onEnterFrame(delta:Int):Void {
        if (LevelResult.ONGOING == this.result) {
            if (this.shamed || this.farted) {
                this.result = LevelResult.FINISHED_LOST;
            } else {
                var seconds:Float = delta / 1000.0;

                if (this.floor_moving_time < this.floor.moving_time) {
                    this.floor_moving_time += seconds;
                } else if (this.floor_stop_time < this.floor.stop_time) {
                    this.floor_stop_time += seconds;
                } else if (this.floor_next_available) {
                    this.floor_moving_time = 0.0;
                    this.floor_stop_time = 0.0;

                    this.nextFloor();
                } else {
                    this.result = LevelResult.FINISHED_WON;
                }

                if (this.smalltalk.visible = (this.player.smalltalk_ongoing)) {
                    this.smalltalk.show(this.player.smalltalk_with.smalltalk);
                } else {
                    this.smalltalk.dismiss();
                }

                this.asset.label_floor.text = Std.string(this.floor.id);
                this.asset.label_floor_moving.text = Std.string(this.floor_moving_time);
                this.asset.label_floor_stop.text = Std.string(this.floor_stop_time);

                this.asset.label_fart_level.text = Std.string(this.fart_limit_percentage) + '%';
                this.asset.label_shame_level.text = Std.string(this.shame_limit_percentage) + '%';

                this.room.onEnterFrame(delta);
            }
        }
    }

    public function nextFloor():Void {
        if (this.floor_next_available) {
            for (npc in this.room.npcs) {
                if (npc.leaving_next_floor) {
                    this.room.leave(npc);
                } else {
                    for (i in 0 ... npc.driff()) {
                        var empty_fields:Vector<RoomField> = this.room.getEmptyAround(npc.field);

                        if (0 < empty_fields.length) {
                            this.room.step(npc, empty_fields.get(Std.int(Math.random() * empty_fields.length)));
                        }
                    }
                }
            }

            this.floor = this.floors.splice(0, 1).get(0);

            var npc_factory:NpcFactory = new NpcFactory();
            for (i in 0 ... this.floor.randomize()) {
                var empty_fields:Vector<RoomField> = this.room.getEmptyAround(this.room.entrance);
                if (0 < empty_fields.length) {
                    var npc:Npc = npc_factory.createNpc(NpcType.BOSS);

                    this.room.add(npc, empty_fields.get(Std.int(Math.random() * empty_fields.length)));
                }
            }
        }
    }

    public function get_floor_next_available():Bool {
        return 0 < this.floors.length;
    }

    public function get_is_moving():Bool {
        return 0 >= this.floor_stop_time && 0 < this.floor_moving_time;
    }

    public function get_has_stopped():Bool {
        return 0 < this.floor_stop_time;
    }

    public function get_shame_limit_percentage():Int {
        return Std.int((this.player.shame_level / this.shame_limit) * 100.0);
    }

    public function get_fart_limit_percentage():Int {
        return Std.int((this.player.fart_level / this.fart_limit) * 100.0);
    }

    public function get_shamed():Bool {
        return this.player.shame_level >= this.shame_limit;
    }

    public function get_farted():Bool {
        return this.player.fart_level >= this.fart_limit;
    }
}
