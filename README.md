# ZtmWarszawa

This is a simple gem making querying the UM Warszawa's ZTM API easy. No-one has to reinvent the wheel anymore :)

Using this gem, you can easily:

- find out, which bus lines depart from a given bus stop
- get the hours of departure of a given bus line from a specified bus stop
- get the closest bus departures for a given bus stop
- check for traffic alerts (buses/trams suspended due to traffic accidents etc.)

It also seems to work with other types of stops that are under ZTM's administration (e.g. railway stations, tram stations...)

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'ztm_warszawa'
```
or just require it with 

```ruby
require 'ztm_warszawa'
```

Then execute:

    $ bundle

Or install it yourself as:

    $ gem install ztm_warszawa

## Dependencies

This gem depends on the `httparty` gem for making HTTP requests and the `addressable` gem for transcribing any Polish characters.

## Usage

First, create the the appropriate object:

`ztm_api = ZtmWarszawa.new`

Most of the methods require setting an API key. You can set the API key by calling `ztm_api.api_key = (new api key)`. The API key has to be a string. If you try to use a function which requires the API key without specifying it, an NoApiKey exception will be raised.

You can get an API key by registering [here](https://api.um.warszawa.pl/index.php?wcag=true&opc=8.8,2,0,0,).

Now, you can use the following methods:

##### Methods which require setting the API key:

- `get_stop_id(bus_stop_name)`

Queries the ZTM API to get the bus stop's ID from its name. The ID is required for all the latter operations. Raises an "BusStopNotFound" exception if the bus stop hasn't been found.

- `get_bus_lines(bus_stop_id, bus_stop_no)`
 
Returns an array of bus lines (e.g. 527, 141...) that depart from a given bus stop. Raises an "NoDepartures" exception when the server's response is empty (which could mean no buses depart from this stop).

- `get_line_departure_hours(bus_stop_id, bus_stop_no, bus_line)` 
 
Returns the server response with all the hours of departure of a given bus line from a given bus stop. Night bus lines (e.g. N37, N85...) are not supported due to some server-side errors (and an "NightLineError" exception is raised)

`get_closest_departures(server_response, script_starting_time, bus_line, number_of_departures)`

Given the server's response from `get_line_departure_hours()`, finds a given number of closest departures. The result is an array of hashes with "bus_line" and "time" entries.

##### Methods which don't require setting the API key:

- `check_alerts()`

Checks the ZTM website's RSS feed for any traffic alerts (buses/trams suspended due to traffic accidents etc.); returns an array of hashes with "title", "description" and "link" keys.

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
