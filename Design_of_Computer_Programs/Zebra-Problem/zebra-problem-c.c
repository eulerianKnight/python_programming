#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdbool.h>

/**
 * Categories of attributes in the Zebra Puzzle
 */
typedef enum {
    COLOR,
    NATIONALITY,
    DRINK,
    SMOKE,
    PET,
    NUM_CATEGORIES
} Category;

/**
 * An attribute in the Zebra Puzzle with its category and name
 */
typedef struct {
    Category category;
    const char* name;
} Attribute;

/**
 * A house in the Zebra Puzzle with its position and attributes
 */
typedef struct {
    int position; /* 0-based index, where 0 is the leftmost house */
    Attribute* attributes[NUM_CATEGORIES]; /* One attribute per category */
} House;

/* Number of houses in the puzzle */
#define NUM_HOUSES 5

/* Total number of attributes per category */
#define NUM_ATTRIBUTES_PER_CATEGORY 5

/* Total number of attributes across all categories */
#define TOTAL_ATTRIBUTES (NUM_CATEGORIES * NUM_ATTRIBUTES_PER_CATEGORY)

/**
 * The Zebra Puzzle solver
 */
typedef struct {
    /* Attributes by category */
    Attribute colors[NUM_ATTRIBUTES_PER_CATEGORY];
    Attribute nationalities[NUM_ATTRIBUTES_PER_CATEGORY];
    Attribute drinks[NUM_ATTRIBUTES_PER_CATEGORY];
    Attribute smokes[NUM_ATTRIBUTES_PER_CATEGORY];
    Attribute pets[NUM_ATTRIBUTES_PER_CATEGORY];
    
    /* All attributes combined */
    Attribute all_attributes[TOTAL_ATTRIBUTES];
    
    /* Houses in the puzzle */
    House houses[NUM_HOUSES];
    
    /* Solution houses when found */
    House solution[NUM_HOUSES];
    
    /* Flag to indicate if a solution was found */
    bool has_solution;
} ZebraPuzzle;

/**
 * Initialize the Zebra Puzzle with attributes and houses
 */
void zebra_puzzle_init(ZebraPuzzle* puzzle) {
    /* Initialize colors */
    puzzle->colors[0] = (Attribute){COLOR, "red"};
    puzzle->colors[1] = (Attribute){COLOR, "green"};
    puzzle->colors[2] = (Attribute){COLOR, "white"};
    puzzle->colors[3] = (Attribute){COLOR, "yellow"};
    puzzle->colors[4] = (Attribute){COLOR, "blue"};
    
    /* Initialize nationalities */
    puzzle->nationalities[0] = (Attribute){NATIONALITY, "Englishman"};
    puzzle->nationalities[1] = (Attribute){NATIONALITY, "Spaniard"};
    puzzle->nationalities[2] = (Attribute){NATIONALITY, "Ukrainian"};
    puzzle->nationalities[3] = (Attribute){NATIONALITY, "Norwegian"};
    puzzle->nationalities[4] = (Attribute){NATIONALITY, "Japanese"};
    
    /* Initialize drinks */
    puzzle->drinks[0] = (Attribute){DRINK, "coffee"};
    puzzle->drinks[1] = (Attribute){DRINK, "tea"};
    puzzle->drinks[2] = (Attribute){DRINK, "milk"};
    puzzle->drinks[3] = (Attribute){DRINK, "orange juice"};
    puzzle->drinks[4] = (Attribute){DRINK, "water"};
    
    /* Initialize smokes */
    puzzle->smokes[0] = (Attribute){SMOKE, "Old Gold"};
    puzzle->smokes[1] = (Attribute){SMOKE, "Kools"};
    puzzle->smokes[2] = (Attribute){SMOKE, "Chesterfields"};
    puzzle->smokes[3] = (Attribute){SMOKE, "Lucky Strike"};
    puzzle->smokes[4] = (Attribute){SMOKE, "Parliaments"};
    
    /* Initialize pets */
    puzzle->pets[0] = (Attribute){PET, "dog"};
    puzzle->pets[1] = (Attribute){PET, "snails"};
    puzzle->pets[2] = (Attribute){PET, "fox"};
    puzzle->pets[3] = (Attribute){PET, "horse"};
    puzzle->pets[4] = (Attribute){PET, "zebra"};
    
    /* Combine all attributes for easier access */
    int index = 0;
    for (int i = 0; i < NUM_ATTRIBUTES_PER_CATEGORY; i++) {
        puzzle->all_attributes[index++] = puzzle->colors[i];
    }
    for (int i = 0; i < NUM_ATTRIBUTES_PER_CATEGORY; i++) {
        puzzle->all_attributes[index++] = puzzle->nationalities[i];
    }
    for (int i = 0; i < NUM_ATTRIBUTES_PER_CATEGORY; i++) {
        puzzle->all_attributes[index++] = puzzle->drinks[i];
    }
    for (int i = 0; i < NUM_ATTRIBUTES_PER_CATEGORY; i++) {
        puzzle->all_attributes[index++] = puzzle->smokes[i];
    }
    for (int i = 0; i < NUM_ATTRIBUTES_PER_CATEGORY; i++) {
        puzzle->all_attributes[index++] = puzzle->pets[i];
    }
    
    /* Initialize houses */
    for (int i = 0; i < NUM_HOUSES; i++) {
        puzzle->houses[i].position = i;
        for (int j = 0; j < NUM_CATEGORIES; j++) {
            puzzle->houses[i].attributes[j] = NULL;
        }
    }
    
    /* No solution initially */
    puzzle->has_solution = false;
}

/**
 * Get an attribute by name
 */
Attribute* get_attribute_by_name(ZebraPuzzle* puzzle, const char* name) {
    for (int i = 0; i < TOTAL_ATTRIBUTES; i++) {
        if (strcmp(puzzle->all_attributes[i].name, name) == 0) {
            return &puzzle->all_attributes[i];
        }
    }
    return NULL;
}

/**
 * Find a house with a specific attribute
 */
House* find_house_with_attribute(House houses[NUM_HOUSES], Attribute* attr) {
    if (attr == NULL) {
        return NULL;
    }
    
    for (int i = 0; i < NUM_HOUSES; i++) {
        if (houses[i].attributes[attr->category] == attr) {
            return &houses[i];
        }
    }
    
    return NULL;
}

/**
 * Check if all puzzle constraints are satisfied by the current arrangement
 */
bool check_constraints(ZebraPuzzle* puzzle) {
    /* Get attribute pointers for easier constraint checking */
    Attribute* red = get_attribute_by_name(puzzle, "red");
    Attribute* green = get_attribute_by_name(puzzle, "green");
    Attribute* white = get_attribute_by_name(puzzle, "white");
    Attribute* yellow = get_attribute_by_name(puzzle, "yellow");
    Attribute* blue = get_attribute_by_name(puzzle, "blue");
    
    Attribute* englishman = get_attribute_by_name(puzzle, "Englishman");
    Attribute* spaniard = get_attribute_by_name(puzzle, "Spaniard");
    Attribute* ukrainian = get_attribute_by_name(puzzle, "Ukrainian");
    Attribute* norwegian = get_attribute_by_name(puzzle, "Norwegian");
    Attribute* japanese = get_attribute_by_name(puzzle, "Japanese");
    
    Attribute* coffee = get_attribute_by_name(puzzle, "coffee");
    Attribute* tea = get_attribute_by_name(puzzle, "tea");
    Attribute* milk = get_attribute_by_name(puzzle, "milk");
    Attribute* oj = get_attribute_by_name(puzzle, "orange juice");
    Attribute* water = get_attribute_by_name(puzzle, "water");
    
    Attribute* old_gold = get_attribute_by_name(puzzle, "Old Gold");
    Attribute* kools = get_attribute_by_name(puzzle, "Kools");
    Attribute* chesterfields = get_attribute_by_name(puzzle, "Chesterfields");
    Attribute* lucky_strike = get_attribute_by_name(puzzle, "Lucky Strike");
    Attribute* parliaments = get_attribute_by_name(puzzle, "Parliaments");
    
    Attribute* dog = get_attribute_by_name(puzzle, "dog");
    Attribute* snails = get_attribute_by_name(puzzle, "snails");
    Attribute* fox = get_attribute_by_name(puzzle, "fox");
    Attribute* horse = get_attribute_by_name(puzzle, "horse");
    Attribute* zebra = get_attribute_by_name(puzzle, "zebra");
    
    House* houses = puzzle->houses;
    
    /* 1. The Norwegian lives in the first house */
    if (houses[0].attributes[NATIONALITY] != norwegian) {
        return false;
    }
    
    /* 2. The Englishman lives in the red house */
    House* englishman_house = find_house_with_attribute(houses, englishman);
    House* red_house = find_house_with_attribute(houses, red);
    if (englishman_house != red_house) {
        return false;
    }
    
    /* 3. The green house is immediately to the right of the white house */
    House* green_house = find_house_with_attribute(houses, green);
    House* white_house = find_house_with_attribute(houses, white);
    if (green_house == NULL || white_house == NULL || 
        green_house->position != white_house->position + 1) {
        return false;
    }
    
    /* 4. Coffee is drunk in the green house */
    House* coffee_house = find_house_with_attribute(houses, coffee);
    if (coffee_house != green_house) {
        return false;
    }
    
    /* 5. The Ukrainian drinks tea */
    House* ukrainian_house = find_house_with_attribute(houses, ukrainian);
    House* tea_house = find_house_with_attribute(houses, tea);
    if (ukrainian_house != tea_house) {
        return false;
    }
    
    /* 6. Milk is drunk in the middle house */
    House* milk_house = find_house_with_attribute(houses, milk);
    if (milk_house == NULL || milk_house->position != 2) {
        return false;
    }
    
    /* 7. The Norwegian lives next to the blue house */
    House* norwegian_house = find_house_with_attribute(houses, norwegian);
    House* blue_house = find_house_with_attribute(houses, blue);
    int norwegian_pos = norwegian_house->position;
    int blue_pos = blue_house->position;
    if (abs(norwegian_pos - blue_pos) != 1) {
        return false;
    }
    
    /* 8. Kools are smoked in the yellow house */
    House* kools_house = find_house_with_attribute(houses, kools);
    House* yellow_house = find_house_with_attribute(houses, yellow);
    if (kools_house != yellow_house) {
        return false;
    }
    
    /* 9. The Lucky Strike smoker drinks orange juice */
    House* lucky_strike_house = find_house_with_attribute(houses, lucky_strike);
    House* oj_house = find_house_with_attribute(houses, oj);
    if (lucky_strike_house != oj_house) {
        return false;
    }
    
    /* 10. The Japanese smokes Parliaments */
    House* japanese_house = find_house_with_attribute(houses, japanese);
    House* parliaments_house = find_house_with_attribute(houses, parliaments);
    if (japanese_house != parliaments_house) {
        return false;
    }
    
    /* 11. The Spaniard owns the dog */
    House* spaniard_house = find_house_with_attribute(houses, spaniard);
    House* dog_house = find_house_with_attribute(houses, dog);
    if (spaniard_house != dog_house) {
        return false;
    }
    
    /* 12. The Old Gold smoker owns snails */
    House* old_gold_house = find_house_with_attribute(houses, old_gold);
    House* snails_house = find_house_with_attribute(houses, snails);
    if (old_gold_house != snails_house) {
        return false;
    }
    
    /* 13. The Kools smoker lives next to the horse owner */
    House* horse_house = find_house_with_attribute(houses, horse);
    int kools_pos = kools_house->position;
    int horse_pos = horse_house->position;
    if (abs(kools_pos - horse_pos) != 1) {
        return false;
    }
    
    /* 14. The Chesterfields smoker lives next to the fox owner */
    House* chesterfields_house = find_house_with_attribute(houses, chesterfields);
    House* fox_house = find_house_with_attribute(houses, fox);
    int chesterfields_pos = chesterfields_house->position;
    int fox_pos = fox_house->position;
    if (abs(chesterfields_pos - fox_pos) != 1) {
        return false;
    }
    
    /* All constraints are satisfied */
    return true;
}

/**
 * Swap two attribute pointers
 */
void swap_attributes(Attribute** a, Attribute** b) {
    Attribute* temp = *a;
    *a = *b;
    *b = temp;
}

/**
 * Generate permutations using Heap's algorithm and check constraints
 * 
 * This is a recursive function that generates all possible permutations
 * of attributes for a category and checks puzzle constraints
 * 
 * @param puzzle The puzzle instance
 * @param category The category being permuted
 * @param attrs Array of attribute pointers to permute
 * @param size Current size of the permutation
 * @param next_category The next category to permute if this one is done
 * @return true if a solution is found, false otherwise
 */
bool permute_category(ZebraPuzzle* puzzle, Category category, Attribute** attrs, int size, Category next_category) {
    /* Base case: if size is 1, move to the next category or check solution */
    if (size == 1) {
        /* If this is the last category, check if we have a solution */
        if (category == PET) {
            if (check_constraints(puzzle)) {
                /* Save the solution */
                for (int i = 0; i < NUM_HOUSES; i++) {
                    puzzle->solution[i] = puzzle->houses[i];
                }
                puzzle->has_solution = true;
                return true;
            }
            return false;
        }
        
        /* Otherwise, move to the next category */
        Attribute** next_attrs = NULL;
        switch (next_category) {
            case NATIONALITY:
                next_attrs = (Attribute**)malloc(NUM_ATTRIBUTES_PER_CATEGORY * sizeof(Attribute*));
                for (int i = 0; i < NUM_ATTRIBUTES_PER_CATEGORY; i++) {
                    next_attrs[i] = &puzzle->nationalities[i];
                }
                break;
            case DRINK:
                next_attrs = (Attribute**)malloc(NUM_ATTRIBUTES_PER_CATEGORY * sizeof(Attribute*));
                for (int i = 0; i < NUM_ATTRIBUTES_PER_CATEGORY; i++) {
                    next_attrs[i] = &puzzle->drinks[i];
                }
                break;
            case SMOKE:
                next_attrs = (Attribute**)malloc(NUM_ATTRIBUTES_PER_CATEGORY * sizeof(Attribute*));
                for (int i = 0; i < NUM_ATTRIBUTES_PER_CATEGORY; i++) {
                    next_attrs[i] = &puzzle->smokes[i];
                }
                break;
            case PET:
                next_attrs = (Attribute**)malloc(NUM_ATTRIBUTES_PER_CATEGORY * sizeof(Attribute*));
                for (int i = 0; i < NUM_ATTRIBUTES_PER_CATEGORY; i++) {
                    next_attrs[i] = &puzzle->pets[i];
                }
                break;
            default:
                break;
        }
        
        bool found = permute_category(puzzle, next_category, next_attrs, NUM_ATTRIBUTES_PER_CATEGORY, next_category + 1);
        free(next_attrs);
        return found;
    }
    
    /* Recursive case: generate permutations */
    for (int i = 0; i < size; i++) {
        /* Assign the current permutation to houses */
        for (int j = 0; j < NUM_HOUSES; j++) {
            puzzle->houses[j].attributes[category] = attrs[j];
        }
        
        /* Try this arrangement */
        if (permute_category(puzzle, category, attrs, size - 1, next_category)) {
            return true;
        }
        
        /* Generate the next permutation */
        if (size % 2 == 1) {
            swap_attributes(&attrs[0], &attrs[size - 1]);
        } else {
            swap_attributes(&attrs[i], &attrs[size - 1]);
        }
    }
    
    return false;
}

/**
 * Solve the Zebra Puzzle
 * 
 * This function tries all possible assignments of attributes to houses
 * and checks if all constraints of the puzzle are satisfied.
 * 
 * @param puzzle The puzzle to solve
 * @return true if a solution was found, false otherwise
 */
bool zebra_puzzle_solve(ZebraPuzzle* puzzle) {
    /* Start by permuting colors */
    Attribute** color_attrs = (Attribute**)malloc(NUM_ATTRIBUTES_PER_CATEGORY * sizeof(Attribute*));
    for (int i = 0; i < NUM_ATTRIBUTES_PER_CATEGORY; i++) {
        color_attrs[i] = &puzzle->colors[i];
    }
    
    bool success = permute_category(puzzle, COLOR, color_attrs, NUM_ATTRIBUTES_PER_CATEGORY, NATIONALITY);
    
    free(color_attrs);
    return success;
}

/**
 * Find the nationality of the person who owns/has the given attribute
 * 
 * @param puzzle The solved puzzle
 * @param attribute_name The name of the attribute to find the owner of
 * @return The nationality name or NULL if not found
 */
const char* get_attribute_owner(ZebraPuzzle* puzzle, const char* attribute_name) {
    if (!puzzle->has_solution) {
        return NULL;
    }
    
    Attribute* attr = get_attribute_by_name(puzzle, attribute_name);
    if (attr == NULL) {
        return NULL;
    }
    
    House* house = find_house_with_attribute(puzzle->solution, attr);
    if (house == NULL) {
        return NULL;
    }
    
    return house->attributes[NATIONALITY]->name;
}

/**
 * Print the puzzle solution
 * 
 * @param puzzle The solved puzzle
 */
void print_solution(ZebraPuzzle* puzzle) {
    if (!puzzle->has_solution) {
        printf("No solution found.\n");
        return;
    }
    
    printf("\nZebra Puzzle Solution:\n");
    printf("=====================\n\n");
    
    /* Print each house with its attributes */
    for (int i = 0; i < NUM_HOUSES; i++) {
        printf("House %d:\n", i + 1);
        
        /* Print attributes by category */
        const char* category_names[] = {"Color", "Nationality", "Drink", "Smoke", "Pet"};
        for (int j = 0; j < NUM_CATEGORIES; j++) {
            if (puzzle->solution[i].attributes[j] != NULL) {
                printf("  %s: %s\n", category_names[j], puzzle->solution[i].attributes[j]->name);
            }
        }
        printf("\n");
    }
    
    /* Find who owns the zebra */
    const char* zebra_owner = get_attribute_owner(puzzle, "zebra");
    if (zebra_owner != NULL) {
        printf("The %s owns the zebra.\n", zebra_owner);
    }
    
    /* Find who drinks water */
    const char* water_drinker = get_attribute_owner(puzzle, "water");
    if (water_drinker != NULL) {
        printf("The %s drinks water.\n", water_drinker);
    }
}

/**
 * Main function to solve and display the Zebra Puzzle
 */
int main() {
    printf("Solving the Zebra Puzzle (Einstein's Riddle)...\n");
    printf("This may take a moment as we check all possible combinations...\n");
    
    /* Initialize the puzzle */
    ZebraPuzzle puzzle;
    zebra_puzzle_init(&puzzle);
    
    /* Solve the puzzle */
    if (zebra_puzzle_solve(&puzzle)) {
        /* Print the solution */
        print_solution(&puzzle);
    } else {
        printf("No solution could be found. Please check the puzzle constraints.\n");
    }
    
    return 0;
}