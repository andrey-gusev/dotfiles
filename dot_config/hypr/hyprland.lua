require("~/.cache/wal/hyprland.lua")

hl.monitor({
	output = "DP-1",
	mode = "1920x1080@143.98",
	position = "auto",
	scale = 1,
})

hl.monitor({
	output = "HDMI-A-1",
	disabled = true,
})

hl.monitor({
	output = "",
	mode = "preferred",
	position = "auto",
	scale = 1,
})

local terminal = "foot"
local fileManager = "lf"
local menu = "rofi -show drun"
local emojimenu = "rofi -show emoji"
local browser = "librewolf"
local editor = "nvim"
local mainMod = "SUPER"

hl.on("hyprland.start", function()
	hl.exec_cmd("foot --server")
	hl.exec_cmd("waybar")
	hl.exec_cmd("awww-daemon")
	hl.exec_cmd("hypridle")
	hl.exec_cmd("hyprsunset")
	hl.exec_cmd("mako")
	hl.exec_cmd("setbg")
	hl.exec_cmd("wl-paste --type text --watch cliphist store")
	hl.exec_cmd("wl-paste --type image --watch cliphist store")
	hl.exec_cmd("dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP")
	hl.exec_cmd("gsettings set org.gnome.desktop.interface gtk-theme 'Adwaita-dark'")
	hl.exec_cmd("gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'")
end)

hl.env("LIBVA_DRIVER_NAME", "nvidia")
hl.env("GBM_BACKEND", "nvidia-drm")
hl.env("__GLX_VENDOR_LIBRARY_NAME", "nvidia")

hl.config({
	general = {
		gaps_in = 5,
		gaps_out = { top = 10, right = 20, bottom = 10, left = 20 },
		border_size = 3,
		col = {
			active_border = color1,
			inactive_border = "rgba(0,0,0,0)",
		},
		resize_on_border = false,
		allow_tearing = true,
		layout = "dwindle",
		snap = {
			enabled = true,
			window_gap = 15,
			monitor_gap = 15,
		},
	},

	dwindle = {
		force_split = 1,
		preserve_split = true,
		smart_split = false,
		smart_resizing = true,
	},

	xwayland = {
		enabled = true,
	},

	decoration = {
		rounding = 0,
		fullscreen_opacity = 1.0,

		shadow = {
			enabled = false,
		},

		blur = {
			enabled = false,
		},
	},

	animations = {
		enabled = true,
	},

	misc = {
		force_default_wallpaper = 0,
		disable_hyprland_logo = true,
		disable_splash_rendering = true,
		enable_swallow = true,
		swallow_regex = "^(" .. terminal .. ")$",
		background_color = "rgb(0, 0, 0)",
	},

	cursor = {
		inactive_timeout = 1,
		no_warps = true,
		hide_on_key_press = true,
	},

	input = {
		kb_layout = "us,ru",
		kb_options = "caps:escape",
		scroll_method = "on_button_down",
		scroll_button = 274,
		follow_mouse = 1,
		sensitivity = 0,
		repeat_rate = 50,
		repeat_delay = 300,

		touchpad = {
			natural_scroll = false,
			scroll_factor = 0.5,
		},
	},

	scrolling = {
		follow_focus = true,
		focus_fit_method = 1,
	},
})

hl.curve("appleEase", { type = "bezier", points = { { 0.25, 1 }, { 0.5, 1 } } })
hl.curve("appleClose", { type = "bezier", points = { { 0.5, 0 }, { 0.75, 0.25 } } })

hl.animation({ leaf = "global", enabled = true, speed = 3.8, bezier = "appleEase" })
hl.animation({ leaf = "windows", enabled = true, speed = 3.5, bezier = "appleEase", style = "popin 80%" })
hl.animation({ leaf = "windowsIn", enabled = true, speed = 3.2, bezier = "appleEase", style = "popin 80%" })
hl.animation({ leaf = "windowsOut", enabled = true, speed = 2.8, bezier = "appleClose", style = "popin 82%" })
hl.animation({ leaf = "layers", enabled = true, speed = 3.0, bezier = "appleEase", style = "fade" })
hl.animation({ leaf = "workspaces", enabled = true, speed = 4.0, bezier = "appleEase", style = "slide" })

-- Переключение раскладки
hl.bind("F24", hl.dsp.exec_cmd("hyprctl switchxkblayout all next"), { locked = true })

-- Основные
hl.bind(mainMod .. " + return", hl.dsp.exec_cmd(terminal), { repeating = true })
hl.bind(mainMod .. " + Q", hl.dsp.window.close(), { repeating = true })
hl.bind(mainMod .. " + SHIFT + C", hl.dsp.exit())
hl.bind(mainMod .. " + R", hl.dsp.exec_cmd(terminal .. " -e " .. fileManager))
hl.bind(mainMod .. " + SHIFT + SPACE", function()
	hl.dispatch(hl.dsp.window.float({ action = "toggle" }))
	hl.dispatch(hl.dsp.window.resize({ x = 1000, y = 1000, exact = true }))
	hl.dispatch(hl.dsp.window.center())
end)
hl.bind(mainMod .. " + D", hl.dsp.exec_cmd(menu))
hl.bind(mainMod .. " + GRAVE", hl.dsp.exec_cmd(emojimenu))
hl.bind(mainMod .. " + W", hl.dsp.exec_cmd(browser))
hl.bind(mainMod .. " + T", hl.dsp.exec_cmd("Telegram"))
hl.bind(mainMod .. " + M", hl.dsp.exec_cmd("yandex-music"))
hl.bind(mainMod .. " + B", hl.dsp.exec_cmd("pkill -SIGUSR1 waybar"))
hl.bind(mainMod .. " + SHIFT + B", hl.dsp.exec_cmd("setbg"))
hl.bind(mainMod .. " + SHIFT + R", hl.dsp.exec_cmd(terminal .. " btop"))

-- GAPS!!

local gaps_off = false

-- Дефолтные значения (твоя исходная таблица)
local DEFAULT_GAPS_IN = 5
local DEFAULT_GAPS_OUT = { top = 10, right = 20, bottom = 10, left = 20 }

local step_out = 20

-- Текущие отступы (копируем дефолты)
local gaps_in = DEFAULT_GAPS_IN
local gaps_out = {
	top = DEFAULT_GAPS_OUT.top,
	right = DEFAULT_GAPS_OUT.right,
	bottom = DEFAULT_GAPS_OUT.bottom,
	left = DEFAULT_GAPS_OUT.left,
}

-- Функция обновления конфигурации
local function apply_gaps()
	if gaps_off then
		hl.config({ general = { gaps_in = 0, gaps_out = 0 } })
	else
		hl.config({
			general = {
				gaps_in = gaps_in,
				gaps_out = gaps_out,
			},
		})
	end
end

-- 1. Тоггл Вкл/Выкл (ALT + A)
hl.bind("ALT + A", function()
	gaps_off = not gaps_off
	apply_gaps()
end)

-- 2. Увеличение всех внешних отступов на step_out (ALT + X)
hl.bind("ALT + X", function()
	gaps_out.top = gaps_out.top + step_out
	gaps_out.right = gaps_out.right + step_out
	gaps_out.bottom = gaps_out.bottom + step_out
	gaps_out.left = gaps_out.left + step_out

	gaps_off = false
	apply_gaps()
end, { repeating = true })

-- 3. Уменьшение всех внешних отступов с проверкой на 0 (ALT + Z)
hl.bind("ALT + Z", function()
	if gaps_out.top - step_out >= 0 and gaps_out.left - step_out >= 0 then
		gaps_out.top = gaps_out.top - step_out
		gaps_out.right = gaps_out.right - step_out
		gaps_out.bottom = gaps_out.bottom - step_out
		gaps_out.left = gaps_out.left - step_out

		gaps_off = false
		apply_gaps()
	end
end, { repeating = true })

-- 4. Сброс к дефолтной таблице (ALT + R)
hl.bind("ALT + SHIFT + A", function()
	gaps_in = DEFAULT_GAPS_IN
	gaps_out = {
		top = DEFAULT_GAPS_OUT.top,
		right = DEFAULT_GAPS_OUT.right,
		bottom = DEFAULT_GAPS_OUT.bottom,
		left = DEFAULT_GAPS_OUT.left,
	}
	gaps_off = false
	apply_gaps()
end)

-- Состояние анимаций (true = включены, false = выключены)
local animations_enabled = true

-- Переключатель анимаций (ALT + SHIFT + A)
hl.bind("SUPER + SHIFT + A", function()
	animations_enabled = not animations_enabled

	hl.config({
		animations = {
			enabled = animations_enabled,
		},
	})
end)

hl.bind(mainMod .. " + SHIFT + BACKSPACE", hl.dsp.exec_cmd("hyprlock"))
hl.bind(mainMod .. " + F3", hl.dsp.exec_cmd("displayselect"))
hl.bind(mainMod .. " + F4", hl.dsp.exec_cmd(terminal .. " -e pulsemixer"))
hl.bind(mainMod .. " + SHIFT + W", hl.dsp.exec_cmd(terminal .. " -e nmtui"))
hl.bind(
	mainMod .. " + F12",
	hl.dsp.exec_cmd(
		"sh -c 'mpv av://v4l2:$(ls /dev/video* | head -n 1) --title=cam --profile=low-latency --untimed --no-cache --no-osc --no-input-default-bindings --input-conf=/dev/null'"
	)
)
hl.bind(mainMod .. " + BACKSPACE", hl.dsp.exec_cmd("pwr"))
hl.bind(mainMod .. " + SHIFT + X", hl.dsp.exec_cmd("pwr"))

-- Скриншоты
hl.bind("Print", hl.dsp.exec_cmd("hyprshot -m output -m active --clipboard-only"))
hl.bind("SHIFT + Print", hl.dsp.exec_cmd("hyprshot -m region --clipboard-only"))
hl.bind("ALT + Print", hl.dsp.exec_cmd("hyprshot -m window -m active --clipboard-only"))
hl.bind(
	mainMod .. " + SHIFT + S",
	hl.dsp.exec_cmd("hyprshot --raw -m region | tesseract stdin stdout -l rus+eng | wl-copy")
)
hl.bind(mainMod .. " + Print", hl.dsp.exec_cmd("record"))

-- Буфер обмена
hl.bind(
	"SUPER + V",
	hl.dsp.exec_cmd(
		"cliphist list | rofi -dmenu -display-columns 2 | cliphist decode | wl-copy && wtype -M ctrl v -m ctrl"
	)
)

-- Фокус
hl.bind(mainMod .. " + h", hl.dsp.focus({ direction = "left" }), { repeating = true })
hl.bind(mainMod .. " + l", hl.dsp.focus({ direction = "right" }), { repeating = true })
hl.bind(mainMod .. " + k", hl.dsp.focus({ direction = "up" }), { repeating = true })
hl.bind(mainMod .. " + j", hl.dsp.focus({ direction = "down" }), { repeating = true })

-- Ресайз
hl.bind(mainMod .. " + SHIFT + h", hl.dsp.window.resize({ x = -50, y = 0, relative = true }), { repeating = true })
hl.bind(mainMod .. " + SHIFT + j", hl.dsp.window.resize({ x = 0, y = 50, relative = true }), { repeating = true })
hl.bind(mainMod .. " + SHIFT + k", hl.dsp.window.resize({ x = 0, y = -50, relative = true }), { repeating = true })
hl.bind(mainMod .. " + SHIFT + l", hl.dsp.window.resize({ x = 50, y = 0, relative = true }), { repeating = true })

-- Остальное
hl.bind(mainMod .. " + F", hl.dsp.window.fullscreen())
hl.bind(mainMod .. " + S", hl.dsp.window.pin())
hl.bind(mainMod .. " + TAB", hl.dsp.window.cycle_next())
hl.bind("ALT + TAB", hl.dsp.focus({ workspace = "previous" }))

-- Перемещение окон
hl.bind(mainMod .. " + CTRL + h", hl.dsp.window.move({ direction = "left" }), { repeating = true })
hl.bind(mainMod .. " + CTRL + j", hl.dsp.window.move({ direction = "down" }), { repeating = true })
hl.bind(mainMod .. " + CTRL + k", hl.dsp.window.move({ direction = "up" }), { repeating = true })
hl.bind(mainMod .. " + CTRL + l", hl.dsp.window.move({ direction = "right" }), { repeating = true })

-- Воркспейсы
for i = 1, 10 do
	local key = i % 10 -- 10 → 0
	hl.bind(mainMod .. " + " .. key, hl.dsp.focus({ workspace = i }))
	hl.bind(mainMod .. " + SHIFT + " .. key, hl.dsp.window.move({ workspace = i }))
end

-- Скролл воркспейсов
hl.bind(mainMod .. " + mouse_down", hl.dsp.focus({ workspace = "e+1" }))
hl.bind(mainMod .. " + mouse_up", hl.dsp.focus({ workspace = "e-1" }))

-- Мышь
hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(), { mouse = true })
hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

-- Медиа-клавиши
hl.bind(
	"XF86AudioRaiseVolume",
	hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+"),
	{ locked = true, repeating = true }
)
hl.bind(
	"XF86AudioLowerVolume",
	hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"),
	{ locked = true, repeating = true }
)
hl.bind(
	"XF86AudioMute",
	hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"),
	{ locked = true, repeating = true }
)
hl.bind(
	"XF86AudioMicMute",
	hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"),
	{ locked = true, repeating = true }
)
hl.bind("XF86MonBrightnessUp", hl.dsp.exec_cmd("brightnessctl s 10%+"), { locked = true, repeating = true })
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("brightnessctl s 10%-"), { locked = true, repeating = true })

hl.bind("XF86AudioNext", hl.dsp.exec_cmd("playerctl next"), { locked = true })
hl.bind("XF86AudioPause", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPlay", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPrev", hl.dsp.exec_cmd("playerctl previous"), { locked = true })

hl.bind("SUPER + Escape", hl.dsp.submap("passthru"))
hl.define_submap("passthru", function()
	hl.bind("SUPER + Escape", hl.dsp.submap("reset"))
end)

hl.window_rule({
	name = "tile-nsxiv",
	match = { class = "^(Nsxiv)$" },
	tile = true,
})

hl.window_rule({
	name = "tile-freerdp",
	match = { class = "^(FreeRDP)$" },
	tile = true,
})

hl.window_rule({
	name = "no-gaps-wtv1",
	match = { float = false, workspace = "w[tv1]" },
	border_size = 0,
	rounding = 0,
})

hl.window_rule({
	name = "no-gaps-f1",
	match = { float = false, workspace = "f[1]" },
	border_size = 0,
	rounding = 0,
})

-- Убираем рамку для всех неактивных окон
hl.window_rule({
	name = "inactive-no-border",
	match = { focus = false }, -- focus = false ловит все неактивные окна (аналог focus:0)
	border_size = 0,
})
