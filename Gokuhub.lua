import tkinter as tk
from tkinter import ttk

# Configuración de la ventana principal
root = tk.Tk()
root.title("Menu Premium")
root.geometry("450x600")
root.configure(bg="#121212")  # Fondo oscuro moderno
root.resizable(False, False)

# Estilo para los elementos
style = ttk.Style()
style.theme_use("clam")

# Colores del tema
BG_COLOR = "#121212"
CARD_COLOR = "#1e1e1e"
ACCENT_COLOR = "#00adb5"
TEXT_COLOR = "#eeeeee"
DISABLED_COLOR = "#444444"

# Título principal
title_label = tk.Label(
    root, 
    text="CHEAT MENU v1.0", 
    font=("Helvetica", 18, "bold"), 
    fg=ACCENT_COLOR, 
    bg=BG_COLOR,
    pady=20
)
title_label.pack()

# Contenedor de botones
menu_frame = tk.Frame(root, bg=BG_COLOR)
menu_frame.pack(fill="both", expand=True, padx=30, pady=10)

# Funciones de estado para los botones
def toggle_status(button, hack_name):
    # Comparamos el color actual usando cget para evitar problemas de formato hexadecimal
    current_bg = button.cget("bg")
    
    if current_bg == CARD_COLOR:
        button.config(bg=ACCENT_COLOR, fg="#121212", text=f"{hack_name} [ON]")
        print(f"[+] {hack_name} Activado")
    else:
        button.config(bg=CARD_COLOR, fg=TEXT_COLOR, text=f"{hack_name} [OFF]")
        print(f"[-] {hack_name} Desactivado")

# --- BOTÓN 1: Aim Silent ---
btn_aim = tk.Button(
    menu_frame, text="Aim Silent [OFF]", font=("Helvetica", 11, "bold"),
    bg=CARD_COLOR, fg=TEXT_COLOR, activebackground=ACCENT_COLOR,
    bd=0, height=2, cursor="hand2"
)
btn_aim.config(command=lambda: toggle_status(btn_aim, "Aim Silent"))
btn_aim.pack(fill="x", pady=8)

# --- BOTÓN 2: Fov Circle ---
btn_fov = tk.Button(
    menu_frame, text="Fov Circle [OFF]", font=("Helvetica", 11, "bold"),
    bg=CARD_COLOR, fg=TEXT_COLOR, activebackground=ACCENT_COLOR,
    bd=0, height=2, cursor="hand2"
)
btn_fov.config(command=lambda: toggle_status(btn_fov, "Fov Circle"))
btn_fov.pack(fill="x", pady=8)

# --- BOTÓN 3: Speed Hack (Con porcentaje 1 al 100) ---
# Se corrigió tk.Frame eliminando 'padding' e introduciendo padx/pady en el pack
speed_frame = tk.Frame(menu_frame, bg=CARD_COLOR)
speed_frame.pack(fill="x", pady=8)

btn_speed = tk.Button(
    speed_frame, text="Speed Hack [OFF]", font=("Helvetica", 11, "bold"),
    bg=CARD_COLOR, fg=TEXT_COLOR, activebackground=ACCENT_COLOR,
    bd=0, height=1, cursor="hand2"
)
btn_speed.config(command=lambda: toggle_status(btn_speed, "Speed Hack"))
btn_speed.pack(fill="x", pady=(10, 0))

# Deslizador de porcentaje (1 a 100)
speed_val = tk.IntVar(value=50)
speed_slider = tk.Scale(
    speed_frame, from_=1, to=100, orient="horizontal", variable=speed_val,
    bg=CARD_COLOR, fg=TEXT_COLOR, highlightthickness=0, troughcolor=BG_COLOR,
    activebackground=ACCENT_COLOR, label="Porcentaje de Velocidad:"
)
speed_slider.pack(fill="x", padx=10, pady=(0, 10))

# --- BOTÓN 4: Jump Hack ---
btn_jump = tk.Button(
    menu_frame, text="Jump Hack [OFF]", font=("Helvetica", 11, "bold"),
    bg=CARD_COLOR, fg=TEXT_COLOR, activebackground=ACCENT_COLOR,
    bd=0, height=2, cursor="hand2"
)
btn_jump.config(command=lambda: toggle_status(btn_jump, "Jump Hack"))
btn_jump.pack(fill="x", pady=8)

# --- BOTÓN 5: ESP Items de Blockspin ---
btn_esp = tk.Button(
    menu_frame, text="ESP Items (Blockspin) [OFF]", font=("Helvetica", 11, "bold"),
    bg=CARD_COLOR, fg=TEXT_COLOR, activebackground=ACCENT_COLOR,
    bd=0, height=2, cursor="hand2"
)
btn_esp.config(command=lambda: toggle_status(btn_esp, "ESP Items (Blockspin)"))
btn_esp.pack(fill="x", pady=8)

# --- BOTÓN 6: Próximamente ---
btn_soon = tk.Button(
    menu_frame, text="Próximamente...", font=("Helvetica", 11, "italic"),
    bg=DISABLED_COLOR, fg="#888888", state="disabled",
    bd=0, height=2
)
btn_soon.pack(fill="x", pady=8)

# Pie de página técnico
footer_label = tk.Label(root, text="Presiona los botones para activar/desactivar", font=("Helvetica", 9), fg="#666666", bg=BG_COLOR, pady=10)
footer_label.pack(side="bottom")

# Iniciar la interfaz
root.mainloop()
