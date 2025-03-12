use std::collections::HashMap;
use std::fmt;
use itertools::Itertools;

/// Categories of attributes in the Zebra Puzzle
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
enum Category {
    Color,
    Nationality,
    Drink,
    Smoke,
    Pet,
}

impl fmt::Display for Category {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        match self {
            Category::Color => write!(f, "Color"),
            Category::Nationality => write!(f, "Nationality"),
            Category::Drink => write!(f, "Drink"),
            Category::Smoke => write!(f, "Smoke"),
            Category::Pet => write!(f, "Pet"),
        }
    }
}

/// An attribute in the Zebra Puzzle with its category and name
#[derive(Debug, Clone, PartialEq, Eq, Hash)]
struct Attribute {
    category: Category,
    name: String,
}

impl Attribute {
    /// Create a new attribute with the given category and name
    fn new(category: Category, name: &str) -> Self {
        Attribute {
            category,
            name: name.to_string(),
        }
    }
}

/// A house in the Zebra Puzzle with its position and attributes
#[derive(Debug, Clone)]
struct House {
    /// 0-based index, where 0 is the leftmost house
    position: usize,
    /// Map of categories to attributes
    attributes: HashMap<Category, Attribute>,
}

impl House {
    /// Create a new house at the given position
    fn new(position: usize) -> Self {
        House {
            position,
            attributes: HashMap::new(),
        }
    }
}

/// Helper struct to manage attributes by category
#[derive(Debug)]
struct AttributeGroup {
    colors: Vec<Attribute>,
    nationalities: Vec<Attribute>,
    drinks: Vec<Attribute>,
    smokes: Vec<Attribute>,
    pets: Vec<Attribute>,
    all_attributes: Vec<Attribute>,
    attribute_map: HashMap<String, Attribute>,
}

impl AttributeGroup {
    /// Initialize all attributes used in the puzzle
    fn new() -> Self {
        // Define all attributes by category
        let colors = vec![
            Attribute::new(Category::Color, "red"),
            Attribute::new(Category::Color, "green"),
            Attribute::new(Category::Color, "white"),
            Attribute::new(Category::Color, "yellow"),
            Attribute::new(Category::Color, "blue"),
        ];
        
        let nationalities = vec![
            Attribute::new(Category::Nationality, "Englishman"),
            Attribute::new(Category::Nationality, "Spaniard"),
            Attribute::new(Category::Nationality, "Ukrainian"),
            Attribute::new(Category::Nationality, "Norwegian"),
            Attribute::new(Category::Nationality, "Japanese"),
        ];
        
        let drinks = vec![
            Attribute::new(Category::Drink, "coffee"),
            Attribute::new(Category::Drink, "tea"),
            Attribute::new(Category::Drink, "milk"),
            Attribute::new(Category::Drink, "orange juice"),
            Attribute::new(Category::Drink, "water"),
        ];
        
        let smokes = vec![
            Attribute::new(Category::Smoke, "Old Gold"),
            Attribute::new(Category::Smoke, "Kools"),
            Attribute::new(Category::Smoke, "Chesterfields"),
            Attribute::new(Category::Smoke, "Lucky Strike"),
            Attribute::new(Category::Smoke, "Parliaments"),
        ];
        
        let pets = vec![
            Attribute::new(Category::Pet, "dog"),
            Attribute::new(Category::Pet, "snails"),
            Attribute::new(Category::Pet, "fox"),
            Attribute::new(Category::Pet, "horse"),
            Attribute::new(Category::Pet, "zebra"),
        ];
        
        // Combine all attributes
        let mut all_attributes = Vec::new();
        all_attributes.extend(colors.clone());
        all_attributes.extend(nationalities.clone());
        all_attributes.extend(drinks.clone());
        all_attributes.extend(smokes.clone());
        all_attributes.extend(pets.clone());
        
        // Create attribute map for lookup by name
        let mut attribute_map = HashMap::new();
        for attr in &all_attributes {
            attribute_map.insert(attr.name.clone(), attr.clone());
        }
        
        AttributeGroup {
            colors,
            nationalities,
            drinks,
            smokes,
            pets,
            all_attributes,
            attribute_map,
        }
    }
    
    /// Get an attribute by its name
    fn get_attribute(&self, name: &str) -> Option<&Attribute> {
        self.attribute_map.get(name)
    }
}

/// A solver for the Zebra Puzzle (Einstein's Riddle)
#[derive(Debug)]
struct ZebraPuzzle {
    /// Attribute definitions and groupings
    attributes: AttributeGroup,
    /// Houses in the puzzle
    houses: Vec<House>,
    /// The solution when found
    solution: Option<Vec<House>>,
}

impl ZebraPuzzle {
    /// Create a new Zebra Puzzle solver
    fn new() -> Self {
        let attributes = AttributeGroup::new();
        
        // Initialize houses
        let houses = (0..5).map(House::new).collect();
        
        ZebraPuzzle {
            attributes,
            houses,
            solution: None,
        }
    }
    
    /// Solve the Zebra Puzzle using constraint satisfaction
    /// 
    /// This method tries all possible assignments of attributes to houses
    /// and checks if all constraints of the puzzle are satisfied.
    /// 
    /// Returns true if a solution was found, false otherwise.
    fn solve(&mut self) -> bool {
        // Get references to attributes for easier constraint checking
        let red = self.attributes.get_attribute("red").unwrap();
        let green = self.attributes.get_attribute("green").unwrap();
        let white = self.attributes.get_attribute("white").unwrap();
        let yellow = self.attributes.get_attribute("yellow").unwrap();
        let blue = self.attributes.get_attribute("blue").unwrap();
        
        let englishman = self.attributes.get_attribute("Englishman").unwrap();
        let spaniard = self.attributes.get_attribute("Spaniard").unwrap();
        let ukrainian = self.attributes.get_attribute("Ukrainian").unwrap();
        let norwegian = self.attributes.get_attribute("Norwegian").unwrap();
        let japanese = self.attributes.get_attribute("Japanese").unwrap();
        
        let coffee = self.attributes.get_attribute("coffee").unwrap();
        let tea = self.attributes.get_attribute("tea").unwrap();
        let milk = self.attributes.get_attribute("milk").unwrap();
        let oj = self.attributes.get_attribute("orange juice").unwrap();
        let water = self.attributes.get_attribute("water").unwrap();
        
        let old_gold = self.attributes.get_attribute("Old Gold").unwrap();
        let kools = self.attributes.get_attribute("Kools").unwrap();
        let chesterfields = self.attributes.get_attribute("Chesterfields").unwrap();
        let lucky_strike = self.attributes.get_attribute("Lucky Strike").unwrap();
        let parliaments = self.attributes.get_attribute("Parliaments").unwrap();
        
        let dog = self.attributes.get_attribute("dog").unwrap();
        let snails = self.attributes.get_attribute("snails").unwrap();
        let fox = self.attributes.get_attribute("fox").unwrap();
        let horse = self.attributes.get_attribute("horse").unwrap();
        let zebra = self.attributes.get_attribute("zebra").unwrap();
        
        // Try all possible permutations of colors
        for color_perm in self.attributes.colors.iter().permutations(5) {
            // Assign colors to houses
            for (i, color) in color_perm.iter().enumerate() {
                self.houses[i].attributes.insert(Category::Color, (*color).clone());
            }
            
            // Check constraint: The green house is immediately to the right of the white house
            let green_pos = self.houses.iter().find_map(|h| {
                if h.attributes.get(&Category::Color)? == green {
                    Some(h.position)
                } else {
                    None
                }
            });
            
            let white_pos = self.houses.iter().find_map(|h| {
                if h.attributes.get(&Category::Color)? == white {
                    Some(h.position)
                } else {
                    None
                }
            });
            
            if let (Some(g), Some(w)) = (green_pos, white_pos) {
                if g != w + 1 {
                    continue;
                }
            } else {
                continue;
            }
            
            // Try all possible permutations of nationalities
            for nationality_perm in self.attributes.nationalities.iter().permutations(5) {
                // Assign nationalities to houses
                for (i, nationality) in nationality_perm.iter().enumerate() {
                    self.houses[i].attributes.insert(Category::Nationality, (*nationality).clone());
                }
                
                // Check constraint: The Norwegian lives in the first house
                if self.houses[0].attributes.get(&Category::Nationality).unwrap() != norwegian {
                    continue;
                }
                
                // Check constraint: The Englishman lives in the red house
                let englishman_pos = self.houses.iter().find_map(|h| {
                    if h.attributes.get(&Category::Nationality)? == englishman {
                        Some(h.position)
                    } else {
                        None
                    }
                });
                
                let red_pos = self.houses.iter().find_map(|h| {
                    if h.attributes.get(&Category::Color)? == red {
                        Some(h.position)
                    } else {
                        None
                    }
                });
                
                if let (Some(e), Some(r)) = (englishman_pos, red_pos) {
                    if e != r {
                        continue;
                    }
                } else {
                    continue;
                }
                
                // Try all possible permutations of drinks
                for drink_perm in self.attributes.drinks.iter().permutations(5) {
                    // Assign drinks to houses
                    for (i, drink) in drink_perm.iter().enumerate() {
                        self.houses[i].attributes.insert(Category::Drink, (*drink).clone());
                    }
                    
                    // Check constraint: Coffee is drunk in the green house
                    let coffee_pos = self.houses.iter().find_map(|h| {
                        if h.attributes.get(&Category::Drink)? == coffee {
                            Some(h.position)
                        } else {
                            None
                        }
                    });
                    
                    let green_pos = self.houses.iter().find_map(|h| {
                        if h.attributes.get(&Category::Color)? == green {
                            Some(h.position)
                        } else {
                            None
                        }
                    });
                    
                    if let (Some(c), Some(g)) = (coffee_pos, green_pos) {
                        if c != g {
                            continue;
                        }
                    } else {
                        continue;
                    }
                    
                    // Check constraint: The Ukrainian drinks tea
                    let ukrainian_pos = self.houses.iter().find_map(|h| {
                        if h.attributes.get(&Category::Nationality)? == ukrainian {
                            Some(h.position)
                        } else {
                            None
                        }
                    });
                    
                    let tea_pos = self.houses.iter().find_map(|h| {
                        if h.attributes.get(&Category::Drink)? == tea {
                            Some(h.position)
                        } else {
                            None
                        }
                    });
                    
                    if let (Some(u), Some(t)) = (ukrainian_pos, tea_pos) {
                        if u != t {
                            continue;
                        }
                    } else {
                        continue;
                    }
                    
                    // Check constraint: Milk is drunk in the middle house
                    if self.houses[2].attributes.get(&Category::Drink).unwrap() != milk {
                        continue;
                    }
                    
                    // Try all possible permutations of smokes
                    for smoke_perm in self.attributes.smokes.iter().permutations(5) {
                        // Assign smokes to houses
                        for (i, smoke) in smoke_perm.iter().enumerate() {
                            self.houses[i].attributes.insert(Category::Smoke, (*smoke).clone());
                        }
                        
                        // Check constraint: The Japanese smokes Parliaments
                        let japanese_pos = self.houses.iter().find_map(|h| {
                            if h.attributes.get(&Category::Nationality)? == japanese {
                                Some(h.position)
                            } else {
                                None
                            }
                        });
                        
                        let parliaments_pos = self.houses.iter().find_map(|h| {
                            if h.attributes.get(&Category::Smoke)? == parliaments {
                                Some(h.position)
                            } else {
                                None
                            }
                        });
                        
                        if let (Some(j), Some(p)) = (japanese_pos, parliaments_pos) {
                            if j != p {
                                continue;
                            }
                        } else {
                            continue;
                        }
                        
                        // Check constraint: Kools are smoked in the yellow house
                        let kools_pos = self.houses.iter().find_map(|h| {
                            if h.attributes.get(&Category::Smoke)? == kools {
                                Some(h.position)
                            } else {
                                None
                            }
                        });
                        
                        let yellow_pos = self.houses.iter().find_map(|h| {
                            if h.attributes.get(&Category::Color)? == yellow {
                                Some(h.position)
                            } else {
                                None
                            }
                        });
                        
                        if let (Some(k), Some(y)) = (kools_pos, yellow_pos) {
                            if k != y {
                                continue;
                            }
                        } else {
                            continue;
                        }
                        
                        // Check constraint: The Lucky Strike smoker drinks orange juice
                        let lucky_strike_pos = self.houses.iter().find_map(|h| {
                            if h.attributes.get(&Category::Smoke)? == lucky_strike {
                                Some(h.position)
                            } else {
                                None
                            }
                        });
                        
                        let oj_pos = self.houses.iter().find_map(|h| {
                            if h.attributes.get(&Category::Drink)? == oj {
                                Some(h.position)
                            } else {
                                None
                            }
                        });
                        
                        if let (Some(ls), Some(o)) = (lucky_strike_pos, oj_pos) {
                            if ls != o {
                                continue;
                            }
                        } else {
                            continue;
                        }
                        
                        // Check constraint: The Norwegian lives next to the blue house
                        let norwegian_pos = self.houses.iter().find_map(|h| {
                            if h.attributes.get(&Category::Nationality)? == norwegian {
                                Some(h.position)
                            } else {
                                None
                            }
                        });
                        
                        let blue_pos = self.houses.iter().find_map(|h| {
                            if h.attributes.get(&Category::Color)? == blue {
                                Some(h.position)
                            } else {
                                None
                            }
                        });
                        
                        if let (Some(n), Some(b)) = (norwegian_pos, blue_pos) {
                            if (n as isize - b as isize).abs() != 1 {
                                continue;
                            }
                        } else {
                            continue;
                        }
                        
                        // Try all possible permutations of pets
                        for pet_perm in self.attributes.pets.iter().permutations(5) {
                            // Assign pets to houses
                            for (i, pet) in pet_perm.iter().enumerate() {
                                self.houses[i].attributes.insert(Category::Pet, (*pet).clone());
                            }
                            
                            // Check constraint: The Spaniard owns the dog
                            let spaniard_pos = self.houses.iter().find_map(|h| {
                                if h.attributes.get(&Category::Nationality)? == spaniard {
                                    Some(h.position)
                                } else {
                                    None
                                }
                            });
                            
                            let dog_pos = self.houses.iter().find_map(|h| {
                                if h.attributes.get(&Category::Pet)? == dog {
                                    Some(h.position)
                                } else {
                                    None
                                }
                            });
                            
                            if let (Some(s), Some(d)) = (spaniard_pos, dog_pos) {
                                if s != d {
                                    continue;
                                }
                            } else {
                                continue;
                            }
                            
                            // Check constraint: The Old Gold smoker owns snails
                            let old_gold_pos = self.houses.iter().find_map(|h| {
                                if h.attributes.get(&Category::Smoke)? == old_gold {
                                    Some(h.position)
                                } else {
                                    None
                                }
                            });
                            
                            let snails_pos = self.houses.iter().find_map(|h| {
                                if h.attributes.get(&Category::Pet)? == snails {
                                    Some(h.position)
                                } else {
                                    None
                                }
                            });
                            
                            if let (Some(og), Some(s)) = (old_gold_pos, snails_pos) {
                                if og != s {
                                    continue;
                                }
                            } else {
                                continue;
                            }
                            
                            // Check constraint: The Chesterfields smoker lives next to the fox owner
                            let chesterfields_pos = self.houses.iter().find_map(|h| {
                                if h.attributes.get(&Category::Smoke)? == chesterfields {
                                    Some(h.position)
                                } else {
                                    None
                                }
                            });
                            
                            let fox_pos = self.houses.iter().find_map(|h| {
                                if h.attributes.get(&Category::Pet)? == fox {
                                    Some(h.position)
                                } else {
                                    None
                                }
                            });
                            
                            if let (Some(c), Some(f)) = (chesterfields_pos, fox_pos) {
                                if (c as isize - f as isize).abs() != 1 {
                                    continue;
                                }
                            } else {
                                continue;
                            }
                            
                            // Check constraint: The Kools smoker lives next to the horse owner
                            let horse_pos = self.houses.iter().find_map(|h| {
                                if h.attributes.get(&Category::Pet)? == horse {
                                    Some(h.position)
                                } else {
                                    None
                                }
                            });
                            
                            if let (Some(k), Some(h)) = (kools_pos, horse_pos) {
                                if (k as isize - h as isize).abs() != 1 {
                                    continue;
                                }
                            } else {
                                continue;
                            }
                            
                            // All constraints are satisfied, we've found a solution!
                            self.solution = Some(self.houses.clone());
                            return true;
                        }
                    }
                }
            }
        }
        
        // No solution found
        false
    }
    
    /// Find the house containing an attribute with the given name
    fn get_house_with_attribute(&self, attribute_name: &str) -> Option<&House> {
        let solution = self.solution.as_ref()?;
        let attr = self.attributes.get_attribute(attribute_name)?;
        
        solution.iter().find(|house| {
            house.attributes.values().any(|a| a == attr)
        })
    }
    
    /// Find the nationality of the person who owns/has the given attribute
    fn get_attribute_owner(&self, attribute_name: &str) -> Option<&str> {
        let house = self.get_house_with_attribute(attribute_name)?;
        
        if let Some(nationality) = house.attributes.get(&Category::Nationality) {
            Some(&nationality.name)
        } else {
            None
        }
    }
    
    /// Print the solution in a readable format
    fn print_solution(&self) {
        if let Some(solution) = &self.solution {
            println!("\nZebra Puzzle Solution:");
            println!("=====================\n");
            
            // Sort houses by position for consistent output
            let mut sorted_houses = solution.clone();
            sorted_houses.sort_by_key(|h| h.position);
            
            for house in &sorted_houses {
                println!("House {}:", house.position + 1);
                for category in &[
                    Category::Color,
                    Category::Nationality,
                    Category::Drink,
                    Category::Smoke,
                    Category::Pet,
                ] {
                    if let Some(attr) = house.attributes.get(category) {
                        println!("  {}: {}", category, attr.name);
                    }
                }
                println!();
            }
            
            // Find who owns the zebra
            if let Some(zebra_owner) = self.get_attribute_owner("zebra") {
                println!("The {} owns the zebra.", zebra_owner);
            }
            
            // Find who drinks water
            if let Some(water_drinker) = self.get_attribute_owner("water") {
                println!("The {} drinks water.", water_drinker);
            }
        } else {
            println!("No solution found.");
        }
    }
}

fn main() {
    println!("Solving the Zebra Puzzle (Einstein's Riddle)...");
    println!("This may take a moment as we check all possible combinations...");
    
    let mut puzzle = ZebraPuzzle::new();
    
    if puzzle.solve() {
        puzzle.print_solution();
    } else {
        println!("No solution could be found. Please check the puzzle constraints.");
    }
}