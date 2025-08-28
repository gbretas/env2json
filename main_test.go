package main

import (
	"encoding/json"
	"os"
	"path/filepath"
	"testing"

	"github.com/joho/godotenv"
)

func TestFileExists(t *testing.T) {
	// Create a temporary file
	tmpDir := t.TempDir()
	tmpFile := filepath.Join(tmpDir, "test.env")

	// File doesn't exist yet
	if fileExists(tmpFile) {
		t.Error("fileExists should return false for non-existent file")
	}

	// Create file
	err := os.WriteFile(tmpFile, []byte("TEST=value"), 0644)
	if err != nil {
		t.Fatalf("Failed to create test file: %v", err)
	}

	// File should exist now
	if !fileExists(tmpFile) {
		t.Error("fileExists should return true for existing file")
	}

	// Directory should not be considered as existing file
	if fileExists(tmpDir) {
		t.Error("fileExists should return false for directories")
	}
}

func TestIsSensitiveKey(t *testing.T) {
	testCases := []struct {
		key      string
		expected bool
	}{
		{"DATABASE_PASSWORD", true},
		{"API_SECRET", true},
		{"JWT_TOKEN", true},
		{"PRIVATE_KEY", true},
		{"AUTH_CREDENTIAL", true},
		{"DATABASE_URL", false},
		{"PORT", false},
		{"NODE_ENV", false},
		{"DEBUG", false},
	}

	for _, tc := range testCases {
		result := isSensitiveKey(tc.key)
		if result != tc.expected {
			t.Errorf("isSensitiveKey(%s) = %v, expected %v", tc.key, result, tc.expected)
		}
	}
}

func TestEnvToJSONConversion(t *testing.T) {
	// Create temporary .env file
	tmpDir := t.TempDir()
	envFile := filepath.Join(tmpDir, ".env")

	envContent := `# Database configuration
DATABASE_URL=postgresql://user:pass@localhost:5432/mydb
DATABASE_PASSWORD=secret123

# API Configuration
API_KEY=abc123def456
PORT=3000
NODE_ENV=development

# Empty lines and comments should be ignored

DEBUG=true`

	err := os.WriteFile(envFile, []byte(envContent), 0644)
	if err != nil {
		t.Fatalf("Failed to create test .env file: %v", err)
	}

	// Test the godotenv parsing (simulating our main logic)
	envMap, err := godotenv.Read(envFile)
	if err != nil {
		t.Fatalf("Failed to read .env file: %v", err)
	}

	// Verify expected variables are present
	expectedVars := map[string]string{
		"DATABASE_URL":      "postgresql://user:pass@localhost:5432/mydb",
		"DATABASE_PASSWORD": "secret123",
		"API_KEY":           "abc123def456",
		"PORT":              "3000",
		"NODE_ENV":          "development",
		"DEBUG":             "true",
	}

	for key, expectedValue := range expectedVars {
		if value, exists := envMap[key]; !exists {
			t.Errorf("Expected variable %s not found", key)
		} else if value != expectedValue {
			t.Errorf("Variable %s = %s, expected %s", key, value, expectedValue)
		}
	}

	// Test JSON conversion
	jsonData, err := json.MarshalIndent(envMap, "", "  ")
	if err != nil {
		t.Fatalf("Failed to convert to JSON: %v", err)
	}

	// Verify it's valid JSON
	var testMap map[string]string
	err = json.Unmarshal(jsonData, &testMap)
	if err != nil {
		t.Fatalf("Generated JSON is not valid: %v", err)
	}

	// Verify all variables are in the JSON
	for key := range expectedVars {
		if _, exists := testMap[key]; !exists {
			t.Errorf("Variable %s missing from JSON output", key)
		}
	}
}
