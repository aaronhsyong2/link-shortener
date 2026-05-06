# Link Shortener

A URL shortening service built with Ruby on Rails. Shorten long URLs, track clicks with geolocation, and view usage reports.

**Deployed application:** https://link-shortener-kdxz.onrender.com

**Wiki:** [Design decisions, security, scalability, and short URL strategy](https://github.com/aaronhsyong2/link-shortener/wiki)

## Features

- Shorten any URL and get a short, shareable link
- Deterministic slug generation via [Sqids](https://sqids.org) — no collisions, no stored codes
- Built-in profanity filtering (Sqids default blocklist)
- Automatic page title extraction from target URLs (async via background jobs)
- Click tracking with geolocation (country, city), browser, OS, device type, and referer
- Bot detection on visits via user agent parsing
- Real-time updates via ActionCable (Turbo Streams) — live click counts, geo resolution, title fetching
- Analytics dashboard with Chartkick charts — daily trends, hourly distribution, browser/OS/device breakdowns, traffic sources
- Session-based recent URLs on the homepage (last 10 shortened)
- Dark mode toggle with localStorage persistence and OS preference detection
- Geolocation caching by /24 subnet (1-day TTL) to reduce API calls
- URL validation hardening — rejects embedded credentials, private/loopback IPs, and self-referential URLs
- Custom error pages (404 dynamic, 422/500 static with dark mode)
- Rate limiting to prevent abuse
- Copy-to-clipboard for short URLs

## Tech Stack

- **Backend:** Ruby 3.3.0, Rails 7.2.3
- **Database:** PostgreSQL 16
- **Frontend:** Tailwind CSS 4.2, Hotwire (Turbo + Stimulus)
- **Slug Generation:** [Sqids](https://sqids.org) (deterministic, ID-based encoding)
- **Charts:** Chartkick + Chart.js
- **Real-time:** ActionCable (Turbo Streams)
- **User Agent Parsing:** Browser gem
- **Pagination:** Kaminari
- **Decorators:** Draper
- **Testing:** RSpec, FactoryBot, WebMock, SimpleCov (96% line coverage, 189 examples)
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
| `SHORTENER_HOSTS` | *(optional)* | Comma-separated hostnames to reject as self-referential targets |
| `SECRET_KEY_BASE` | *(required in production)* | Rails encryption key |
| `DATABASE_URL` | *(production)* | Overrides all individual DB variables |

## Running Tests

```bash
bundle exec rspec                        # Run all specs (189 examples)
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
│   ├── urls_controller.rb         # URL shortening + session-based recent URLs
│   ├── redirects_controller.rb    # Short URL redirect + enriched visit tracking
│   ├── reports_controller.rb      # Tabbed analytics dashboard
│   └── errors_controller.rb       # Custom 404 error page
├── models/
│   ├── url.rb                     # Sqids slug, validations, Turbo broadcasts
│   └── visit.rb                   # Click record with UA/geo/referer, broadcasts
├── services/
│   ├── url_shortener_service.rb   # URL creation (single insert, no collision retry)
│   ├── url_metadata_service.rb    # HTTP title extraction with redirect following
│   └── geolocation_service.rb     # IP-to-location with /24 subnet caching
├── jobs/
│   ├── fetch_title_job.rb         # Async page title fetching
│   └── resolve_geo_job.rb         # Async geolocation resolution
├── queries/
│   └── url_analytics_query.rb     # Analytics aggregations (daily, hourly, device, referer)
├── decorators/
│   ├── url_decorator.rb           # Display title with fetch state
│   └── visit_decorator.rb         # Masked IP, formatted location, browser/OS display
├── helpers/
│   ├── urls_helper.rb             # URL sanitization for XSS prevention
│   └── charts_helper.rb           # Dark-mode-aware Chartkick color configs
├── views/
│   ├── urls/                      # Shortening form, details, recent URLs partial
│   ├── reports/                   # Tabbed analytics (overview, devices, sources, recent)
│   └── errors/                    # Custom 404 page
└── javascript/controllers/
    ├── clipboard_controller.js    # Copy short URL to clipboard
    ├── dark_mode_controller.js    # Theme toggle with localStorage persistence
    ├── tabs_controller.js         # Tab navigation for analytics
    └── local_time_controller.js   # UTC-to-local time conversion
```

## Short URL Strategy

Slugs are generated deterministically from the database record ID using [Sqids](https://sqids.org):

- `Url#slug` encodes the record's `id` → minimum 4 alphanumeric characters
- `Url.from_slug(slug)` decodes the slug back to an ID and finds the record
- No `short_code` column needed — slugs are computed at runtime
- No collision retry — each ID maps to exactly one slug
- Profanity filter is active via Sqids default blocklist

**Security note:** Sqids provides obfuscation, not encryption. A determined attacker with knowledge of the alphabet could enumerate IDs. This is an accepted tradeoff for a demo project — all shortened URLs are considered public. For production use, a secret shuffled alphabet stored in Rails credentials would prevent casual enumeration.

## Background Jobs

Asynchronous work (e.g. page title fetching) is handled by Active Job with environment-specific adapters:

| Environment | Adapter | How it runs |
|-------------|---------|-------------|
| Development | `:async` | In-process threads inside the web server — no separate worker needed |
| Production | `:solid_queue` | Database-backed queue with forked worker processes (`bin/jobs`) |

This is a one-line config swap (`config.active_job.queue_adapter`). All job code (`FetchTitleJob`, etc.) is adapter-agnostic — Active Job's interface abstracts the backend. Switching between adapters requires zero code changes.

**Why not Solid Queue in development?** Solid Queue's default fork mode crashes on macOS due to `fork()`-after-threads being unsafe on Darwin. The `:async` adapter avoids this while providing identical job execution semantics. Production runs on Linux (Docker/Render) where forking works correctly.

## Database Schema

```
urls
├── id               (bigint, PK)
├── target_url       (string, NOT NULL)
├── title            (string, nullable)
├── clicks_count     (integer, NOT NULL, default 0)
├── title_fetched_at (timestamp, nullable)
├── created_at       (timestamp)
└── updated_at       (timestamp)

visits
├── id               (bigint, PK)
├── url_id           (bigint, FK → urls.id, INDEX)
├── ip_address       (string)
├── country          (string)
├── city             (string)
├── visited_at       (timestamp)
├── user_agent       (string, 512 chars)
├── referer          (string, 2048 chars)
├── referer_domain   (string, 256 chars, INDEX)
├── browser          (string, 128 chars, INDEX)
├── os               (string, 128 chars, INDEX)
├── device_type      (string, 32 chars, INDEX)
├── is_bot           (boolean, default false, INDEX)
├── created_at       (timestamp)
└── updated_at       (timestamp)
```
