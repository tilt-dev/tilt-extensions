// +build !skipfailing

package bar

import (
	"testing"
)

func TestPicard(t *testing.T) {
	numLights := 4
	if numLights != 5 {
		t.Fatal("there are five lights")
	}
}

