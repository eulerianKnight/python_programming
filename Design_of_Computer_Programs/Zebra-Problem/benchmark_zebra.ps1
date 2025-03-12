# Zebra Problem Solver Benchmark Script for Windows
# This PowerShell script compares the performance of Python, Rust, and C implementations
# of the Zebra Problem solver in terms of execution time and memory usage.

# Check if script is running as Administrator
$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $isAdmin) {
    Write-Host "Warning: Some operations might require administrator privileges." -ForegroundColor Yellow
    Write-Host "If you encounter permission issues, consider running this script as administrator."
    Write-Host ""
}

# Number of times to run each benchmark for averaging
$RUNS = 5

# Function to format strings with color
function Write-ColorOutput($text, $color) {
    Write-Host $text -ForegroundColor $color
}

# Check for required dependencies
Write-Host "Checking dependencies..." -ForegroundColor Cyan

# Check for Python
$pythonInstalled = $null -ne (Get-Command python -ErrorAction SilentlyContinue)
if (-not $pythonInstalled) {
    $pythonInstalled = $null -ne (Get-Command python3 -ErrorAction SilentlyContinue)
    if ($pythonInstalled) {
        $pythonCmd = "python3"
    } else {
        Write-Host "Python not found. Please install Python from https://www.python.org/downloads/" -ForegroundColor Red
        exit 1
    }
} else {
    $pythonCmd = "python"
}

# Check for Rust
$rustInstalled = $null -ne (Get-Command rustc -ErrorAction SilentlyContinue)
if (-not $rustInstalled) {
    Write-Host "Rust not found. Please install Rust from https://www.rust-lang.org/tools/install" -ForegroundColor Red
    exit 1
}

# Check for C compiler (we'll look for MSVC cl.exe or GCC/MinGW gcc.exe)
$cCompilerInstalled = $null -ne (Get-Command cl -ErrorAction SilentlyContinue) -or $null -ne (Get-Command gcc -ErrorAction SilentlyContinue)
if (-not $cCompilerInstalled) {
    $cCompilerPath = $null
    
    # Look for Visual Studio installations
    $vsPath = "C:\Program Files (x86)\Microsoft Visual Studio"
    if (Test-Path $vsPath) {
        # Try to find cl.exe in the typical Visual Studio installation paths
        $clPath = Get-ChildItem -Path $vsPath -Recurse -Filter "cl.exe" -ErrorAction SilentlyContinue | Select-Object -First 1 -ExpandProperty FullName
        if ($clPath) {
            $cCompilerPath = $clPath
            $cCompilerType = "msvc"
            $cCompilerCmd = "cl"
        }
    }
    
    # Look for MinGW installations
    if (-not $cCompilerPath) {
        $mingwPaths = @(
            "C:\MinGW\bin\gcc.exe",
            "C:\Program Files\mingw-w64\*\mingw*\bin\gcc.exe"
        )
        
        foreach ($path in $mingwPaths) {
            if (Test-Path $path) {
                $cCompilerPath = $path
                $cCompilerType = "gcc"
                $cCompilerCmd = "gcc"
                break
            }
        }
    }
    
    if (-not $cCompilerPath) {
        Write-Host "C compiler not found. Please install Visual Studio with C++ workload or MinGW." -ForegroundColor Red
        Write-Host "Visual Studio: https://visualstudio.microsoft.com/downloads/"
        Write-Host "MinGW: https://www.mingw-w64.org/downloads/"
        exit 1
    }
} else {
    if ($null -ne (Get-Command cl -ErrorAction SilentlyContinue)) {
        $cCompilerType = "msvc"
        $cCompilerCmd = "cl"
    } else {
        $cCompilerType = "gcc"
        $cCompilerCmd = "gcc"
    }
}

# Check for gnuplot (optional)
$gnuplotInstalled = $null -ne (Get-Command gnuplot -ErrorAction SilentlyContinue)
if (-not $gnuplotInstalled) {
    Write-Host "Note: gnuplot not found - performance charts will not be generated" -ForegroundColor Yellow
    Write-Host "To enable charts, install gnuplot from http://www.gnuplot.info/"
    Write-Host ""
}

Write-ColorOutput "=== Zebra Problem Solver Benchmark ===" "Cyan"
Write-Host "Comparing Python, Rust, and C implementations"
Write-Host "Each implementation will be run $RUNS times for averaging"
Write-Host ""

# Create directories for the source files and results
$currentDir = Get-Location
$pythonDir = Join-Path -Path $currentDir -ChildPath "python"
$rustDir = Join-Path -Path $currentDir -ChildPath "rust"
$cDir = Join-Path -Path $currentDir -ChildPath "c"
$resultsDir = Join-Path -Path $currentDir -ChildPath "results"

# Create directories if they don't exist
if (-not (Test-Path $pythonDir)) { New-Item -ItemType Directory -Path $pythonDir | Out-Null }
if (-not (Test-Path $rustDir)) { New-Item -ItemType Directory -Path $rustDir | Out-Null }
if (-not (Test-Path $cDir)) { New-Item -ItemType Directory -Path $cDir | Out-Null }
if (-not (Test-Path $resultsDir)) { New-Item -ItemType Directory -Path $resultsDir | Out-Null }

# Functions to prepare each implementation
function Prepare-Python {
    Write-ColorOutput "Preparing Python implementation..." "Yellow"
    
    # Assuming the Python code is already saved from a previous step
    Copy-Item -Path "zebra-puzzle-solver.py" -Destination (Join-Path -Path $pythonDir -ChildPath "zebra_solver.py")
    
    Write-ColorOutput "Python implementation ready." "Green"
}

function Prepare-Rust {
    Write-ColorOutput "Preparing Rust implementation..." "Yellow"
    
    # Create a new Rust project
    Set-Location -Path $rustDir
    if (-not (Test-Path "Cargo.toml")) {
        & cargo init --bin
    }
    
    # Add necessary dependencies
    if (-not (Select-String -Path "Cargo.toml" -Pattern "itertools" -SimpleMatch -Quiet)) {
        Add-Content -Path "Cargo.toml" -Value 'itertools = "0.10.5"'
    }
    
    # Copy the Rust code into src/main.rs
    Copy-Item -Path (Join-Path -Path $currentDir -ChildPath "zebra-problem-rust.rs") -Destination (Join-Path -Path $rustDir -ChildPath "src\main.rs")
    
    # Build the project in release mode
    & cargo build --release
    
    Set-Location -Path $currentDir
    Write-ColorOutput "Rust implementation ready." "Green"
}

function Prepare-C {
    Write-ColorOutput "Preparing C implementation..." "Yellow"
    
    # Copy the C code
    Copy-Item -Path "zebra-problem-c.c" -Destination (Join-Path -Path $cDir -ChildPath "zebra_solver.c")
    
    # Compile with optimization
    Set-Location -Path $cDir
    
    if ($cCompilerType -eq "msvc") {
        # Visual C++ compilation
        & cl /O2 /Fe:zebra_solver.exe zebra_solver.c
    } else {
        # GCC/MinGW compilation
        & gcc -O3 -o zebra_solver.exe zebra_solver.c
    }
    
    Set-Location -Path $currentDir
    Write-ColorOutput "C implementation ready." "Green"
}

# Function to run benchmarks for a specific implementation
function Run-Benchmark($lang, $exePath) {
    Write-ColorOutput "Running $lang benchmark..." "Cyan"
    
    $resultsFile = Join-Path -Path $resultsDir -ChildPath "${lang}_results.txt"
    
    # Clear previous results
    if (Test-Path $resultsFile) {
        Remove-Item -Path $resultsFile
    }
    
    # Arrays to store results
    $times = @()
    $memories = @()
    
    for ($i = 1; $i -le $RUNS; $i++) {
        Write-Host "  Run $i of $RUNS..."
        
        # Measure execution time
        $process = New-Object System.Diagnostics.Process
        $process.StartInfo.FileName = $exePath.Split()[0]
        $process.StartInfo.Arguments = $exePath.Substring($exePath.IndexOf(' ') + 1)
        $process.StartInfo.UseShellExecute = $false
        $process.StartInfo.RedirectStandardOutput = $true
        $process.StartInfo.CreateNoWindow = $true
        
        $stopwatch = [System.Diagnostics.Stopwatch]::StartNew()
        $process.Start() | Out-Null
        $process.WaitForExit()
        $stopwatch.Stop()
        
        # Get elapsed time in seconds
        $elapsedTime = $stopwatch.Elapsed.TotalSeconds
        
        # Get memory usage (peak working set in MB)
        $wmiProcess = Get-Process -Id $process.Id -ErrorAction SilentlyContinue
        if ($wmiProcess) {
            $memoryUsage = [Math]::Round($wmiProcess.PeakWorkingSet64 / 1MB, 2)
        } else {
            $memoryUsage = 0
        }
        
        $times += $elapsedTime
        $memories += $memoryUsage
        
        Add-Content -Path $resultsFile -Value "  Time: ${elapsedTime}s, Memory: ${memoryUsage}MB"
    }
    
    # Calculate averages
    $totalTime = 0
    $totalMemory = 0
    
    for ($i = 0; $i -lt $RUNS; $i++) {
        $totalTime += $times[$i]
        $totalMemory += $memories[$i]
    }
    
    $avgTime = [Math]::Round($totalTime / $RUNS, 4)
    $avgMemory = [Math]::Round($totalMemory / $RUNS, 2)
    
    Add-Content -Path $resultsFile -Value ""
    Add-Content -Path $resultsFile -Value "Average Time: ${avgTime}s"
    Add-Content -Path $resultsFile -Value "Average Memory: ${avgMemory}MB"
    
    # Store the averages in script-level variables for the summary
    if ($lang -eq "Python") {
        $script:py_time = $avgTime
        $script:py_mem = $avgMemory
    } elseif ($lang -eq "Rust") {
        $script:rs_time = $avgTime
        $script:rs_mem = $avgMemory
    } else {
        $script:c_time = $avgTime
        $script:c_mem = $avgMemory
    }
    
    Write-ColorOutput "$lang benchmark completed." "Green"
    Write-Host ""
}

# Prepare all implementations
Prepare-Python
Prepare-Rust
Prepare-C

# Run benchmarks
$pythonExe = if ($pythonCmd -eq "python") { "python" } else { "python3" }
Run-Benchmark "Python" "$pythonExe $pythonDir\zebra_solver.py"
Run-Benchmark "Rust" "$rustDir\target\release\rust.exe"
Run-Benchmark "C" "$cDir\zebra_solver.exe"

# Calculate relative performance (using C as baseline)
$py_time_rel = [Math]::Round($py_time / $c_time, 2)
$rs_time_rel = [Math]::Round($rs_time / $c_time, 2)
$c_time_rel = 1.00

$py_mem_rel = [Math]::Round($py_mem / $c_mem, 2)
$rs_mem_rel = [Math]::Round($rs_mem / $c_mem, 2)
$c_mem_rel = 1.00

# Print summary table
Write-ColorOutput "=== Performance Summary ===" "Cyan"
Write-Host ""
Write-Host "| Language | Avg. Time (s) | Relative Time | Avg. Memory (MB) | Relative Memory |"
Write-Host "|----------|--------------|---------------|-----------------|-----------------|"
Write-Host "| C        | $c_time      | $c_time_rel         | $c_mem           | $c_mem_rel           |"
Write-Host "| Rust     | $rs_time      | $rs_time_rel         | $rs_mem           | $rs_mem_rel           |"
Write-Host "| Python   | $py_time      | $py_time_rel         | $py_mem           | $py_mem_rel           |"
Write-Host ""

Write-Host "Detailed results saved in the 'results' directory."

# Optional: Generate a simple plot if gnuplot is available
if ($gnuplotInstalled) {
    Write-Host "Generating performance plots..."
    
    # Create gnuplot script for execution time
    $timePlotScript = @"
set terminal png size 800,600 enhanced font "Arial,12"
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
"@
    
    # Create gnuplot script for memory usage
    $memoryPlotScript = @"
set terminal png size 800,600 enhanced font "Arial,12"
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
"@
    
    # Save the gnuplot scripts
    $timePlotScript | Out-File -FilePath (Join-Path -Path $resultsDir -ChildPath "time_plot.gp") -Encoding ASCII
    $memoryPlotScript | Out-File -FilePath (Join-Path -Path $resultsDir -ChildPath "memory_plot.gp") -Encoding ASCII
    
    # Run gnuplot to generate the images
    & gnuplot (Join-Path -Path $resultsDir -ChildPath "time_plot.gp")
    & gnuplot (Join-Path -Path $resultsDir -ChildPath "memory_plot.gp")
    
    Write-Host "Performance plots saved in the 'results' directory."
}

# Generate a comprehensive HTML report
$htmlReport = @"
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
        <tr class="$(if ($c_time -lt $rs_time -and $c_time -lt $py_time) { 'highlight' } else { '' })">
            <td>C</td>
            <td>$c_time</td>
            <td>$c_time_rel</td>
            <td>$c_mem</td>
            <td>$c_mem_rel</td>
        </tr>
        <tr class="$(if ($rs_time -lt $c_time -and $rs_time -lt $py_time) { 'highlight' } else { '' })">
            <td>Rust</td>
            <td>$rs_time</td>
            <td>$rs_time_rel</td>
            <td>$rs_mem</td>
            <td>$rs_mem_rel</td>
        </tr>
        <tr class="$(if ($py_time -lt $c_time -and $py_time -lt $rs_time) { 'highlight' } else { '' })">
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
            $(if ($gnuplotInstalled) { '<img src="execution_time.png" alt="Execution Time Comparison" width="100%">' } else { '<p>Charts not available - gnuplot not installed</p>' })
        </div>
        <div class="chart">
            <h2>Memory Usage Comparison</h2>
            $(if ($gnuplotInstalled) { '<img src="memory_usage.png" alt="Memory Usage Comparison" width="100%">' } else { '<p>Charts not available - gnuplot not installed</p>' })
        </div>
    </div>
    
    <h2>Detailed Results</h2>
    <h3>C Implementation</h3>
    <pre>$(Get-Content -Path (Join-Path -Path $resultsDir -ChildPath "C_results.txt") -Raw)</pre>
    
    <h3>Rust Implementation</h3>
    <pre>$(Get-Content -Path (Join-Path -Path $resultsDir -ChildPath "Rust_results.txt") -Raw)</pre>
    
    <h3>Python Implementation</h3>
    <pre>$(Get-Content -Path (Join-Path -Path $resultsDir -ChildPath "Python_results.txt") -Raw)</pre>
    
    <footer>
        <p><small>Generated on: $(Get-Date)</small></p>
    </footer>
</body>
</html>
"@

$htmlReport | Out-File -FilePath (Join-Path -Path $resultsDir -ChildPath "benchmark_report.html") -Encoding UTF8

Write-Host "HTML benchmark report generated: results/benchmark_report.html"
Write-ColorOutput "=== Benchmark Complete ===" "Cyan"