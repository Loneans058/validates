package main

import (
	"embed"
	"io/fs"
	"log/slog"
	"net/http"
	"smartshielddocumentvalidator/internal/env"
	"smartshielddocumentvalidator/internal/logger"
	"text/template"
)

var (
	HttpPort       = "8000"
	Version        = "n/a"
	CommitHash     = "n/a"
	BuildTimestamp = "n/a"
)

const envTemplate = `ENV={{.Env}}
URL={{.Url}}
SSO_URL={{.SsoUrl}}
SSO_CLIENT_ID={{.SsoClientId}}
`

type envVariable struct {
	Env         string
	Url         string
	SsoUrl      string
	SsoClientId string
}

//go:embed assets
var public embed.FS

func main() {
	logger.SetUp(Version, CommitHash, BuildTimestamp)
	staticFs, err := fs.Sub(public, "assets")
	if err != nil {
		slog.Error("error get static fs", slog.Any("err", err))
		return
	}
	http.HandleFunc("/assets/env", handleEnv)
	http.Handle("/", http.FileServer(http.FS(staticFs)))
	if err := http.ListenAndServe(":"+HttpPort, nil); err != nil {
		slog.Error("error serve http request", slog.Any("err", err))
	}
}

func handleEnv(res http.ResponseWriter, _ *http.Request) {
	cfg, err := env.LoadConfig()
	if err != nil {
		slog.Error("error load config", slog.Any("err", err))
		res.WriteHeader(http.StatusInternalServerError)
		res.Write([]byte(`{"error":"` + err.Error() + `"}`))
		return
	}
	t := template.New("publicEnv")
	t, err = t.Parse(envTemplate)
	if err != nil {
		slog.Error("error parse template", slog.Any("err", err))
		res.WriteHeader(http.StatusInternalServerError)
		res.Write([]byte(`{"error":"` + err.Error() + `"}`))
		return
	}

	res.WriteHeader(http.StatusOK)
	err = t.Execute(res, envVariable{
		Env:         "public",
		Url:         cfg.Url,
		SsoUrl:      cfg.SsoUrl,
		SsoClientId: cfg.SsoClientId,
	})
	if err != nil {
		slog.Error("error execute template", slog.Any("err", err))
		res.WriteHeader(http.StatusInternalServerError)
		res.Write([]byte(`{"error":"` + err.Error() + `"}`))
		return
	}
}
