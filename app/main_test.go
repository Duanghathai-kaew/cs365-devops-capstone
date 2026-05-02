package main

import (
	"net/http"
	"net/http/httptest"
	"testing"
)

func TestStaticFileServer(t *testing.T) {
	// Create a test server using the same handler as main
	fs := http.FileServer(http.Dir("static"))
	handler := http.StripPrefix("/", fs)
	server := httptest.NewServer(handler)
	defer server.Close()

	// Test GET request to root path
	resp, err := http.Get(server.URL + "/")
	if err != nil {
		t.Fatalf("Failed to make GET request: %v", err)
	}
	defer resp.Body.Close()

	// Check if status code is 200 OK
	if resp.StatusCode != http.StatusOK {
		t.Errorf("Expected status 200, got %d", resp.StatusCode)
	}
}
