# Httrb: A Lightweight Ruby Web Framework

**Httrb** is a lightweight and minimalist web framework for Ruby inspired by Sinatra. It's designed to be simple, flexible, and powerful, allowing developers to quickly create web applications and APIs with minimal setup.

> **Note:** Httrb is a work in progress and not yet available for download or installation through Rubygems.

---

## Table of Contents

1. [Features](#features)
2. [Installation](#installation)
3. [Getting Started](#getting-started)
4. [Defining Routes](#defining-routes)
5. [Middleware](#middleware)
    - [Before Hooks](#before-hooks)
    - [After Hooks](#after-hooks)
6. [Response Helpers](#response-helpers)
7. [Example Applications](#example-applications)
8. [Testing and Development](#testing-and-development)
9. [Folder Structure](#folder-structure)
10. [Roadmap](#roadmap)
11. [License](#license)

---

## Features

- Simple and intuitive DSL for defining routes
- Support for HTTP methods like `GET`, `POST`, `PUT`, `DELETE`, and `ANY`
- Middleware hooks (`before` and `after`) for request/response customization
- JSON and file-based responses out of the box
- Built-in route parameters and query string parsing
- Easy-to-read codebase for learning and customization

---

## Installation

Since Httrb is under development, you will need to clone the repository and use it locally.

```bash
git clone https://github.com/ntijoh-martin-terner/httrb.git
cd httrb
```

Make sure to add the `httrb/lib` folder to your Ruby load path when working on your application.

---

## Getting Started

Here’s how to create a simple web server using **Httrb**:

```ruby
# app.rb
require_relative 'lib/httrb'

Httrb.get('/') do
  Httrb::Response.json({ message: 'Welcome to Httrb!' })
end

Httrb.start_blocking
```

Run the application:

```bash
ruby app.rb
```

By default, the server will run at `http://localhost:8080`.

---

## Defining Routes

Httrb supports a simple DSL for defining routes. Below are some examples:

### GET Requests

```ruby
Httrb.get('/hello') do
  Httrb::Response.json({ greeting: 'Hello, world!' })
end
```

### Route Parameters

```ruby
Httrb.get('/user/:id') do |id|
  Httrb::Response.json({ user_id: id })
end
```

### Query Strings

Access query parameters via the `params` method:

```ruby
Httrb.get('/search') do
  Httrb::Response.json({ query: params['q'] })
end
```

### Any HTTP Method

Use `Httrb.any` to define routes that respond to any HTTP method:

```ruby
Httrb.any('/webhook') do
  Httrb::Response.json({ message: 'Webhook received!' })
end
```

---

## Middleware

Httrb provides hooks for executing code **before** or **after** handling a request.

### Before Hooks

Use `Httrb.before_route` to run code before any route is processed:

```ruby
Httrb.before_route do
  @global_variable = 'Shared Data'
end
```

### After Hooks

Use `Httrb.after` to modify the response or perform cleanup tasks:

```ruby
Httrb.after do
  if response.status == 404
    next Httrb::Response.json({ error: 'Not Found' })
  end
end
```

---

## Response Helpers

Httrb provides several helpers for crafting responses.

### JSON Responses

```ruby
Httrb::Response.json({ key: 'value' })
```

### Static Files

Serve files using `Response.from_file`:

```ruby
Httrb.any('/download') do
  Httrb::Response.from_file('/path/to/file')
end
```

---

## Example Applications

### Simple JSON API

```ruby
Httrb.get('/api/user/:id') do |id|
  Httrb::Response.json({ user_id: id, name: 'John Doe' })
end

Httrb.start_blocking
```

### Custom 404 Page

```ruby
Httrb.after do
  if response.status == 404
    next Httrb::Response.from_file('./404.html')
  end
end
```

---

## Testing and Development

Httrb includes a suite of tests to ensure its functionality. You can run tests using Rake:

```bash
rake test
```

To generate documentation:

```bash
rake doc
```

To analyze the codebase with RubyCritic:

```bash
rake rubycritic
```

---

## Folder Structure

A typical Httrb project might look like this:

```
📁 httrb/
├── 📁 examples/          # Example apps using Httrb
├── 📁 lib/               # Core framework files
│   ├── httrb.rb          # Entry point for the framework
│   ├── request.rb        # HTTP request handling
│   ├── response.rb       # HTTP response handling
│   ├── router.rb         # Route matching and dispatching
│   └── http_server.rb    # Core HTTP server implementation
├── 📁 spec/              # Unit tests and examples
├── Rakefile             # Tasks for testing, benchmarking, and analysis
└── README.md            # Documentation
```

---

## Roadmap

- Add support for more HTTP methods
- Provide built-in templating options
- Add a gemspec for easy installation
- Improve error handling and middleware options

---

## License

Httrb is open-source software licensed under the [WTFPL](LICENSE) License. Contributions are welcome!