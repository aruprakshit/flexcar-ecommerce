# E-commerce Application

A modern Rails e-commerce application with Docker containerization, featuring product management, shopping cart functionality, and advanced promotion system.

## 🚀 Quick Start

### Prerequisites
- Docker and Docker Compose
- Git

### Setup

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd ecommerce
   ```

2. **Load development aliases**
   ```bash
   source script/aliases.sh
   ```

3. **Start the development environment**
   ```bash
   dl-up
   ```

> **⚠️ Important**: All Docker commands and aliases must be run from the `ecommerce` directory (where `docker-compose.yml` is located).

4. **Access the application**
   - Web application: http://localhost:3000
   - Database: PostgreSQL on port 5432

## 🛠 Development

> **📁 Working Directory**: Make sure you're in the `ecommerce` directory before running any commands.

### Available Aliases

After sourcing `script/aliases.sh`, you'll have access to these convenient commands:

#### Development Commands
- `dl-up` - Start all services (web + database)
- `dl-down` - Stop all services
- `dl-logs-web` - View web application logs
- `dl-exec` - Execute commands in the web container
- `dl-bexec` - Execute bundle commands in the web container

#### Testing Commands
- `dl-bexec-t -a` - Run all tests
- `dl-bexec-t rspec spec/models/` - Run specific tests
- `dl-test` - Access test container shell
- `dl-test-specific` - Run tests with custom RSPEC_ARGS

### Development Workflow

1. **Start development environment**
   ```bash
   dl-up
   ```

2. **Run database migrations**
   ```bash
   dl-bexec rails db:migrate
   ```

3. **Seed the database**
   ```bash
   dl-bexec rails db:seed
   ```

4. **Access Rails console**
   ```bash
   dl-exec rails console
   ```

5. **View logs**
   ```bash
   dl-logs-web
   ```

## 🧪 Testing

> **📁 Working Directory**: Ensure you're in the `ecommerce` directory before running tests.

### Running Tests

#### All Tests
```bash
dl-bexec-t -a
```

#### Specific Test Files
```bash
dl-bexec-t rspec spec/models/item_spec.rb
dl-bexec-t rspec spec/services/promotion_service_spec.rb
```

#### Test Categories
```bash
# Model tests
dl-bexec-t rspec spec/models/

# Service tests  
dl-bexec-t rspec spec/services/

# Helper tests
dl-bexec-t rspec spec/helpers/

# Controller tests
dl-bexec-t rspec spec/controllers/
```

#### Test with Documentation Format
```bash
dl-bexec-t rspec spec/models/ --format documentation
```

#### Custom Test Arguments
```bash
dl-test-specific RSPEC_ARGS="spec/models/ --format documentation"
```

### Test Database Setup

The test environment automatically:
- Prepares the test database
- Runs DatabaseCleaner for test isolation
- Uses separate test database (ecommerce_test)

## 🏗 Architecture

### Models
- **Item**: Products with price, sale_type (by_weight/by_quantity)
- **Brand**: Product brands
- **Category**: Product categories  
- **Cart**: Shopping cart with session management
- **CartItem**: Individual cart items with quantity and final price
- **Promotion**: Advanced promotion system with multiple discount types

### Services
- **CartService**: Manages cart operations (add/remove/update items)
- **PromotionService**: Calculates best promotions and discounts
- **ItemFilterService**: Handles product filtering and sorting

### Promotion Types
- **Flat Fee**: Fixed amount discount
- **Percentage**: Percentage-based discount
- **BOGO**: Buy X get Y free promotions
- **Weight Threshold**: Discounts based on weight thresholds

## 🐳 Docker Services

### Development Services
- **web**: Rails application (port 3000)
- **db**: PostgreSQL database (port 5432)

### Test Services
- **test**: Test runner with isolated environment

### Volumes
- `postgres_data`: Persistent database storage
- `bundle_cache`: Ruby gem cache for faster builds

## 📁 Project Structure

```
ecommerce/
├── app/
│   ├── controllers/     # Rails controllers
│   ├── models/         # ActiveRecord models
│   ├── services/       # Business logic services
│   └── helpers/        # View helpers
├── spec/
│   ├── models/         # Model tests
│   ├── services/       # Service tests
│   ├── helpers/        # Helper tests
│   └── controllers/    # Controller tests
├── script/
│   └── aliases.sh      # Development aliases
├── docker-compose.yml  # Docker services configuration
└── Dockerfile.dev     # Development container
```

## 🔧 Configuration

### Environment Variables
- `RAILS_ENV`: Application environment
- `DATABASE_DEV_URL`: Development database connection
- `DATABASE_TEST_URL`: Test database connection
- `UID`/`GID`: User/group IDs for container permissions

### Database Configuration
- **Development**: `ecommerce_development`
- **Test**: `ecommerce_test`
- **Credentials**: postgres/password

## 🚨 Troubleshooting

> **📁 Working Directory**: All troubleshooting commands must be run from the `ecommerce` directory.

### Common Issues

1. **Permission errors**
   ```bash
   # Set proper user/group IDs
   export UID=$(id -u)
   export GID=$(id -g)
   dl-up
   ```

2. **Database connection issues**
   ```bash
   # Restart database
   dl-down
   dl-up
   ```

3. **Test failures**
   ```bash
   # Reset test database
   dl-bexec-t rails db:test:prepare
   dl-bexec-t -a
   ```

4. **Container issues**
   ```bash
   # Clean rebuild (run from ecommerce directory)
   dl-down
   docker compose build --no-cache
   dl-up
   ```

5. **Commands not working**
   ```bash
   # Make sure you're in the correct directory
   pwd  # Should show: /path/to/ecommerce
   ls docker-compose.yml  # Should show the file
   ```

### Logs and Debugging
```bash
# View all logs
docker compose logs

# View specific service logs
dl-logs-web

# Access container shell
dl-exec bash
```