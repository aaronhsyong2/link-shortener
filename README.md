# Link Shortener

A URL shortening service built with Ruby on Rails. Shorten long URLs, track clicks with geolocation, and view usage reports.

**Deployed application:** https://link-shortener-kdxz.onrender.com

**Wiki:** [Design decisions, security, scalability, and short URL strategy](https://github.com/aaronhsyong2/link-shortener/wiki)

## Features

- Shorten any URL and get a short, shareable link
- Deterministic slug generation via [Sqids](https://sqids.org) — no collisions, no stored codes
- Built-in profanity filtering (Sqids default blocklist)
- Automatic page title extraction from target URLs
- Click tracking with originating geolocation (country, city) and timestamps
- Usage reports per short URL with click breakdowns
- Rate limiting to prevent abuse
- Copy-to-clipboard for short URLs

## Tech Stack

- **Backend:** Ruby 3.3.0, Rails 7.2.3
- **Database:** PostgreSQL 16
- **Frontend:** Tailwind CSS 4.2, Hotwire (Turbo + Stimulus)
- **Slug Generation:** [Sqids](https://sqids.org) (deterministic, ID-based encoding)
- **Testing:** RSpec, FactoryBot, WebMock, SimpleCov (93% coverage)
- **Security:** Rack::Attack (rate limiting), Brakeman (static analysis)
- **Deployment:** Render (Docker)

## Prerequisites

- Ruby 3.3.0 (via rbenv or asdf)
- PostgreSQL 16+
- Node.js 22+ (for importmap)

## Installation

```bash
git clone https://github.com/aaronhsyong2/link-shortener.git
cd link-shortener
bundle install

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

| Variable | Default | Description |
|----------|---------|-------------|
| `DB_HOST` | `localhost` | PostgreSQL host |
| `DB_USERNAME` | `postgres` | PostgreSQL username |
| `DB_PASSWORD` | `postgres` | PostgreSQL password |
| `DB_PORT` | `5432` | PostgreSQL port |
| `IPINFO_TOKEN` | *(optional)* | ipinfo.io API token for geolocation |
| `SECRET_KEY_BASE` | *(required in production)* | Rails encryption key |
| `DATABASE_URL` | *(production)* | Overrides all individual DB variables |

## Running Tests

```bash
bundle exec rspec                        # Run all specs (83 examples)
bundle exec rspec spec/models/           # Run model specs only
bundle exec rspec --format documentation # Verbose output
```

Coverage report generated at `coverage/index.html` after each run.

## Linting and Security

```bash
bin/rubocop          # Code style
bin/brakeman         # Security scan
bin/importmap audit  # JavaScript dependency audit
```

## Architecture

```
app/
├── controllers/
│   ├── urls_controller.rb       # URL shortening (index, show, new, create)
│   ├── redirects_controller.rb  # Short URL redirect + visit tracking
│   └── reports_controller.rb    # Usage analytics dashboard
├── models/
│   ├── url.rb                   # Sqids slug encoding, validations, associations
│   └── visit.rb                 # Click record with geolocation data
├── services/
│   ├── url_shortener_service.rb # URL creation (single insert, no collision retry)
│   ├── url_metadata_service.rb  # HTTP title extraction with redirect following
│   └── geolocation_service.rb   # IP-to-location with private IP detection
├── views/
│   ├── urls/                    # Shortening form, details, listing
│   └── reports/                 # Analytics with geo breakdown tables
└── helpers/
    └── urls_helper.rb           # URL sanitization for XSS prevention
```

## Short URL Strategy

Slugs are generated deterministically from the database record ID using [Sqids](https://sqids.org):

- `Url#slug` encodes the record's `id` → minimum 4 alphanumeric characters
- `Url.from_slug(slug)` decodes the slug back to an ID and finds the record
- No `short_code` column needed — slugs are computed at runtime
- No collision retry — each ID maps to exactly one slug
- Profanity filter is active via Sqids default blocklist

**Security note:** Sqids provides obfuscation, not encryption. A determined attacker with knowledge of the alphabet could enumerate IDs. This is an accepted tradeoff for a demo project — all shortened URLs are considered public. For production use, a secret shuffled alphabet stored in Rails credentials would prevent casual enumeration.

## Database Schema

```
urls
├── id              (bigint, PK)
├── target_url      (string, NOT NULL)
├── title           (string, nullable)
├── clicks_count    (integer, NOT NULL, default 0)
├── created_at      (timestamp)
└── updated_at      (timestamp)

visits
├── id              (bigint, PK)
├── url_id          (bigint, FK → urls.id, INDEX)
├── ip_address      (string)
├── country         (string)
├── city            (string)
├── visited_at      (timestamp)
├── created_at      (timestamp)
└── updated_at      (timestamp)
```
