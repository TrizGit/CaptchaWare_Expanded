extends Microgame

@onready var line_edit: LineEdit = $LineEdit

var cur_text_problem : String = ""
var answer : int = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	line_edit.grab_focus.call_deferred()
	generate_math_eq()
	override_instruction_text.emit(cur_text_problem)

func generate_math_eq() -> void:
	var equation_array : Array = generate_equation()

	cur_text_problem = str(equation_array[0]) + " " + equation_array[2] + " " + str(equation_array[1])
	answer = equation_array[3]

func generate_num(start:int, end:int, min_num:int=1, max_num:int=1000) -> Array: # you don't know math? tsk tsk tsk
	var num_one = min_num - 1
	var num_two = max_num + 1
	while num_one < min_num:
		num_one = randi_range(start * ((difficulty - 1) * 0.5), end * (difficulty * 0.5))
	while num_two > max_num:
		num_two = randi_range(start * ((difficulty - 1) * 0.5), end * (difficulty * 0.5))
	return [num_one, num_two]

func generate_equation() -> Array:
	var cur_num = generate_num(1, 10)
	var math_signs : Array

	if difficulty == 1 or difficulty == 2:
		math_signs = ["+", "-"]
	if difficulty == 3 or difficulty == 4:
		math_signs = ["+", "-", "*"]

	var cur_math_signs : String = math_signs.pick_random()
	var set_answer : int = 0

	if cur_math_signs == "+":
		set_answer = cur_num[0] + cur_num[1]
	elif cur_math_signs == "-":
		set_answer = cur_num[0] - cur_num[1]
	elif cur_math_signs == "*":
		cur_num = generate_num(1, 10, 1, 10)
		set_answer = cur_num[0] * cur_num[1]
	print(cur_num[0], " ", cur_num[1], " ", cur_math_signs, " ", set_answer)
	return [cur_num[0], cur_num[1], cur_math_signs, set_answer]

func isWinning() -> bool:
	super.isWinning()
	return answer == int(line_edit.text)

func canSkip() -> bool:
	return line_edit.text.strip_edges() != ""

func _on_line_edit_text_changed(_new_text: String) -> void:
	if is_intro: return
	set_camera_shake.emit(3, 0.25)
