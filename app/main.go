package main

import (
	"log"
	"net/http"
)

func healthHandler(w http.ResponseWriter, r *http.Request) {
	w.WriteHeader(http.StatusOK)
	_, _ = w.Write([]byte("ok"))
}

func pingHandler(w http.ResponseWriter, r *http.Request) {
	w.WriteHeader(http.StatusOK)
	_, _ = w.Write([]byte("Hello World"))
}

func newRouter() http.Handler {
	mux := http.NewServeMux()

	mux.HandleFunc("/health", healthHandler)
	mux.HandleFunc("/ping", pingHandler)

	fs := http.FileServer(http.Dir("static"))
	mux.Handle("/", http.StripPrefix("/", fs))

	return mux
}

func main() {
	log.Println("Server started on :8080")
	log.Fatal(http.ListenAndServe(":8080", newRouter()))
}
