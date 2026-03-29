# Link Shortener

A URL shortening service built with Ruby on Rails. Shorten long URLs, track clicks with geolocation, and view usage reports.

**Deployed application:** https://link-shortener-kdxz.onrender.com

## Features

- Shorten any URL and get a short, shareable link (max 15 characters)
- Automatic page title extraction from target URLs
- Click tracking with originating geolocation (country, city) and timestamps
- Usage reports per short URL with click breakdowns
- Rate limiting to prevent abuse
- Copy-to-clipboard for short URLs

## Tech Stack

- **Backend:** Ruby 3.3.0, Rails 7.2.3
- **Database:** PostgreSQL 16
- **Frontend:** Tailwind CSS 4.2, Hotwire (Turbo + Stimulus)
- **Testing:** RSpec, FactoryBot, WebMock, SimpleCov (89% coverage)
- **Security:** Rack::Attack (rate limiting), Brakeman (static analysis)
- **Deployment:** Render (Docker)

## Prerequisites

- Ruby 3.3.0 (via rbenv or asdf)
- PostgreSQL 16+
- Node.js 22+ (for importmap)

## Installation

```bash
# Clone the repository
git clone https://github.com/aaronhsyong2/link-shortener.git
cd link-shortener

# Install dependencies
bundle install

# Set up database
# Option A: Local PostgreSQL
bin/rails db:create db:migrate

# Option B: Docker PostgreSQL
docker run --name link-shortener-pg -e POSTGRES_USER=postgres -e POSTGRES_PASSWORD=postgres -p 5432:5432 -d postgres:16-alpine
bin/rails db:create db:migrate

# Start the development server
bin/dev
```

Visit http://localhost:3000

## Configuration

Database connection is configured via environment variables with sensible defaults:

| Variable | Default | Description |
|----------|---------|-------------|
| `DB_HOST` | `localhost` | PostgreSQL host |
| `DB_USERNAME` | `postgres` | PostgreSQL username |
| `DB_PASSWORD` | `postgres` | PostgreSQL password |
| `DB_PORT` | `5432` | PostgreSQL port |
| `IPINFO_TOKEN` | *(optional)* | ipinfo.io API token for geolocation |
| `SECRET_KEY_BASE` | *(required in production)* | Rails encryption key |

In production, `DATABASE_URL` overrides all individual DB variables.

## Running Tests

```bash
bundle exec rspec                        # Run all specs
bundle exec rspec spec/models/           # Run model specs only
bundle exec rspec --format documentation # Verbose output
```

Coverage report is generated at `coverage/index.html` after each run.

## Linting and Security

```bash
bin/rubocop          # Code style (RuboCop)
bin/brakeman         # Security scan (Brakeman)
bin/importmap audit  # JavaScript dependency audit
```

## Short URL Strategy

Short codes are generated using **Base62 encoding** (a-z, A-Z, 0-9):

- Default length: 6 characters
- Maximum length: 15 characters (per specification)
- Total possible codes at 6 chars: 62^6 = ~56.8 billion
- Collision handling: random generation with retry (max 10 attempts)

### Limitations

1. **Not sequential** — codes are random, not incremental. This prevents enumeration attacks but means codes aren't predictable.
2. **Collision probability** — at scale, random generation has increasing collision risk. With 1 million URLs and 6-char codes, collision probability is ~0.002%. Mitigation: retry loop with up to 10 attempts.
3. **No custom codes** — users cannot choose their own short code. This simplifies the system and avoids offensive/reserved word handling.
4. **Case-sensitive** — `aBc` and `abc` are different codes. This maximizes the code space but can confuse users sharing URLs verbally.

### Workarounds for Scale

- Increase code length (7-8 chars) when collision rate rises
- Switch to sequential Base62 encoding with a counter for guaranteed uniqueness
- Add a Bloom filter for O(1) collision checks instead of database lookups
- Partition the code space across multiple database shards

## Design Patterns

- **Service Objects** — `UrlShortenerService`, `UrlMetadataService`, `GeolocationService` encapsulate business logic with singleton instances for performance
- **Memoized Singletons** — services use `@instance ||= new` to avoid per-request object creation
- **Strong Parameters** — whitelist only `target_url` from user input
- **Helper Methods** — `safe_url` sanitizes URLs at the view layer as defense-in-depth

## Architecture

```
app/
├── controllers/
│   ├── urls_controller.rb       # CRUD for URLs (index, show, new, create)
│   ├── redirects_controller.rb  # Short URL redirect + visit tracking
│   └── reports_controller.rb    # Usage analytics dashboard
├── models/
│   ├── url.rb                   # URL record with validations and associations
│   └── visit.rb                 # Click tracking record
├── services/
│   ├── url_shortener_service.rb # Base62 code generation
│   ├── url_metadata_service.rb  # HTTP title extraction via Nokogiri
│   └── geolocation_service.rb   # ipinfo.io IP-to-location resolution
├── views/
│   ├── urls/                    # URL shortening form, details, listing
│   └── reports/                 # Analytics dashboard with geo breakdown
└── helpers/
    └── urls_helper.rb           # safe_url XSS prevention helper
```

## License

This project was built as a coding assessment submission.
