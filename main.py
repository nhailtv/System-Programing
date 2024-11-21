import os
import subprocess
import gi
gi.require_version("Gtk", "3.0")
from gi.repository import GLib, Gtk

# Path to the modules folder
MODULES_DIR = os.path.join(os.getcwd(), "modules")


class ModuleManagerApp(Gtk.Window):
    def __init__(self):
        super().__init__(title="Module Manager")
        self.set_border_width(10)
        self.set_default_size(400, 300)

        # Create a vertical box layout
        vbox = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=10)
        self.add(vbox)

        # Create a label
        label = Gtk.Label(label="Available Modules")
        vbox.pack_start(label, False, False, 0)

        # Create a scrolled window for the list of modules
        scrolled_window = Gtk.ScrolledWindow()
        scrolled_window.set_policy(Gtk.PolicyType.AUTOMATIC, Gtk.PolicyType.AUTOMATIC)
        vbox.pack_start(scrolled_window, True, True, 0)

        # Create a list store to hold the module names
        self.module_list_store = Gtk.ListStore(str)

        # Create a tree view to display the modules
        tree_view = Gtk.TreeView(model=self.module_list_store)
        scrolled_window.add(tree_view)

        # Add a single column to the tree view
        renderer = Gtk.CellRendererText()
        column = Gtk.TreeViewColumn("Module", renderer, text=0)
        tree_view.append_column(column)

        # Selection handling
        self.selection = tree_view.get_selection()

        # Refresh button
        refresh_button = Gtk.Button(label="Refresh")
        refresh_button.connect("clicked", self.refresh_module_list)
        vbox.pack_start(refresh_button, False, False, 0)

        # Execute button
        execute_button = Gtk.Button(label="Execute")
        execute_button.connect("clicked", self.execute_module)
        vbox.pack_start(execute_button, False, False, 0)

        # Run with sudo checkbox
        self.run_with_sudo_checkbox = Gtk.CheckButton(label="Run with Sudo")
        vbox.pack_start(self.run_with_sudo_checkbox, False, False, 0)

        # Load the module list
        self.refresh_module_list()

    def refresh_module_list(self, button=None):
        # Clear the list store
        self.module_list_store.clear()

        # Populate the list store with .sh files from the modules directory
        if not os.path.exists(MODULES_DIR):
            os.makedirs(MODULES_DIR)

        for file_name in os.listdir(MODULES_DIR):
            if file_name.endswith(".sh"):
                self.module_list_store.append([file_name])

    def execute_module(self, button):
        # Get the selected module
        model, tree_iter = self.selection.get_selected()
        if tree_iter is None:
            self.show_message("Warning", "No module selected.")
            return

        module_name = model[tree_iter][0]
        module_path = os.path.join(MODULES_DIR, module_name)

        try:
            # Construct the command
            if self.run_with_sudo_checkbox.get_active():
                command = f'sudo bash "{module_path}"; read -p "Press enter to exit..."'
            else:
                command = f'bash "{module_path}"; read -p "Press enter to exit..."'

            # Execute the command in a new terminal
            subprocess.Popen(["gnome-terminal", "--", "bash", "-c", command],
                             stderr=subprocess.PIPE,
                             stdout=subprocess.PIPE)

        except Exception as e:
            self.show_message("Error", f"An unexpected error occurred: {e}")

    def show_message(self, title, message):
        dialog = Gtk.MessageDialog(
            parent=self,
            flags=Gtk.DialogFlags.MODAL,
            type=Gtk.MessageType.INFO,
            buttons=Gtk.ButtonsType.OK,
            message_format=message,
        )
        dialog.set_title(title)
        dialog.run()
        dialog.destroy()


if __name__ == "__main__":
    app = ModuleManagerApp()
    app.connect("destroy", Gtk.main_quit)
    app.show_all()
    Gtk.main()
