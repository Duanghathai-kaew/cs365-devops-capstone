package main

import (
	"io"
	"net/http"
	"net/http/httptest"
	"strings"
	"testing"
)

func TestHealthHandlerUnit(t *testing.T) {
	req := httptest.NewRequest(http.MethodGet, "/health", nil)
	rec := httptest.NewRecorder()

	healthHandler(rec, req)

	resp := rec.Result()
	defer func() {
		err := resp.Body.Close()
		if err != nil {
			t.Log(err)
		}
	}()

	if resp.StatusCode != http.StatusOK {
		t.Fatalf("expected status 200, got %d", resp.StatusCode)
	}

	body, err := io.ReadAll(resp.Body)
	if err != nil {
		t.Fatalf("failed to read response body: %v", err)
	}

	if strings.TrimSpace(string(body)) != "ok" {
		t.Fatalf("expected body ok, got %q", string(body))
	}
}

func TestPingHandlerUnit(t *testing.T) {
	req := httptest.NewRequest(http.MethodGet, "/ping", nil)
	rec := httptest.NewRecorder()

	pingHandler(rec, req)

	resp := rec.Result()
	defer func() {
		err := resp.Body.Close()
		if err != nil {
			t.Log(err)
		}
	}()

	if resp.StatusCode != http.StatusOK {
		t.Fatalf("expected status 200, got %d", resp.StatusCode)
	}

	body, err := io.ReadAll(resp.Body)
	if err != nil {
		t.Fatalf("failed to read response body: %v", err)
	}

	if strings.TrimSpace(string(body)) != "Hello World" {
		t.Fatalf("expected Hello World, got %q", string(body))
	}
}

func TestStaticFileServerIntegration(t *testing.T) {
	server := httptest.NewServer(newRouter())
	defer server.Close()

	resp, err := http.Get(server.URL + "/")
	if err != nil {
		t.Fatalf("failed to make GET request: %v", err)
	}
	defer func() {
		err := resp.Body.Close()
		if err != nil {
			t.Log(err)
		}
	}()

	if resp.StatusCode != http.StatusOK {
		t.Errorf("expected status 200, got %d", resp.StatusCode)
	}
}

func TestHealthEndpointIntegration(t *testing.T) {
	server := httptest.NewServer(newRouter())
	defer server.Close()

	resp, err := http.Get(server.URL + "/health")
	if err != nil {
		t.Fatalf("failed to call /health: %v", err)
	}
	defer func() {
		err := resp.Body.Close()
		if err != nil {
			t.Log(err)
		}
	}()

	if resp.StatusCode != http.StatusOK {
		t.Fatalf("expected status 200, got %d", resp.StatusCode)
	}

	body, err := io.ReadAll(resp.Body)
	if err != nil {
		t.Fatalf("failed to read response body: %v", err)
	}

	if strings.TrimSpace(string(body)) != "ok" {
		t.Fatalf("expected body ok, got %q", string(body))
	}
}

func TestNotFoundPathNegativeCase(t *testing.T) {
	server := httptest.NewServer(newRouter())
	defer server.Close()

	resp, err := http.Get(server.URL + "/not-found-page")
	if err != nil {
		t.Fatalf("failed to call not found path: %v", err)
	}
	defer func() {
		err := resp.Body.Close()
		if err != nil {
			t.Log(err)
		}
	}()

	if resp.StatusCode != http.StatusNotFound {
		t.Fatalf("expected status 404, got %d", resp.StatusCode)
	}
}
