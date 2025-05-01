package plg_authenticate_keycloak

import (
	"context"
	"encoding/json"
	"errors"
	"net/http"
	"net/url"
	"strings"

	"github.com/mickael-kerjean/filestash/server/common/types"
)

type KeycloakAuth struct{}

func (k *KeycloakAuth) Name() string {
	return "keycloak"
}

func (k *KeycloakAuth) Login(ctx context.Context, username, password string) (*types.User, error) {
	form := url.Values{}
	form.Set("grant_type", "password")
	form.Set("client_id", "filestash")
	form.Set("client_secret", "KdNzeCdD29t5p97IrCynWMzhexpl4c6R")
	form.Set("username", username)
	form.Set("password", password)

	resp, err := http.Post(
		"https://keycloak.wikichi.org/realms/WikiChi/protocol/openid-connect/token",
		"application/x-www-form-urlencoded",
		strings.NewReader(form.Encode()),
	)
	if err != nil {
		return nil, err
	}
	defer resp.Body.Close()

	if resp.StatusCode != http.StatusOK {
		return nil, errors.New("login failed: bad credentials or server error")
	}

	var tokenResp struct {
		AccessToken string `json:"access_token"`
		IDToken     string `json:"id_token"`
		// Add more fields here if needed
	}

	if err := json.NewDecoder(resp.Body).Decode(&tokenResp); err != nil {
		return nil, err
	}

	return &types.User{
		Username: username, // Optional: parse token to extract email, etc.
	}, nil
}

func (k *KeycloakAuth) Logout(ctx context.Context, session *types.Session) error {
	// Optional: Implement Keycloak token revocation if desired
	return nil
}

func init() {
	types.RegisterPlugin(&KeycloakAuth{})
}
