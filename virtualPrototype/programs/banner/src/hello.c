#include <stdio.h>
#include <vga.h>

char hello[] =
" _________________ _               \n"
"|  ___| ___ \  ___| |              \n"
"| |__ | |_/ / |_  | |              \n"
"|  __||  __/|  _| | |              \n"
"| |___| |   | |   | |____          \n"
"\____/\_|   \_|   \_____/          \n"
"                                   \n"
"                                   \n"
" _____  _____     ___  __________  \n"
"/  __ \/  ___|   /   ||___  / ___| \n"
"| /  \/\ `--.   / /| |   / / /___  \n"
"| |     `--. \ / /_| |  / /| ___ \ \n"
"| \__/\/\__/ / \___  |./ / | \_/ | \n"
" \____/\____/      |_/\_/  \_____/ \n"
"______                             \n"
"|  _  \                            \n"
"| | | |___ _ __ ___   ___          \n"
"| | | / _ \ '_ ` _ \ / _ \         \n"
"| |/ /  __/ | | | | | (_) |        \n"
"|___/ \___|_| |_| |_|\___/         \n"
"   ___       _ _                  _        _____           _   _                        \n"
"  |_  |     | (_)                | |      /  __ \         | | | |                       \n"
"    | |_   _| |_  ___ _ __     __| | ___  | /  \/ __ _ ___| |_| | ___ _ __   __ _ _   _ \n"
"    | | | | | | |/ _ \ '_ \   / _` |/ _ \ | |    / _` / __| __| |/ _ \ '_ \ / _` | | | |\n"
"/\__/ / |_| | | |  __/ | | | | (_| |  __/ | \__/\ (_| \__ \ |_| |  __/ | | | (_| | |_| |\n"
"\____/ \__,_|_|_|\___|_| |_|  \__,_|\___|  \____/\__,_|___/\__|_|\___|_| |_|\__,_|\__,_|\n"
"                                                                    \n"
"                                                                    \n"
" _____                 ______      _            _                   \n"
"/  __ \                | ___ \    | |          | |                  \n"
"| /  \/ ___ _ __ ___   | |_/ / ___| | ___ _ __ | |_ ___ _ __   ___  \n"
"| |    / _ \ '_ ` _ \  | ___ \/ _ \ |/ _ \ '_ \| __/ _ \ '_ \ / _ \ \n"
"| \__/\  __/ | | | | | | |_/ /  __/ |  __/ | | | ||  __/ |_) |  __/ \n"
" \____/\___|_| |_| |_| \____/ \___|_|\___|_| |_|\__\___| .__/ \___| \n"
"                                                       | |          \n"
"                                                       |_|          \n";

int main () {
  vga_clear();
  for (size_t i = 0; i < sizeof(hello); i++)
  {
    putchar(hello[i]);
  }
  
}
