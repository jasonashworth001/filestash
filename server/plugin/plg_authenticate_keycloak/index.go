package plg_authenticate_keycloak

import (
	"context"
	"encoding/json"
	"errors"
	"net/http"
	"net/url"
	"os"
	"strings"

	"github.com/jasonashworth001/filestash/server/common/types"
)

// Auth plugin struct
type KeycloakAuth struct{}

func (k *KeycloakAuth) Name() string {
	return "keycloak"
}

func (k *KeycloakAuth) Login(ctx context.Context, username, password string) (*types.User, error) {
	clientID := os.Getenv("KEYCLOAK_CLIENT_ID")
	clientSecret := os.Getenv("KEYCLOAK_CLIENT_SECRET")
	tokenURL := os.Getenv("KEYCLOAK_TOKEN_URL")

	if clientID == "" || clientSecret == "" || tokenURL == "" {
		return nil, errors.New("Keycloak ENV vars not set")
	}

	form := url.Values{}
	form.Set("grant_type", "password")
	form.Set("client_id", clientID)
	form.Set("client_secret", clientSecret)
	form.Set("username", username)
	form.Set("password", password)

	resp, err := http.Post(tokenURL, "application/x-www-form-urlencoded", strings.NewReader(form.Encode()))
	if err != nil {
		return nil, err
	}
	defer resp.Body.Close()

	if resp.StatusCode != http.StatusOK {
		return nil, errors.New("login failed: check credentials or Keycloak config")
	}

	var tokenResp struct {
		AccessToken string `json:"access_token"`
		IDToken     string `json:"id_token"`
	}

	if err := json.NewDecoder(resp.Body).Decode(&tokenResp); err != nil {
		return nil, err
	}

	return &types.User{
		Username: username,
	}, nil
}

func (k *KeycloakAuth) Logout(ctx context.Context, session *types.Session) error {
	// Optional: revoke token or log out at Keycloak
	return nil
}

// Authorisation plugin struct (optional for access control)
type KeycloakAuthorizer struct{}

func (a *KeycloakAuthorizer) Name() string {
	return "keycloak"
}

// Grant full access (you can change this later to restrict)
func (a *KeycloakAuthorizer) Ls(ctx *types.App, path string) error    { return nil }
func (a *KeycloakAuthorizer) Cat(ctx *types.App, path string) error   { return nil }
func (a *KeycloakAuthorizer) Mkdir(ctx *types.App, path string) error { return nil }
func (a *KeycloakAuthorizer) Rm(ctx *types.App, path string) error    { return nil }
func (a *KeycloakAuthorizer) Mv(ctx *types.App, from string, to string) error {
	return nil
}
func (a *KeycloakAuthorizer) Save(ctx *types.App, path string) error  { return nil }
func (a *KeycloakAuthorizer) Touch(ctx *types.App, path string) error { return nil }

// Register both plugins
func init() {
	types.RegisterPlugin(&KeycloakAuth{})
	types.RegisterPlugin(&KeycloakAuthorizer{})
}
