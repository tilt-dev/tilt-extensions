package main

import (
	"net/http"
	"os"
)

func main() {
	http.Handle("/", http.FileServer(http.Dir(os.Getenv("KO_DATA_PATH"))))
	http.ListenAndServe(":8080", nil)
}
