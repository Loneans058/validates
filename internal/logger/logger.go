package logger

import (
	"errors"
	"fmt"
	"log/slog"
	"os"
	"runtime"
	"strings"

	"github.com/lmittmann/tint"
	st "github.com/pkg/errors"
)

var (
	Level  = new(slog.LevelVar)
	Logger *slog.Logger
)

func SetUp(version, commitHash, buildTimestamp string) {
	logLevel, err := parseLogLevel(os.Getenv("LOG_LEVEL"))
	Level.Set(logLevel)

	opts := &slog.HandlerOptions{
		AddSource:   true,
		Level:       logLevel,
		ReplaceAttr: replaceAttr,
	}

	if Level.Level() >= slog.LevelInfo {
		Logger = slog.New(slog.NewJSONHandler(os.Stdout, opts)).With(
			slog.String("app", "chainsmart/smartshieldapi"),
			slog.String("version", version),
			slog.String("commit", commitHash),
			slog.String("build", buildTimestamp),
		)
		slog.SetDefault(Logger)
	} else {
		Logger = slog.New(tint.NewHandler(os.Stdout, &tint.Options{
			AddSource:   true,
			Level:       logLevel,
			ReplaceAttr: replaceAttr,
		}))
	}

	slog.SetDefault(Logger)

	if err != nil {
		slog.Error("error parsing log level", slog.Any("err", err))
	}

	if Level.Level() < slog.LevelInfo {
		slog.Debug("app information",
			slog.String("app", "chainsmart/smartshield-queue"),
			slog.String("version", version),
			slog.String("commit", commitHash),
			slog.String("build", buildTimestamp),
		)
	}
}

func parseLogLevel(level string) (slog.Level, error) {
	switch strings.ToUpper(level) {
	case "DEBUG":
		return slog.LevelDebug, nil
	case "INFO":
		return slog.LevelInfo, nil
	case "WARN":
		return slog.LevelWarn, nil
	case "ERROR":
		return slog.LevelError, nil
	default:
		return slog.LevelDebug, errors.New("unknown log level, revert to debug mode")
	}
}

func replaceAttr(groups []string, a slog.Attr) slog.Attr {
	switch a.Value.Kind() {
	// other cases

	case slog.KindAny:
		switch v := a.Value.Any().(type) {
		case error:
			a.Value = fmtErr(v)
		}
	}

	return a
}

// fmtErr returns a slog.GroupValue with keys "msg" and "trace". If the error
// does not implement interface { StackTrace() errors.StackTrace }, the "trace"
// key is omitted.
func fmtErr(err error) slog.Value {
	var groupValues []slog.Attr

	groupValues = append(groupValues, slog.String("msg", err.Error()))

	type StackTracer interface {
		StackTrace() st.StackTrace
	}

	// Find the trace to the location of the first errors.New,
	// errors.Wrap, or errors.WithStack call.
	var st StackTracer
	for err := err; err != nil; err = errors.Unwrap(err) {
		if x, ok := err.(StackTracer); ok {
			st = x
		}
	}

	if st != nil {
		groupValues = append(groupValues,
			slog.Any("trace", traceLines(st.StackTrace())),
		)
	}

	return slog.GroupValue(groupValues...)
}

func traceLines(frames st.StackTrace) []string {
	traceLines := make([]string, len(frames))

	// Iterate in reverse to skip uninteresting, consecutive runtime frames at
	// the bottom of the trace.
	var skipped int
	skipping := true
	for i := len(frames) - 1; i >= 0; i-- {
		// Adapted from errors.Frame.MarshalText(), but avoiding repeated
		// calls to FuncForPC and FileLine.
		pc := uintptr(frames[i]) - 1
		fn := runtime.FuncForPC(pc)
		if fn == nil {
			traceLines[i] = "unknown"
			skipping = false
			continue
		}

		name := fn.Name()

		if skipping && strings.HasPrefix(name, "runtime.") {
			skipped++
			continue
		} else {
			skipping = false
		}

		filename, lineNr := fn.FileLine(pc)

		traceLines[i] = fmt.Sprintf("%s %s:%d", name, filename, lineNr)
	}

	return traceLines[:len(traceLines)-skipped]
}
