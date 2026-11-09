using System;
using System.Diagnostics;
using System.IO;
using System.IO.Compression;
using System.Reflection;
using System.Security.Cryptography;
using System.Threading.Tasks;
using System.Windows.Forms;
using Microsoft.Win32;

[assembly: AssemblyTitle("Apple Music Red Icon Setup")]
[assembly: AssemblyDescription("Event-triggered taskbar icon companion installer")]
[assembly: AssemblyCompany("Sanwead")]
[assembly: AssemblyProduct("Apple Music Windows Icon Restore")]
[assembly: AssemblyVersion("0.3.0.0")]
[assembly: AssemblyFileVersion("0.3.0.0")]

internal static class Bootstrap
{
    const string Key = @"Software\Sanwead\AppleMusicRedIcon";
    const string AppsKey = @"Software\Microsoft\Windows\CurrentVersion\Uninstall\AppleMusicRedIcon";
    const string Marker = ".applemusic-redicon-install";
    const string MarkerValue = "AppleMusicRedIcon-0bfba87d-252c-4c29-a2c2-12a512586014";
    static readonly string[] Files = { "Install.ps1", "Uninstall.ps1", "Register-Companion.ps1", "Watch-Icon.ps1", "RunHidden.vbs", "Taskbar.cs", "assets/red.ico", "LICENSE", "NOTICE.md", "THIRD_PARTY_NOTICES.md", "README.md", "README.zh-CN.md", "uninstall.exe" };

    [STAThread]
    static int Main(string[] args)
    {
        Application.EnableVisualStyles();
        bool quiet = Array.IndexOf(args, "/quiet") >= 0;
        string directory = DefaultDirectory();
        foreach (string arg in args) if (arg.StartsWith("/dir=", StringComparison.OrdinalIgnoreCase)) directory = arg.Substring(5);
        try
        {
            if (Array.IndexOf(args, "/verify") >= 0) {
#if !UNINSTALL
                using (Stream s = Payload()) using (ZipArchive zip = new ZipArchive(s, ZipArchiveMode.Read)) ValidatePayload(zip);
#endif
                return 0;
            }
            if (!quiet) {
#if UNINSTALL
                if (MessageBox.Show("Remove the Apple Music Red Icon companion?\nApple Music and its library will remain installed.", "Apple Music Red Icon", MessageBoxButtons.OKCancel, MessageBoxIcon.Question) != DialogResult.OK) return 0;
#else
                using (FolderBrowserDialog chooser = new FolderBrowserDialog()) {
                    chooser.Description = "Choose a permanent folder for Apple Music Red Icon. Apple Music itself will not be moved.";
                    chooser.SelectedPath = directory;
                    if (chooser.ShowDialog() != DialogResult.OK) return 0;
                    directory = chooser.SelectedPath;
                }
#endif
                RunWithProgress(directory);
            } else Run(directory);
            return 0;
        }
        catch (Exception e) {
            string log = Path.Combine(Path.GetTempPath(), "AppleMusicRedIcon-setup-error.log");
            File.WriteAllText(log, e.ToString());
            if (!quiet) MessageBox.Show(e.Message + "\n\nDetails: " + log, "Apple Music Red Icon", MessageBoxButtons.OK, MessageBoxIcon.Error);
            return 1;
        }
    }

    static string DefaultDirectory()
    {
        using (RegistryKey k = Registry.CurrentUser.OpenSubKey(Key)) {
            string saved = k == null ? null : k.GetValue("InstallDirectory") as string;
            if (!String.IsNullOrEmpty(saved)) return saved;
        }
#if UNINSTALL
        if (File.Exists(Path.Combine(AppDomain.CurrentDomain.BaseDirectory, Marker))) return AppDomain.CurrentDomain.BaseDirectory;
#endif
        string preferred = @"H:\Program Files\codex";
        return Directory.Exists(preferred) ? Path.Combine(preferred, "AppleMusic-RedIcon-App") : Path.Combine(Environment.GetFolderPath(Environment.SpecialFolder.LocalApplicationData), "Programs", "AppleMusicRedIcon");
    }

    static void RunWithProgress(string directory)
    {
        Exception failure = null;
        using (Form form = new Form()) {
            form.Text = "Apple Music Red Icon"; form.Width = 460; form.Height = 150;
            form.FormBorderStyle = FormBorderStyle.FixedDialog; form.MaximizeBox = false;
            form.MinimizeBox = false; form.ControlBox = false; form.StartPosition = FormStartPosition.CenterScreen;
            Label label = new Label { Left = 20, Top = 20, Width = 410, Text = "Please wait while setup updates the icon companion..." };
            ProgressBar bar = new ProgressBar { Left = 20, Top = 55, Width = 400, Style = ProgressBarStyle.Marquee };
            form.Controls.Add(label); form.Controls.Add(bar);
            form.Shown += async delegate { try { await Task.Run(() => Run(directory)); } catch (Exception e) { failure = e; } finally { form.Close(); } };
            form.ShowDialog();
        }
        if (failure != null) throw failure;
#if UNINSTALL
        MessageBox.Show("Companion removed. Close and reopen Apple Music to restore the default icon.\nApple Music and your library were not uninstalled.", "Apple Music Red Icon");
#else
        MessageBox.Show("Installed. Open Apple Music normally.\nThe companion starts with Apple Music and exits with it; there is no login startup.", "Apple Music Red Icon");
#endif
    }

    static void Run(string requested)
    {
        string directory = Path.GetFullPath(requested).TrimEnd(Path.DirectorySeparatorChar);
        if (directory == Path.GetPathRoot(directory).TrimEnd(Path.DirectorySeparatorChar)) throw new InvalidOperationException("Choose a dedicated subfolder.");
        string marker = Path.Combine(directory, Marker);
#if UNINSTALL
        if (!File.Exists(marker) || File.ReadAllText(marker) != MarkerValue) throw new InvalidOperationException("No EXE-installed companion was found. Use the script uninstaller for a source installation.");
        if (File.Exists(Path.Combine(directory, "Uninstall.ps1"))) RunScript(Path.Combine(directory, "Uninstall.ps1"));
        Registry.CurrentUser.DeleteSubKeyTree(AppsKey, false);
        Registry.CurrentUser.DeleteSubKeyTree(Key, false);
        // Delete only known installed files. Never recursively delete a user-selected directory.
        string self = Assembly.GetExecutingAssembly().Location;
        foreach (string relative in Files) {
            string file = Path.Combine(directory, relative.Replace('/', Path.DirectorySeparatorChar));
            if (!String.Equals(file, self, StringComparison.OrdinalIgnoreCase) && File.Exists(file)) File.Delete(file);
        }
        string assets = Path.Combine(directory, "assets");
        if (Directory.Exists(assets) && Directory.GetFileSystemEntries(assets).Length == 0) Directory.Delete(assets);
        // Keep state, logs, custom files and a running uninstall.exe; remove manually if desired.
#else
        if (Directory.Exists(directory) && Directory.GetFileSystemEntries(directory).Length > 0 &&
            (!File.Exists(marker) || File.ReadAllText(marker) != MarkerValue)) throw new InvalidOperationException("Choose an empty folder, or this tool's existing EXE installation folder.");
        using (Stream s = Payload()) using (ZipArchive zip = new ZipArchive(s, ZipArchiveMode.Read)) {
            ValidatePayload(zip);
            if (File.Exists(marker) && File.Exists(Path.Combine(directory, "Uninstall.ps1"))) RunScript(Path.Combine(directory, "Uninstall.ps1"));
            Directory.CreateDirectory(directory);
            foreach (ZipArchiveEntry entry in zip.Entries) {
                string destination = Path.Combine(directory, entry.FullName.Replace('/', Path.DirectorySeparatorChar));
                Directory.CreateDirectory(Path.GetDirectoryName(destination));
                using (Stream input = entry.Open()) using (FileStream output = File.Create(destination)) input.CopyTo(output);
            }
        }
        File.WriteAllText(marker, MarkerValue);
        RunScript(Path.Combine(directory, "Install.ps1"));
        using (RegistryKey k = Registry.CurrentUser.CreateSubKey(Key)) k.SetValue("InstallDirectory", directory);
        using (RegistryKey k = Registry.CurrentUser.CreateSubKey(AppsKey)) {
            k.SetValue("DisplayName", "Apple Music Red Icon"); k.SetValue("DisplayVersion", "0.3.0"); k.SetValue("Publisher", "Sanwead");
            k.SetValue("InstallLocation", directory); k.SetValue("UninstallString", "\"" + Path.Combine(directory, "uninstall.exe") + "\"");
            k.SetValue("URLInfoAbout", "https://github.com/Sanwead/Apple-Music-Windows-Icon-Restore");
            k.SetValue("NoModify", 1); k.SetValue("NoRepair", 1);
        }
#endif
    }

    static Stream Payload() { return Assembly.GetExecutingAssembly().GetManifestResourceStream("payload.zip"); }
    static void ValidatePayload(ZipArchive zip)
    {
        if (zip.Entries.Count != Files.Length) throw new InvalidDataException("Unexpected embedded payload.");
        foreach (ZipArchiveEntry entry in zip.Entries) {
            if (Array.IndexOf(Files, entry.FullName) < 0) throw new InvalidDataException("Unexpected payload path.");
        }
        foreach (string name in Files) if (zip.GetEntry(name) == null) throw new InvalidDataException("Missing payload file: " + name);
    }

    static void RunScript(string script)
    {
        ProcessStartInfo info = new ProcessStartInfo {
            FileName = Path.Combine(Environment.GetFolderPath(Environment.SpecialFolder.Windows), @"System32\WindowsPowerShell\v1.0\powershell.exe"),
            Arguments = "-NoProfile -ExecutionPolicy Bypass -File \"" + script + "\"",
            WorkingDirectory = Path.GetDirectoryName(script), UseShellExecute = false, CreateNoWindow = true,
            RedirectStandardOutput = true, RedirectStandardError = true
        };
        using (Process process = Process.Start(info)) {
            Task<string> output = process.StandardOutput.ReadToEndAsync();
            Task<string> error = process.StandardError.ReadToEndAsync();
            process.WaitForExit(); Task.WaitAll(output, error);
            if (process.ExitCode != 0) throw new InvalidOperationException("Setup step failed:\n" + output.Result + error.Result);
        }
    }
}
