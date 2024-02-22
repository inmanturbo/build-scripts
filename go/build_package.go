package main

import (
	"fmt"
	"os"
	"os/exec"
	"path/filepath"
	"strings"
)

func main() {
	if len(os.Args) < 2 {
		fmt.Println("Usage: go run script.go <branch_B> [build_directory]")
		os.Exit(1)
	}

	branchB := os.Args[1]
	buildDir := "build"
	if len(os.Args) > 2 {
		buildDir = os.Args[2]
	}

	branchA, err := exec.Command("git", "rev-parse", "--abbrev-ref", "HEAD").Output()
	if err != nil {
		fmt.Printf("Error getting current branch: %v\n", err)
		os.Exit(1)
	}

	diffCmd := exec.Command("git", "diff", "--name-status", strings.TrimSpace(string(branchA)), branchB)
	diffOut, err := diffCmd.Output()
	if err != nil {
		fmt.Printf("Error getting diff: %v\n", err)
		os.Exit(1)
	}

	for _, line := range strings.Split(strings.TrimSpace(string(diffOut)), "\n") {
		parts := strings.Fields(line)
		if len(parts) < 2 || parts[0] == "D" {
			continue
		}

		filePath := parts[1]
		var destPath string

		if strings.HasPrefix(filePath, "app/") {
			destPath = filepath.Join(buildDir, "src", strings.TrimPrefix(filePath, "app/"))
		} else {
			destPath = filepath.Join(buildDir, filePath)
		}

		if err := os.MkdirAll(filepath.Dir(destPath), os.ModePerm); err != nil {
			fmt.Printf("Error creating directory for %s: %v\n", destPath, err)
			continue
		}

		showCmd := exec.Command("git", "show", fmt.Sprintf("%s:%s", branchB, filePath))
		content, err := showCmd.Output()
		if err != nil {
			fmt.Printf("Error showing file %s: %v\n", filePath, err)
			continue
		}

		if err := os.WriteFile(destPath, content, 0644); err != nil {
			fmt.Printf("Error writing file %s: %v\n", destPath, err)
		}
	}

	fmt.Printf("Package structure for branch %s has been prepared in the %s directory.\n", branchB, buildDir)
}
