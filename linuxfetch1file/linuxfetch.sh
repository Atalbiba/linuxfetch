#include <iostream>
#include <fstream>
#include <sstream>
#include <string>
#include <vector>
#include <map>
#include <cstdlib>
#include <ctime>
#include <unistd.h>
#include <sys/utsname.h>
#include <sys/sysinfo.h>
#include <filesystem>
#include <algorithm>
#include <iomanip>
#include <memory>

#ifdef __linux__
#include <sys/statvfs.h>
#endif

namespace fs = std::filesystem;

// ============ КОНФИГУРАЦИЯ ============
struct Config {
    std::string language = "auto";
    bool show_logo = true;
    bool show_os = true;
    bool show_host = true;
    bool show_kernel = true;
    bool show_uptime = true;
    bool show_packages = true;
    bool show_shell = true;
    bool show_cpu = true;
    bool show_gpu = true;
    bool show_memory = true;
    bool show_disk = true;
    bool show_battery = true;
    bool show_color_blocks = true;
    bool show_bar = true;
    bool show_network = true;
    bool show_quote = true;
    bool show_animation = true;
    std::string logo_type = "auto";
    int logo_color = 34;
    int memory_warn = 80;
    int disk_warn = 80;
};

// ============ ЦВЕТА ANSI ============
class Color {
public:
    static std::string reset() { return "\033[0m"; }
    static std::string fg(int code) { return "\033[38;5;" + std::to_string(code) + "m"; }
    static std::string bg(int code) { return "\033[48;5;" + std::to_string(code) + "m"; }
    
    static std::string colored(int color_code, const std::string& text) {
        return fg(color_code) + text + reset();
    }
    
    static std::string title(const std::string& text) {
        return colored(34, text);
    }
    
    static std::string value(const std::string& text) {
        return colored(36, text);
    }
    
    static std::string accent(const std::string& text) {
        return colored(35, text);
    }
    
    static std::string warn(const std::string& text) {
        return colored(196, text);
    }
    
    static std::string ok(const std::string& text) {
        return colored(46, text);
    }
};

// ============ ЯЗЫКОВЫЕ СТРОКИ ============
class Language {
private:
    std::map<std::string, std::map<std::string, std::string>> strings;
    Config config;
    
public:
    Language(const Config& cfg) : config(cfg) {
        initStrings();
    }
    
    void initStrings() {
        // English
        strings["en"] = {
            {"loading", "LinuxFetch 1.0 beta 2"},
            {"title", "System Information"},
            {"os", "OS"},
            {"host", "Host"},
            {"kernel", "Kernel"},
            {"uptime", "Uptime"},
            {"packages", "Packages"},
            {"shell", "Shell"},
            {"cpu", "CPU"},
            {"gpu", "GPU"},
            {"memory", "Memory"},
            {"disk", "Disk"},
            {"battery", "Battery"},
            {"network", "Network"},
            {"offline", "Offline"},
            {"unknown", "Unknown"},
            {"help", "Run: linuxfetch --help for options"}
        };
        
        // Russian
        strings["ru"] = {
            {"loading", "LinuxFetch 1.0 бета 2"},
            {"title", "Информация о системе"},
            {"os", "ОС"},
            {"host", "Хост"},
            {"kernel", "Ядро"},
            {"uptime", "Время работы"},
            {"packages", "Пакеты"},
            {"shell", "Оболочка"},
            {"cpu", "Процессор"},
            {"gpu", "Видеокарта"},
            {"memory", "Память"},
            {"disk", "Диск"},
            {"battery", "Батарея"},
            {"network", "Сеть"},
            {"offline", "Не в сети"},
            {"unknown", "Неизвестно"},
            {"help", "Запустите: linuxfetch --help для опций"}
        };
        
        // Ukrainian
        strings["uk"] = {
            {"loading", "LinuxFetch 1.0 бета 2"},
            {"title", "Інформація про систему"},
            {"os", "ОС"},
            {"host", "Хост"},
            {"kernel", "Ядро"},
            {"uptime", "Час роботи"},
            {"packages", "Пакети"},
            {"shell", "Оболонка"},
            {"cpu", "Процесор"},
            {"gpu", "Відеокарта"},
            {"memory", "Пам'ять"},
            {"disk", "Диск"},
            {"battery", "Батарея"},
            {"network", "Мережа"},
            {"offline", "Не в мережі"},
            {"unknown", "Невідомо"},
            {"help", "Запустіть: linuxfetch --help для опцій"}
        };
        
        // Belarusian
        strings["be"] = {
            {"loading", "LinuxFetch 1.0 бэта 2"},
            {"title", "Інфармацыя аб сістэме"},
            {"os", "АС"},
            {"host", "Хост"},
            {"kernel", "Ядро"},
            {"uptime", "Час працы"},
            {"packages", "Пакеты"},
            {"shell", "Абалонка"},
            {"cpu", "Працэсар"},
            {"gpu", "Відэакарта"},
            {"memory", "Памяць"},
            {"disk", "Дыск"},
            {"battery", "Батарэя"},
            {"network", "Сетка"},
            {"offline", "Не ў сетцы"},
            {"unknown", "Невядома"},
            {"help", "Запусціце: linuxfetch --help для опцый"}
        };
        
        // Finnish
        strings["fi"] = {
            {"loading", "LinuxFetch 1.0 beta 2"},
            {"title", "Järjestelmätiedot"},
            {"os", "Käyttöjärjestelmä"},
            {"host", "Isäntä"},
            {"kernel", "Kernel"},
            {"uptime", "Käyntiaika"},
            {"packages", "Paketit"},
            {"shell", "Käyttöliittymä"},
            {"cpu", "Suoritin"},
            {"gpu", "Näytönohjain"},
            {"memory", "Muisti"},
            {"disk", "Levytila"},
            {"battery", "Paristo"},
            {"network", "Verkko"},
            {"offline", "Offline"},
            {"unknown", "Tuntematon"},
            {"help", "Suorita: linuxfetch --help vaihtoehdoille"}
        };
    }
    
    std::string detectLanguage() const {
        if (config.language != "auto") return config.language;
        
        const char* lang = std::getenv("LANG");
        if (!lang) return "en";
        
        std::string lang_str = lang;
        if (lang_str.find("ru") == 0) return "ru";
        if (lang_str.find("uk") == 0) return "uk";
        if (lang_str.find("be") == 0) return "be";
        if (lang_str.find("fi") == 0) return "fi";
        return "en";
    }
    
    std::string get(const std::string& key) const {
        std::string lang = detectLanguage();
        auto lang_it = strings.find(lang);
        if (lang_it != strings.end()) {
            auto key_it = lang_it->second.find(key);
            if (key_it != lang_it->second.end()) return key_it->second;
        }
        
        auto en_it = strings.find("en");
        if (en_it != strings.end()) {
            auto key_it = en_it->second.find(key);
            if (key_it != en_it->second.end()) return key_it->second;
        }
        
        return key; // Fallback
    }
};

// ============ СИСТЕМНАЯ ИНФОРМАЦИЯ ============
class SystemInfo {
private:
    Config config;
    Language lang;
    
public:
    SystemInfo(const Config& cfg) : config(cfg), lang(cfg) {}
    
    std::string getOS() const {
        std::ifstream file("/etc/os-release");
        if (file.is_open()) {
            std::string line;
            while (std::getline(file, line)) {
                if (line.find("PRETTY_NAME=") == 0) {
                    size_t start = line.find('"');
                    size_t end = line.rfind('"');
                    if (start != std::string::npos && end != std::string::npos && start < end) {
                        return line.substr(start + 1, end - start - 1);
                    }
                }
            }
        }
        
        // Используем уникальный указатель для автоматического закрытия
        std::unique_ptr<FILE, decltype(&pclose)> pipe(popen("lsb_release -ds 2>/dev/null", "r"), pclose);
        if (pipe) {
            char buffer[256];
            if (fgets(buffer, sizeof(buffer), pipe.get())) {
                std::string result = buffer;
                if (!result.empty() && result.back() == '\n') result.pop_back();
                return result;
            }
        }
        
        return lang.get("unknown");
    }
    
    std::string getHost() const {
        std::ifstream file("/sys/devices/virtual/dmi/id/product_name");
        if (file.is_open()) {
            std::string line;
            if (std::getline(file, line)) {
                return line;
            }
        }
        return lang.get("unknown");
    }
    
    std::string getKernel() const {
        struct utsname buf;
        if (uname(&buf) == 0) {
            return std::string(buf.release);
        }
        return "Unknown";
    }
    
    std::string getUptime() const {
        struct sysinfo info;
        if (sysinfo(&info) == 0) {
            long uptime = info.uptime;
            int days = uptime / 86400;
            int hours = (uptime % 86400) / 3600;
            int minutes = (uptime % 3600) / 60;
            
            std::string lang_code = lang.detectLanguage();
            
            if (days > 0) {
                if (lang_code == "ru") return std::to_string(days) + "д " + std::to_string(hours) + "ч " + std::to_string(minutes) + "м";
                if (lang_code == "uk") return std::to_string(days) + "д " + std::to_string(hours) + "г " + std::to_string(minutes) + "хв";
                if (lang_code == "be") return std::to_string(days) + "дз " + std::to_string(hours) + "г " + std::to_string(minutes) + "хв";
                if (lang_code == "fi") return std::to_string(days) + "p " + std::to_string(hours) + "t " + std::to_string(minutes) + "min";
                return std::to_string(days) + "d " + std::to_string(hours) + "h " + std::to_string(minutes) + "m";
            } else if (hours > 0) {
                if (lang_code == "ru") return std::to_string(hours) + "ч " + std::to_string(minutes) + "м";
                if (lang_code == "uk") return std::to_string(hours) + "г " + std::to_string(minutes) + "хв";
                if (lang_code == "be") return std::to_string(hours) + "г " + std::to_string(minutes) + "хв";
                if (lang_code == "fi") return std::to_string(hours) + "t " + std::to_string(minutes) + "min";
                return std::to_string(hours) + "h " + std::to_string(minutes) + "m";
            } else {
                if (lang_code == "ru") return std::to_string(minutes) + "м";
                if (lang_code == "uk") return std::to_string(minutes) + "хв";
                if (lang_code == "be") return std::to_string(minutes) + "хв";
                if (lang_code == "fi") return std::to_string(minutes) + "min";
                return std::to_string(minutes) + "m";
            }
        }
        return "N/A";
    }
    
    int getPackageCount() const {
        const char* commands[] = {
            "pacman -Q 2>/dev/null | wc -l",
            "dpkg -l 2>/dev/null | grep '^ii' | wc -l",
            "rpm -qa 2>/dev/null | wc -l",
            "xbps-query -l 2>/dev/null | grep '^ii' | wc -l",
            "apk info 2>/dev/null | wc -l",
            "nix-env -q 2>/dev/null | wc -l",
            nullptr
        };
        
        for (int i = 0; commands[i] != nullptr; i++) {
            std::unique_ptr<FILE, decltype(&pclose)> pipe(popen(commands[i], "r"), pclose);
            if (pipe) {
                char buffer[32];
                if (fgets(buffer, sizeof(buffer), pipe.get())) {
                    int count = std::atoi(buffer);
                    if (count > 0) return count;
                }
            }
        }
        return 0;
    }
    
    std::string getShell() const {
        const char* shell = std::getenv("SHELL");
        if (shell) {
            std::string shell_str = shell;
            size_t pos = shell_str.find_last_of('/');
            if (pos != std::string::npos) {
                return shell_str.substr(pos + 1);
            }
            return shell_str;
        }
        return "Unknown";
    }
    
    std::string getCPU() const {
        std::ifstream file("/proc/cpuinfo");
        if (file.is_open()) {
            std::string line;
            while (std::getline(file, line)) {
                if (line.find("model name") != std::string::npos) {
                    size_t pos = line.find(':');
                    if (pos != std::string::npos) {
                        std::string model = line.substr(pos + 2);
                        if (model.length() > 40) {
                            model = model.substr(0, 37) + "...";
                        }
                        return model;
                    }
                }
            }
        }
        return "Unknown";
    }
    
    std::string getGPU() const {
        std::unique_ptr<FILE, decltype(&pclose)> pipe(popen("lspci 2>/dev/null | grep -i 'vga\\|3d\\|display' | head -1", "r"), pclose);
        if (pipe) {
            char buffer[256];
            if (fgets(buffer, sizeof(buffer), pipe.get())) {
                std::string gpu = buffer;
                size_t pos = gpu.find(':');
                if (pos != std::string::npos && pos + 2 < gpu.length()) {
                    std::string result = gpu.substr(pos + 2);
                    if (!result.empty() && result.back() == '\n') result.pop_back();
                    if (result.length() > 40) {
                        result = result.substr(0, 37) + "...";
                    }
                    return result;
                }
                if (!gpu.empty() && gpu.back() == '\n') gpu.pop_back();
                return gpu;
            }
        }
        return "N/A";
    }
    
    std::pair<int, std::string> getMemory() const {
        std::ifstream file("/proc/meminfo");
        if (file.is_open()) {
            long total = 0, free = 0, buffers = 0, cached = 0;
            std::string line;
            
            while (std::getline(file, line)) {
                if (line.find("MemTotal:") == 0) {
                    total = std::stol(line.substr(9));
                } else if (line.find("MemFree:") == 0) {
                    free = std::stol(line.substr(8));
                } else if (line.find("Buffers:") == 0) {
                    buffers = std::stol(line.substr(8));
                } else if (line.find("Cached:") == 0) {
                    cached = std::stol(line.substr(7));
                }
            }
            
            if (total > 0) {
                long used = total - free - buffers - cached;
                int percent = (used * 100) / total;
                
                double used_gb = used / 1048576.0;
                double total_gb = total / 1048576.0;
                
                std::string lang_code = lang.detectLanguage();
                std::string unit;
                
                if (lang_code == "ru" || lang_code == "uk" || lang_code == "be") {
                    unit = "ГБ";
                } else if (lang_code == "fi") {
                    unit = "GT";
                } else {
                    unit = "GB";
                }
                
                std::ostringstream oss;
                oss << std::fixed << std::setprecision(1) << used_gb << unit << " / " << total_gb << unit;
                
                return {percent, oss.str()};
            }
        }
        return {0, "N/A"};
    }
    
    std::pair<int, std::string> getDisk() const {
#ifdef __linux__
        struct statvfs buf;
        if (statvfs("/", &buf) == 0) {
            unsigned long long total = buf.f_blocks * buf.f_frsize;
            unsigned long long free = buf.f_bfree * buf.f_frsize;
            unsigned long long used = total - free;
            int percent = (used * 100) / total;
            
            double used_gb = used / 1073741824.0;
            double total_gb = total / 1073741824.0;
            
            std::ostringstream oss;
            oss << std::fixed << std::setprecision(1) << used_gb << "GB / " << total_gb << "GB";
            
            return {percent, oss.str()};
        }
#endif
        return {0, "N/A"};
    }
    
    std::string getBattery() const {
        std::string battery_path = "/sys/class/power_supply/BAT0";
        if (fs::exists(battery_path)) {
            std::ifstream capacity_file(battery_path + "/capacity");
            std::ifstream status_file(battery_path + "/status");
            
            if (capacity_file.is_open()) {
                std::string capacity;
                std::getline(capacity_file, capacity);
                
                std::string status = "Unknown";
                if (status_file.is_open()) {
                    std::getline(status_file, status);
                }
                
                if (status == "Charging") {
                    return "⚡ " + capacity + "%";
                } else {
                    return "🔋 " + capacity + "%";
                }
            }
        }
        return "N/A";
    }
    
    std::string getNetwork() const {
        std::unique_ptr<FILE, decltype(&pclose)> pipe(popen("ip route 2>/dev/null | grep default | awk '{print $5}' | head -1", "r"), pclose);
        if (pipe) {
            char interface[32] = {0};
            if (fgets(interface, sizeof(interface), pipe.get())) {
                std::string iface = interface;
                if (!iface.empty() && iface.back() == '\n') iface.pop_back();
                
                if (!iface.empty()) {
                    std::string cmd = "ip addr show " + iface + " 2>/dev/null | grep -oP 'inet \\K[\\d.]+' | head -1";
                    std::unique_ptr<FILE, decltype(&pclose)> pipe2(popen(cmd.c_str(), "r"), pclose);
                    if (pipe2) {
                        char ip[32] = {0};
                        if (fgets(ip, sizeof(ip), pipe2.get())) {
                            std::string ip_str = ip;
                            if (!ip_str.empty() && ip_str.back() == '\n') ip_str.pop_back();
                            return "🌐 " + ip_str;
                        }
                    }
                }
            }
        }
        return "📡 " + lang.get("offline");
    }
};

// ============ ЛОГОТИПЫ ============
class Logo {
private:
    std::map<std::string, std::vector<std::string>> logos;
    
public:
    Logo() {
        initLogos();
    }
    
    void initLogos() {
        logos["arch"] = {
            "      /\\",
            "     /  \\",
            "    / /\\ \\",
            "   / /  \\ \\",
            "  / /    \\ \\",
            " / / _____\\ \\",
            "/_/  `----.\\_\\"
        };
        
        logos["debian"] = {
            "    _____",
            "   /  __ \\",
            "  |  /   |",
            "  |  \\__-",
            "  -_",
            "    --_"
        };
        
        logos["ubuntu"] = {
            "     _////",
            "   _\\\\( )",
            "  //(__)",
            "    )(",
            "    (_)"
        };
        
        logos["fedora"] = {
            "   ______",
            "  /  __  \\",
            " /  |  |  \\",
            "/  /    \\  \\",
            "\\  \\____/  /",
            "  \\______/"
        };
        
        logos["tux"] = {
            "   .--.",
            "  |o_o |",
            "  |:_/ |",
            " //   \\ \\",
            "(|     | )",
            "/ \\_  _/ \\",
            "\\/(__)(__)/"
        };
    }
    
    std::string detectDistro() const {
        std::ifstream file("/etc/os-release");
        if (file.is_open()) {
            std::string line;
            while (std::getline(file, line)) {
                if (line.find("ID=") == 0) {
                    std::string id = line.substr(3);
                    if (id.front() == '"' && id.back() == '"') {
                        id = id.substr(1, id.length() - 2);
                    }
                    
                    if (id == "arch" || id == "archlinux") return "arch";
                    if (id == "debian") return "debian";
                    if (id == "ubuntu") return "ubuntu";
                    if (id == "fedora") return "fedora";
                    if (id == "linuxmint") return "ubuntu";
                    break;
                }
            }
        }
        return "tux";
    }
    
    void print(const std::string& name, int color) const {
        auto it = logos.find(name);
        if (it == logos.end()) {
            it = logos.find("tux");
        }
        
        for (const auto& line : it->second) {
            std::cout << Color::fg(color) << line << Color::reset() << std::endl;
        }
    }
};

// ============ ОСНОВНАЯ ПРОГРАММА ============
class LinuxFetch {
private:
    Config config;
    Language lang;
    SystemInfo sysinfo;
    Logo logo;
    
public:
    LinuxFetch(const Config& cfg) : config(cfg), lang(cfg), sysinfo(cfg), logo() {}
    
    void showLoading() const {
        std::cout << "\n  " << Color::colored(33, lang.get("loading")) << std::endl;
        std::cout << "  [";
        
        for (int i = 0; i < 20; i++) {
            std::cout << Color::colored(32, "█");
            std::cout.flush();
            usleep(150000);
        }
        
        std::cout << "]" << std::endl;
        usleep(500000);
        
        system("clear");
    }
    
    void showASCIIArt() const {
        std::vector<std::string> art = {
            "    ╔══════════════════════════════╗",
            "    ║     LINUXFETCH v1.0 β2      ║",
            "    ╚══════════════════════════════╝",
            "       Fast • Custom • Beautiful"
        };
        
        for (const auto& line : art) {
            std::cout << Color::colored(33, line) << std::endl;
        }
        std::cout << std::endl;
    }
    
    std::string progressBar(int percent, int width = 25) const {
        int filled = (percent * width) / 100;
        std::string bar = "[";
        
        for (int i = 0; i < filled; i++) bar += "▓";
        for (int i = 0; i < width - filled; i++) bar += "░";
        bar += "]";
        
        if (percent >= config.memory_warn) {
            return Color::warn(bar + " " + std::to_string(percent) + "%");
        } else if (percent >= 60) {
            return Color::colored(214, bar + " " + std::to_string(percent) + "%");
        } else {
            return Color::ok(bar + " " + std::to_string(percent) + "%");
        }
    }
    
    void showColorBlocks() const {
        std::cout << "  ";
        for (int i = 0; i < 8; i++) {
            std::cout << Color::bg(i) << "  " << Color::reset();
        }
        std::cout << " ";
        for (int i = 8; i < 16; i++) {
            std::cout << Color::bg(i) << "  " << Color::reset();
        }
        std::cout << std::endl;
    }
    
    std::string getRandomQuote() const {
        std::string lang_code = lang.detectLanguage();
        std::vector<std::string> quotes;
        
        if (lang_code == "ru") {
            quotes = {
                "Век живи — век учись.",
                "Кто ищет, тот всегда найдёт.",
                "Без труда не вытащишь и рыбку из пруда.",
                "Учиться, учиться и ещё раз учиться! - Ленин",
                "Лучше один раз увидеть, чем сто раз услышать."
            };
        } else if (lang_code == "uk") {
            quotes = {
                "Вік живи — вік учись.",
                "Хто шукає, той завжди знайде.",
                "Без праці не витягнеш і рибку з ставка.",
                "Вчитися, вчитися і ще раз вчитися!",
                "Краще один раз побачити, ніж сто разів почути."
            };
        } else if (lang_code == "be") {
            quotes = {
                "Век жыві — век вучыся.",
                "Хто шукае, той заўсёды знойдзе.",
                "Без працы не выцягнеш і рыбку з сажалкі.",
                "Вучыцца, вучыцца і яшчэ раз вучыцца!",
                "Лепш адзін раз убачыць, чым сто разоў пачуць."
            };
        } else if (lang_code == "fi") {
            quotes = {
                "Elä oppi, elä opi.",
                "Etsijä aina löytää.",
                "Ilman työtä ei kalaa saa.",
                "Opiskele, opiskele ja opiskele vielä kerran!",
                "Parempi nähdä kerran kuin kuulla sata kertaa."
            };
        } else {
            quotes = {
                "The only way to do great work is to love what you do. - Steve Jobs",
                "Simplicity is the ultimate sophistication. - Leonardo da Vinci",
                "Talk is cheap. Show me the code. - Linus Torvalds",
                "Linux is only free if your time has no value. - Jamie Zawinski",
                "Stay hungry, stay foolish. - Steve Jobs"
            };
        }
        
        std::srand(std::time(nullptr));
        int index = std::rand() % quotes.size();
        return quotes[index];
    }
    
    void run() const {
        showLoading();
        showASCIIArt();
        
        std::cout << "  " << Color::colored(245, "Language: " + lang.detectLanguage()) << std::endl;
        std::cout << std::endl;
        
        std::cout << Color::title("╭─ " + lang.get("title") + " ─╮") << std::endl;
        std::cout << std::endl;
        
        if (config.show_logo) {
            std::string logo_name = (config.logo_type == "auto") ? logo.detectDistro() : config.logo_type;
            logo.print(logo_name, config.logo_color);
            std::cout << "  ";
        }
        
        std::vector<std::string> info_lines;
        
        if (config.show_os) {
            info_lines.push_back(Color::accent(lang.get("os")) + " : " + 
                                Color::value(sysinfo.getOS()));
        }
        
        if (config.show_host) {
            info_lines.push_back(Color::accent(lang.get("host")) + " : " + 
                                Color::value(sysinfo.getHost()));
        }
        
        if (config.show_kernel) {
            info_lines.push_back(Color::accent(lang.get("kernel")) + " : " + 
                                Color::value(sysinfo.getKernel()));
        }
        
        if (config.show_uptime) {
            info_lines.push_back(Color::accent(lang.get("uptime")) + " : " + 
                                Color::value(sysinfo.getUptime()));
        }
        
        if (config.show_packages) {
            int packages = sysinfo.getPackageCount();
            info_lines.push_back(Color::accent(lang.get("packages")) + " : " + 
                                Color::value(std::to_string(packages)));
        }
        
        if (config.show_shell) {
            info_lines.push_back(Color::accent(lang.get("shell")) + " : " + 
                                Color::value(sysinfo.getShell()));
        }
        
        if (config.show_cpu) {
            info_lines.push_back(Color::accent(lang.get("cpu")) + " : " + 
                                Color::value(sysinfo.getCPU()));
        }
        
        if (config.show_gpu) {
            std::string gpu = sysinfo.getGPU();
            if (gpu != "N/A") {
                info_lines.push_back(Color::accent(lang.get("gpu")) + " : " + 
                                    Color::value(gpu));
            }
        }
        
        if (config.show_network) {
            info_lines.push_back(Color::accent(lang.get("network")) + " : " + 
                                Color::value(sysinfo.getNetwork()));
        }
        
        for (const auto& line : info_lines) {
            std::cout << "  " << std::left << std::setw(45) << line << std::endl;
        }
        
        std::cout << std::endl;
        
        if (config.show_bar) {
            if (config.show_memory) {
                auto memory = sysinfo.getMemory();
                std::cout << "  " << Color::accent(lang.get("memory")) << " : " 
                          << progressBar(memory.first) << std::endl;
            }
            
            if (config.show_disk) {
                auto disk = sysinfo.getDisk();
                std::cout << "  " << Color::accent(lang.get("disk")) << " : " 
                          << progressBar(disk.first) << std::endl;
            }
        } else {
            if (config.show_memory) {
                auto memory = sysinfo.getMemory();
                std::cout << "  " << Color::accent(lang.get("memory")) << " : " 
                          << Color::value(memory.second) << std::endl;
            }
            
            if (config.show_disk) {
                auto disk = sysinfo.getDisk();
                std::cout << "  " << Color::accent(lang.get("disk")) << " : " 
                          << Color::value(disk.second) << std::endl;
            }
        }
        
        if (config.show_battery) {
            std::cout << "  " << Color::accent(lang.get("battery")) << " : " 
                      << Color::value(sysinfo.getBattery()) << std::endl;
        }
        
        std::cout << std::endl;
        
        if (config.show_color_blocks) {
            showColorBlocks();
            std::cout << std::endl;
        }
        
        if (config.show_quote) {
            std::cout << "  " << Color::colored(245, getRandomQuote()) << std::endl;
            std::cout << std::endl;
        }
        
        std::cout << Color::title("╰───────────────────────────────────╯") << std::endl;
        std::cout << std::endl;
        
        std::cout << "  " << Color::colored(33, lang.get("help")) << std::endl;
        std::cout << "  " << Color::colored(245, "Language settings: --lang=ru (en, ru, uk, be, fi)") << std::endl;
    }
};

int main(int argc, char* argv[]) {
    Config config;
    
    // Обработка аргументов командной строки
    for (int i = 1; i < argc; i++) {
        std::string arg = argv[i];
        if (arg == "--help" || arg == "-h") {
            std::cout << "LinuxFetch 1.0 - System Information Tool" << std::endl;
            std::cout << "Usage: linuxfetch [OPTIONS]" << std::endl;
            std::cout << "Options:" << std::endl;
            std::cout << "  --lang=LANG    Set language (en, ru, uk, be, fi)" << std::endl;
            std::cout << "  --help, -h     Show this help" << std::endl;
            return 0;
        } else if (arg.find("--lang=") == 0) {
            config.language = arg.substr(7);
        }
    }
    
    try {
        LinuxFetch fetch(config);
        fetch.run();
    } catch (const std::exception& e) {
        std::cerr << "Error: " << e.what() << std::endl;
        return 1;
    }
    
    return 0;
}
