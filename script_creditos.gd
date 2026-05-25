extends Control

@export var scroll_speed: float = 50.0
@export var next_scene_path: String = "res://cena_inicio.tscn"

# IMAGEM FINAL
@export var imagem_final: Texture2D

@onready var scroll_container = $ScrollContainer
@onready var credits_text = $ScrollContainer/CreditsText

var is_scrolling: bool = false
var final_ja_iniciado := false

func _ready():
	ScriptGlobal.esconder_dica()
	for child in get_tree().root.get_children():
		if child is CanvasLayer and child.layer == 100:
			child.queue_free()

	# ESCONDE BARRA
	scroll_container.get_v_scroll_bar().modulate.a = 0

	# ESPAÇO
	var empty_space = "\n".repeat(30)

	credits_text.text = (
		empty_space
		+ credits_text.text
		+ empty_space
	)

	is_scrolling = true

func _process(delta):

	if is_scrolling:

		var scroll_bar = scroll_container.get_v_scroll_bar()

		scroll_bar.value += scroll_speed * delta

		# FINAL
		if scroll_bar.value >= scroll_bar.max_value - scroll_bar.page:

			is_scrolling = false

			if not final_ja_iniciado:
				final_ja_iniciado = true
				call_deferred("_final_creditos")

func _input(event):

	# PULAR CRÉDITOS
	if event.is_action_pressed("ui_cancel"):

		_finish_credits()

func _final_creditos():

	# ESCONDE CRÉDITOS
	scroll_container.visible = false

	# =========================
	# IMAGEM FINAL
	# =========================
	var imagem = TextureRect.new()

	imagem.texture = imagem_final
	# TAMANHO DA IMAGEM
	imagem.custom_minimum_size = Vector2(700, 400)

	# CENTRALIZA
	imagem.anchor_left = 0.5
	imagem.anchor_top = 0.5
	imagem.anchor_right = 0.5
	imagem.anchor_bottom = 0.5

	imagem.position = Vector2(-350, -200)

	# MODO DA TEXTURA
	imagem.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	imagem.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED

	imagem.modulate.a = 0

	add_child(imagem)

	# FADE IN
	var tween = create_tween()

	tween.tween_property(
		imagem,
		"modulate:a",
		1.0,
		2.0
	)

	await tween.finished

	# =========================
	# DIÁLOGOS FINAIS
	# =========================
	ScriptGlobal.iniciar_dialogo([
		{
			"texto":"Obrigada por jogar nosso projeto.",
			"personagem":"Leticia"
		}
	])
	await get_tree().create_timer(3.0).timeout
	ScriptGlobal.remover_caixa()
	ScriptGlobal.iniciar_dialogo([
		{
			"texto":"Esperamos que você tenha gostado :)",
			"personagem":"Kaua"
		}
			])
	await get_tree().create_timer(3.0).timeout
	ScriptGlobal.remover_caixa()
	ScriptGlobal.iniciar_dialogo([
		{
			"texto":"Foi tudo feito com muito carinho.",
			"personagem":"Isa"
		}
	])
	await get_tree().create_timer(3.0).timeout
	ScriptGlobal.remover_caixa()
	ScriptGlobal.iniciar_dialogo([
		{
			"texto":"E também muita gambiarra.",
			"personagem":"Lucas"
		}
	])
	await get_tree().create_timer(3.0).timeout
	ScriptGlobal.remover_caixa()
	ScriptGlobal.iniciar_dialogo([
		{
			"texto":"E principalmente bugs.",
			"personagem":"Kelvin"
		}
	])
	await get_tree().create_timer(3.0).timeout
	ScriptGlobal.remover_caixa()
	ScriptGlobal.iniciar_dialogo([
		{
			"texto":"MUITOS bugs.",
			"personagem":"Heitor"
		}
	])
	await get_tree().create_timer(3.0).timeout
	ScriptGlobal.remover_caixa()
	ScriptGlobal.iniciar_dialogo([
		{
			"texto":"Obrigado por acompanhar até aqui.",
			"personagem":"Thais"
		}
	])
	await get_tree().create_timer(3.0).timeout
	ScriptGlobal.remover_caixa()
	ScriptGlobal.iniciar_dialogo([
		{
			"texto":"Até a próxima!",
			"personagem":"Matheus"
		}
	])
	await get_tree().create_timer(3.0).timeout
	ScriptGlobal.remover_caixa()

	_finish_credits()

func _finish_credits():

	get_tree().change_scene_to_file(
		next_scene_path
	)
