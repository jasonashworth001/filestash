package plugin

import (
	"strings"

	. "github.com/mickael-kerjean/filestash/server/common"
)

func init() {
	// Register our Keycloak‐aware authorization middleware
	Hooks.Register.AuthorisationMiddleware(KeycloakAuth{})
}

type KeycloakAuth struct{}

// getEmail returns the logged-in user’s email (lowercased), or "" if none.
// It also logs what it found.
func getEmail(ctx *App) string {
	if ctx.Session == nil || ctx.Session.User == nil {
		Log.Stdout("KeycloakAuth getEmail: no session or user object")
		return ""
	}
	email := strings.ToLower(ctx.Session.User.Email)
	Log.Stdout("KeycloakAuth getEmail → %q", email)
	return email
}

// getRoles returns the slice of roles, or nil, and logs them.
func getRoles(ctx *App) []string {
	if ctx.Session == nil || ctx.Session.User == nil {
		Log.Stdout("KeycloakAuth getRoles: no session or user object")
		return nil
	}
	roles := ctx.Session.User.Roles
	Log.Stdout("KeycloakAuth getRoles → %+v", roles)
	return roles
}

// allowIfAuthed is our shared check: must have a non-empty email.
func allowIfAuthed(ctx *App, op, path string) error {
	email := getEmail(ctx)
	roles := getRoles(ctx)
	Log.Stdout("KeycloakAuth %s: path=%q, email=%q, roles=%+v", op, path, email, roles)
	if email == "" {
		return ErrNotAllowed
	}
	return nil
}

func (k KeycloakAuth) Ls(ctx *App, path string) error {
	return allowIfAuthed(ctx, "Ls", path)
}

func (k KeycloakAuth) Cat(ctx *App, path string) error {
	return allowIfAuthed(ctx, "Cat", path)
}

func (k KeycloakAuth) Mkdir(ctx *App, path string) error {
	return allowIfAuthed(ctx, "Mkdir", path)
}

func (k KeycloakAuth) Rm(ctx *App, path string) error {
	return allowIfAuthed(ctx, "Rm", path)
}

func (k KeycloakAuth) Mv(ctx *App, from, to string) error {
	// we include both source & destination in the log
	return allowIfAuthed(ctx, "Mv", from+" → "+to)
}

func (k KeycloakAuth) Save(ctx *App, path string) error {
	return allowIfAuthed(ctx, "Save", path)
}

func (k KeycloakAuth) Touch(ctx *App, path string) error {
	return allowIfAuthed(ctx, "Touch", path)
}
