package main

import (
	"bufio"
	"encoding/json"
	"flag"
	"fmt"
	"os"
	"os/exec"
	"runtime"
	"strings"
)

func main() {
	var inputFile = flag.String("input", "", "Path to .env file (default: .env in current directory)")
	var output = flag.String("output", "", "Output file path (default: stdout)")
	var help = flag.Bool("help", false, "Show help")

	flag.Usage = func() {
		fmt.Fprintf(os.Stderr, "env2json - Convert .env files to JSON format for secrets managers\n\n")
		fmt.Fprintf(os.Stderr, "Usage:\n")
		fmt.Fprintf(os.Stderr, "  env2json [flags]\n\n")
		fmt.Fprintf(os.Stderr, "Examples:\n")
		fmt.Fprintf(os.Stderr, "  env2json                    # Convert .env in current directory\n")
		fmt.Fprintf(os.Stderr, "  env2json -input .env.prod   # Convert specific .env file\n")
		fmt.Fprintf(os.Stderr, "  env2json -output secrets.json  # Save to specific file\n\n")
		fmt.Fprintf(os.Stderr, "Flags:\n")
		flag.PrintDefaults()
	}

	flag.Parse()

	if *help {
		flag.Usage()
		os.Exit(0)
	}

	convertEnvToJSON(*inputFile, *output)
}

func convertEnvToJSON(inputFile, output string) {
	// Determine input file
	envFile := inputFile
	if envFile == "" {
		envFile = ".env"
	}

	// Check if file exists
	if !fileExists(envFile) {
		if inputFile == "" {
			fmt.Fprintf(os.Stderr, "No .env file found in current directory.\n")
			fmt.Fprintf(os.Stderr, "Use --input flag to specify a different .env file:\n")
			fmt.Fprintf(os.Stderr, "  env2json --input /path/to/.env\n")
			fmt.Fprintf(os.Stderr, "  env2json --input .env.production\n")
		} else {
			fmt.Fprintf(os.Stderr, "File not found: %s\n", envFile)
		}
		os.Exit(1)
	}

	// Load environment variables
	envMap, err := parseEnvFile(envFile)
	if err != nil {
		fmt.Fprintf(os.Stderr, "Error reading .env file: %v\n", err)
		os.Exit(1)
	}

	if len(envMap) == 0 {
		fmt.Fprintf(os.Stderr, "The .env file is empty or contains no valid environment variables.\n")
		os.Exit(1)
	}

	// Convert to JSON
	jsonData, err := json.MarshalIndent(envMap, "", "  ")
	if err != nil {
		fmt.Fprintf(os.Stderr, "Error converting to JSON: %v\n", err)
		os.Exit(1)
	}

	// Output result
	jsonString := string(jsonData)

	if output == "" {
		// Just print JSON and copy to clipboard
		fmt.Println(jsonString)
		copyToClipboard(jsonString)
	} else {
		// Save to file
		err := os.WriteFile(output, jsonData, 0644)
		if err != nil {
			fmt.Fprintf(os.Stderr, "Error writing to file %s: %v\n", output, err)
			os.Exit(1)
		}
		fmt.Printf("Saved to %s (%d variables)\n", output, len(envMap))
	}
}

func fileExists(filename string) bool {
	info, err := os.Stat(filename)
	if os.IsNotExist(err) {
		return false
	}
	return !info.IsDir()
}

// parseEnvFile parses a .env file and returns a map of key-value pairs
func parseEnvFile(filename string) (map[string]string, error) {
	file, err := os.Open(filename)
	if err != nil {
		return nil, err
	}
	defer file.Close()

	envMap := make(map[string]string)
	scanner := bufio.NewScanner(file)

	for scanner.Scan() {
		line := strings.TrimSpace(scanner.Text())

		// Skip empty lines and comments
		if line == "" || strings.HasPrefix(line, "#") {
			continue
		}

		// Find the first = sign
		parts := strings.SplitN(line, "=", 2)
		if len(parts) != 2 {
			continue // Skip invalid lines
		}

		key := strings.TrimSpace(parts[0])
		value := strings.TrimSpace(parts[1])

		// Remove quotes if present
		if len(value) >= 2 {
			if (value[0] == '"' && value[len(value)-1] == '"') ||
				(value[0] == '\'' && value[len(value)-1] == '\'') {
				value = value[1 : len(value)-1]
			}
		}

		if key != "" {
			envMap[key] = value
		}
	}

	return envMap, scanner.Err()
}

// copyToClipboard copies text to clipboard using OS-specific commands
func copyToClipboard(text string) {
	var cmd *exec.Cmd

	switch runtime.GOOS {
	case "darwin":
		cmd = exec.Command("pbcopy")
	case "linux":
		// Try xclip first, then xsel as fallback
		if _, err := exec.LookPath("xclip"); err == nil {
			cmd = exec.Command("xclip", "-selection", "clipboard")
		} else if _, err := exec.LookPath("xsel"); err == nil {
			cmd = exec.Command("xsel", "--clipboard", "--input")
		} else {
			return // No clipboard tool available
		}
	case "windows":
		cmd = exec.Command("clip")
	default:
		return // Unsupported OS
	}

	if cmd != nil {
		cmd.Stdin = strings.NewReader(text)
		cmd.Run() // Ignore errors silently
	}
}
