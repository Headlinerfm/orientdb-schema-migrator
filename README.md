# OrientdbSchemaMigrator

Migrate Orientdb schema.

Uses a `schema_versions` class to keep track of migrations.

## Installation

Add this line to your application's Gemfile:

    gem 'orientdb-schema-migrator'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install orientdb-schema-migrator

## Usage

### Create Migration

`rake odb:generate_migration migration_name=CreateFoos`

### Migrate

`rake odb:migrate`

### Rollback

Rollback (one migration at a time).

`rake odb:rollback`

## Testing

1. Install OrientDb and run it locally.
2. Create a database named `schema_test` with an admin user named `test`, password `test` (or provide your own credentials via environment variables).
You can test that this is correctly setup with `rake db:test_connection`.
3. `ODB_TEST=true bundle exec rake db:add_schema_class`
4. `bundle exec rake spec`

## Contributing

1. Fork it ( https://github.com/Headlinerfm/orientdb-schema-migrator/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
