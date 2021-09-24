package slow

import (
	"fmt"
	"testing"
	"time"
)

// This is invoked with a small `go test -timeout` to test the extension's timeout setting
func TestSlightlySlow(t *testing.T) {
	// small durations such as 3ms apparently allow a `go test -timeout 1ms` to still succeed
	time.Sleep(time.Second)
	fmt.Println("nothing to see here...")
}
