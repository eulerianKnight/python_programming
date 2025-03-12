#!/bin/bash

# Zebra Problem Solver Benchmark Script
# This script compares the performance of Python, Rust, and C implementations
# of the Zebra Problem solver in terms of execution time and memory usage.

# Set colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[0;33m'
NC='\033[0m' # No Color

# Number of times to run each benchmark for averaging
RUNS=5

# Create directories for the source files
mkdir -p python rust c

# Create a results directory for output
mkdir -p results

echo -e "${BLUE}=== Zebra Problem Solver Benchmark ===${NC}"
echo -e "Comparing Python, Rust, and C implementations"
echo "Each implementation will be run $RUNS times for averaging"
echo ""

# Functions to prepare each implementation
prepare_python() {
    echo -e "${YELLOW}Preparing Python implementation...${NC}"
    # Assuming the Python code is already saved from a previous step
    cp zebra-puzzle-solver.py python/zebra_solver.py
    echo -e "${GREEN}Python implementation ready.${NC}"
}

prepare_rust() {
    echo -e "${YELLOW}Preparing Rust implementation...${NC}"
    
    # Create a new Rust project
    cd rust
    cargo init --bin
    
    # Add necessary dependencies
    echo 'itertools = "0.10.5"' >> Cargo.toml
    
    # Copy the Rust code into src/main.rs
    cp ../zebra-problem-rust.rs src/main.rs
    
    # Build the project in release mode
    cargo build --release
    
    cd ..
    echo -e "${GREEN}Rust implementation ready.${NC}"
}

prepare_c() {
    echo -e "${YELLOW}Preparing C implementation...${NC}"
    
    # Copy the C code
    cp zebra-problem-c.c c/zebra_solver.c
    
    # Compile with optimization
    cd c
    gcc -O3 -o zebra_solver zebra_solver.c -lm
    cd ..
    
    echo -e "${GREEN}C implementation ready.${NC}"
}

# Function to run benchmarks for a specific implementation
run_benchmark() {
    local lang=$1
    local cmd=$2
    local results_file="results/${lang}_results.txt"
    
    echo -e "${BLUE}Running $lang benchmark...${NC}"
    
    # Clear previous results
    > $results_file
    
    # Arrays to store results
    declare -a times
    declare -a memories
    
    for i in $(seq 1 $RUNS); do
        echo -e "  Run $i of $RUNS..."
        
        # Use /usr/bin/time to measure both time and memory
        # -f format string: %e is elapsed time (seconds), %M is max resident set size (KB)
        /usr/bin/time -f "%e %M" $cmd 2> temp_result.txt > /dev/null
        
        # Read the results
        read elapsed_time max_memory < temp_result.txt
        
        # Convert memory from KB to MB for better readability
        max_memory=$(echo "scale=2; $max_memory / 1024" | bc)
        
        times[$i]=$elapsed_time
        memories[$i]=$max_memory
        
        echo "  Time: ${elapsed_time}s, Memory: ${max_memory}MB" >> $results_file
    done
    
    # Calculate averages
    total_time=0
    total_memory=0
    
    for i in $(seq 1 $RUNS); do
        total_time=$(echo "$total_time + ${times[$i]}" | bc)
        total_memory=$(echo "$total_memory + ${memories[$i]}" | bc)
    done
    
    avg_time=$(echo "scale=4; $total_time / $RUNS" | bc)
    avg_memory=$(echo "scale=2; $total_memory / $RUNS" | bc)
    
    echo "" >> $results_file
    echo "Average Time: ${avg_time}s" >> $results_file
    echo "Average Memory: ${avg_memory}MB" >> $results_file
    
    # Store the averages in global variables for the summary
    if [ "$lang" == "Python" ]; then
        py_time=$avg_time
        py_mem=$avg_memory
    elif [ "$lang" == "Rust" ]; then
        rs_time=$avg_time
        rs_mem=$avg_memory
    else
        c_time=$avg_time
        c_mem=$avg_memory
    fi
    
    echo -e "${GREEN}$lang benchmark completed.${NC}"
    echo ""
}

# Prepare all implementations
prepare_python
prepare_rust
prepare_c

# Run benchmarks
run_benchmark "Python" "python python/zebra_solver.py"
run_benchmark "Rust" "./rust/target/release/rust"
run_benchmark "C" "./c/zebra_solver"

# Remove temporary files
rm -f temp_result.txt

# Calculate relative performance (using C as baseline)
py_time_rel=$(echo "scale=2; $py_time / $c_time" | bc)
rs_time_rel=$(echo "scale=2; $rs_time / $c_time" | bc)
c_time_rel="1.00"

py_mem_rel=$(echo "scale=2; $py_mem / $c_mem" | bc)
rs_mem_rel=$(echo "scale=2; $rs_mem / $c_mem" | bc)
c_mem_rel="1.00"

# Print summary table
echo -e "${BLUE}=== Performance Summary ===${NC}"
echo ""
echo -e "| ${YELLOW}Language${NC} | ${YELLOW}Avg. Time (s)${NC} | ${YELLOW}Relative Time${NC} | ${YELLOW}Avg. Memory (MB)${NC} | ${YELLOW}Relative Memory${NC} |"
echo "|----------|--------------|---------------|-----------------|-----------------|"
echo -e "| C        | $c_time      | $c_time_rel         | $c_mem           | $c_mem_rel           |"
echo -e "| Rust     | $rs_time      | $rs_time_rel         | $rs_mem           | $rs_mem_rel           |"
echo -e "| Python   | $py_time      | $py_time_rel         | $py_mem           | $py_mem_rel           |"
echo ""

echo "Detailed results saved in the 'results' directory."
echo -e "${BLUE}=== Benchmark Complete ===${NC}"

# Optional: Generate a simple plot if gnuplot is available
if command -v gnuplot &> /dev/null; then
    echo "Generating performance plots..."
    
    # Create gnuplot script for execution time
    cat > results/time_plot.gp << EOL
set terminal png size 800,600 enhanced font "Helvetica,12"
set output 'results/execution_time.png'
set title 'Zebra Problem Solver - Execution Time Comparison'
set style data histogram
set style histogram cluster gap 1
set style fill solid border -1
set boxwidth 0.9
set xtic scale 0
set ylabel 'Time (seconds)'
set grid ytics
set yrange [0:*]
plot '< echo "C $c_time\nRust $rs_time\nPython $py_time"' using 2:xtic(1) title 'Average Execution Time' linecolor rgb '#4169E1'
EOL

    # Create gnuplot script for memory usage
    cat > results/memory_plot.gp << EOL
set terminal png size 800,600 enhanced font "Helvetica,12"
set output 'results/memory_usage.png'
set title 'Zebra Problem Solver - Memory Usage Comparison'
set style data histogram
set style histogram cluster gap 1
set style fill solid border -1
set boxwidth 0.9
set xtic scale 0
set ylabel 'Memory (MB)'
set grid ytics
set yrange [0:*]
plot '< echo "C $c_mem\nRust $rs_mem\nPython $py_mem"' using 2:xtic(1) title 'Average Memory Usage' linecolor rgb '#32CD32'
EOL

    # Run gnuplot to generate the images
    gnuplot results/time_plot.gp
    gnuplot results/memory_plot.gp
    
    echo "Performance plots saved in the 'results' directory."
fi

# Optional: Generate a comprehensive HTML report
cat > results/benchmark_report.html << EOL
<!DOCTYPE html>
<html>
<head>
    <title>Zebra Problem Solver Benchmark Results</title>
    <style>
        body { font-family: Arial, sans-serif; max-width: 1000px; margin: 0 auto; padding: 20px; }
        h1, h2 { color: #2c3e50; }
        table { border-collapse: collapse; width: 100%; margin: 20px 0; }
        th, td { border: 1px solid #ddd; padding: 8px; text-align: left; }
        th { background-color: #f2f2f2; }
        tr:nth-child(even) { background-color: #f9f9f9; }
        .highlight { background-color: #e6f7ff; font-weight: bold; }
        .container { display: flex; justify-content: space-between; }
        .chart { width: 48%; }
    </style>
</head>
<body>
    <h1>Zebra Problem Solver Benchmark Results</h1>
    <p>Comparison of Python, Rust, and C implementations</p>
    
    <h2>Summary</h2>
    <table>
        <tr>
            <th>Language</th>
            <th>Average Time (s)</th>
            <th>Relative Time</th>
            <th>Average Memory (MB)</th>
            <th>Relative Memory</th>
        </tr>
        <tr class="${c_time < rs_time && c_time < py_time ? 'highlight' : ''}">
            <td>C</td>
            <td>$c_time</td>
            <td>$c_time_rel</td>
            <td>$c_mem</td>
            <td>$c_mem_rel</td>
        </tr>
        <tr class="${rs_time < c_time && rs_time < py_time ? 'highlight' : ''}">
            <td>Rust</td>
            <td>$rs_time</td>
            <td>$rs_time_rel</td>
            <td>$rs_mem</td>
            <td>$rs_mem_rel</td>
        </tr>
        <tr class="${py_time < c_time && py_time < rs_time ? 'highlight' : ''}">
            <td>Python</td>
            <td>$py_time</td>
            <td>$py_time_rel</td>
            <td>$py_mem</td>
            <td>$py_mem_rel</td>
        </tr>
    </table>
    
    <div class="container">
        <div class="chart">
            <h2>Execution Time Comparison</h2>
            <img src="execution_time.png" alt="Execution Time Comparison" width="100%">
        </div>
        <div class="chart">
            <h2>Memory Usage Comparison</h2>
            <img src="memory_usage.png" alt="Memory Usage Comparison" width="100%">
        </div>
    </div>
    
    <h2>Detailed Results</h2>
    <h3>C Implementation</h3>
    <pre>$(cat results/C_results.txt)</pre>
    
    <h3>Rust Implementation</h3>
    <pre>$(cat results/Rust_results.txt)</pre>
    
    <h3>Python Implementation</h3>
    <pre>$(cat results/Python_results.txt)</pre>
    
    <footer>
        <p><small>Generated on: $(date)</small></p>
    </footer>
</body>
</html>
EOL

echo "HTML benchmark report generated: results/benchmark_report.html"