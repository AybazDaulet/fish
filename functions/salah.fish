function encode_for_url
    set input $argv[1]
    set trimmed (string trim -- $input)
    if string match -rq '\w+\s+\w+' -- $trimmed
        set url_encoded (string replace -r '\s' '+' -- $trimmed)
    end
    echo $url_encoded
end

function salah
    # Make sure gum and jq are installed
    if not type -q gum
        echo "Please install 'gum' first: https://github.com/charmbracelet/gum"
        return 1
    end
    if not type -q jq
        echo "Please install 'jq' first"
        return 1
    end

    set mode (gum choose "Daily prayer times" "Monthly prayer times" )

    # Get location
    set city (gum input --placeholder "City (e.g. New York)")
    set encoded_city (encode_for_url $city)

    set state (gum input --placeholder "State (e.g. New York)")
    set encoded_state (encode_for_url $state)

    set country (gum input --placeholder "Country (e.g. USA)")
    set encoded_country (encode_for_url $country)

    switch $mode
        case "Daily prayer times"
            set date (gum input --placeholder "Date (dd-mm-yyyy), leave blank for today")
            if test -z "$date"
                set date (date "+%d-%m-%Y")
            end

            set response (curl -s "https://api.aladhan.com/v1/timingsByCity/$date?city=$encoded_city&country=$encoded_country&state=$encoded_state")
            echo
            echo "📍 Prayer times for $city, $state, $country on $date:"
            echo "$response" | jq -r '.data.timings | to_entries[] | "\(.key): \(.value)"'

        case "Monthly prayer times"
            set month (gum input --placeholder "Month number (1-12)")
            set year (gum input --placeholder "Year (e.g. 2025)")
            set response (curl -s "https://api.aladhan.com/v1/calendarByCity/$year/$month?city=$encoded_city&country=$encoded_country&state=$encoded_state")

            echo
            echo "📅 Monthly prayer tiems for $city, $state in $month/$year"
            echo "$response" | jq -r '.data[] | .date.readable + ":\n" + (.timings | to_entries | map("\(.key): \(.value)") | join("\n")) + "\n"'
    end
end
