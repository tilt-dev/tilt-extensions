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
var watchFile = flag.String("watch_file", "", "File that entr will watch for changes; changes to this file trigger entr to rerun the command(s) passed")
var entrPath = flag.String("entr_path", "/entr", "Path to `entr` executable")

func main() {
	flag.Parse()

	cmd := exec.Command(*entrPath, "-rz")
	cmd.Stdin = strings.NewReader(fmt.Sprintf("%s\n", *watchFile))
	cmd.Args = append(cmd.Args, flag.Args()...)
	cmd.Stdout = os.Stdout
	cmd.Stderr = os.Stderr

	if err := cmd.Run(); err != nil {
		if exiterr, ok := err.(*exec.ExitError); ok {
			// The program has exited with an exit code != 0
			if status, ok := exiterr.Sys().(syscall.WaitStatus); ok {
				if len(flag.Args()) == 0 {
					log.Println("`tilt-restart-wrapper` requires at least one positional arg " +
						"(a command or set of args to be  executed / rerun whenever `watch_file` changes)")
				}
				os.Exit(status.ExitStatus())
			}
		} else {
			log.Fatalf("error running command: %v", err)
		}
	}

	fmt.Println("hi there")
	if len(flag.Args()) == 0 {
		log.Fatal("`tilt-restart-wrapper` requires at least one positional arg "+
			"(will be passed to `entr` and executed / rerun whenever `watch_file` changes)")
	}
}
