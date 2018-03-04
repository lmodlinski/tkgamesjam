package level;

import flash.media.SoundTransform;
import flash.media.SoundChannel;
import openfl.Assets;
import thoughts.Thought;
import thoughts.ThoughtBubbleView;
import motion.Actuate;
import characters.talks.SmalltalkView;
import openfl.display.Sprite;
import room.RoomField;
import characters.Npc;
import characters.NpcFactory;
import level.LevelResult;
import openfl.Vector;
import room.Room;
import characters.Player;

class Level extends Sprite {
    private static inline var ROOM_X:Float = 391.0;
    private static inline var ROOM_Y:Float = 166.0;

    private static inline var THOUGHTS_X:Float = 950.0;
    private static inline var THOUGHTS_Y:Float = 130.0;

    private static inline var SMALLTALK_X:Float = 14.0;
    private static inline var SMALLTALK_Y:Float = 128.0;

    private var asset(null, null):LevelAsset;
    private var smalltalk(null, null):SmalltalkView;

    public var player(default, null):Player;
    public var room(default, null):Room;

    public var npc_factory(default, null):NpcFactory;

    public var thoughts(default, null):ThoughtBubbleView;

    public var floor(default, null):Floor;
    public var floor_moving_time(default, set):Float;
    public var floor_stop_time(default, set):Float;
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

    public var sound_loop(default, null):SoundChannel;
    public var sound_doors(default, null):SoundChannel;

    public function new(floors:Vector<Floor>, shame_limit:Float, fart_limit:Float) {
        super();

        this.addChild(this.asset = new LevelAsset());
        this.asset.label_floor.defaultTextFormat = Main.format;
        this.asset.label_fart_level.defaultTextFormat = Main.format;
        this.asset.label_shame_level.defaultTextFormat = Main.format;

        this.addChild(this.smalltalk = new SmalltalkView());
        this.smalltalk.x = SMALLTALK_X;
        this.smalltalk.y = SMALLTALK_Y;

        this.addChild(this.thoughts = new ThoughtBubbleView());
        this.thoughts.x = THOUGHTS_X;
        this.thoughts.y = THOUGHTS_Y;

        this.floors = floors;

        this.npc_factory = new NpcFactory();

        this.shame_limit = shame_limit;
        this.fart_limit = fart_limit;

        this.result = LevelResult.IDLE;
    }

    public function start():Void {
        if (null != this.player && null != this.room && this.floor_next_available) {
            this.nextFloor();

            this.result = LevelResult.ONGOING;

            this.sound_loop = Assets.getSound('assets/Sounds/bg_music.mp3').play(0.0, 0, new SoundTransform(0.4));
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

                if (null != this.sound_loop) {
                    this.sound_loop.stop();
                    this.sound_loop = null;
                }
            } else {
                var seconds:Float = delta / 1000.0;

                if (this.floor_moving_time < this.floor.moving_time) {
                    this.floor_moving_time += seconds;
                } else if (this.floor_stop_time < this.floor.stop_time) {
                    if (null == this.sound_doors) {
                        this.sound_doors = Assets.getSound('assets/Sounds/door_sound.mp3').play(0.0, 1);
                    }

                    this.floor_stop_time += seconds;
                } else if (this.floor_next_available) {
                    this.floor_moving_time = 0.0;
                    this.floor_stop_time = 0.0;

                    this.nextFloor();
                } else {
                    this.result = LevelResult.FINISHED_WON;

                    if (null != this.sound_loop) {
                        this.sound_loop.stop();
                        this.sound_loop = null;
                    }
                }

                if (this.smalltalk.visible = (this.player.smalltalk_ongoing)) {
                    this.smalltalk.show(this.player.smalltalk_with.smalltalk);
                } else {
                    this.smalltalk.dismiss();
                }

                this.asset.label_fart_level.text = Std.string(this.fart_limit_percentage) + '%';
                this.asset.label_shame_level.text = Std.string(this.shame_limit_percentage) + '%';

                this.manageProgress();
                this.manageSkills();

                this.room.onEnterFrame(delta);
            }
        }
    }

    private function manageProgress():Void {
        this.asset.progress_shame.scaleX = this.player.shame_level / this.shame_limit;
        this.asset.progress_tension.scaleX = this.player.fart_level / this.fart_limit;
        this.asset.progress_floor.scaleX = this.floor_moving_time / this.floor.moving_time;
    }

    private function manageSkills():Void {
        if (this.asset.button_ventilator.icon_shadow.visible = this.asset.button_ventilator.label_cooldown.visible = (0.0 < this.room.ventilating_cooldown)) {
            this.asset.button_ventilator.label_cooldown.defaultTextFormat = Main.format;
            this.asset.button_ventilator.label_cooldown.text = Std.int(Math.ceil(this.room.ventilating_cooldown));
        }

        if (this.asset.button_smalltalk.icon_shadow.visible = this.asset.button_smalltalk.label_cooldown.visible = (0.0 < this.player.smalltalk_cooldown)) {
            this.asset.button_smalltalk.label_cooldown.defaultTextFormat = Main.format;
            this.asset.button_smalltalk.label_cooldown.text = Std.int(Math.ceil(this.player.smalltalk_cooldown));
        }

        this.asset.button_fart.icon_shadow.visible = this.player.field.full;
    }

    public function answer(answer_no:Int):Void {
        if (this.player.smalltalk_ongoing) {
            if (this.player.answer(this.player.smalltalk_with.smalltalk.answers.get(answer_no))) {
                this.player.shame_level -= this.player.smalltalk_with.smalltalk.shame_decr;
            }
        }
    }

    public function nextFloor():Void {
        if (this.floor_next_available) {
            var leavers:Vector<Npc> = new Vector<Npc>();

            for (npc in this.room.npcs) {
                if (!npc.leaving_next_floor) {
                    for (i in 0 ... npc.driff()) {
                        var empty_fields:Vector<RoomField> = this.room.getEmptyAround(npc.field);

                        if (0 < empty_fields.length) {
                            this.room.step(npc, empty_fields.get(Std.int(Math.random() * empty_fields.length)));
                        }
                    }
                } else {
                    leavers.push(npc);
                }
            }

            while (0 < leavers.length) {
                this.room.leave(leavers.pop());
            }

            this.floor = this.floors.splice(0, 1).get(0);
            this.asset.label_floor.text = Std.string(this.floor.id);

            var npc_factory:NpcFactory = new NpcFactory();
            for (npc_type in this.floor.npcs) {
                var empty_fields:Vector<RoomField> = this.room.getEmptyAround(this.room.entrance);
                if (0 < empty_fields.length) {
                    var npc:Npc = this.npc_factory.createNpc(npc_type);

                    this.room.add(npc, empty_fields.get(Std.int(Math.random() * empty_fields.length)));
                }
            }
        }

        if (null != this.sound_doors) {
            this.sound_doors.stop();
            this.sound_doors = null;
        }

        this.thoughts.push(new Thought(this.room.getRandomNpc().type));
        this.thoughts.invalidate(this.room.npcs);
        this.thoughts.revalidate();
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

    public function set_floor_moving_time(value:Float):Float {
        if (this.floor.moving_time <= value) {
            this.floor_moving_time = this.floor.moving_time;

            Actuate.tween(this.asset.door_left, 2.0, {x: 349});
            Actuate.tween(this.asset.door_right, 2.0, {x: 741});
        } else {
            this.floor_moving_time = value;
        }

        return this.floor_moving_time;
    }

    public function set_floor_stop_time(value:Float):Float {
        if (this.floor.stop_time <= value) {
            this.floor_stop_time = this.floor.stop_time;

            Actuate.tween(this.asset.door_left, 2.0, {x: 449});
            Actuate.tween(this.asset.door_right, 2.0, {x: 641});
        } else {
            this.floor_stop_time = value;
        }

        return this.floor_stop_time;
    }

}
