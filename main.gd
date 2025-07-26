@tool
class_name GameSceneTree
extends SceneTree


func find_child_of_type(type : String, node : Node = current_scene):
	return _find_child(node, "*", type, true, false)


static func _find_child(node : Node, pattern : String, type : String = "", recursive : bool = true, owned : bool = true) -> Node:
	if node != null:
		for i in node.get_child_count():
			var child := node.get_child(i)
			if  child.name.match(pattern) and \
				(type.is_empty() or _is_game_class(child, type)) and \
				(not owned or child.owner):
					return child

			if recursive:
				var found := _find_child(child, pattern, type, recursive, owned)
				if found:
					return found

	return null


static func _find_ancestor(node : Node, pattern : String, type : String = "") -> Node:
	while node:
		if  node.name.match(pattern) and \
			(type.is_empty() or _is_game_class(node, type)):
				break

		node = node.get_parent()

	return node


static func _is_game_class(node : Node, type : String) -> bool:
	if node.has_method("is_game_class"):
		if node.is_game_class(type):
			return true

	return node.is_class(type)
