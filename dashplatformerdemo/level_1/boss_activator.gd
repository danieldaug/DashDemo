extends Area2D

@export var squid_boss: SquidBoss

func _on_body_entered(body):
    if body is Player:
        squid_boss.call_deferred("set_process_mode", Node.PROCESS_MODE_INHERIT)
