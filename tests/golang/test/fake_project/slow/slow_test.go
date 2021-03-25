package slow

import (
	"fmt"
	"testing"
	"time"
)

func TestSlightlySlow(t *testing.T) {
	time.Sleep(time.Millisecond*3)
	fmt.Println("nothing to see here...")
}
