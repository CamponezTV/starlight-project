extends Node
## Autoload "Stars": a vida do Jupiter, contada em estrelas.

signal changed(count: int)

const START_COUNT := 3
const MAX_COUNT := 5

var count := START_COUNT:
	set(value):
		count = clampi(value, 0, MAX_COUNT)
		changed.emit(count)


func gain() -> void:
	count += 1


func lose() -> void:
	count -= 1


func reset() -> void:
	count = START_COUNT


func is_empty() -> bool:
	return count == 0


## Vida de 0.0 a 1.0.
func ratio() -> float:
	return float(count) / MAX_COUNT
