class_name MutationStateComponent
extends Node

enum Mutations {NONE, HIGH_JUMP, FAST_LEGS, LONG_NECK, STRONG_SHELL}

@onready var current_mutation: Mutations = Mutations.NONE

func changeMutationState(newState: Mutations) -> void:
	if not newState:
		return;
	current_mutation = newState
