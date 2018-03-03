package room;

import openfl.Vector;
import haxe.ds.StringMap;
import haxe.ds.IntMap;

import characters.Npc;
import characters.Player;
import characters.AbstractCharacter;

import openfl.display.Sprite;

class Room extends Sprite {
    public static inline var VENTILATING_COOLDOWN:Float = 30.0;
    public static inline var VENTILATING_DURATION:Float = 3.0;
    public static inline var VENTILATING_DECR:Float = 0.2;

    public var ventilating(default, set):Float;
    public var ventilating_cooldown(default, set):Float;

    public var ventilating_on(get, never):Bool;
    public var ventilating_decr(get, never):Float;

    public var fields(default, null):IntMap<IntMap<RoomField>>;
    public var fields_width(default, null):Int;
    public var fields_height(default, null):Int;

    public var player(default, null):Player;
    public var npcs(default, null):Vector<Npc>;

    public function new(width:Int, height:Int) {
        super();

        this.ventilating = 0.0;
        this.ventilating_cooldown = 0.0;

        this.fields_width = width;
        this.fields_height = height;

        this.npcs = new Vector<Npc>();

        this.fields = new IntMap<IntMap<RoomField>>();

        for (i in 0 ... (this.fields_height = height)) {
            var fields_row:IntMap<RoomField> = new IntMap<RoomField>();

            for (j in 0 ... (this.fields_width = width)) {
                fields_row.set(j, new RoomField(this, i, j));
            }

            this.fields.set(i, fields_row);
        }
    }

    public function onEnterFrame(delta:Int):Void {
        for (i in 0 ... this.fields_width) {
            for (j in 0 ... this.fields_height) {
                var field:RoomField = this.fields.get(i).get(j);

                if (null != field.occupied) {
                    if (Std.is(field.occupied, Npc)) {
                        var npc:Npc = cast(field.occupied, Npc);

                        if (npc.accusing) {
                            this.player.accuse(npc.accusation);
                        }
                    }
                }

                field.onEnterFrame(delta);
            }
        }

        var seconds:Float = delta / 1000.0;

        if (0 < this.ventilating) {
            this.ventilating -= seconds;
        } else {
            this.ventilating_cooldown -= seconds;
        }
    }

    public function add(character:AbstractCharacter, x:Int, y:Int):Void {
        if (Std.is(character, Player)) {
            this.player = cast(character, Player);
        } else if (Std.is(character, Npc)) {
            this.npcs.push(cast(character, Npc));
        }

        var field:RoomField = this.fields.get(x).get(y);
        field.occupy(character);
    }

    public function move(character:AbstractCharacter, direction:Direction):Void {
        var field:RoomField = character.field;
        var target:RoomField = null;

        var target_x:Int = field.field_x;
        var target_y:Int = field.field_y;

        var changed:Bool = false;

        switch(direction){
            case Direction.DOWN:
                if (changed = (this.fields_height - 1 > target_y)) {
                    target_y++;
                }
            case Direction.UP:
                if (changed = (0 < target_y)) {
                    target_y--;
                }
            case Direction.LEFT:
                if (changed = (0 < target_x)) {
                    target_x--;
                }
            case Direction.RIGHT:
                if (changed = (this.fields_width - 1 > target_x)) {
                    target_x++;
                }
        }

        target = this.fields.get(target_x).get(target_y);

        if (changed && null == target.occupied) {
            field.free();
            target.occupy(character);
        }
    }

    public function ventilate():Void {
        if (0 >= this.ventilating && 0 >= this.ventilating_cooldown) {
            this.ventilating = VENTILATING_DURATION;
            this.ventilating_cooldown = VENTILATING_COOLDOWN;
        }
    }

    public function get_ventilating_on():Bool {
        return 0 < this.ventilating;
    }

    public function get_ventilating_decr():Float {
        return VENTILATING_DECR;
    }

    public function set_ventilating(value:Float):Float {
        if (0.0 > value) {
            this.ventilating = 0.0;
        } else {
            this.ventilating = value;
        }

        return this.ventilating;
    }

    public function set_ventilating_cooldown(value:Float):Float {
        if (0.0 > value) {
            this.ventilating_cooldown = 0.0;
        } else {
            this.ventilating_cooldown = value;
        }

        return this.ventilating_cooldown;
    }
}
