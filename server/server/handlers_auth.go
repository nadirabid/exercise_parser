package server

import (
	"encoding/json"
	"exercise_parser/models"
	"fmt"
	"io/ioutil"
	"log"
	"net/http"
	"net/url"
	"strings"
	"time"

	"github.com/labstack/echo"
	"github.com/lestrrat-go/jwx/jwa"
	"github.com/lestrrat-go/jwx/jwk"
	"github.com/lestrrat-go/jwx/jws"
	"github.com/lestrrat-go/jwx/jwt"
	"github.com/spf13/viper"
)

type TokenResponse struct {
	Token string             `json:"token"`
	User  models.WrappedUser `json:"user"`
}

func handleUserRegistrationHelper(user *models.User, ctx *Context) (*TokenResponse, error) {
	err := ctx.db.
		Where("external_user_id = ?", user.ExternalUserId).
		FirstOrCreate(user).
		Error

	if err != nil {
		return nil, err
	}

	now := time.Unix(time.Now().Unix(), 0)

	// alrighty - lets create a token for this user. the jwt given
	// by apple only lasts for 10 minutes. SO - use apple token to
	// do a "login", and then handout our own jwt
	t := jwt.New()

	// standard claims
	t.Set(jwt.AudienceKey, "ryden")
	t.Set(jwt.ExpirationKey, now.Add(7*24*time.Hour).Unix()) // a goddamn week
	t.Set(jwt.IssuedAtKey, now.Unix())
	t.Set(jwt.IssuerKey, "https://ryden.app")
	t.Set(jwt.SubjectKey, fmt.Sprint(user.ID))
	t.Set(JWTKeySubjectRoles, user.Roles)

	payload, err := t.Sign(jwa.RS256, ctx.key)

	if err != nil {
		return nil, err
	}

	r := models.WrappedUser{
		User:        *user,
		ImageExists: user.ImagePath != "",
	}

	return &TokenResponse{
		Token: string(payload),
		User:  r,
	}, nil
}

// right now this only does "sign in with apple"
func handleUserRegistration(c echo.Context) error {
	ctx := c.(*Context)

	bearerToken := strings.Split(c.Request().Header.Get("Authorization"), " ")

	if viper.GetBool("middleware.auth") {
		// this is the check we do - before handing out a token

		// TODO: we should cache jwk
		jwkURL := "https://appleid.apple.com/auth/keys"
		set, err := jwk.Fetch(jwkURL)
		if err != nil {
			log.Printf("failed to parse JWK: %s", err)
			return ctx.JSON(http.StatusInternalServerError, newErrorMessage(err.Error()))
		}

		_, err = jws.VerifyWithJWKSet([]byte(bearerToken[1]), set, nil)
		if err != nil {
			return ctx.JSON(http.StatusUnauthorized, newErrorMessage(err.Error()))
		}
	}

	user := &models.User{}
	if err := ctx.Bind(user); err != nil {
		return ctx.JSON(http.StatusBadRequest, newErrorMessage(err.Error()))
	}

	r, err := handleUserRegistrationHelper(user, ctx)
	if err != nil {
		return ctx.JSON(http.StatusInternalServerError, newErrorMessage(err.Error()))
	}

	return ctx.JSON(http.StatusOK, r)
}

type AppleAuthTokenResponse struct {
	AccessToken  string `json:"access_token"`
	ExpiresIn    uint   `json:"expires_in"`
	IdToken      string `json:"id_token"`
	RefreshToken string `json:"refresh_token"`
	TokenType    string `json:"token_type"`
}

type AppleUserFormPost struct {
	Email string `json:"email"`
	Name  struct {
		FirstName string `json:"firstName"`
		LastName  string `json:"lastName"`
	}
}

// https://developer.okta.com/blog/2019/06/04/what-the-heck-is-sign-in-with-apple
// https://developer.apple.com/documentation/sign_in_with_apple/generate_and_validate_tokens
func handleAppleAuthCallback(c echo.Context) error {
	ctx := c.(*Context)

	user := &models.User{}

	if userFormValue := ctx.FormValue("user"); userFormValue != "" {
		u := &AppleUserFormPost{}
		if err := json.Unmarshal([]byte(userFormValue), u); err != nil {
			return ctx.JSON(http.StatusInternalServerError, newErrorMessage(err.Error()))
		}

		user.GivenName = u.Name.FirstName
		user.FamilyName = u.Name.LastName
	}

	appleAuthCode := ctx.FormValue("code")
	if appleAuthCode == "" {
		return ctx.JSON(http.StatusInternalServerError, newErrorMessage("Auth code is missing. Failed to authenticate!"))
	}

	referrer := ctx.Request().Header.Get("Referrer")
	referrerURL, err := url.Parse(referrer)
	if err != nil {
		return ctx.JSON(http.StatusInternalServerError, newErrorMessage(fmt.Sprintf("Unable to parser referrer URL: %s", referrer)))
	}

	appleClientSecret, err := generateAppleClientSecret(ctx.viper)
	if err != nil {
		return ctx.JSON(http.StatusInternalServerError, newErrorMessage("couldnt validate client secret"))
	}

	resp, err := http.PostForm("https://appleid.apple.com/auth/token", url.Values{
		"grant_type":    {"authorization_code"},
		"code":          {appleAuthCode},
		"redirect_uri":  {referrerURL.Query().Get("redirect_uri")},
		"client_id":     {ctx.viper.GetString("auth.apple.client_id")},
		"client_secret": {appleClientSecret},
	})

	if err != nil {
		return ctx.JSON(http.StatusInternalServerError, newErrorMessage(err.Error()))
	} else if resp.StatusCode == 400 {
		defer resp.Body.Close()
		body, _ := ioutil.ReadAll(resp.Body)

		r := struct {
			Error string `json:"error"`
		}{}
		json.Unmarshal(body, &r)

		return ctx.JSON(http.StatusUnauthorized, newErrorMessage(r.Error))
	}

	defer resp.Body.Close()
	body, err := ioutil.ReadAll(resp.Body)

	tokenResp := &AppleAuthTokenResponse{}
	if err := json.Unmarshal(body, &tokenResp); err != nil {
		return ctx.JSON(http.StatusInternalServerError, newErrorMessage(err.Error()))
	}

	appleIdToken, _ := jwt.ParseString(tokenResp.IdToken) // TODO: verify signature?
	user.ExternalUserId = appleIdToken.Subject()
	user.Email, _ = getEmailFromJWT(appleIdToken)

	r, err := handleUserRegistrationHelper(user, ctx)

	if err != nil {
		return ctx.JSON(http.StatusInternalServerError, newErrorMessage(err.Error()))
	}

	return ctx.Redirect(http.StatusFound, fmt.Sprintf("%s?id_token=%s", ctx.viper.GetString("auth.apple.redirect_uri"), r.Token))
}
