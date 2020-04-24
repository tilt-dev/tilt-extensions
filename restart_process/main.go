package main

import (
	"flag"
	"fmt"
	"log"
	"os"
	"os/exec"
	"strings"
	"syscall"
)

var defaultWatchFile = "/.restart-proc"
var watchFile = flag.String("watchfile", "", "File that entr will watch for changes; changes to this file trigger entr to rerun the command(s) passed")

func main() {
	flag.Parse()

	args := os.Args[1:]
	if *watchFile == "" {
		*watchFile = defaultWatchFile
	} else {
		// user passed this arg, make sure we don't pass it along to entr
		args = os.Args[2:]
	}
	fmt.Println("Hello, world.")
	fmt.Println("args:", args)
	cmd := exec.Command("/entr", "-rz")
	cmd.Stdin = strings.NewReader(fmt.Sprintf("%s\n", *watchFile))
	cmd.Args = append(cmd.Args, args...)
	cmd.Stdout = os.Stdout
	cmd.Stderr = os.Stderr

	if err := cmd.Run(); err != nil {
		if exiterr, ok := err.(*exec.ExitError); ok {
			// The program has exited with an exit code != 0
			if status, ok := exiterr.Sys().(syscall.WaitStatus); ok {
				os.Exit(status.ExitStatus())
			}
		} else {
			log.Fatalf("error running command: %v", err)
		}
	}
}
