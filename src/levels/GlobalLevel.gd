extends Node

var level_root: Node3D
const TARGET_GROUPS = {
	"Enemy": ["player"],
	"Ally": ["mobs"],
	"Passive": [],
	"Neutral": ["player", "mobs"]
}
