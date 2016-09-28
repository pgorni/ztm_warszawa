# ZtmWarszawa

This is a simple gem making querying the UM Warszawa's ZTM API easy. No-one has to reinvent the wheel anymore :)

Using this gem, you can easily:

- find out, which bus lines depart from a given bus stop
- get the hours of departure of a given bus line from a specified bus stop
- get the closest bus departures for a given bus stop

It also seems to work with other types of stops that are under ZTM's administration (e.g. railway stations, tram stations...)

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'ztm_warszawa'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install ztm_warszawa

## Dependencies

This gem depends on the `httparty` gem for making HTTP requests and the `addressable` gem for transcribing any Polish characters.

## Usage

First, create the the appropriate object:

`ztm_api = ZtmWarszawa.new(api_key)`

The API key has to be a string. It can be changed later on by calling `ztm_api.api_key = (new api key)`.

You can get an API key by registering [here](https://api.um.warszawa.pl/index.php?wcag=true&opc=8.8,2,0,0,).

Now, you can use the following methods:

- `get_stop_id(bus_stop_name)`: Queries the ZTM API to get the bus stop's ID from its name. The ID is required for all the latter operations.

- `get_bus_lines(bus_stop_id, bus_stop_no)`: Returns an array of bus lines (e.g. 527, 141...) that depart from a given bus stop.

- `get_line_departure_hours(bus_stop_id, bus_stop_no, bus_line)`: Returns the server response with all the hours of departure of a given bus line from a given bus stop. Night bus lines (e.g. N37, N85...) are not supported due to some server-side errors.

- `get_closest_departures(server_response, script_starting_time, bus_line, number_of_departures)`: Given the server's response from `get_line_departure_hours()`, finds a given number of closest departures. The result is an array of hashes with "bus_line" and "time" entries.

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
