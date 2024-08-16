@tool
extends TextureButton

@export_category("Author")
@export var author_name: String:
	set(new):
		author_name = new
		if $AuthorName:
			$AuthorName.text = new
@export var link: String
@export var author_image: Texture2D:
	set(new):
		author_image = new
		if $ClipMask/AuthorImage:
			$ClipMask/AuthorImage.texture = new
@export_color_no_alpha var background_color: Color:
	set(new):
		background_color = new
		if $ClipMask/Background:
			$ClipMask/Background.color = new
@export_range(0.1,2.0) var author_scale: float = 1.0:
	set(new):
		author_scale = clamp(new, 0.1, 2.0);
		if $ClipMask/AuthorImage:
			$ClipMask/AuthorImage.scale = Vector2(author_scale, author_scale)
@export var author_offset: Vector2 = Vector2.ZERO:
	set(new):
		author_offset = new;
		if $ClipMask/AuthorImage:
			$ClipMask/AuthorImage.position = author_offset
@export_range(0.1,2.0) var name_scale: float = 1.0:
	set(new):
		name_scale = clamp(new, 0.1, 2.0);
		if $AuthorName:
			$AuthorName.scale = Vector2(name_scale, name_scale)

func _ready():
	$ClipMask/AuthorImage.texture = author_image
	$ClipMask/Background.color = background_color
	$AuthorName.text = author_name
	self.pressed.connect(func():
		Global.click()
		OS.shell_open(link)
	)
