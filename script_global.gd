extends Node

signal entrada_detectada
var qtd_vidas = 0
var tem_cartao = false
var tem_chave = false
var caixa_atual = null
var layer_atual = null
var is_dialogando = false
var cena_atual = ""
var is_debuging = false
var etapa_cena = 0
var tipo_caixa = ""

# Lógica de troca de personagens
var personagens = []
var personagens_paths = []
var personagem_atual = 0

const PERSONAGENS_DATA = {
	"Leticia": { "cor": Color.REBECCA_PURPLE, "sprite_path": "res://Imagens/leticia_rosto.png" },
	"Lucas": { "cor": Color.DARK_ORANGE, "sprite_path": "res://Imagens/lucas_rosto.png" },
	"Heitor": { "cor": Color.WEB_GREEN, "sprite_path": "res://Imagens/heitor_rosto.png" },
	"Isa": { "cor": Color.HOT_PINK, "sprite_path": "res://Imagens/isa_rosto.png" },
	"Thais": { "cor": Color.DARK_RED, "sprite_path": "res://Imagens/thais_rosto.png" },
	"Matheus": { "cor": Color.NAVY_BLUE, "sprite_path": "res://Imagens/matheus_rosto.png" },
	"Kaua": { "cor": Color.YELLOW, "sprite_path": "res://Imagens/kaua_rosto.png" },
	"Kelvin": { "cor": Color.WEB_MAROON, "sprite_path": "res://Imagens/kelvin_rosto.png" },
	"Veronica": { "cor": Color.WHITE, "sprite_path": "res://Imagens/tia_rosto.png" }
}

var menu_pausa_atual = null
const LOGO_PATH = "res://Imagens/game_logo.png" 

func inicializar():
	qtd_vidas = 3
	tem_cartao = false
	tem_chave = false
	caixa_atual = null
	layer_atual = null
	is_dialogando = false
	cena_atual = ""
	is_debuging = false
	etapa_cena = 0	
	personagens = []
	personagens_paths = []
	personagem_atual = 0

func dano_player_flash():
	var player = get_tree().get_first_node_in_group("player")
	if player == null: return
	var sprite = player.get_node_or_null("Sprite2D")
	if sprite == null: sprite = player.get_node_or_null("AnimatedSprite2D")
	if sprite:
		for i in 3:
			if qtd_vidas==0: return
			sprite.modulate = Color(1, 0, 0)
			await get_tree().create_timer(0.05).timeout
			sprite.modulate = Color(1, 1, 1)
			await get_tree().create_timer(0.05).timeout
	
func _ready() -> void:
	inicializar()

func _process(_delta: float) -> void:
	if is_debuging:
		qtd_vidas=3

func _input(event):
	if event.is_action_pressed("ui_accept") and caixa_atual:
		entrada_detectada.emit()
	
	if event.is_action_pressed("trocar_personagem") and personagens.size() > 0:
		personagem_atual = (personagem_atual + 1) % personagens.size()
		trocar_de_personagem(personagem_atual)

	if event.is_action_pressed("ui_cancel"):
		if get_tree().current_scene.name != "MenuInicial":
			if get_tree().paused: retomar_jogo()
			else: pausar_jogo()

func trocar_de_personagem(index):
	for i in range(personagens.size()):
		var p = personagens[i]
		if is_instance_valid(p):
			var is_active = (i == index)
			if "ativo" in p: p.ativo = is_active
			if p.has_node("Camera2D"): p.get_node("Camera2D").enabled = is_active
			if is_active: p.add_to_group("player")
			else: p.remove_from_group("player")

func tocar_som(caminho_audio: String):
	var player = AudioStreamPlayer.new()
	player.stream = load(caminho_audio)
	add_child(player)
	player.play()
	player.finished.connect(func(): player.queue_free())

func iniciar_dialogo(lista_falas):

	tipo_caixa = "dialogo"
	is_dialogando = true

	for fala in lista_falas:

		remover_caixa()

		var personagem_nome = fala["personagem"]
		var personagem_data = PERSONAGENS_DATA.get(personagem_nome, null)

		if personagem_data == null:
			push_error("Personagem '" + personagem_nome + "' não encontrado.")
			continue

		var painel = criar_caixa(
			fala["texto"],
			personagem_nome,
			personagem_data["cor"],
			personagem_data["sprite_path"]
		)

		exibir_na_tela(painel)

		await entrada_detectada

	remover_caixa()

	is_dialogando = false
	tipo_caixa = ""
# -----------------------------
func mostrar_dica(texto, cor = Color.WHITE):

	# NÃO MOSTRA DICA DURANTE DIÁLOGO
	if is_dialogando:
		return

	tipo_caixa = "dica"

	remover_caixa()

	var painel = criar_caixa(texto, null, cor, null)
	exibir_na_tela(painel)
func esconder_dica():
	if tipo_caixa=="dica":
		remover_caixa()

#-----------------------------
func recebeu_item(texto):
	var canvas_layer = CanvasLayer.new()
	add_child(canvas_layer)
	# FUNDO
	var fundo = ColorRect.new()
	fundo.color = Color(0, 0, 0, 0.7)
	fundo.custom_minimum_size = Vector2(350, 50)
	var tamanho_tela = get_viewport().get_visible_rect().size
	fundo.position = Vector2(
		tamanho_tela.x - 440,
		20
	)
	canvas_layer.add_child(fundo)
	# TEXTO
	var label = Label.new()
	label.text = texto
	label.modulate = Color(1, 1, 1, 0) 
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.custom_minimum_size = Vector2(350, 50)
	label.add_theme_font_size_override("font_size", 20)
	label.position = fundo.position
	canvas_layer.add_child(label)
	# fundo começa invisível
	fundo.modulate.a = 0
	tocar_som("res://Sons e m├║sicas/novo_item.mp3")
	
	# animação
	var tween = create_tween()

	# fade in
	tween.parallel().tween_property(fundo, "modulate:a", 1.0, 0.5)
	tween.parallel().tween_property(label, "modulate:a", 1.0, 0.5)

	await tween.finished

	await get_tree().create_timer(4.0).timeout

	var tween2 = create_tween()

	# fade out
	tween2.parallel().tween_property(fundo, "modulate:a", 0.0, 0.5)
	tween2.parallel().tween_property(label, "modulate:a", 0.0, 0.5)

	await tween.finished

	canvas_layer.queue_free()
	
# -----------------------------
# AUXILIAR PARA EXIBIR
# -----------------------------
func exibir_na_tela(painel):
	layer_atual = CanvasLayer.new()
	layer_atual.add_child(painel)
	get_tree().root.add_child(layer_atual)
	caixa_atual = layer_atual

# -----------------------------
# CRIAR CAIXA (FLEXÍVEL)
# -----------------------------
func criar_caixa(texto, personagem_nome, cor_texto, sprite_path):
	var painel = Panel.new()
	painel.custom_minimum_size = Vector2(0, 100)
	var estilo = StyleBoxFlat.new()
	estilo.bg_color = Color(0,0,0,0.8)
	painel.add_theme_stylebox_override("panel", estilo)

	var hbox = HBoxContainer.new()
	hbox.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	hbox.offset_left = 20
	hbox.offset_top = 10
	hbox.offset_right = -20
	hbox.offset_bottom = -10
	painel.add_child(hbox)

	# TEXTO PRINCIPAL
	var label = Label.new()
	label.text = texto
	label.modulate = cor_texto
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	
	# Se não houver personagem, centraliza o texto (modo Dica)
	if personagem_nome == null:
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	else:
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	
	hbox.add_child(label)

	# SÓ ADICIONA SPRITE SE HOUVER PERSONAGEM
	if personagem_nome != null:
		var vbox_personagem = VBoxContainer.new()
		vbox_personagem.alignment = BoxContainer.ALIGNMENT_CENTER
		vbox_personagem.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
		hbox.add_child(vbox_personagem)

		var label_nome = Label.new()
		label_nome.text = personagem_nome
		label_nome.modulate = cor_texto
		label_nome.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		vbox_personagem.add_child(label_nome)

		var texture_rect = TextureRect.new()
		texture_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		texture_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		texture_rect.custom_minimum_size = Vector2(64, 64)
		texture_rect.texture = load(sprite_path) if sprite_path else null
		vbox_personagem.add_child(texture_rect)

		# ICONE ENTER (Opcional para dicas, mas mantido para consistência)
		var enter_label = Label.new()
		enter_label.text = "⏎"
		enter_label.modulate = Color.WHITE
		enter_label.anchor_left = 1
		enter_label.anchor_top = 1
		enter_label.anchor_right = 1
		enter_label.anchor_bottom = 1
		enter_label.offset_left = -30
		enter_label.offset_top = -28
		painel.add_child(enter_label)

	painel.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_WIDE)
	painel.offset_top = -100
	return painel

func remover_caixa():
	if is_instance_valid(caixa_atual):
		caixa_atual.queue_free()
	caixa_atual = null

# -----------------------------
# MENU DE PAUSA
# -----------------------------
func pausar_jogo():
	if menu_pausa_atual: return # Já está pausado

	get_tree().paused = true

	menu_pausa_atual = CanvasLayer.new()
	menu_pausa_atual.name = "MenuPausa"
	menu_pausa_atual.process_mode = Node.PROCESS_MODE_ALWAYS # Permite que o menu processe mesmo com o jogo pausado

	# Fundo escuro
	var fundo_escuro = ColorRect.new()
	fundo_escuro.color = Color(0, 0, 0, 0.8)
	fundo_escuro.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	fundo_escuro.mouse_filter = Control.MOUSE_FILTER_STOP # Impede cliques passarem para o jogo
	menu_pausa_atual.add_child(fundo_escuro)

	# Container principal para logo e botões
	var main_vbox = VBoxContainer.new()
	main_vbox.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	main_vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	menu_pausa_atual.add_child(main_vbox)

	# Logo do jogo
	var logo = TextureRect.new()
	logo.texture = load(LOGO_PATH) if LOGO_PATH else null
	logo.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	logo.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	logo.custom_minimum_size = Vector2(300, 150) # Ajuste o tamanho conforme sua logo
	logo.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	main_vbox.add_child(logo)

	# Espaçamento
	var spacer = Control.new()
	spacer.custom_minimum_size = Vector2(0, 50) # Espaço entre logo e botões
	main_vbox.add_child(spacer)

	# Container para os botões
	var button_vbox = VBoxContainer.new()
	button_vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	button_vbox.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	main_vbox.add_child(button_vbox)

	# Estilo básico para os botões (opcional, mas melhora a visibilidade)
	# Estilo básico para os botões no Godot 4
	var button_style = StyleBoxFlat.new()
	button_style.bg_color = Color(0.2, 0.4, 0.6, 0.8) # Azul escuro
	button_style.corner_radius_top_left = 5
	button_style.corner_radius_top_right = 5
	button_style.corner_radius_bottom_left = 5
	button_style.corner_radius_bottom_right = 5
	button_style.border_width_left = 2
	button_style.border_width_top = 2
	button_style.border_width_right = 2
	button_style.border_width_bottom = 2
	button_style.border_color = Color.WHITE

	# Botão Retomar
	var btn_retomar = Button.new()
	btn_retomar.text = "Retomar"
	btn_retomar.custom_minimum_size = Vector2(200, 40)
	btn_retomar.add_theme_stylebox_override("normal", button_style)
	btn_retomar.pressed.connect(retomar_jogo)
	button_vbox.add_child(btn_retomar)

	# Espaçamento entre botões
	var button_spacer = Control.new()
	button_spacer.custom_minimum_size = Vector2(0, 10)
	button_vbox.add_child(button_spacer)

	# Botão Sair do Jogo
	var btn_sair = Button.new()
	btn_sair.text = "Sair do Jogo"
	btn_sair.custom_minimum_size = Vector2(200, 40)
	btn_sair.add_theme_stylebox_override("normal", button_style)
	btn_sair.pressed.connect(sair_do_jogo)
	button_vbox.add_child(btn_sair)
	
	# Espaçamento entre botões
	var button_spacer_ = Control.new()
	button_spacer_.custom_minimum_size = Vector2(0, 10)
	button_vbox.add_child(button_spacer_)

	# Botão Sair do Jogo
	var btn_debug = Button.new()
	var status = "(Ativar)"
	if is_debuging:
		status="(Inativar)"
	btn_debug.text = "Debug "+ status
	btn_debug.custom_minimum_size = Vector2(200, 40)
	btn_debug.add_theme_stylebox_override("normal", button_style)
	btn_debug.pressed.connect(debug)
	button_vbox.add_child(btn_debug)

	get_tree().root.add_child(menu_pausa_atual)

func retomar_jogo():
	if is_instance_valid(menu_pausa_atual):
		menu_pausa_atual.queue_free()
		menu_pausa_atual = null
	get_tree().paused = false

func sair_do_jogo():
	get_tree().quit()

func debug():
	is_debuging = !is_debuging
	if is_debuging == false:
		sair_do_jogo()
	else:
		tem_chave=true
		tem_cartao=true
		if is_instance_valid(menu_pausa_atual):
			menu_pausa_atual.queue_free()
			menu_pausa_atual = null
		get_tree().paused = false
