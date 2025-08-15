extends CanvasLayer

@onready var fade_rect = $Blackout
@onready var anim = $AnimationPlayer

func _ready():
  anim.play("fade_in")

func change_scene(scene_path: String):
  anim.play("fade_out")
  await anim.animation_finished

  get_tree().change_scene_to_file(scene_path)

  anim.play("fade_in")
