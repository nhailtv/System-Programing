import os
from dotenv import load_dotenv
import google.generativeai as genai
import gi

gi.require_version("Gtk", "3.0")
from gi.repository import GLib, Gtk
# Load API key from .env



load_dotenv()
api_key = os.getenv("GEMINI_API_KEY")
if not api_key:
    raise ValueError("API key not found in .env file")

# Configure the Gemini API
genai.configure(api_key=api_key)

# Model configuration
generation_config = {
    "temperature": 1,
    "top_p": 0.95,
    "top_k": 40,
    "max_output_tokens": 8192,
    "response_mime_type": "text/plain",
}

model = genai.GenerativeModel(
    model_name="gemini-1.5-flash",
    generation_config=generation_config,
)


class ShellScriptGenerator(Gtk.Window):
    def __init__(self):
        super().__init__(title="Gemini Shell Script Generator")
        self.set_border_width(10)
        self.set_default_size(600, 400)

        # Main layout box
        vbox = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=10)
        self.add(vbox)

        # Title
        title_label = Gtk.Label(label="Shell Script Generator")
        title_label.set_markup("<b><big>Shell Script Generator</big></b>")
        vbox.pack_start(title_label, False, False, 0)

        # Input fields container
        grid = Gtk.Grid(column_spacing=10, row_spacing=10)
        vbox.pack_start(grid, True, True, 0)

        # Script Name field
        name_label = Gtk.Label(label="Script Name:")
        name_label.set_halign(Gtk.Align.END)
        grid.attach(name_label, 0, 0, 1, 1)

        self.name_entry = Gtk.Entry()
        grid.attach(self.name_entry, 1, 0, 1, 1)

        # Request Text field
        request_label = Gtk.Label(label="Request:")
        request_label.set_halign(Gtk.Align.END)
        grid.attach(request_label, 0, 1, 1, 1)

        self.req_text = Gtk.TextView()
        self.req_text.set_wrap_mode(Gtk.WrapMode.WORD)
        scrolled_window = Gtk.ScrolledWindow()
        scrolled_window.set_vexpand(True)
        scrolled_window.add(self.req_text)
        grid.attach(scrolled_window, 1, 1, 1, 1)

        # Generate Button
        self.generate_button = Gtk.Button(label="Generate Script")
        self.generate_button.connect("clicked", self.generate_script)
        vbox.pack_start(self.generate_button, False, False, 0)

    def generate_script(self, button):
        req_buffer = self.req_text.get_buffer()
        req_start, req_end = req_buffer.get_bounds()
        req = req_buffer.get_text(req_start, req_end, False).strip()

        file_name = self.name_entry.get_text().strip()

        if not req or not file_name:
            self.show_message("Input Error", "Both Name and Request fields must be filled.", Gtk.MessageType.WARNING)
            return

        # Start chat session and send request
        try:
            chat_session = model.start_chat(history=[])
            response = chat_session.send_message(f"Make a .sh file to fulfill the request: {req}, only respond with the code!")
            code = response.text.splitlines()

            if len(code) > 2:
                code = code[1:-1]
            else:
                self.show_message("Error", "Generated script is too short.", Gtk.MessageType.ERROR)
                return

            code = [line.strip() for line in code if line.strip() != "'''"]
            code_text = "\n".join(code)

            # Show the code in a new window
            self.show_code_window(file_name, code_text)

        except Exception as e:
            self.show_message("Error", f"An error occurred: {e}", Gtk.MessageType.ERROR)

    def show_code_window(self, file_name, code_text):
        code_window = Gtk.Window(title="Generated Script")
        code_window.set_default_size(700, 400)

        vbox = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=10)
        code_window.add(vbox)

        scrolled_window = Gtk.ScrolledWindow()
        scrolled_window.set_vexpand(True)
        vbox.pack_start(scrolled_window, True, True, 0)

        text_view = Gtk.TextView()
        text_view.set_editable(False)
        text_view.set_wrap_mode(Gtk.WrapMode.WORD)
        text_buffer = text_view.get_buffer()
        text_buffer.set_text(code_text)
        scrolled_window.add(text_view)

        button_box = Gtk.Box(spacing=10)
        vbox.pack_start(button_box, False, False, 0)

        save_button = Gtk.Button(label="Save Script")
        save_button.connect("clicked", lambda _: self.save_script(file_name, code_text))
        button_box.pack_start(save_button, True, True, 0)

        cancel_button = Gtk.Button(label="Cancel")
        cancel_button.connect("clicked", lambda _: code_window.destroy())
        button_box.pack_start(cancel_button, True, True, 0)

        code_window.show_all()

    def save_script(self, file_name, code_text):
        os.makedirs("modules", exist_ok=True)
        file_path = os.path.join("modules", f"{file_name}.sh")
        with open(file_path, "w") as file:
            file.write(code_text)
        self.show_message("Success", f"File '{file_path}' created successfully.", Gtk.MessageType.INFO)

    def show_message(self, title, message, message_type):
        dialog = Gtk.MessageDialog(
            parent=self,
            flags=Gtk.DialogFlags.MODAL,
            type=message_type,
            buttons=Gtk.ButtonsType.OK,
            text=title,
            secondary_text=message,
        )
        dialog.run()
        dialog.destroy()


if __name__ == "__main__":
    app = ShellScriptGenerator()
    app.connect("destroy", Gtk.main_quit)
    app.show_all()
    Gtk.main()
