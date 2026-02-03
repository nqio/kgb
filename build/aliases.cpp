#include <assert.h>
#include <cstdlib>
#include <fstream>
#include <iostream>
#include <sstream>
#include <string>
#include <unordered_map>

std::unordered_map<std::string, std::string> aliases;
void manage_alias_creation(std::istringstream file);

template <typename in, typename out>
void evaluate(in& file, out& outfile) {
  std::string word;

no_log_line:
  while (std::getline(file, word)) {
    size_t index;
    while ((index = word.find('@')) != std::string::npos) {
      size_t original_index = index;
      index++;
      std::string fullword = "";
      while (std::isalnum(word[index]) || word[index] == '_') {
        fullword += word[index];
        index++;
      }

      if (fullword == "alias") {
        manage_alias_creation(std::istringstream(word));
        goto no_log_line;
      }

      if (aliases.count(fullword) == 0) {
        std::cout << "Word \"" << fullword << "\" not found!\n";
        assert(0);
      }

      word.replace(original_index, fullword.length() + 1, aliases[fullword]);
    }
    outfile << word << '\n';
  }
}

void manage_alias_creation(std::istringstream file) {
  std::string word;
  while (file >> word) {
    if (word.substr(0, 6) == "@alias") {
      while (word.find(")") == std::string::npos) {
        std::string next;
        if (!(file >> next)) {
          std::cout << "File ended before parenthesis closed:\n"
                    << word << '\n';
          assert(0);
        }

        word += next;
      }

      // now we have the full string with the parenthesis
      bool start_recording = false;
      bool switch_words = false;
      std::string var_name = "";
      std::string var_value = "";

      for (char c : word) {
        if (c == '(') {
          start_recording = true;
          continue;
        } else if (c == ')') {
          start_recording = false;
          continue;
        } else if (c == ',') {
          switch_words = true;
          continue;
        }

        if (start_recording) {
          if (!switch_words) {
            var_name += c;
          } else {
            var_value += c;
          }
        }

        if (var_name == "alias") {
          std::cout << "You can't name an alias \"alias\" :/\n";
          assert(0);
        }
      }
      std::ostringstream result("");
      std::istringstream inp(var_value);
      evaluate(inp, result);
      std::string sresult = result.str();

      aliases[var_name] = sresult.substr(0, sresult.length() - 1);
    }
  }
}

int main(int argc, char **argv) {
  assert(argc >= 3);
  std::ifstream infile(argv[1]); 
  std::ofstream outfile(argv[2]); 

  evaluate(infile, outfile);
  return EXIT_SUCCESS;
}
