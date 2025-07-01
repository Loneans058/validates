package env

import (
	"log/slog"

	"github.com/caarlos0/env/v11"
	"github.com/go-playground/validator/v10"
)

type Config struct {
	Env         string `env:"ENV"`
	Url         string `env:"URL" validate:"required"`
	SsoUrl      string `env:"SSO_URL" validate:"required"`
	SsoClientId string `env:"SSO_CLIENT_ID" validate:"required"`
}

func LoadConfig() (Config, error) {
	cfg := Config{}
	if err := env.Parse(&cfg); err != nil {
		slog.Error("unable to parse environment variables", slog.Any("err", err))
		return Config{}, err
	}
	if err := validator.New().Struct(cfg); err != nil {
		slog.Error("invalid environment variables", slog.Any("err", err))
		return Config{}, err
	}
	return cfg, nil
}
