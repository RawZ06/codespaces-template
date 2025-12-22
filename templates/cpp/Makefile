# Compilateur et flags
CXX = g++
CXXFLAGS = -Wall -Wextra -std=c++23 -O2
LDFLAGS =

# Répertoires
SRC_DIR = src
OBJ_DIR = obj
BIN_DIR = bin

# Nom de l'exécutable
TARGET = $(BIN_DIR)/program

# Récupération automatique de tous les fichiers .cpp dans src/
SRCS = $(wildcard $(SRC_DIR)/*.cpp)
OBJS = $(patsubst $(SRC_DIR)/%.cpp,$(OBJ_DIR)/%.o,$(SRCS))

# Règle par défaut
all: $(TARGET)

# Création de l'exécutable
$(TARGET): $(OBJS) | $(BIN_DIR)
	$(CXX) $(OBJS) -o $@ $(LDFLAGS)

# Compilation des fichiers objets
$(OBJ_DIR)/%.o: $(SRC_DIR)/%.cpp | $(OBJ_DIR)
	$(CXX) $(CXXFLAGS) -c $< -o $@

# Création des répertoires s'ils n'existent pas
$(OBJ_DIR):
	mkdir -p $(OBJ_DIR)

$(BIN_DIR):
	mkdir -p $(BIN_DIR)

# Nettoyage des fichiers de compilation
clean:
	rm -rf $(OBJ_DIR) $(BIN_DIR)

# Recompilation complète
rebuild: clean all

# Exécution du programme
run: $(TARGET)
	./$(TARGET)

.PHONY: all clean rebuild run
