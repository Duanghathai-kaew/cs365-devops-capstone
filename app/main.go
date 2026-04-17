package main

import (
	"log"
	"net/http"
)

func main() {
    fs := http.FileServer(http.Dir("static"))
    http.Handle("/", http.StripPrefix("/", fs))

    log.Println("Server started on :8080")
    log.Fatal(http.ListenAndServe(":8080", nil))
}
