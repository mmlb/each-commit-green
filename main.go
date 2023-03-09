package main

import (
	"context"
	"fmt"
	"os"

	"github.com/gofri/go-github-ratelimit/github_ratelimit"
	"github.com/google/go-github/v50/github"
	"golang.org/x/oauth2"
)

func main() {
	ctx := context.Background()
	ts := oauth2.StaticTokenSource(
		&oauth2.Token{AccessToken: os.Getenv("GITHUB_TOKEN")},
	)
	tc := oauth2.NewClient(ctx, ts)
	rateLimiter, err := github_ratelimit.NewRateLimitWaiterClient(tc.Transport)
	if err != nil {
		panic(err)
	}
	client := github.NewClient(rateLimiter)

	orgs, _, err := client.Organizations.List(context.Background(), "mmlb", nil)
	if err != nil {
		panic(err)
	}

	for _, o := range orgs {
		fmt.Println(o.GetLogin())
	}
}
