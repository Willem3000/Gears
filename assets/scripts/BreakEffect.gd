extends Node2D

func _ready() -> void:
	$AudioStreamPlayer2D.pitch_scale = randf_range(0.8, 1.2)
	$GPUParticles2D.emitting = true


func _on_gpu_particles_2d_finished() -> void:
	queue_free()
