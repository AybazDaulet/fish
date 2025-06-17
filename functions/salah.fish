function salah
    # Usage: salah <city> <state> <country>
    # Example: salah new+york new+york usa
    # Accept location
    set city $argv[1]
    set state $argv[2]
    set country $argv[3]
    set date (date "+%d-%m-%Y")
    
    # Build URL with variables
    set response (curl -s "https://api.aladhan.com/v1/timingsByCity/$date?city=$city&country=$country&state=$state")
    
    if test -z "$response"
        echo "No response from API."
        return 1
    end
    
    echo "Prayer times for $city, $state, $country on $date:"
    echo "$response" | jq -r '.data.timings | to_entries[] | "\(.key): \(.value)"'
end
