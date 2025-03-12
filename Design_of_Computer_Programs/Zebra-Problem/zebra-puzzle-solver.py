from dataclasses import dataclass
from enum import Enum, auto
from typing import Dict, List, Optional, Tuple
from itertools import permutations


class Category(Enum):
    """Categories of attributes in the Zebra Puzzle."""
    COLOR = auto()
    NATIONALITY = auto()
    DRINK = auto()
    SMOKE = auto()
    PET = auto()


@dataclass
class Attribute:
    """An attribute in the Zebra Puzzle with its category and name."""
    category: Category
    name: str


@dataclass
class House:
    """A house in the Zebra Puzzle with its attributes."""
    position: int  # 0-based index, where 0 is the leftmost house
    attributes: Dict[Category, Attribute]


class ZebraPuzzle:
    """
    A solver for the Zebra Puzzle (Einstein's Riddle).
    
    The classic puzzle involves 5 houses in a row, each with different attributes:
    - A resident of a specific nationality
    - A color
    - A pet
    - A preferred drink
    - A preferred brand of cigarettes
    
    The goal is to determine who owns the zebra and who drinks water based on a set of clues.
    """

    def __init__(self) -> None:
        """Initialize the puzzle with attributes and constraints."""
        # Define all attributes by category
        self.colors = [
            Attribute(Category.COLOR, "red"),
            Attribute(Category.COLOR, "green"),
            Attribute(Category.COLOR, "white"),
            Attribute(Category.COLOR, "yellow"),
            Attribute(Category.COLOR, "blue")
        ]
        
        self.nationalities = [
            Attribute(Category.NATIONALITY, "Englishman"),
            Attribute(Category.NATIONALITY, "Spaniard"),
            Attribute(Category.NATIONALITY, "Ukrainian"),
            Attribute(Category.NATIONALITY, "Norwegian"),
            Attribute(Category.NATIONALITY, "Japanese")
        ]
        
        self.drinks = [
            Attribute(Category.DRINK, "coffee"),
            Attribute(Category.DRINK, "tea"),
            Attribute(Category.DRINK, "milk"),
            Attribute(Category.DRINK, "orange juice"),
            Attribute(Category.DRINK, "water")
        ]
        
        self.smokes = [
            Attribute(Category.SMOKE, "Old Gold"),
            Attribute(Category.SMOKE, "Kools"),
            Attribute(Category.SMOKE, "Chesterfields"),
            Attribute(Category.SMOKE, "Lucky Strike"),
            Attribute(Category.SMOKE, "Parliaments")
        ]
        
        self.pets = [
            Attribute(Category.PET, "dog"),
            Attribute(Category.PET, "snails"),
            Attribute(Category.PET, "fox"),
            Attribute(Category.PET, "horse"),
            Attribute(Category.PET, "zebra")
        ]
        
        # Combine all attributes for easier manipulation
        self.all_attributes = self.colors + self.nationalities + self.drinks + self.smokes + self.pets
        
        # Map attribute names to objects for easy lookup
        self.attribute_map = {attr.name: attr for attr in self.all_attributes}
        
        # Initialize houses
        self.houses = [House(i, {}) for i in range(5)]
        
        # Solution will be stored here
        self.solution: Optional[List[House]] = None

    def get_attribute(self, name: str) -> Optional[Attribute]:
        """
        Get an attribute object by its name.
        
        Args:
            name: The name of the attribute to retrieve
            
        Returns:
            The attribute object or None if not found
        """
        return self.attribute_map.get(name)

    def solve(self) -> bool:
        """
        Solve the Zebra Puzzle using constraint satisfaction.
        
        This method tries all possible assignments of attributes to houses
        and checks if all constraints of the puzzle are satisfied.
        
        Returns:
            True if a solution was found, False otherwise.
        """
        # Generate all possible permutations of attributes by category
        color_perms = list(permutations(self.colors))
        nationality_perms = list(permutations(self.nationalities))
        drink_perms = list(permutations(self.drinks))
        smoke_perms = list(permutations(self.smokes))
        pet_perms = list(permutations(self.pets))
        
        # Get attribute objects for easier reference in constraints
        red = self.get_attribute("red")
        green = self.get_attribute("green")
        white = self.get_attribute("white")
        yellow = self.get_attribute("yellow")
        blue = self.get_attribute("blue")
        
        englishman = self.get_attribute("Englishman")
        spaniard = self.get_attribute("Spaniard")
        ukrainian = self.get_attribute("Ukrainian")
        norwegian = self.get_attribute("Norwegian")
        japanese = self.get_attribute("Japanese")
        
        coffee = self.get_attribute("coffee")
        tea = self.get_attribute("tea")
        milk = self.get_attribute("milk")
        oj = self.get_attribute("orange juice")
        water = self.get_attribute("water")
        
        old_gold = self.get_attribute("Old Gold")
        kools = self.get_attribute("Kools")
        chesterfields = self.get_attribute("Chesterfields")
        lucky_strike = self.get_attribute("Lucky Strike")
        parliaments = self.get_attribute("Parliaments")
        
        dog = self.get_attribute("dog")
        snails = self.get_attribute("snails")
        fox = self.get_attribute("fox")
        horse = self.get_attribute("horse")
        zebra = self.get_attribute("zebra")
        
        # Try all possible combinations
        for color_perm in color_perms:
            # Assign colors to houses
            for i, color in enumerate(color_perm):
                self.houses[i].attributes[Category.COLOR] = color
            
            # Check constraint: The green house is immediately to the right of the white house
            green_house = next((h for h in self.houses if h.attributes[Category.COLOR] == green), None)
            white_house = next((h for h in self.houses if h.attributes[Category.COLOR] == white), None)
            if not (green_house and white_house and green_house.position == white_house.position + 1):
                continue
            
            for nationality_perm in nationality_perms:
                # Assign nationalities to houses
                for i, nationality in enumerate(nationality_perm):
                    self.houses[i].attributes[Category.NATIONALITY] = nationality
                
                # Check constraint: The Norwegian lives in the first house
                if self.houses[0].attributes[Category.NATIONALITY] != norwegian:
                    continue
                
                # Check constraint: The Englishman lives in the red house
                red_house = next((h for h in self.houses if h.attributes[Category.COLOR] == red), None)
                englishman_house = next((h for h in self.houses if h.attributes[Category.NATIONALITY] == englishman), None)
                if not (red_house and englishman_house and red_house.position == englishman_house.position):
                    continue
                
                for drink_perm in drink_perms:
                    # Assign drinks to houses
                    for i, drink in enumerate(drink_perm):
                        self.houses[i].attributes[Category.DRINK] = drink
                    
                    # Check constraint: Coffee is drunk in the green house
                    coffee_house = next((h for h in self.houses if h.attributes[Category.DRINK] == coffee), None)
                    if not (coffee_house and green_house and coffee_house.position == green_house.position):
                        continue
                    
                    # Check constraint: The Ukrainian drinks tea
                    ukrainian_house = next((h for h in self.houses if h.attributes[Category.NATIONALITY] == ukrainian), None)
                    tea_house = next((h for h in self.houses if h.attributes[Category.DRINK] == tea), None)
                    if not (ukrainian_house and tea_house and ukrainian_house.position == tea_house.position):
                        continue
                    
                    # Check constraint: Milk is drunk in the middle house
                    if self.houses[2].attributes[Category.DRINK] != milk:
                        continue
                    
                    for smoke_perm in smoke_perms:
                        # Assign smoking preferences to houses
                        for i, smoke in enumerate(smoke_perm):
                            self.houses[i].attributes[Category.SMOKE] = smoke
                        
                        # Check constraint: The Japanese smokes Parliaments
                        japanese_house = next((h for h in self.houses if h.attributes[Category.NATIONALITY] == japanese), None)
                        parliaments_house = next((h for h in self.houses if h.attributes[Category.SMOKE] == parliaments), None)
                        if not (japanese_house and parliaments_house and japanese_house.position == parliaments_house.position):
                            continue
                        
                        # Check constraint: Kools are smoked in the yellow house
                        kools_house = next((h for h in self.houses if h.attributes[Category.SMOKE] == kools), None)
                        yellow_house = next((h for h in self.houses if h.attributes[Category.COLOR] == yellow), None)
                        if not (kools_house and yellow_house and kools_house.position == yellow_house.position):
                            continue
                        
                        # Check constraint: The Lucky Strike smoker drinks orange juice
                        lucky_strike_house = next((h for h in self.houses if h.attributes[Category.SMOKE] == lucky_strike), None)
                        oj_house = next((h for h in self.houses if h.attributes[Category.DRINK] == oj), None)
                        if not (lucky_strike_house and oj_house and lucky_strike_house.position == oj_house.position):
                            continue
                        
                        # Check constraint: The Norwegian lives next to the blue house
                        norwegian_house = next((h for h in self.houses if h.attributes[Category.NATIONALITY] == norwegian), None)
                        blue_house = next((h for h in self.houses if h.attributes[Category.COLOR] == blue), None)
                        if not (norwegian_house and blue_house and abs(norwegian_house.position - blue_house.position) == 1):
                            continue
                        
                        for pet_perm in pet_perms:
                            # Assign pets to houses
                            for i, pet in enumerate(pet_perm):
                                self.houses[i].attributes[Category.PET] = pet
                            
                            # Check constraint: The Spaniard owns the dog
                            spaniard_house = next((h for h in self.houses if h.attributes[Category.NATIONALITY] == spaniard), None)
                            dog_house = next((h for h in self.houses if h.attributes[Category.PET] == dog), None)
                            if not (spaniard_house and dog_house and spaniard_house.position == dog_house.position):
                                continue
                            
                            # Check constraint: The Old Gold smoker owns snails
                            old_gold_house = next((h for h in self.houses if h.attributes[Category.SMOKE] == old_gold), None)
                            snails_house = next((h for h in self.houses if h.attributes[Category.PET] == snails), None)
                            if not (old_gold_house and snails_house and old_gold_house.position == snails_house.position):
                                continue
                            
                            # Check constraint: The Chesterfields smoker lives next to the fox owner
                            chesterfields_house = next((h for h in self.houses if h.attributes[Category.SMOKE] == chesterfields), None)
                            fox_house = next((h for h in self.houses if h.attributes[Category.PET] == fox), None)
                            if not (chesterfields_house and fox_house and abs(chesterfields_house.position - fox_house.position) == 1):
                                continue
                            
                            # Check constraint: The Kools smoker lives next to the horse owner
                            horse_house = next((h for h in self.houses if h.attributes[Category.PET] == horse), None)
                            if not (kools_house and horse_house and abs(kools_house.position - horse_house.position) == 1):
                                continue
                            
                            # All constraints are satisfied, we've found a solution!
                            self.solution = list(self.houses)  # Make a copy to preserve the solution
                            return True
        
        # No solution found
        return False

    def get_house_with_attribute(self, attribute_name: str) -> Optional[House]:
        """
        Find the house containing the given attribute.
        
        Args:
            attribute_name: The name of the attribute to search for
            
        Returns:
            The house containing the attribute or None if not found
        """
        if not self.solution or attribute_name not in self.attribute_map:
            return None
        
        attr = self.attribute_map[attribute_name]
        for house in self.solution:
            for category_attr in house.attributes.values():
                if category_attr == attr:
                    return house
        
        return None

    def get_attribute_owner(self, attribute_name: str) -> Optional[str]:
        """
        Find the nationality of the person who owns/has the given attribute.
        
        Args:
            attribute_name: The name of the attribute to find the owner of
            
        Returns:
            The nationality of the owner or None if not found
        """
        house = self.get_house_with_attribute(attribute_name)
        if not house:
            return None
        
        nationality = house.attributes.get(Category.NATIONALITY)
        return nationality.name if nationality else None

    def print_solution(self) -> None:
        """
        Print the solution in a readable format.
        
        Displays each house with all its attributes, and answers the key questions
        of who owns the zebra and who drinks water.
        """
        if not self.solution:
            print("No solution found.")
            return
        
        print("\nZebra Puzzle Solution:")
        print("=====================\n")
        
        for house in sorted(self.solution, key=lambda h: h.position):
            print(f"House {house.position + 1}:")
            for category in Category:
                attr = house.attributes.get(category)
                if attr:
                    print(f"  {category.name.capitalize()}: {attr.name}")
            print()
        
        # Find who owns the zebra
        zebra_owner = self.get_attribute_owner("zebra")
        if zebra_owner:
            print(f"The {zebra_owner} owns the zebra.")
        
        # Find who drinks water
        water_drinker = self.get_attribute_owner("water")
        if water_drinker:
            print(f"The {water_drinker} drinks water.")


def main() -> None:
    """
    Main function to solve and display the Zebra Puzzle.
    
    Initializes the puzzle, solves it, and prints the results.
    """
    print("Solving the Zebra Puzzle (Einstein's Riddle)...")
    print("This may take a moment as we check all possible combinations...")
    
    puzzle = ZebraPuzzle()
    
    if puzzle.solve():
        puzzle.print_solution()
    else:
        print("No solution could be found. Please check the puzzle constraints.")


if __name__ == "__main__":
    main()